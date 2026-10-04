package com.crm.realestate.service;

import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.entity.TimeOff;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final SecurityUtils  securityUtils;
    private final ScopeService   scopeService;
    private final TimeOffService timeOffService;

    // only active agents for frontend select (for meetings, deals)
    public List<AgentOptionResponse> getAgentOptions() {
        // Everyone who can be put on a deal or a meeting, not only Role.AGENT.
        // Managers and admins run viewings too, and in a young agency they are
        // often the only accounts there are — under the old filter that list
        // came back empty and the meeting form could not be submitted at all.
        //
        // But only the caller's own agency: this list is also where a departing
        // agent picks who inherits their clients, and a name from another agency
        // there would be both a leak and a way to hand records across the wall.
        User currentUser = securityUtils.getCurrentUser();
        List<User> people;
        if (scopeService.isAdmin(currentUser)) {
            people = userRepository.findByIsActiveTrueOrderByFullNameAsc();
        } else if (currentUser.getTeam() == null) {
            people = currentUser.isActive() ? List.of(currentUser) : List.of();
        } else {
            people = userRepository.findByTeamIdAndIsActiveTrueOrderByFullNameAsc(currentUser.getTeam().getId());
        }
        // Inside an agency each person says when they are away, so nobody hands work to somebody on
        // holiday without knowing it. One statement for the whole list.
        Map<Long, List<TimeOff>> away = scopeService.isAdmin(currentUser) || currentUser.getTeam() == null
                ? null
                : timeOffService.notOverByPerson(currentUser.getTeam().getId(),
                        people.stream().map(User::getId).toList());
        LocalDate today = away == null ? null : timeOffService.today();
        return people
                .stream()
                .map(user -> {
                    AgentOptionResponse.AgentOptionResponseBuilder option = AgentOptionResponse.builder()
                            .id(user.getId())
                            .fullName(user.getFullName());
                    if (away != null) {
                        List<TimeOff> theirs = away.getOrDefault(user.getId(), List.of());
                        option.timeOff(theirs.stream()
                                .map(t -> AgentOptionResponse.Away.builder()
                                        .kind(t.getKind())
                                        .startDate(t.getStartDate())
                                        .endDate(t.getEndDate())
                                        .build())
                                .toList());
                        option.awayUntil(theirs.stream()
                                .filter(t -> t.covers(today))
                                .map(TimeOff::getEndDate)
                                .findFirst()
                                .orElse(null));
                    }
                    return option.build();
                })
                .collect(Collectors.toList());
    }
}
