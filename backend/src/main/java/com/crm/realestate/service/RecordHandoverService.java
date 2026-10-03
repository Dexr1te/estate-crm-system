package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.OpenHouse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.OpenHouseRepository;
import com.crm.realestate.repository.PropertyOfferRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Moves records between owners when people move between teams.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RecordHandoverService {

    private final ClientRepository   clientRepository;
    private final PropertyRepository propertyRepository;
    private final DealRepository     dealRepository;
    private final MeetingRepository  meetingRepository;
    private final ClientActivityRepository activityRepository;
    private final DealCommentRepository dealCommentRepository;
    private final TaskRepository     taskRepository;
    private final OpenHouseRepository openHouseRepository;
    private final PropertyOfferRepository offerRepository;
    private final NotificationEvents notificationEvents;
    private final ChangeLogService   changeLog;

    /**
     * Brings what someone owned while in no team into the team they have just joined.
     *
     * <p>A person outside any team can still see records that are theirs and team-less — mostly
     * what an account held before teams existed. The moment they join one, those records would drop
     * out of sight, because a team member sees only the team's. So they come along.
     *
     * <p>Only team-less records move. Anything already in a team stays with that team: a record
     * belongs to the agency it was made in, not to whoever carried it.
     */
    /**
     * Hands what {@code from} holds in {@code team} to {@code to}, who stays in that team.
     *
     * <p>Used when an agent leaves or is taken off a team: the clients, listings, deals and meetings
     * are the agency's, so they stay behind with a colleague. Anything the agent holds outside that
     * team is not the team's to keep, and does not move.
     */
    @Transactional
    public void reassignTeamRecords(User from, User to, Team team) {
        reassignTeamRecords(from, to, team, null);
    }

    /**
     * The same, with who made it happen: {@code to} hears what they were given, unless they did
     * the handing themselves.
     */
    @Transactional
    public void reassignTeamRecords(User from, User to, Team team, User actor) {
        // Each client, listing and deal says it changed hands; read before the bulk update moves them.
        changeLog.handingOver(from, to, team, actor);
        int clients    = clientRepository.reassignInTeam(from, to, team);
        int properties = propertyRepository.reassignInTeam(from, to, team);
        int deals      = dealRepository.reassignInTeam(from, to, team);
        int meetings   = meetingRepository.reassignInTeam(from, to, team);
        int tasks      = taskRepository.reassignInTeam(from, to, team);
        openHouseRepository.reassignInTeam(from, to, team);
        offerRepository.reassignInTeam(from, to, team);
        if (clients + properties + deals + meetings + tasks > 0) {
            log.info("Handed {} clients, {} listings, {} deals, {} meetings and {} tasks in team {} from user {} to user {}",
                    clients, properties, deals, meetings, tasks, team.getId(), from.getId(), to.getId());
        }
        notificationEvents.recordsHandedOver(from, to, actor, team, clients, properties, deals, meetings, tasks);
    }

    /**
     * Records picked one by one, to be given to somebody else. Each list may be empty, never null.
     */
    public record Records(List<Client> clients, List<Property> listings, List<Deal> deals,
                          List<Meeting> meetings, List<Task> tasks, List<OpenHouse> openHouses) {

        public static Records of(List<Client> clients, List<Property> listings, List<Deal> deals,
                                 List<Meeting> meetings, List<Task> tasks) {
            return new Records(clients, listings, deals, meetings, tasks, List.of());
        }

        public int total() {
            return clients.size() + listings.size() + deals.size() + meetings.size() + tasks.size()
                    + openHouses.size();
        }
    }

    /**
     * Gives each of these records to {@code to}: the agent on a client, listing, deal, meeting or
     * open house, the assignee of a task. Nothing else about them changes — not the team, not the
     * history, not who created a task.
     *
     * <p>The one place a hand-picked set changes hands: an account being closed (everything it
     * holds) and a manager's handover (what they chose) both come through here, so the two cannot
     * drift on what "moving a record" means. Saying so to {@code to} is the caller's business; the
     * two say it differently.
     */
    @Transactional
    public void move(Records records, User to) {
        records.clients().forEach(c -> c.setAgent(to));
        records.listings().forEach(p -> p.setAgent(to));
        records.deals().forEach(d -> d.setAgent(to));
        records.meetings().forEach(m -> m.setAgent(to));
        records.tasks().forEach(t -> t.setAssignee(to));
        records.openHouses().forEach(o -> o.setAgent(to));
        clientRepository.saveAll(records.clients());
        propertyRepository.saveAll(records.listings());
        dealRepository.saveAll(records.deals());
        meetingRepository.saveAll(records.meetings());
        taskRepository.saveAll(records.tasks());
        openHouseRepository.saveAll(records.openHouses());
    }

    @Transactional
    public void adoptTeamlessRecords(User user) {
        if (user == null || user.getTeam() == null) {
            return;
        }
        int clients    = clientRepository.adoptTeamless(user, user.getTeam());
        int properties = propertyRepository.adoptTeamless(user, user.getTeam());
        int deals      = dealRepository.adoptTeamless(user, user.getTeam());
        int meetings   = meetingRepository.adoptTeamless(user, user.getTeam());
        taskRepository.adoptTeamless(user, user.getTeam());
        // A client's history travels with the client, so it follows the clients just moved.
        activityRepository.adoptTeamless(user, user.getTeam());
        // So does a deal's discussion, with the deals just moved.
        dealCommentRepository.adoptTeamless(user, user.getTeam());
        if (clients + properties + deals + meetings > 0) {
            log.info("Moved {} clients, {} listings, {} deals and {} meetings of user {} into team {}",
                    clients, properties, deals, meetings, user.getId(), user.getTeam().getId());
        }
    }
}
