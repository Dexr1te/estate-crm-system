package com.crm.realestate.service;

import com.crm.realestate.dto.request.TeamRequest;
import com.crm.realestate.dto.response.TeamResponse;
import com.crm.realestate.dto.response.TeamStatsResponse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final ClientRepository clientRepository;
    private final DealRepository dealRepository;
    private final MeetingRepository meetingRepository;
    private final SecurityUtils securityUtils;
    private final ScopeService scopeService;

    public List<TeamResponse> getTeams() {
        User currentUser = securityUtils.getCurrentUser();
        if (scopeService.isAdmin(currentUser)) {
            return teamRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
        }
        if (scopeService.isManager(currentUser) && currentUser.getTeam() != null) {
            return List.of(toResponse(currentUser.getTeam()));
        }
        return List.of();
    }

    @Transactional
    public TeamResponse createTeam(TeamRequest request) {
        User manager = userRepository.findById(request.getManagerId())
                .orElseThrow(() -> new ResourceNotFoundException("Manager not found"));
        if (manager.getRole() != Role.MANAGER) {
            throw new IllegalArgumentException("Team manager must have role MANAGER");
        }
        Team team = Team.builder()
                .name(request.getName())
                .manager(manager)
                .build();
        team = teamRepository.save(team);
        manager.setTeam(team);
        userRepository.save(manager);
        return toResponse(team);
    }

    @Transactional
    public TeamResponse updateTeam(Long id, TeamRequest request) {
        Team team = findById(id);
        if (request.getName() != null && !request.getName().isBlank()) {
            team.setName(request.getName());
        }
        if (request.getManagerId() != null && !request.getManagerId().equals(team.getManager() == null ? null : team.getManager().getId())) {
            User manager = userRepository.findById(request.getManagerId())
                    .orElseThrow(() -> new ResourceNotFoundException("Manager not found"));
            if (manager.getRole() != Role.MANAGER) {
                throw new IllegalArgumentException("Team manager must have role MANAGER");
            }
            if (team.getManager() != null) {
                team.getManager().setTeam(null);
                userRepository.save(team.getManager());
            }
            team.setManager(manager);
            manager.setTeam(team);
            userRepository.save(manager);
        }
        return toResponse(teamRepository.save(team));
    }

    public TeamStatsResponse getTeamStats(Long id) {
        User currentUser = securityUtils.getCurrentUser();
        Team team = findById(id);
        if (!scopeService.isAdmin(currentUser)
                && !(scopeService.isManager(currentUser) && currentUser.getTeam() != null && currentUser.getTeam().getId().equals(id))) {
            throw new ResourceNotFoundException("Team not found");
        }
        List<Long> agentIds = userRepository.findByTeamId(team.getId()).stream().map(User::getId).toList();
        long totalClients = clientRepository.countByAgentIdIn(agentIds);
        long totalDeals = dealRepository.countByAgentIdIn(agentIds);
        long activeDeals = dealRepository.findByAgentIdIn(agentIds).stream()
                .filter(d -> d.getStatus() != com.crm.realestate.enums.DealStatus.CLOSED_WON
                        && d.getStatus() != com.crm.realestate.enums.DealStatus.CLOSED_LOST)
                .count();
        long upcomingMeetings = meetingRepository.findAllUpcoming(LocalDateTime.now()).stream()
                .filter(m -> agentIds.contains(m.getAgent().getId()))
                .count();

        return TeamStatsResponse.builder()
                .teamId(team.getId())
                .teamName(team.getName())
                .managerId(team.getManager().getId())
                .managerName(team.getManager().getFullName())
                .totalAgents(agentIds.size())
                .totalClients(totalClients)
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .upcomingMeetings(upcomingMeetings)
                .build();
    }

    private Team findById(Long id) {
        return teamRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));
    }

    private TeamResponse toResponse(Team team) {
        return TeamResponse.builder()
                .id(team.getId())
                .name(team.getName())
                .managerId(team.getManager() != null ? team.getManager().getId() : null)
                .managerName(team.getManager() != null ? team.getManager().getFullName() : null)
                .memberCount(userRepository.findByTeamId(team.getId()).size())
                .createdAt(team.getCreatedAt())
                .build();
    }
}
