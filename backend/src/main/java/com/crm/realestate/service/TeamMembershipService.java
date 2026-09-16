package com.crm.realestate.service;

import com.crm.realestate.dto.request.AddMemberRequest;
import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.request.TeamNameRequest;
import com.crm.realestate.dto.response.AddMemberResponse;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.dto.response.JoinRequestResponse;
import com.crm.realestate.dto.response.TeamMemberResponse;
import com.crm.realestate.dto.response.TeamResponse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.TeamJoinRequest;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.JoinRequestStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.TeamJoinRequestRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.AuthResponseFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

/**
 * Who is in an agency, and how they got there.
 *
 * <p>A manager starts the agency and adds people to it. Adding someone who already has an account
 * is a request, not a move: their clients and deals become visible to the manager once they join,
 * so it takes their yes. An address nobody has registered gets the old invite email instead, and
 * the account joins the team as soon as it is activated.
 *
 * <p>Leaving works the other way round. The records were made for the agency and stay in it, handed
 * to the manager or to whoever the manager nominates.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TeamMembershipService {

    private final UserRepository            userRepository;
    private final TeamRepository            teamRepository;
    private final TeamJoinRequestRepository requestRepository;
    private final AdminService              adminService;
    private final RecordHandoverService     recordHandoverService;
    private final AuthResponseFactory       authResponseFactory;
    private final AuditLogService           auditLogService;
    private final EmailService              emailService;

    // The manager's side ---------------------------------------------------------------

    /**
     * Opens the agency this manager will run.
     *
     * <p>Their own data scope widens to the team here: a manager who could only see their own
     * records would be running an agency they cannot look at.
     */
    @Transactional
    public TeamResponse createMyTeam(User manager, TeamNameRequest request) {
        if (manager.getTeam() != null) {
            throw new BusinessException(HttpStatus.CONFLICT, "ALREADY_HAS_TEAM",
                    "You already have a team");
        }
        Team team = teamRepository.save(Team.builder()
                .name(request.getName().trim())
                .manager(manager)
                .build());
        manager.setTeam(team);
        manager.setDataScope(DataScope.TEAM);
        userRepository.save(manager);
        recordHandoverService.adoptTeamlessRecords(manager);
        auditLogService.record(manager, "CREATE_TEAM", "Team", team.getId(), "name=" + team.getName());
        return toTeamResponse(team);
    }

    @Transactional
    public TeamResponse renameMyTeam(User manager, TeamNameRequest request) {
        Team team = requireTeam(manager);
        team.setName(request.getName().trim());
        return toTeamResponse(teamRepository.save(team));
    }

    public TeamResponse getMyTeam(User manager) {
        return toTeamResponse(requireTeam(manager));
    }

    /** The team, managers first, then everyone else by name. */
    public List<TeamMemberResponse> getMembers(User manager) {
        Team team = requireTeam(manager);
        Long managerId = team.getManager() == null ? null : team.getManager().getId();
        return userRepository.findByTeamId(team.getId()).stream()
                .sorted(Comparator.comparing((User u) -> !u.getId().equals(managerId))
                        .thenComparing(User::getFullName, Comparator.nullsLast(String::compareToIgnoreCase)))
                .map(member -> toMemberResponse(member, managerId))
                .toList();
    }

    /**
     * Asks an agent to join, or invites one who has no account yet.
     *
     * <p>The answer says which of the two happened, because they mean different things to the
     * manager waiting: one is out of their hands, the other is an email that may still bounce.
     */
    @Transactional
    public AddMemberResponse addMember(User manager, AddMemberRequest request) {
        Team team = requireTeam(manager);
        String email = request.getEmail().trim();

        User existing = userRepository.findFirstByEmailIgnoreCase(email).orElse(null);
        if (existing == null) {
            CreateAgentRequest invite = new CreateAgentRequest();
            invite.setFullName(request.getFullName().trim());
            invite.setEmail(email);
            invite.setPhone(request.getPhone());
            AgentResponse invited = adminService.inviteAgentToManagerTeam(invite, manager);
            return AddMemberResponse.builder()
                    .result(AddMemberResponse.Result.INVITE_SENT)
                    .member(TeamMemberResponse.builder()
                            .id(invited.getId())
                            .fullName(invited.getFullName())
                            .email(invited.getEmail())
                            .phone(invited.getPhone())
                            .role(invited.getRole())
                            .status(UserStatus.PENDING_INVITE)
                            .active(invited.isActive())
                            .createdAt(invited.getCreatedAt())
                            .build())
                    .build();
        }

        if (existing.getId().equals(manager.getId())) {
            throw new BusinessException(HttpStatus.CONFLICT, "NOT_AN_AGENT", "That is your own account");
        }
        if (existing.getRole() != Role.AGENT) {
            throw new BusinessException(HttpStatus.CONFLICT, "NOT_AN_AGENT",
                    "This account is not an agent account");
        }
        if (!existing.isActive()) {
            throw new BusinessException(HttpStatus.CONFLICT, "ACCOUNT_DEACTIVATED",
                    "This account has been deactivated");
        }
        if (existing.getStatus() == UserStatus.PENDING_INVITE) {
            throw new BusinessException(HttpStatus.CONFLICT, "INVITE_PENDING",
                    "This person already has an invite waiting and has not used it yet");
        }
        if (existing.getTeam() != null) {
            // Which team is deliberately not named: that is the other agency's business.
            throw new BusinessException(HttpStatus.CONFLICT,
                    team.getId().equals(existing.getTeam().getId()) ? "ALREADY_MEMBER" : "ALREADY_IN_TEAM",
                    team.getId().equals(existing.getTeam().getId())
                            ? "This agent is already in your team"
                            : "This agent already belongs to a team");
        }
        if (requestRepository.existsByTeamIdAndUserIdAndStatus(
                team.getId(), existing.getId(), JoinRequestStatus.PENDING)) {
            throw new BusinessException(HttpStatus.CONFLICT, "REQUEST_PENDING",
                    "This agent has already been asked and has not answered yet");
        }

        TeamJoinRequest joinRequest = requestRepository.save(TeamJoinRequest.builder()
                .team(team)
                .user(existing)
                .invitedBy(manager)
                .status(JoinRequestStatus.PENDING)
                .build());
        emailService.sendTeamRequest(existing.getEmail(), existing.getFullName(),
                team.getName(), manager.getFullName());
        auditLogService.record(manager, "REQUEST_TEAM_JOIN", "User", existing.getId(),
                "team=" + team.getName());

        return AddMemberResponse.builder()
                .result(AddMemberResponse.Result.REQUEST_SENT)
                .request(toRequestResponse(joinRequest))
                .build();
    }

    public List<JoinRequestResponse> getOutgoingRequests(User manager) {
        Team team = requireTeam(manager);
        return requestRepository
                .findByTeamIdAndStatusOrderByCreatedAtDesc(team.getId(), JoinRequestStatus.PENDING)
                .stream().map(this::toRequestResponse).toList();
    }

    @Transactional
    public void cancelRequest(User manager, Long requestId) {
        Team team = requireTeam(manager);
        TeamJoinRequest request = requestRepository.findById(requestId)
                .filter(r -> r.getTeam().getId().equals(team.getId()))
                .filter(r -> r.getStatus() == JoinRequestStatus.PENDING)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found with id: " + requestId));
        request.setStatus(JoinRequestStatus.CANCELLED);
        request.setRespondedAt(LocalDateTime.now());
        requestRepository.save(request);
    }

    /**
     * Takes an agent off the team, leaving their work behind with a colleague.
     *
     * <p>Someone who never used their invite has nothing to hand over and no account worth keeping,
     * so the invite is simply revoked.
     */
    @Transactional
    public void removeMember(User manager, Long userId, Long replacementId) {
        Team team = requireTeam(manager);
        User member = userRepository.findById(userId)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Member not found with id: " + userId));
        if (member.getId().equals(manager.getId())) {
            throw new BusinessException(HttpStatus.CONFLICT, "CANNOT_REMOVE_SELF",
                    "You cannot remove yourself from your own team");
        }
        if (member.getRole() != Role.AGENT) {
            throw new BusinessException(HttpStatus.CONFLICT, "NOT_AN_AGENT",
                    "Only agents can be removed from a team");
        }

        if (member.getStatus() == UserStatus.PENDING_INVITE) {
            auditLogService.record(manager, "REVOKE_INVITE", "User", member.getId(),
                    "email=" + member.getEmail() + ", team=" + team.getName());
            userRepository.delete(member);
            return;
        }

        User successor = resolveSuccessor(manager, team, replacementId, member);
        recordHandoverService.reassignTeamRecords(member, successor, team);
        member.setTeam(null);
        member.setDataScope(DataScope.OWN);
        userRepository.save(member);
        auditLogService.record(manager, "REMOVE_FROM_TEAM", "User", member.getId(),
                "team=" + team.getName() + ", movedTo=" + successor.getEmail());
    }

    // The agent's side -----------------------------------------------------------------

    public List<JoinRequestResponse> getMyRequests(User user) {
        return requestRepository
                .findByUserIdAndStatusOrderByCreatedAtDesc(user.getId(), JoinRequestStatus.PENDING)
                .stream().map(this::toRequestResponse).toList();
    }

    /** Joining brings along whatever this account holds outside any team. */
    @Transactional
    public AuthResponse acceptRequest(User user, Long requestId) {
        TeamJoinRequest request = myPendingRequest(user, requestId);
        if (user.getTeam() != null) {
            throw new BusinessException(HttpStatus.CONFLICT, "ALREADY_IN_TEAM",
                    "You already belong to a team");
        }
        request.setStatus(JoinRequestStatus.ACCEPTED);
        request.setRespondedAt(LocalDateTime.now());
        requestRepository.save(request);
        // Every other agency's invitation is moot now.
        requestRepository.cancelOtherPending(user.getId(), request.getId(), LocalDateTime.now());

        user.setTeam(request.getTeam());
        User joined = userRepository.save(user);
        recordHandoverService.adoptTeamlessRecords(joined);
        auditLogService.record(joined, "ACCEPT_TEAM_JOIN", "Team", request.getTeam().getId(),
                "team=" + request.getTeam().getName());
        return authResponseFactory.build(joined, null, null);
    }

    @Transactional
    public void declineRequest(User user, Long requestId) {
        TeamJoinRequest request = myPendingRequest(user, requestId);
        request.setStatus(JoinRequestStatus.DECLINED);
        request.setRespondedAt(LocalDateTime.now());
        requestRepository.save(request);
    }

    /** Leaving hands the team's records back to it, the same as being removed. */
    @Transactional
    public AuthResponse leaveTeam(User user) {
        Team team = user.getTeam();
        if (team == null) {
            throw new BusinessException(HttpStatus.CONFLICT, "NO_TEAM", "You are not in a team");
        }
        if (user.getRole() != Role.AGENT) {
            throw new BusinessException(HttpStatus.CONFLICT, "NOT_AN_AGENT",
                    "A manager cannot leave their own team");
        }
        User successor = resolveSuccessor(user, team, null, user);
        recordHandoverService.reassignTeamRecords(user, successor, team);
        user.setTeam(null);
        user.setDataScope(DataScope.OWN);
        User left = userRepository.save(user);
        auditLogService.record(left, "LEAVE_TEAM", "Team", team.getId(),
                "team=" + team.getName() + ", movedTo=" + successor.getEmail());
        return authResponseFactory.build(left, null, null);
    }

    // Helpers ---------------------------------------------------------------------------

    private Team requireTeam(User manager) {
        if (manager.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "Create your team first");
        }
        return manager.getTeam();
    }

    private TeamJoinRequest myPendingRequest(User user, Long requestId) {
        return requestRepository.findById(requestId)
                .filter(r -> r.getUser().getId().equals(user.getId()))
                .filter(r -> r.getStatus() == JoinRequestStatus.PENDING)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found with id: " + requestId));
    }

    /**
     * Who inherits the leaver's work: the nominated colleague, or the team's manager.
     *
     * <p>The nominee has to be an active member of that same team — the records are not leaving the
     * agency, so neither is their new owner.
     */
    private User resolveSuccessor(User actor, Team team, Long replacementId, User leaver) {
        if (replacementId == null) {
            User manager = team.getManager();
            if (manager == null || manager.getId().equals(leaver.getId())) {
                throw new BusinessException(HttpStatus.CONFLICT, "SUCCESSOR_REQUIRED",
                        "Choose who takes over the clients and deals");
            }
            return manager;
        }
        return userRepository.findById(replacementId)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .filter(User::isActive)
                .filter(u -> !u.getId().equals(leaver.getId()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User not found with id: " + replacementId));
    }

    private TeamResponse toTeamResponse(Team team) {
        return TeamResponse.builder()
                .id(team.getId())
                .name(team.getName())
                .managerId(team.getManager() == null ? null : team.getManager().getId())
                .managerName(team.getManager() == null ? null : team.getManager().getFullName())
                .memberCount((long) userRepository.findByTeamId(team.getId()).size())
                .createdAt(team.getCreatedAt())
                .build();
    }

    private TeamMemberResponse toMemberResponse(User member, Long managerId) {
        return TeamMemberResponse.builder()
                .id(member.getId())
                .fullName(member.getFullName())
                .email(member.getEmail())
                .phone(member.getPhone())
                .role(member.getRole())
                .status(member.getStatus())
                .active(member.isActive())
                .teamManager(member.getId().equals(managerId))
                .createdAt(member.getCreatedAt())
                .build();
    }

    private JoinRequestResponse toRequestResponse(TeamJoinRequest request) {
        return JoinRequestResponse.builder()
                .id(request.getId())
                .teamId(request.getTeam().getId())
                .teamName(request.getTeam().getName())
                .invitedByName(request.getInvitedBy() == null ? null : request.getInvitedBy().getFullName())
                .userId(request.getUser().getId())
                .userFullName(request.getUser().getFullName())
                .userEmail(request.getUser().getEmail())
                .status(request.getStatus())
                .createdAt(request.getCreatedAt())
                .build();
    }
}
