package com.crm.realestate.service;

import com.crm.realestate.dto.request.ClientActivityRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * A client's history of contact: every call, message, email and note, newest first.
 *
 * <p>Whoever may read the client may read and add to its history — the entries are reached only
 * through the client, so they inherit its walls, and another agency's client answers not found here
 * exactly as it does everywhere else. Taking an entry back out is narrower: the person who wrote it,
 * or someone who runs the team.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientActivityService {

    static final int MAX_NOTE_LENGTH = 2000;

    /** A phone whose clock runs a little ahead should still be able to log a call "now". */
    private static final Duration CLOCK_SKEW = Duration.ofMinutes(5);

    private final ClientActivityRepository activityRepository;
    private final ClientService            clientService;
    private final SecurityUtils            securityUtils;
    private final ScopeService             scopeService;

    public List<ClientActivityResponse> list(Long clientId) {
        Client client = clientService.requireVisible(clientId, securityUtils.getCurrentUser());
        return activityRepository.findByClientNewestFirst(client.getId()).stream()
                .map(ClientActivityService::toResponse)
                .toList();
    }

    @Transactional
    public ClientActivityResponse create(Long clientId, ClientActivityRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, currentUser);

        if (request.getType() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "ACTIVITY_TYPE_REQUIRED",
                    "Say whether it was a call, a message, an email or a note");
        }
        String note = request.getNote() == null || request.getNote().isBlank()
                ? null : request.getNote().trim();
        if (request.getType() == ActivityType.NOTE && note == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NOTE_REQUIRED",
                    "A note needs some text");
        }
        if (note != null && note.length() > MAX_NOTE_LENGTH) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NOTE_TOO_LONG",
                    "Note must be at most " + MAX_NOTE_LENGTH + " characters");
        }
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime occurredAt = request.getOccurredAt() == null ? now : request.getOccurredAt();
        if (occurredAt.isAfter(now.plus(CLOCK_SKEW))) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "OCCURRED_IN_FUTURE",
                    "A contact cannot be logged before it has happened");
        }

        ClientActivity activity = activityRepository.save(ClientActivity.builder()
                .client(client)
                .team(client.getTeam())
                .author(currentUser)
                .authorName(currentUser.getFullName())
                .type(request.getType())
                .note(note)
                .occurredAt(occurredAt)
                .build());
        return toResponse(activity);
    }

    @Transactional
    public void delete(Long clientId, Long activityId) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, currentUser);
        // Checked against the client in the URL too, or any id would be reachable through a
        // client the caller can see.
        ClientActivity activity = activityRepository.findById(activityId)
                .filter(a -> Objects.equals(a.getClient().getId(), client.getId()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Activity not found with id: " + activityId));

        boolean isAuthor = activity.getAuthor() != null
                && Objects.equals(activity.getAuthor().getId(), currentUser.getId());
        if (!isAuthor && !scopeService.isManager(currentUser) && !scopeService.isAdmin(currentUser)) {
            throw new AccessDeniedException("Only the author or a manager can remove this entry");
        }
        activityRepository.delete(activity);
    }

    static ClientActivityResponse toResponse(ClientActivity activity) {
        User author = activity.getAuthor();
        return ClientActivityResponse.builder()
                .id(activity.getId())
                .clientId(activity.getClient().getId())
                .type(activity.getType())
                .note(activity.getNote())
                .occurredAt(activity.getOccurredAt())
                .authorId(author == null ? null : author.getId())
                .authorName(author == null ? activity.getAuthorName() : author.getFullName())
                .createdAt(activity.getCreatedAt())
                .build();
    }
}
