package com.crm.realestate.service;

import com.crm.realestate.dto.request.OpenHouseRequest;
import com.crm.realestate.dto.request.OpenHouseVisitorRequest;
import com.crm.realestate.dto.response.OpenHouseResponse;
import com.crm.realestate.dto.response.OpenHouseVisitorResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.ClientActivityProperty;
import com.crm.realestate.entity.OpenHouse;
import com.crm.realestate.entity.OpenHouseVisitor;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityPropertyRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.OpenHouseRepository;
import com.crm.realestate.repository.OpenHouseVisitorRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * Open houses on a listing, and the sign-in sheet that fills during one.
 *
 * <p><b>Who sees what.</b> An open house is the listing's, so it sits behind the listing's wall:
 * the whole agency sees a listing's open houses whatever their data scope, and another agency is
 * told it does not exist. The calendar is narrower, as it is for meetings: an agent on their own
 * records sees the open houses they hold, a colleague with the team's scope sees all of them.
 *
 * <p><b>Who changes what.</b> Anyone who can see an open house can sign visitors in, since a
 * colleague may be the one at the door. Moving or cancelling it is for its host, a manager or an
 * admin; taking a visitor back off the sheet is for them and for whoever signed that visitor in.
 *
 * <p><b>A visitor.</b> The phone is matched against the agency's clients exactly as the
 * duplicate check matches them ({@link ClientRepository#findDuplicates}). A number nobody knows
 * becomes a new buyer, held by the open house's host, with the source {@code OPEN_HOUSE}. A number
 * the agency knows is that client, whoever holds it, and the card is left as it is: what was typed
 * at the door does not rename anybody. Either way the client's history gets a line, linked to the
 * listing and marked as this open house, so the visit shows wherever the history does.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OpenHouseService {

    /** Longer than this is a mistake in the end time, not an open house. */
    static final Duration MAX_LENGTH = Duration.ofHours(12);

    /** How wide a window the calendar may ask for at once. */
    static final Duration MAX_RANGE = Duration.ofDays(366);

    private final OpenHouseRepository openHouseRepository;
    private final OpenHouseVisitorRepository visitorRepository;
    private final PropertyRepository propertyRepository;
    private final ClientRepository clientRepository;
    private final ClientActivityRepository activityRepository;
    private final ClientActivityPropertyRepository activityPropertyRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final ChangeLogService changeLog;

    // Reading -----------------------------------------------------------------------------

    /** A listing's open houses, the latest first, each with its summary. */
    public List<OpenHouseResponse> forProperty(Long propertyId) {
        User user = securityUtils.getCurrentUser();
        Property property = requireVisibleProperty(propertyId, user);
        return toResponses(openHouseRepository.findByPropertyNewestFirst(property.getId()), user);
    }

    /** Open houses overlapping {@code [from, to)} that the caller's data scope reaches, soonest first. */
    public List<OpenHouseResponse> inRange(LocalDateTime from, LocalDateTime to) {
        if (from == null || to == null || !to.isAfter(from)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RANGE_REQUIRED",
                    "Give a window: from, and a later to");
        }
        if (Duration.between(from, to).compareTo(MAX_RANGE) > 0) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RANGE_TOO_WIDE",
                    "Ask for at most a year at a time");
        }
        User user = securityUtils.getCurrentUser();
        Specification<OpenHouse> overlapping = (root, query, cb) -> cb.and(
                cb.lessThan(root.get("startsAt"), to),
                cb.greaterThan(root.get("endsAt"), from));
        List<OpenHouse> found = openHouseRepository.findAll(
                overlapping.and(scopeService.visibleTo(user)),
                Sort.by(Sort.Order.asc("startsAt"), Sort.Order.asc("id")));
        return toResponses(found, user);
    }

    /** One open house with its sign-in sheet. */
    public OpenHouseResponse get(Long id) {
        User user = securityUtils.getCurrentUser();
        OpenHouse openHouse = requireVisible(id, user);
        OpenHouseResponse response = toResponses(List.of(openHouse), user).get(0);
        response.setVisitors(visitorRepository.findSheet(openHouse.getId()).stream()
                .map(v -> toResponse(v, openHouse, user))
                .toList());
        return response;
    }

    // Scheduling --------------------------------------------------------------------------

    @Transactional
    public OpenHouseResponse create(Long propertyId, OpenHouseRequest request) {
        User user = securityUtils.getCurrentUser();
        Property property = requireVisibleProperty(propertyId, user);
        validTimes(request);
        OpenHouse saved = openHouseRepository.save(OpenHouse.builder()
                .property(property)
                .team(property.getTeam())
                .agent(user)
                .startsAt(request.getStartsAt())
                .endsAt(request.getEndsAt())
                .note(strip(request.getNote()))
                .build());
        return toResponses(List.of(saved), user).get(0);
    }

    @Transactional
    public OpenHouseResponse update(Long id, OpenHouseRequest request) {
        User user = securityUtils.getCurrentUser();
        OpenHouse openHouse = requireEditable(id, user);
        validTimes(request);
        openHouse.setStartsAt(request.getStartsAt());
        openHouse.setEndsAt(request.getEndsAt());
        openHouse.setNote(strip(request.getNote()));
        return toResponses(List.of(openHouseRepository.save(openHouse)), user).get(0);
    }

    /**
     * Cancels an open house nobody has signed in at yet. Once there are visitors it happened, and
     * their visits are in clients' histories; deleting it would leave those pointing at nothing.
     */
    @Transactional
    public void delete(Long id) {
        User user = securityUtils.getCurrentUser();
        OpenHouse openHouse = requireEditable(id, user);
        if (visitorRepository.countByOpenHouseId(openHouse.getId()) > 0) {
            throw new BusinessException(HttpStatus.CONFLICT, "OPEN_HOUSE_HAS_VISITORS",
                    "People have signed in at this open house, so it cannot be deleted");
        }
        openHouseRepository.delete(openHouse);
    }

    // The sign-in sheet -------------------------------------------------------------------

    @Transactional
    public OpenHouseVisitorResponse signIn(Long openHouseId, OpenHouseVisitorRequest request) {
        User user = securityUtils.getCurrentUser();
        OpenHouse openHouse = requireVisible(openHouseId, user);
        String name = strip(request.getFullName());
        String phone = strip(request.getPhone());
        if (name == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NAME_REQUIRED", "Name is required");
        }
        String normalized = ContactNormalizer.phone(phone);
        if (normalized == null || !phone.matches("[0-9+()\\-.\\s]+")) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PHONE",
                    "That does not look like a phone number");
        }
        if (visitorRepository.existsByOpenHouseIdAndPhoneNormalized(openHouse.getId(), normalized)) {
            throw new BusinessException(HttpStatus.CONFLICT, "ALREADY_SIGNED_IN",
                    "Someone with this number has already signed in");
        }

        Team team = openHouse.getTeam();
        Property property = openHouse.getProperty();
        User holder = isActiveIn(openHouse.getAgent(), team) ? openHouse.getAgent() : user;
        Optional<Client> existing = clientRepository.findDuplicates(
                team != null ? team.getId() : null,
                holder.getId(),
                normalized, null, null, PageRequest.of(0, 1)).stream().findFirst();
        Client client = existing.orElseGet(() -> {
            Client made = clientRepository.save(Client.builder()
                    .fullName(name)
                    .phone(phone)
                    .type(ClientType.BUYER)
                    .source(ClientSource.OPEN_HOUSE)
                    .agent(holder)
                    .team(team)
                    .build());
            changeLog.created(ChangeSnapshot.target(made), user);
            return made;
        });

        String note = strip(request.getNote());
        ClientActivity activity = activityRepository.save(ClientActivity.builder()
                .client(client)
                .team(client.getTeam())
                .author(user)
                .authorName(user.getFullName())
                .type(ActivityType.NOTE)
                .note(note)
                .occurredAt(visitTime(openHouse))
                .openHouse(openHouse)
                .build());
        activityPropertyRepository.save(ClientActivityProperty.of(activity, property));

        OpenHouseVisitor visitor = visitorRepository.save(OpenHouseVisitor.builder()
                .openHouse(openHouse)
                .team(team)
                .fullName(name)
                .phone(phone)
                .phoneNormalized(normalized)
                .interest(request.getInterest())
                .note(note)
                .client(client)
                .newClient(existing.isEmpty())
                .activity(activity)
                .signedInBy(user)
                .build());
        return toResponse(visitor, openHouse, user);
    }

    /**
     * Takes a visitor back off the sheet — signed in twice, or by mistake — and the line it put in
     * the client's history with it. A client the sign-in made stays: it is somebody in the agency's
     * book now, and deleting a client is a decision of its own.
     */
    @Transactional
    public void removeVisitor(Long openHouseId, Long visitorId) {
        User user = securityUtils.getCurrentUser();
        OpenHouse openHouse = requireVisible(openHouseId, user);
        OpenHouseVisitor visitor = visitorRepository.findById(visitorId)
                .filter(v -> Objects.equals(v.getOpenHouse().getId(), openHouse.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Visitor not found with id: " + visitorId));
        if (!canRemove(visitor, openHouse, user)) {
            throw new AccessDeniedException(
                    "Only whoever signed this visitor in, the host or a manager can remove them");
        }
        Long activityId = visitor.getActivity() == null ? null : visitor.getActivity().getId();
        visitorRepository.delete(visitor);
        if (activityId != null) {
            // The listing link first, which also clears the persistence context, so the entry is
            // removed as read afresh rather than as the sign-in left it in memory.
            activityPropertyRepository.deleteByActivity(activityId);
            activityRepository.findById(activityId).ifPresent(activityRepository::delete);
        }
    }

    // Rules -------------------------------------------------------------------------------

    private static void validTimes(OpenHouseRequest request) {
        LocalDateTime starts = request.getStartsAt();
        LocalDateTime ends = request.getEndsAt();
        if (starts == null || ends == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TIMES_REQUIRED",
                    "An open house needs a start and an end");
        }
        if (!ends.isAfter(starts)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "ENDS_BEFORE_START",
                    "An open house has to end after it starts");
        }
        if (Duration.between(starts, ends).compareTo(MAX_LENGTH) > 0) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "OPEN_HOUSE_TOO_LONG",
                    "An open house lasts at most " + MAX_LENGTH.toHours() + " hours");
        }
    }

    /**
     * When the visit goes into the history: now, while the open house runs or before it; its
     * start, when the sheet is being filled in afterwards from paper.
     */
    private static LocalDateTime visitTime(OpenHouse openHouse) {
        LocalDateTime now = LocalDateTime.now();
        return now.isAfter(openHouse.getEndsAt()) ? openHouse.getStartsAt() : now;
    }

    private Property requireVisibleProperty(Long propertyId, User user) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + propertyId));
        if (!scopeService.canSeeInTeam(user, property.getTeam(), property.getAgent())) {
            throw new ResourceNotFoundException("Property not found with id: " + propertyId);
        }
        return property;
    }

    /** The open house, if the caller can see its listing. */
    private OpenHouse requireVisible(Long id, User user) {
        OpenHouse openHouse = openHouseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Open house not found with id: " + id));
        if (!scopeService.canSeeInTeam(user, openHouse.getTeam(), openHouse.getProperty().getAgent())) {
            throw new ResourceNotFoundException("Open house not found with id: " + id);
        }
        return openHouse;
    }

    private OpenHouse requireEditable(Long id, User user) {
        OpenHouse openHouse = requireVisible(id, user);
        if (!canEdit(openHouse, user)) {
            throw new AccessDeniedException("Only the host or a manager can change this open house");
        }
        return openHouse;
    }

    private boolean canEdit(OpenHouse openHouse, User user) {
        return scopeService.isAdmin(user) || scopeService.isManager(user) || isUser(openHouse.getAgent(), user);
    }

    private boolean canRemove(OpenHouseVisitor visitor, OpenHouse openHouse, User user) {
        return canEdit(openHouse, user) || isUser(visitor.getSignedInBy(), user);
    }

    private static boolean isUser(User someone, User user) {
        return someone != null && Objects.equals(someone.getId(), user.getId());
    }

    private static boolean isActiveIn(User user, Team team) {
        if (user == null || user.getStatus() != UserStatus.ACTIVE) {
            return false;
        }
        return team == null || (user.getTeam() != null
                && Objects.equals(user.getTeam().getId(), team.getId()));
    }

    // Mapping -----------------------------------------------------------------------------

    /** Every open house's summary, read in one statement for the whole list. */
    private List<OpenHouseResponse> toResponses(List<OpenHouse> openHouses, User user) {
        if (openHouses.isEmpty()) {
            return List.of();
        }
        Map<Long, long[]> counts = new HashMap<>();
        for (Object[] row : visitorRepository.summarise(openHouses.stream().map(OpenHouse::getId).toList())) {
            counts.put((Long) row[0], new long[]{
                    ((Number) row[1]).longValue(),
                    row[2] == null ? 0 : ((Number) row[2]).longValue(),
                    row[3] == null ? 0 : ((Number) row[3]).longValue()});
        }
        return openHouses.stream().map(o -> {
            long[] c = counts.getOrDefault(o.getId(), new long[3]);
            Property p = o.getProperty();
            User host = o.getAgent();
            return OpenHouseResponse.builder()
                    .id(o.getId())
                    .propertyId(p.getId())
                    .propertyTitle(p.getTitle())
                    .propertyAddress(p.getAddress())
                    .agentId(host == null ? null : host.getId())
                    .agentName(host == null ? null : host.getFullName())
                    .startsAt(o.getStartsAt())
                    .endsAt(o.getEndsAt())
                    .note(o.getNote())
                    .visitorCount(c[0])
                    .newClientCount(c[1])
                    .interestedCount(c[2])
                    .canEdit(canEdit(o, user))
                    .createdAt(o.getCreatedAt())
                    .build();
        }).toList();
    }

    private OpenHouseVisitorResponse toResponse(OpenHouseVisitor v, OpenHouse openHouse, User user) {
        Client client = v.getClient();
        boolean visible = client != null && scopeService.canSee(user, client.getTeam(), client.getAgent());
        User signer = v.getSignedInBy();
        return OpenHouseVisitorResponse.builder()
                .id(v.getId())
                .openHouseId(openHouse.getId())
                .fullName(v.getFullName())
                .phone(v.getPhone())
                .interest(v.getInterest())
                .note(v.getNote())
                .clientId(client == null ? null : client.getId())
                .clientVisible(visible)
                .clientName(visible ? client.getFullName() : null)
                .clientAgentName(client == null || client.getAgent() == null
                        ? null : client.getAgent().getFullName())
                .newClient(v.isNewClient())
                .signedInById(signer == null ? null : signer.getId())
                .signedInByName(signer == null ? null : signer.getFullName())
                .signedInAt(v.getSignedInAt())
                .canRemove(canRemove(v, openHouse, user))
                .build();
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
