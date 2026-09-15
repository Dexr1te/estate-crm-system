package com.crm.realestate.service;

import com.crm.realestate.entity.User;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
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
    @Transactional
    public void adoptTeamlessRecords(User user) {
        if (user == null || user.getTeam() == null) {
            return;
        }
        int clients    = clientRepository.adoptTeamless(user, user.getTeam());
        int properties = propertyRepository.adoptTeamless(user, user.getTeam());
        int deals      = dealRepository.adoptTeamless(user, user.getTeam());
        int meetings   = meetingRepository.adoptTeamless(user, user.getTeam());
        if (clients + properties + deals + meetings > 0) {
            log.info("Moved {} clients, {} listings, {} deals and {} meetings of user {} into team {}",
                    clients, properties, deals, meetings, user.getId(), user.getTeam().getId());
        }
    }
}
