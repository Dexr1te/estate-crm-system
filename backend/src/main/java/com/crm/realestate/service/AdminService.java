package com.crm.realestate.service;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AgentStatsResponse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminService {

    private final UserRepository    userRepository;
    private final ClientRepository  clientRepository;
    private final DealRepository    dealRepository;
    private final MeetingRepository meetingRepository;
    private final TeamRepository    teamRepository;
    private final PasswordEncoder   passwordEncoder;
    private final SecurityUtils      securityUtils;
    private final AuditLogService    auditLogService;
    private final EmailService       emailService;

    public List<AgentResponse> getAllUsers() {
        return userRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toAgentResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public AgentResponse createUser(CreateAgentRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        Team team = null;
        if (request.getTeamId() != null) {
            team = teamRepository.findById(request.getTeamId())
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found"));
        }

        User currentUser = securityUtils.getCurrentUser();
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .role(request.getRole() != null ? request.getRole() : Role.AGENT)
                .dataScope(request.getDataScope() != null ? request.getDataScope() : DataScope.OWN)
                .team(team)
                .status(UserStatus.PENDING_INVITE)
                .isActive(true)
                .inviteToken(UUID.randomUUID().toString())
                .inviteTokenExpiresAt(LocalDateTime.now().plusHours(48))
                .createdBy(currentUser)
                .build();

        User saved = userRepository.save(user);
        emailService.sendInvite(saved.getEmail(), saved.getFullName(), saved.getInviteToken());
        return toInviteResponse(saved);
    }

    @Transactional
    public AgentResponse inviteAgentToManagerTeam(CreateAgentRequest request, User manager) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }
        if (manager.getTeam() == null) {
            throw new IllegalStateException("Manager must belong to a team before inviting agents");
        }
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .role(Role.AGENT)
                .dataScope(DataScope.OWN)
                .team(manager.getTeam())
                .status(UserStatus.PENDING_INVITE)
                .isActive(true)
                .inviteToken(UUID.randomUUID().toString())
                .inviteTokenExpiresAt(LocalDateTime.now().plusHours(48))
                .createdBy(manager)
                .build();
        User saved = userRepository.save(user);
        emailService.sendInvite(saved.getEmail(), saved.getFullName(), saved.getInviteToken());
        return toInviteResponse(saved);
    }

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

    @Transactional
    public AgentResponse deactivateUser(Long userId) {
        User user = findById(userId);
        if (user.getRole() == Role.ADMIN) {
            ensureNotLastActiveAdmin(user);
        }
        user.setActive(false);
        return toAgentResponse(userRepository.save(user));
    }

    @Transactional
    public AgentResponse activateUser(Long userId) {
        User user = findById(userId);
        user.setActive(true);
        return toAgentResponse(userRepository.save(user));
    }

    @Transactional
    public AgentResponse changeRole(Long userId, Role newRole) {
        User user = findById(userId);
        if (user.getRole() == Role.ADMIN && newRole != Role.ADMIN) {
            ensureNotLastActiveAdmin(user);
        }
        user.setRole(newRole);
        return toAgentResponse(userRepository.save(user));
    }

    @Transactional
    public AgentResponse assignTeam(Long userId, Long teamId) {
        User user = findById(userId);
        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found"));
        user.setTeam(team);
        return toAgentResponse(userRepository.save(user));
    }

    @Transactional
    public AgentResponse resendInvite(Long userId) {
        User user = findById(userId);
        user.setInviteToken(UUID.randomUUID().toString());
        user.setInviteTokenExpiresAt(LocalDateTime.now().plusHours(48));
        if (user.getStatus() != UserStatus.ACTIVE) {
            user.setStatus(UserStatus.PENDING_INVITE);
        }
        return toAgentResponse(userRepository.save(user));
    }

    public List<com.crm.realestate.dto.response.AuditLogResponse> getAuditLogs(Long actorId, String entityType, java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        return auditLogService.getAuditLogs(actorId, entityType, fromDate, toDate);
    }

    private void ensureNotLastActiveAdmin(User user) {
        long activeAdmins = userRepository.countByRoleAndStatusAndIsActiveTrue(Role.ADMIN, UserStatus.ACTIVE);
        if (activeAdmins <= 1) {
            throw new RuntimeException("Cannot remove role ADMIN from the last active admin");
        }
    }

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

    /**
     * Same as {@link #toAgentResponse(User)} but also exposes the one-time invite
     * token. Used only by the create/invite endpoints so the caller can hand the
     * token to the new user (there is no email delivery). List endpoints keep
     * using {@link #toAgentResponse(User)}, so tokens are never leaked in bulk.
     */
    private AgentResponse toInviteResponse(User user) {
        AgentResponse response = toAgentResponse(user);
        response.setInviteToken(user.getInviteToken());
        return response;
    }
}
