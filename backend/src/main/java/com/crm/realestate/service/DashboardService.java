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
        final List<Long> resolvedAgentIds;
        if (currentUser.getDataScope() == DataScope.ALL) {
            if (teamId != null) {
                resolvedAgentIds = userRepository.findByTeamId(teamId).stream().map(User::getId).collect(java.util.stream.Collectors.toList());
            } else if (agentId != null) {
                resolvedAgentIds = List.of(agentId);
            } else {
                resolvedAgentIds = null;
            }
        } else {
            if (agentId != null && !scopeService.isWithinScope(currentUser, agentId)) {
                throw new ResourceNotFoundException("Agent not found");
            }
            resolvedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        }

        long totalDeals = resolvedAgentIds == null ? dealRepository.count() : dealRepository.countByAgentIdIn(resolvedAgentIds);
        long closedDeals = (resolvedAgentIds == null ? dealRepository.findByStatus(DealStatus.CLOSED_WON) : dealRepository.findAll(DealSpecification.build(DealStatus.CLOSED_WON, null, null, resolvedAgentIds)))
                .size() + (resolvedAgentIds == null ? dealRepository.findByStatus(DealStatus.CLOSED_LOST) : dealRepository.findAll(DealSpecification.build(DealStatus.CLOSED_LOST, null, null, resolvedAgentIds))).size();
        long activeDeals = totalDeals - closedDeals;
        long totalClients = resolvedAgentIds == null ? clientRepository.count() : clientRepository.countByAgentIdIn(resolvedAgentIds);
        long upcomingMeetings = meetingRepository.findAllUpcoming(LocalDateTime.now()).stream()
                .filter(m -> resolvedAgentIds == null || resolvedAgentIds.contains(m.getAgent().getId()))
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