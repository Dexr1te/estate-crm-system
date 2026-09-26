package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealCommentRequest;
import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.dto.response.DealCommentPage;
import com.crm.realestate.dto.response.DealCommentResponse;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.DealCommentMention;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.DealCommentMentionRepository;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * The discussion on a deal: comments, oldest first, with @mentions.
 *
 * <p>Whoever may see the deal may read and join its discussion — comments are reached only through
 * the deal, so they inherit its walls, and another agency's deal answers not found here exactly as
 * it does everywhere else. Correcting a comment is for the person who wrote it; taking one down is
 * for them or for someone who runs the team.
 *
 * <p>A mention must point at somebody who could open the deal: an active member of its agency whose
 * data scope reaches it. Mentioning an agent who only sees their own deals is refused rather than
 * quietly accepted — they would get a notification that opens onto "not found", and the author
 * would believe a colleague had been brought in when nobody had.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DealCommentService {

    static final int MAX_BODY_LENGTH = 4000;
    static final int DEFAULT_PAGE = 50;
    static final int MAX_PAGE = 100;

    private final DealCommentRepository        commentRepository;
    private final DealCommentMentionRepository mentionRepository;
    private final DealService                  dealService;
    private final UserRepository               userRepository;
    private final SecurityUtils                securityUtils;
    private final ScopeService                 scopeService;
    private final NotificationEvents           notificationEvents;

    /**
     * The latest {@code limit} comments — older than {@code beforeId} when given — oldest first, and
     * whether there is anything earlier still.
     */
    public DealCommentPage list(Long dealId, Long beforeId, Integer limit) {
        Deal deal = dealService.requireVisible(dealId, securityUtils.getCurrentUser());
        int size = limit == null || limit < 1 ? DEFAULT_PAGE : Math.min(limit, MAX_PAGE);
        List<DealComment> page = new ArrayList<>(
                commentRepository.findLatest(deal.getId(), beforeId, PageRequest.of(0, size + 1)));
        boolean hasEarlier = page.size() > size;
        if (hasEarlier) {
            page = page.subList(0, size);
        }
        Collections.reverse(page);
        Map<Long, List<DealCommentResponse.MentionRef>> mentions = mentionsOf(page);
        return new DealCommentPage(page.stream()
                .map(c -> toResponse(c, mentions.getOrDefault(c.getId(), List.of())))
                .toList(), hasEarlier);
    }

    /** Everybody who could be @mentioned on this deal, by name. */
    public List<AgentOptionResponse> mentionable(Long dealId) {
        Deal deal = dealService.requireVisible(dealId, securityUtils.getCurrentUser());
        if (deal.getTeam() == null) {
            return List.of();
        }
        return userRepository.findByTeamIdAndIsActiveTrueOrderByFullNameAsc(deal.getTeam().getId())
                .stream()
                .filter(u -> canBeMentioned(u, deal))
                .map(u -> AgentOptionResponse.builder().id(u.getId()).fullName(u.getFullName()).build())
                .toList();
    }

    @Transactional
    public DealCommentResponse create(Long dealId, DealCommentRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, currentUser);
        String body = validBody(request.getBody());
        List<User> mentioned = mentionsFor(deal, request.getMentionedUserIds());

        DealComment comment = commentRepository.save(DealComment.builder()
                .deal(deal)
                .team(deal.getTeam())
                .author(currentUser)
                .authorName(currentUser.getFullName())
                .body(body)
                .build());
        List<DealCommentResponse.MentionRef> refs = link(comment, mentioned);
        notificationEvents.dealCommented(deal, comment, mentioned, currentUser);
        return toResponse(comment, refs);
    }

    /**
     * Corrects the text. Only the author may: a manager can take a comment down, but putting words
     * in a colleague's mouth is not theirs to do. A null {@code mentionedUserIds} leaves the mentions
     * alone; a list, even an empty one, replaces them, and anyone newly mentioned hears about it.
     */
    @Transactional
    public DealCommentResponse update(Long dealId, Long commentId, DealCommentRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, currentUser);
        DealComment comment = requireOnDeal(deal, commentId);
        if (!isAuthor(comment, currentUser)) {
            throw new AccessDeniedException("Only the author can edit a comment");
        }
        String body = validBody(request.getBody());
        List<User> mentioned = request.getMentionedUserIds() == null
                ? null : mentionsFor(deal, request.getMentionedUserIds());

        if (!body.equals(comment.getBody())) {
            comment.setBody(body);
            comment.setEditedAt(LocalDateTime.now());
        }
        if (mentioned == null) {
            return toResponse(comment, mentionsOf(List.of(comment)).getOrDefault(comment.getId(), List.of()));
        }
        Set<Long> before = mentionsOf(List.of(comment)).getOrDefault(comment.getId(), List.of()).stream()
                .map(DealCommentResponse.MentionRef::getId).collect(Collectors.toSet());
        mentionRepository.deleteByComment(comment.getId());
        comment = commentRepository.findById(commentId).orElseThrow();
        List<DealCommentResponse.MentionRef> refs = link(comment, mentioned);
        notificationEvents.mentionsAdded(deal, comment,
                mentioned.stream().filter(u -> !before.contains(u.getId())).toList(), currentUser);
        return toResponse(comment, refs);
    }

    @Transactional
    public void delete(Long dealId, Long commentId) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, currentUser);
        DealComment comment = requireOnDeal(deal, commentId);
        if (!isAuthor(comment, currentUser)
                && !scopeService.isManager(currentUser) && !scopeService.isAdmin(currentUser)) {
            throw new AccessDeniedException("Only the author or a manager can delete a comment");
        }
        commentRepository.delete(comment);
    }

    // Rules -----------------------------------------------------------------------------

    private static String validBody(String raw) {
        String body = raw == null ? "" : raw.strip();
        if (body.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "COMMENT_BODY_REQUIRED",
                    "A comment needs some text");
        }
        if (body.length() > MAX_BODY_LENGTH) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "COMMENT_TOO_LONG",
                    "A comment takes at most " + MAX_BODY_LENGTH + " characters");
        }
        return body;
    }

    /**
     * The people a comment may mention: each one active, in the deal's agency and able to see the
     * deal. Anyone else is refused with 400 — including another agency's user, whose existence the
     * refusal does not confirm, since an unknown id reads the same.
     */
    private List<User> mentionsFor(Deal deal, List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        Set<Long> wanted = new LinkedHashSet<>(ids);
        if (wanted.contains(null)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MENTION_ID_REQUIRED",
                    "A mentioned person's id is missing");
        }
        Map<Long, User> found = userRepository.findAllById(wanted).stream()
                .collect(Collectors.toMap(User::getId, Function.identity()));
        return wanted.stream().map(id -> {
            User person = found.get(id);
            if (person == null || !canBeMentioned(person, deal)) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "MENTION_NOT_ALLOWED",
                        "Only colleagues who can see this deal can be mentioned");
            }
            return person;
        }).toList();
    }

    private boolean canBeMentioned(User person, Deal deal) {
        boolean active = person.isActive() && person.getStatus() == UserStatus.ACTIVE;
        boolean sameAgency = deal.getTeam() != null
                && Objects.equals(scopeService.teamIdOf(person), deal.getTeam().getId());
        return active && sameAgency && scopeService.canSee(person, deal.getTeam(), deal.getAgent());
    }

    private DealComment requireOnDeal(Deal deal, Long commentId) {
        // Checked against the deal in the URL too, or any id would be reachable through a deal the
        // caller can see.
        return commentRepository.findById(commentId)
                .filter(c -> Objects.equals(c.getDeal().getId(), deal.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found with id: " + commentId));
    }

    private static boolean isAuthor(DealComment comment, User user) {
        return comment.getAuthor() != null && Objects.equals(comment.getAuthor().getId(), user.getId());
    }

    // Mapping ---------------------------------------------------------------------------

    private List<DealCommentResponse.MentionRef> link(DealComment comment, List<User> people) {
        mentionRepository.saveAll(people.stream().map(u -> DealCommentMention.of(comment, u)).toList());
        return people.stream()
                .map(u -> new DealCommentResponse.MentionRef(u.getId(), u.getFullName()))
                .toList();
    }

    /** Everybody mentioned in these comments, keyed by comment, in one query. */
    private Map<Long, List<DealCommentResponse.MentionRef>> mentionsOf(List<DealComment> comments) {
        if (comments.isEmpty()) {
            return Map.of();
        }
        List<Long> ids = comments.stream().map(DealComment::getId).toList();
        return mentionRepository.findForComments(ids).stream().collect(Collectors.groupingBy(
                m -> m.getId().getCommentId(),
                Collectors.mapping(m -> new DealCommentResponse.MentionRef(
                        m.getUser().getId(), m.getUser().getFullName()), Collectors.toList())));
    }

    static DealCommentResponse toResponse(DealComment comment, List<DealCommentResponse.MentionRef> mentions) {
        User author = comment.getAuthor();
        return DealCommentResponse.builder()
                .id(comment.getId())
                .dealId(comment.getDeal().getId())
                .body(comment.getBody())
                .authorId(author == null ? null : author.getId())
                .authorName(author == null ? comment.getAuthorName() : author.getFullName())
                .createdAt(comment.getCreatedAt())
                .editedAt(comment.getEditedAt())
                .mentions(mentions)
                .build();
    }
}
