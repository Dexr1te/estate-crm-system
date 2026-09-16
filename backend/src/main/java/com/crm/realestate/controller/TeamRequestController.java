package com.crm.realestate.controller;

import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.dto.response.JoinRequestResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.TeamMembershipService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * An agent's own side of team membership: the invitations waiting for them, and the way out.
 *
 * <p>Separate from {@code /team}, which belongs to the manager: these are the only calls an agent
 * with no team can make, and they are what the waiting screen is built on.
 */
@RestController
@RequestMapping("/me")
@RequiredArgsConstructor
@Tag(name = "Team membership", description = "An agent's invitations and their own membership")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('AGENT')")
public class TeamRequestController {

    private final TeamMembershipService teamMembershipService;
    private final SecurityUtils securityUtils;

    @GetMapping("/team-requests")
    @Operation(summary = "Teams that have asked this agent to join")
    public ResponseEntity<List<JoinRequestResponse>> getRequests() {
        return ResponseEntity.ok(teamMembershipService.getMyRequests(securityUtils.getCurrentUser()));
    }

    @PostMapping("/team-requests/{requestId}/accept")
    @Operation(summary = "Join the team that asked")
    public ResponseEntity<AuthResponse> accept(@PathVariable Long requestId) {
        return ResponseEntity.ok(
                teamMembershipService.acceptRequest(securityUtils.getCurrentUser(), requestId));
    }

    @PostMapping("/team-requests/{requestId}/decline")
    @Operation(summary = "Turn down a request")
    public ResponseEntity<Void> decline(@PathVariable Long requestId) {
        teamMembershipService.declineRequest(securityUtils.getCurrentUser(), requestId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/team")
    @Operation(summary = "Leave the current team, handing its records back to the manager")
    public ResponseEntity<AuthResponse> leaveTeam() {
        return ResponseEntity.ok(teamMembershipService.leaveTeam(securityUtils.getCurrentUser()));
    }
}
