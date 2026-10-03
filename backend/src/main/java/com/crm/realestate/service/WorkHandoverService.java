package com.crm.realestate.service;

import com.crm.realestate.dto.request.HandoverRequest;
import com.crm.realestate.dto.response.HandoverResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.OpenHouse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.OpenHouseRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * A manager hands some of an agent's work to a colleague while both stay in the agency — a
 * holiday, an agent with too much on.
 *
 * <p>Nobody leaves, so unlike a departure (see {@link TeamMembershipService#removeMember}) the
 * manager chooses what moves: the source's clients, listings, open deals, meetings to come and open
 * tasks, any of them, or a hand-picked set of clients. A client never moves alone: the open deals
 * the source holds on it, and the meetings to come and open tasks on the client or on those deals,
 * go with it, so the colleague is not left with a buyer whose viewing tomorrow is somebody else's.
 * What is finished — a won deal, a viewing that happened, a task done — stays with whoever did it.
 *
 * <p>The preview and the handover work out the same set the same way, so the counts the manager
 * confirms are the counts that move. The records themselves change hands through
 * {@link RecordHandoverService#move}, the same path as a closed account's.
 *
 * <p>It is the agency's business only: the caller's own agency (an admin names one), and both
 * people active members of it. Anybody or anything from another agency reads as not found.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WorkHandoverService {

    private static final Set<DealStatus> OPEN = Set.of(DealStatus.LEAD, DealStatus.NEGOTIATION);

    private final UserRepository           userRepository;
    private final TeamRepository           teamRepository;
    private final ClientRepository         clientRepository;
    private final PropertyRepository       propertyRepository;
    private final DealRepository           dealRepository;
    private final MeetingRepository        meetingRepository;
    private final TaskRepository           taskRepository;
    private final OpenHouseRepository      openHouseRepository;
    private final ClientActivityRepository activityRepository;
    private final RecordHandoverService    recordHandoverService;
    private final NotificationEvents       notificationEvents;
    private final AuditLogService          auditLogService;
    private final ChangeLogService         changeLog;

    /** What the handover would move, without moving it. */
    public HandoverResponse preview(User actor, Long teamId, HandoverRequest request) {
        Plan plan = plan(actor, teamId, request);
        return plan.response(false);
    }

    /**
     * Moves it. Each client moved gets a line in its history, and the colleague taking over hears
     * once per person the work came from.
     */
    @Transactional
    public HandoverResponse handOver(User actor, Long teamId, HandoverRequest request) {
        Plan plan = plan(actor, teamId, request);
        if (plan.records.total() == 0) {
            return plan.response(true);
        }
        // Who held each client, before the move says otherwise. A client nobody held reads as "".
        Map<Long, String> heldBy = new LinkedHashMap<>();
        plan.records.clients().forEach(c -> heldBy.put(c.getId(),
                c.getAgent() == null ? "" : Objects.requireNonNullElse(c.getAgent().getFullName(), "")));
        Map<Long, Counts> perSource = plan.countsPerSource();
        HandoverResponse response = plan.response(true);

        // Each client, listing and deal says in its change log who held it, before the move does.
        String actorName = ChangeSnapshot.person(actor);
        plan.records.clients().forEach(c -> changeLog.agentChanged(ChangeSnapshot.target(c), actor, actorName,
                c.getAgent(), plan.to));
        plan.records.listings().forEach(p -> changeLog.agentChanged(ChangeSnapshot.target(p), actor, actorName,
                p.getAgent(), plan.to));
        plan.records.deals().forEach(d -> changeLog.agentChanged(ChangeSnapshot.target(d), actor, actorName,
                d.getAgent(), plan.to));
        recordHandoverService.move(plan.records, plan.to);

        LocalDateTime now = LocalDateTime.now();
        activityRepository.saveAll(plan.records.clients().stream()
                .map(client -> ClientActivity.builder()
                        .client(client)
                        .team(client.getTeam())
                        .author(actor)
                        .authorName(actor.getFullName())
                        .type(ActivityType.NOTE)
                        .handoverFromName(heldBy.get(client.getId()))
                        .handoverToName(plan.to.getFullName())
                        .occurredAt(now)
                        .build())
                .toList());

        perSource.forEach((sourceId, counts) -> notificationEvents.recordsHandedOver(
                counts.source, plan.to, actor, plan.team,
                counts.clients, counts.listings, counts.deals, counts.meetings, counts.tasks));

        // The journal points at whose work it was, or at the colleague when it was several people's.
        auditLogService.record(actor, "HAND_OVER_WORK", "User",
                (plan.from == null ? plan.to : plan.from).getId(),
                "from=" + (plan.from == null ? "several" : plan.from.getEmail())
                        + ", to=" + plan.to.getEmail()
                        + ", clients=" + response.getClients()
                        + ", listings=" + response.getListings()
                        + ", deals=" + response.getDeals()
                        + ", meetings=" + response.getMeetings()
                        + ", tasks=" + response.getTasks()
                        + ", openHouses=" + response.getOpenHouses());
        return response;
    }

    // Working out what moves ------------------------------------------------------------

    private Plan plan(User actor, Long teamId, HandoverRequest request) {
        if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager hands work over");
        }
        Team team = teamOf(actor, teamId);
        User to = member(team, request.getToAgentId());
        User from = request.getFromAgentId() == null ? null : member(team, request.getFromAgentId());
        if (from != null && from.getId().equals(to.getId())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "SAME_AGENT",
                    "Choose somebody else to take the work over");
        }
        boolean handPicked = request.getClientIds() != null;
        if (!handPicked && !request.isClients() && !request.isListings()
                && !request.isDeals() && !request.isUpcoming()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NOTHING_SELECTED",
                    "Choose what to hand over");
        }
        if (from == null && (!handPicked || request.isListings() || request.isDeals() || request.isUpcoming())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "FROM_AGENT_REQUIRED",
                    "Say whose work is handed over");
        }

        List<Client> clients = handPicked
                ? pickedClients(team, from, to, request.getClientIds())
                : request.isClients() ? held(clientRepository.findByAgentId(from.getId()), team, Client::getTeam) : List.of();

        // Everybody the work leaves: the one source, or whoever holds each client picked.
        Map<Long, User> sources = new LinkedHashMap<>();
        if (from != null) {
            sources.put(from.getId(), from);
        }
        clients.stream().map(Client::getAgent).filter(Objects::nonNull)
                .forEach(a -> sources.putIfAbsent(a.getId(), a));

        Set<Long> clientIds = ids(clients, Client::getId);
        LocalDateTime now = LocalDateTime.now();
        List<Deal> deals = new ArrayList<>();
        List<Meeting> meetings = new ArrayList<>();
        List<Task> tasks = new ArrayList<>();
        for (User source : sources.values()) {
            boolean whole = from != null && source.getId().equals(from.getId());
            List<Deal> open = held(dealRepository.findByAgentId(source.getId()), team, Deal::getTeam).stream()
                    .filter(d -> OPEN.contains(d.getStatus()))
                    .filter(d -> (whole && request.isDeals()) || clientIds.contains(d.getClient().getId()))
                    .toList();
            deals.addAll(open);
            Set<Long> dealIds = ids(open, Deal::getId);
            boolean everything = whole && request.isUpcoming();
            meetings.addAll(held(meetingRepository.findByAgentId(source.getId()), team, Meeting::getTeam).stream()
                    .filter(m -> !m.isCompleted() && m.getScheduledAt() != null && !m.getScheduledAt().isBefore(now))
                    .filter(m -> everything || clientIds.contains(m.getClient().getId())
                            || (m.getDeal() != null && dealIds.contains(m.getDeal().getId())))
                    .toList());
            tasks.addAll(held(taskRepository.findByAssigneeId(source.getId()), team, Task::getTeam).stream()
                    .filter(t -> t.getCompletedAt() == null)
                    .filter(t -> everything
                            || (t.getClient() != null && clientIds.contains(t.getClient().getId()))
                            || (t.getDeal() != null && dealIds.contains(t.getDeal().getId())))
                    .toList());
        }

        List<Property> listings = List.of();
        List<OpenHouse> openHouses = List.of();
        if (from != null && request.isListings()) {
            listings = held(propertyRepository.findByAgentId(from.getId()), team, Property::getTeam);
            openHouses = openHouseRepository.findByAgentIdAndTeamIdAndEndsAtAfter(from.getId(), team.getId(), now);
        }

        return new Plan(team, from, to,
                new RecordHandoverService.Records(clients, listings, deals, meetings, tasks, openHouses));
    }

    /**
     * The clients named, each in this agency (another agency's reads as not found) and, when a
     * source was named, held by them. Those the colleague already holds have nowhere to go and are
     * left out.
     */
    private List<Client> pickedClients(Team team, User from, User to, List<Long> requested) {
        if (requested.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NOTHING_SELECTED",
                    "Choose the clients to hand over");
        }
        if (requested.stream().anyMatch(Objects::isNull)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "CLIENT_ID_REQUIRED",
                    "A client id is missing");
        }
        Set<Long> wanted = new LinkedHashSet<>(requested);
        if (wanted.size() > HandoverRequest.MAX_CLIENTS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TOO_MANY_CLIENTS",
                    "Hand over at most " + HandoverRequest.MAX_CLIENTS + " clients at a time");
        }
        Map<Long, Client> found = clientRepository.findAllById(wanted).stream()
                .collect(Collectors.toMap(Client::getId, Function.identity()));
        List<Client> clients = new ArrayList<>();
        for (Long id : wanted) {
            Client client = found.get(id);
            if (client == null || client.getTeam() == null || !team.getId().equals(client.getTeam().getId())) {
                throw new ResourceNotFoundException("Client not found with id: " + id);
            }
            Long holder = client.getAgent() == null ? null : client.getAgent().getId();
            if (from != null && !from.getId().equals(holder)) {
                throw new BusinessException(HttpStatus.CONFLICT, "CLIENT_NOT_FROM_AGENT",
                        client.getFullName() + " is not " + from.getFullName() + "'s client");
            }
            if (!to.getId().equals(holder)) {
                clients.add(client);
            }
        }
        return clients;
    }

    /** The caller's own agency; an admin, who runs none, names one. */
    private Team teamOf(User actor, Long teamId) {
        if (actor.getRole() == Role.ADMIN && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (actor.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's work this is");
        }
        return actor.getTeam();
    }

    /** An active member of this agency who can hold records; anybody else reads as not found. */
    private User member(Team team, Long userId) {
        return userRepository.findById(userId)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .filter(User::isActive)
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .filter(u -> u.getRole() != Role.ADMIN)
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + userId));
    }

    /** The records among these that are in this agency — what someone holds elsewhere stays there. */
    private static <T> List<T> held(List<T> records, Team team, Function<T, Team> teamOf) {
        return records.stream()
                .filter(r -> teamOf.apply(r) != null && team.getId().equals(teamOf.apply(r).getId()))
                .toList();
    }

    private static <T> Set<Long> ids(List<T> records, Function<T, Long> id) {
        return records.stream().map(id).collect(Collectors.toCollection(HashSet::new));
    }

    // The plan --------------------------------------------------------------------------

    private record Plan(Team team, User from, User to, RecordHandoverService.Records records) {

        HandoverResponse response(boolean done) {
            return HandoverResponse.builder()
                    .done(done)
                    .fromAgentId(from == null ? singleSource() : from.getId())
                    .fromAgentName(from == null ? singleSourceName() : from.getFullName())
                    .toAgentId(to.getId())
                    .toAgentName(to.getFullName())
                    .clients(records.clients().size())
                    .listings(records.listings().size())
                    .deals(records.deals().size())
                    .meetings(records.meetings().size())
                    .tasks(records.tasks().size())
                    .openHouses(records.openHouses().size())
                    .total(records.total())
                    .build();
        }

        private Long singleSource() {
            Set<Long> ids = records.clients().stream()
                    .map(c -> c.getAgent() == null ? null : c.getAgent().getId())
                    .collect(Collectors.toCollection(HashSet::new));
            return ids.size() == 1 ? ids.iterator().next() : null;
        }

        private String singleSourceName() {
            Long id = singleSource();
            return id == null ? null : records.clients().stream()
                    .map(Client::getAgent)
                    .filter(a -> a != null && a.getId().equals(id))
                    .findFirst().map(User::getFullName).orElse(null);
        }

        /** What each person is giving up, for the line the colleague hears from each of them. */
        Map<Long, Counts> countsPerSource() {
            Map<Long, Counts> counts = new LinkedHashMap<>();
            Function<User, Counts> of = u -> counts.computeIfAbsent(u.getId(), k -> new Counts(u));
            records.clients().stream().filter(c -> c.getAgent() != null)
                    .forEach(c -> of.apply(c.getAgent()).clients++);
            records.listings().forEach(p -> of.apply(p.getAgent()).listings++);
            records.deals().forEach(d -> of.apply(d.getAgent()).deals++);
            records.meetings().forEach(m -> of.apply(m.getAgent()).meetings++);
            records.tasks().forEach(t -> of.apply(t.getAssignee()).tasks++);
            return counts.values().stream()
                    .sorted(Comparator.comparing(c -> Objects.requireNonNullElse(c.source.getFullName(), "")))
                    .collect(Collectors.toMap(c -> c.source.getId(), c -> c, (a, b) -> a, LinkedHashMap::new));
        }
    }

    private static final class Counts {
        final User source;
        int clients;
        int listings;
        int deals;
        int meetings;
        int tasks;

        Counts(User source) {
            this.source = source;
        }
    }
}
