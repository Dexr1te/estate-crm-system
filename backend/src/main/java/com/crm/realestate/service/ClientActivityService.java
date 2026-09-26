package com.crm.realestate.service;

import com.crm.realestate.dto.request.ClientActivityRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.ClientActivityProperty;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityPropertyRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * A client's history of contact: every call, message, email and note, newest first.
 *
 * <p>Whoever may read the client may read and add to its history — the entries are reached only
 * through the client, so they inherit its walls, and another agency's client answers not found here
 * exactly as it does everywhere else. Correcting an entry or taking it back out is narrower: the
 * person who wrote it, or someone who runs the team.
 *
 * <p>An entry can name the listings it was about — the flats that went out in a message. Those follow
 * the same walls as reading them would: a listing the caller cannot see, or one from another agency
 * than the client's, answers not found.
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
    private final PropertyRepository       propertyRepository;
    private final ClientActivityPropertyRepository linkRepository;

    public List<ClientActivityResponse> list(Long clientId) {
        Client client = clientService.requireVisible(clientId, securityUtils.getCurrentUser());
        List<ClientActivity> history = activityRepository.findByClientNewestFirst(client.getId());
        Map<Long, List<ClientActivityResponse.PropertyRef>> sent = linksOf(history);
        return history.stream()
                .map(a -> toResponse(a, sent.getOrDefault(a.getId(), List.of())))
                .toList();
    }

    @Transactional
    public ClientActivityResponse create(Long clientId, ClientActivityRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, currentUser);
        String note = validNote(request);
        LocalDateTime occurredAt = validOccurredAt(request.getOccurredAt());
        List<Property> listings = listingsFor(client, request.getPropertyIds(), currentUser);

        ClientActivity activity = activityRepository.save(ClientActivity.builder()
                .client(client)
                .team(client.getTeam())
                .author(currentUser)
                .authorName(currentUser.getFullName())
                .type(request.getType())
                .note(note)
                .occurredAt(occurredAt)
                .build());
        return toResponse(activity, link(activity, listings));
    }

    /**
     * Corrects an entry — the wrong kind, a note to add, the time it really happened. The same
     * people who may take it back out may change it. A null {@code propertyIds} leaves the linked
     * listings alone; a list, even an empty one, replaces them.
     */
    @Transactional
    public ClientActivityResponse update(Long clientId, Long activityId, ClientActivityRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, currentUser);
        ClientActivity activity = requireEditable(client, activityId, currentUser);
        String note = validNote(request);
        LocalDateTime occurredAt = request.getOccurredAt() == null
                ? activity.getOccurredAt() : validOccurredAt(request.getOccurredAt());

        activity.setType(request.getType());
        activity.setNote(note);
        activity.setOccurredAt(occurredAt);

        if (request.getPropertyIds() != null) {
            List<Property> listings = listingsFor(client, request.getPropertyIds(), currentUser);
            linkRepository.deleteByActivity(activity.getId());
            activity = activityRepository.findById(activityId).orElseThrow();
            return toResponse(activity, link(activity, listings));
        }
        return toResponse(activity, linksOf(List.of(activity)).getOrDefault(activity.getId(), List.of()));
    }

    private String validNote(ClientActivityRequest request) {
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
        return note;
    }

    private static LocalDateTime validOccurredAt(LocalDateTime requested) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime occurredAt = requested == null ? now : requested;
        if (occurredAt.isAfter(now.plus(CLOCK_SKEW))) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "OCCURRED_IN_FUTURE",
                    "A contact cannot be logged before it has happened");
        }
        return occurredAt;
    }

    /**
     * The listings an entry may point at: each one the caller can see and in the client's own
     * agency. Anything else answers not found, as reading it would — the refusal does not confirm
     * another agency's listing exists.
     */
    private List<Property> listingsFor(Client client, List<Long> propertyIds, User currentUser) {
        if (propertyIds == null || propertyIds.isEmpty()) {
            return List.of();
        }
        Set<Long> wanted = new LinkedHashSet<>(propertyIds);
        if (wanted.contains(null)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "PROPERTY_ID_REQUIRED",
                    "A listing id is missing");
        }
        Map<Long, Property> found = propertyRepository.findAllById(wanted).stream()
                .collect(Collectors.toMap(Property::getId, Function.identity()));
        return wanted.stream().map(id -> {
            Property p = found.get(id);
            if (p == null || !scopeService.canSeeInTeam(currentUser, p.getTeam(), p.getAgent())) {
                throw new ResourceNotFoundException("Property not found with id: " + id);
            }
            scopeService.requireSameTeam(client.getTeam(), p.getTeam(), "Property");
            return p;
        }).toList();
    }

    private List<ClientActivityResponse.PropertyRef> link(ClientActivity activity, List<Property> listings) {
        linkRepository.saveAll(listings.stream().map(p -> ClientActivityProperty.of(activity, p)).toList());
        return listings.stream()
                .sorted(Comparator.comparing(Property::getId))
                .map(p -> new ClientActivityResponse.PropertyRef(p.getId(), p.getTitle()))
                .toList();
    }

    /** Every listing behind these entries, keyed by entry, in one query. */
    private Map<Long, List<ClientActivityResponse.PropertyRef>> linksOf(List<ClientActivity> history) {
        if (history.isEmpty()) {
            return Map.of();
        }
        List<Long> ids = history.stream().map(ClientActivity::getId).toList();
        return linkRepository.findForActivities(ids).stream().collect(Collectors.groupingBy(
                ap -> ap.getId().getActivityId(),
                Collectors.mapping(ap -> new ClientActivityResponse.PropertyRef(
                        ap.getProperty().getId(), ap.getProperty().getTitle()), Collectors.toList())));
    }

    @Transactional
    public void delete(Long clientId, Long activityId) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, currentUser);
        activityRepository.delete(requireEditable(client, activityId, currentUser));
    }

    /** The entry, if it is this client's and the caller wrote it or runs the team. */
    private ClientActivity requireEditable(Client client, Long activityId, User currentUser) {
        // Checked against the client in the URL too, or any id would be reachable through a
        // client the caller can see.
        ClientActivity activity = activityRepository.findById(activityId)
                .filter(a -> Objects.equals(a.getClient().getId(), client.getId()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Activity not found with id: " + activityId));

        boolean isAuthor = activity.getAuthor() != null
                && Objects.equals(activity.getAuthor().getId(), currentUser.getId());
        if (!isAuthor && !scopeService.isManager(currentUser) && !scopeService.isAdmin(currentUser)) {
            throw new AccessDeniedException("Only the author or a manager can change this entry");
        }
        return activity;
    }

    static ClientActivityResponse toResponse(ClientActivity activity,
                                             List<ClientActivityResponse.PropertyRef> properties) {
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
                .properties(properties)
                .build();
    }
}
