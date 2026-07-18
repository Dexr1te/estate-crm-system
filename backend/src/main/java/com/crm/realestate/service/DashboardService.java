package com.crm.realestate.service;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.ScopeService;
import com.crm.realestate.specification.DealSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final DealRepository    dealRepository;
    private final ClientRepository  clientRepository;
    private final MeetingRepository meetingRepository;
    private final UserRepository    userRepository;
    private final SecurityUtils     securityUtils;
    private final ScopeService      scopeService;

    public DashboardSummary getSummary(Long agentId, Long teamId) {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);

        if (currentUser.getDataScope() == DataScope.ALL) {
            if (teamId != null) {
                List<Long> teamAgentIds = userRepository.findByTeamId(teamId).stream().map(User::getId).toList();
                allowedAgentIds = teamAgentIds;
            } else if (agentId != null) {
                allowedAgentIds = List.of(agentId);
            }
        } else {
            if (agentId != null && !scopeService.isWithinScope(currentUser, agentId)) {
                throw new ResourceNotFoundException("Agent not found");
            }
        }

        long totalDeals = allowedAgentIds == null ? dealRepository.count() : dealRepository.countByAgentIdIn(allowedAgentIds);
        long closedDeals = (allowedAgentIds == null ? dealRepository.findByStatus(DealStatus.CLOSED_WON) : dealRepository.findAll(DealSpecification.build(DealStatus.CLOSED_WON, null, null, allowedAgentIds)))
                .size() + (allowedAgentIds == null ? dealRepository.findByStatus(DealStatus.CLOSED_LOST) : dealRepository.findAll(DealSpecification.build(DealStatus.CLOSED_LOST, null, null, allowedAgentIds))).size();
        long activeDeals = totalDeals - closedDeals;
        long totalClients = allowedAgentIds == null ? clientRepository.count() : clientRepository.countByAgentIdIn(allowedAgentIds);
        long upcomingMeetings = meetingRepository.findAllUpcoming(LocalDateTime.now()).stream()
                .filter(m -> allowedAgentIds == null || allowedAgentIds.contains(m.getAgent().getId()))
                .count();

        return DashboardSummary.builder()
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .closedDeals(closedDeals)
                .totalClients(totalClients)
                .upcomingMeetings(upcomingMeetings)
                .build();
    }
}