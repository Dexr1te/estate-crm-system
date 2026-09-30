package com.crm.realestate.service;

import com.crm.realestate.dto.request.MessageTemplateRequest;
import com.crm.realestate.dto.response.MessageTemplateResponse;
import com.crm.realestate.entity.MessageTemplate;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.MessageTemplateRepository;
import com.crm.realestate.repository.TeamRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * An agency's message templates: what its agents send clients over WhatsApp or SMS, with
 * placeholders the app fills in for the client, the agent and a listing.
 *
 * <p>Everybody in the agency reads them; its manager (or an admin) writes them, one at a time.
 * Agencies get the {@link DefaultMessageTemplates} the first time anybody needs them: when the
 * manager creates the agency, and for agencies older than the feature, on first read. They are
 * written in the same language the default checklist is, for the same reasons.
 */
@Service
@RequiredArgsConstructor
public class MessageTemplateService {

    /** What the app knows how to fill. Anything else in braces is refused. */
    public static final Set<String> PLACEHOLDERS = Set.of("client", "agent", "listing", "price", "address", "link");

    /** Enough for every kind of message an agency sends, few enough for a picker. */
    public static final int MAX_TEMPLATES = 50;

    private static final Pattern PLACEHOLDER = Pattern.compile("\\{([^{}]*)}");

    private final MessageTemplateRepository templateRepository;
    private final TeamRepository teamRepository;
    private final AuditLogService auditLogService;

    @Transactional
    public List<MessageTemplateResponse> list(User reader, Long teamId) {
        Team team = teamOf(reader, teamId);
        seedIfNeeded(team, reader);
        return templateRepository.findByTeamIdOrderByIdAsc(team.getId()).stream()
                .map(MessageTemplateService::toResponse).toList();
    }

    @Transactional
    public MessageTemplateResponse create(User actor, Long teamId, MessageTemplateRequest request) {
        requireManager(actor);
        Team team = teamOf(actor, teamId);
        // Seed first, so a manager's first template does not leave the agency without the defaults.
        seedIfNeeded(team, actor);
        if (templateRepository.countByTeamId(team.getId()) >= MAX_TEMPLATES) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MESSAGE_TEMPLATE_LIMIT",
                    "An agency keeps at most " + MAX_TEMPLATES + " message templates");
        }
        MessageTemplate saved = templateRepository.save(MessageTemplate.builder()
                .team(team).title(title(request)).body(body(request)).build());
        auditLogService.record(actor, "CREATE_MESSAGE_TEMPLATE", "MessageTemplate", saved.getId(),
                "team=" + team.getId());
        return toResponse(saved);
    }

    @Transactional
    public MessageTemplateResponse update(User actor, Long teamId, Long id, MessageTemplateRequest request) {
        requireManager(actor);
        MessageTemplate template = find(actor, teamId, id);
        template.setTitle(title(request));
        template.setBody(body(request));
        MessageTemplate saved = templateRepository.saveAndFlush(template);
        auditLogService.record(actor, "UPDATE_MESSAGE_TEMPLATE", "MessageTemplate", saved.getId(),
                "team=" + saved.getTeam().getId());
        return toResponse(saved);
    }

    @Transactional
    public void delete(User actor, Long teamId, Long id) {
        requireManager(actor);
        MessageTemplate template = find(actor, teamId, id);
        Long team = template.getTeam().getId();
        templateRepository.delete(template);
        auditLogService.record(actor, "DELETE_MESSAGE_TEMPLATE", "MessageTemplate", id, "team=" + team);
    }

    /**
     * Writes the default templates unless the agency already has had them. {@code reader} decides
     * the language: an agency's own manager gets theirs, anybody else the fallback.
     */
    @Transactional
    public void seedIfNeeded(Team team, User reader) {
        if (team.isMessageTemplatesSeeded() || templateRepository.markSeeded(team.getId()) == 0) {
            return;
        }
        String language = ChecklistTemplateService.languageFor(team, reader);
        templateRepository.saveAll(DefaultMessageTemplates.TEMPLATES.stream()
                .map(t -> t.in(language))
                .map(text -> MessageTemplate.builder().team(team).title(text.title()).body(text.body()).build())
                .toList());
    }

    /** One of this agency's templates; another agency's reads as not found. */
    private MessageTemplate find(User actor, Long teamId, Long id) {
        Team team = teamOf(actor, teamId);
        return templateRepository.findByIdAndTeamId(id, team.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Message template not found with id: " + id));
    }

    private static void requireManager(User actor) {
        if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager can change message templates");
        }
    }

    private static String title(MessageTemplateRequest request) {
        String title = request.getTitle() == null ? "" : request.getTitle().strip();
        if (title.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MESSAGE_TEMPLATE_TITLE_REQUIRED",
                    "A template needs a title");
        }
        return title;
    }

    /** The text, trimmed, with every placeholder one the app can fill. */
    static String body(MessageTemplateRequest request) {
        String body = request.getBody() == null ? "" : request.getBody().strip();
        if (body.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MESSAGE_TEMPLATE_BODY_REQUIRED",
                    "A template needs some text");
        }
        Set<String> unknown = new TreeSet<>();
        Matcher matcher = PLACEHOLDER.matcher(body);
        while (matcher.find()) {
            String name = matcher.group(1).strip().toLowerCase(Locale.ROOT);
            if (!PLACEHOLDERS.contains(name)) {
                unknown.add("{" + matcher.group(1) + "}");
            }
        }
        if (!unknown.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "UNKNOWN_PLACEHOLDER",
                    "Unknown placeholder " + String.join(", ", unknown)
                            + "; use {client}, {agent}, {listing}, {price}, {address} or {link}");
        }
        return body;
    }

    /** The reader's own agency; an admin, who runs none, names one. */
    private Team teamOf(User user, Long teamId) {
        if (user.getRole() == Role.ADMIN && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's templates these are");
        }
        return user.getTeam();
    }

    static MessageTemplateResponse toResponse(MessageTemplate template) {
        return MessageTemplateResponse.builder()
                .id(template.getId())
                .title(template.getTitle())
                .body(template.getBody())
                .updatedAt(template.getUpdatedAt())
                .build();
    }
}
