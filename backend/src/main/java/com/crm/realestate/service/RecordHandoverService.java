package com.crm.realestate.service;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private final TaskRepository     taskRepository;

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
        int clients    = clientRepository.reassignInTeam(from, to, team);
        int properties = propertyRepository.reassignInTeam(from, to, team);
        int deals      = dealRepository.reassignInTeam(from, to, team);
        int meetings   = meetingRepository.reassignInTeam(from, to, team);
        int tasks      = taskRepository.reassignInTeam(from, to, team);
        if (clients + properties + deals + meetings + tasks > 0) {
            log.info("Handed {} clients, {} listings, {} deals, {} meetings and {} tasks in team {} from user {} to user {}",
                    clients, properties, deals, meetings, tasks, team.getId(), from.getId(), to.getId());
        }
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
        if (clients + properties + deals + meetings > 0) {
            log.info("Moved {} clients, {} listings, {} deals and {} meetings of user {} into team {}",
                    clients, properties, deals, meetings, user.getId(), user.getTeam().getId());
        }
    }
}
