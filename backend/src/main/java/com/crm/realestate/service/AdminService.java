package com.crm.realestate.service;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AgentStatsResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminService {

    private final UserRepository    userRepository;
    private final ClientRepository  clientRepository;
    private final DealRepository    dealRepository;
    private final MeetingRepository meetingRepository;
    private final PasswordEncoder   passwordEncoder;

    // list all agents (only ADMIN can do this)
    public List<AgentResponse> getAllAgents() {
        return userRepository.findByRoleOrderByFullNameAsc(Role.AGENT)
                .stream()
                .map(this::toAgentResponse)
                .collect(Collectors.toList());
    }

    // create a new agent (only ADMIN can do this)
    @Transactional
    public AgentResponse createAgent(CreateAgentRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(request.getRole() != null ? request.getRole() : Role.AGENT)
                .isActive(true)
                .build();

        return toAgentResponse(userRepository.save(user));
    }

    // statistics for a specific agent (total clients, total deals, active deals, closed deals, upcoming meetings)
    public AgentStatsResponse getAgentStats(Long agentId) {
        User agent = findById(agentId);

        long totalClients     = clientRepository.findByAgentId(agentId).size();
        long totalDeals       = dealRepository.findByAgentId(agentId).size();
        long closedDeals      = dealRepository.findByAgentIdAndStatus(agentId, DealStatus.CLOSED_WON).size()
                              + dealRepository.findByAgentIdAndStatus(agentId, DealStatus.CLOSED_LOST).size();
        long activeDeals      = totalDeals - closedDeals;
        long upcomingMeetings = meetingRepository.findAllUpcoming(LocalDateTime.now())
                .stream()
                .filter(m -> m.getAgent().getId().equals(agentId))
                .count();

        return AgentStatsResponse.builder()
                .agentId(agent.getId())
                .fullName(agent.getFullName())
                .email(agent.getEmail())
                .isActive(agent.isActive())
                .totalClients(totalClients)
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .closedDeals(closedDeals)
                .upcomingMeetings(upcomingMeetings)
                .build();
    }

    // deactivate agent (only ADMIN can do this)
    @Transactional
    public AgentResponse deactivateAgent(Long agentId) {
        User agent = findById(agentId);
        if (agent.getRole() == Role.ADMIN) {
            throw new RuntimeException("Cannot deactivate an ADMIN user");
        }
        agent.setActive(false);
        return toAgentResponse(userRepository.save(agent));
    }

    // activate agent 
    @Transactional
    public AgentResponse activateAgent(Long agentId) {
        User agent = findById(agentId);
        agent.setActive(true);
        return toAgentResponse(userRepository.save(agent));
    }

    // Change role (ADMIN only can change)
    @Transactional
    public AgentResponse changeRole(Long agentId, Role newRole) {
        User agent = findById(agentId);
        agent.setRole(newRole);
        return toAgentResponse(userRepository.save(agent));
    }

    //Private helpers 

    private User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    private AgentResponse toAgentResponse(User user) {
        return AgentResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .isActive(user.isActive())
                .createdAt(user.getCreatedAt())
                .build();
    }
}