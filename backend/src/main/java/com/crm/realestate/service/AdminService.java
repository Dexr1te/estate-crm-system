package com.crm.realestate.service;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AgentStatsResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
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
    private final EmailDomainValidator emailDomainValidator;
    private final DocumentRepository  documentRepository;
    private final PropertyRepository  propertyRepository;

    @Value("${app.primary-admin-email:admin@gmail.com}")
    private String primaryAdminEmail;

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
        if (!emailDomainValidator.acceptsMail(request.getEmail())) {
            throw new RuntimeException("That email domain cannot receive mail: " + request.getEmail());
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
        if (!emailDomainValidator.acceptsMail(request.getEmail())) {
            throw new RuntimeException("That email domain cannot receive mail: " + request.getEmail());
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
        User saved = userRepository.save(user);
        // Rotating the token without mailing it out is what "resend" used to do,
        // which left the recipient with nothing and the old link dead.
        emailService.sendInvite(saved.getEmail(), saved.getFullName(), saved.getInviteToken());
        return toAgentResponse(saved);
    }

    /**
     * Hands everything the user owns to {@code replacementId}, then deletes the row.
     *
     * <p>Only the primary admin may call this, and the primary admin can never be the target —
     * otherwise the instance could be left with nobody able to administer it.
     *
     * <p>Deals, meetings and documents are reassigned rather than deleted: their foreign keys are
     * {@code ON DELETE RESTRICT} precisely so a departing agent cannot take the agency's history
     * with them. Clients and properties are moved too — the schema would merely orphan them.
     * Audit entries keep their row and lose their actor (see V14).
     */
    @Transactional
    public void deleteUser(Long userId, Long replacementId) {
        User actor = securityUtils.getCurrentUser();
        if (!isPrimaryAdmin(actor)) {
            throw new AccessDeniedException("Only the primary admin can delete users");
        }

        User target = findById(userId);
        if (isPrimaryAdmin(target)) {
            throw new RuntimeException("The primary admin account cannot be deleted");
        }

        final User replacement = replacementId == null ? null : findById(replacementId);
        if (replacement != null && replacement.getId().equals(target.getId())) {
            throw new RuntimeException("Pick a different user to take over the records");
        }

        List<Deal> deals = dealRepository.findByAgentId(userId);
        List<Meeting> meetings = meetingRepository.findByAgentId(userId);
        List<Document> documents = documentRepository.findByUploadedById(userId);
        List<Client> clients = clientRepository.findByAgentId(userId);
        List<Property> properties = propertyRepository.findByAgentId(userId);

        // These three cannot be orphaned by the schema, so without somewhere to put
        // them the delete would fail at the database with an opaque constraint error.
        if (replacement == null
                && !(deals.isEmpty() && meetings.isEmpty() && documents.isEmpty())) {
            throw new RuntimeException(String.format(
                    "%s still holds %d deal(s), %d meeting(s) and %d document(s). "
                            + "Choose someone to take them over.",
                    target.getFullName(), deals.size(), meetings.size(), documents.size()));
        }

        if (replacement != null) {
            deals.forEach(d -> d.setAgent(replacement));
            meetings.forEach(m -> m.setAgent(replacement));
            documents.forEach(d -> d.setUploadedBy(replacement));
            clients.forEach(c -> c.setAgent(replacement));
            properties.forEach(p -> p.setAgent(replacement));
            dealRepository.saveAll(deals);
            meetingRepository.saveAll(meetings);
            documentRepository.saveAll(documents);
            clientRepository.saveAll(clients);
            propertyRepository.saveAll(properties);
        }

        auditLogService.record(actor, "DELETE_USER", "User", target.getId(),
                "email=" + target.getEmail()
                        + (replacement == null ? "" : ", movedTo=" + replacement.getEmail()));

        userRepository.delete(target);
    }

    public boolean isPrimaryAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase(primaryAdminEmail);
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
                .isPrimaryAdmin(isPrimaryAdmin(user))
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
