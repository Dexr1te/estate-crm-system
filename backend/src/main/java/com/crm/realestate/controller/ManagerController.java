package com.crm.realestate.controller;

import com.crm.realestate.dto.request.AddMemberRequest;
import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.request.TeamNameRequest;
import com.crm.realestate.dto.response.AddMemberResponse;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.JoinRequestResponse;
import com.crm.realestate.dto.response.TeamMemberResponse;
import com.crm.realestate.dto.response.TeamResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.AdminService;
import com.crm.realestate.service.TeamMembershipService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** The agency a manager runs: its name, its people, and who has been asked to join. */
@RestController
@RequestMapping("/team")
@RequiredArgsConstructor
@Tag(name = "Team", description = "Manager team operations")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('MANAGER')")
public class ManagerController {

    private final TeamMembershipService teamMembershipService;
    private final AdminService adminService;
    private final SecurityUtils securityUtils;

    @PostMapping
    @Operation(summary = "Create the team this manager runs")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody TeamNameRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(teamMembershipService.createMyTeam(securityUtils.getCurrentUser(), request));
    }

    @GetMapping
    @Operation(summary = "Get the manager's own team")
    public ResponseEntity<TeamResponse> getTeam() {
        return ResponseEntity.ok(teamMembershipService.getMyTeam(securityUtils.getCurrentUser()));
    }

    @PatchMapping
    @Operation(summary = "Rename the manager's own team")
    public ResponseEntity<TeamResponse> renameTeam(@Valid @RequestBody TeamNameRequest request) {
        return ResponseEntity.ok(teamMembershipService.renameMyTeam(securityUtils.getCurrentUser(), request));
    }

    @GetMapping("/members")
    @Operation(summary = "List the team's members")
    public ResponseEntity<List<TeamMemberResponse>> getMembers() {
        return ResponseEntity.ok(teamMembershipService.getMembers(securityUtils.getCurrentUser()));
    }

    @PostMapping("/members")
    @Operation(summary = "Add an agent by email — a request if they have an account, an invite if not")
    public ResponseEntity<AddMemberResponse> addMember(@Valid @RequestBody AddMemberRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(teamMembershipService.addMember(securityUtils.getCurrentUser(), request));
    }

    @DeleteMapping("/members/{userId}")
    @Operation(summary = "Take an agent off the team, handing their records to a colleague")
    public ResponseEntity<Void> removeMember(@PathVariable Long userId,
                                            @RequestParam(required = false) Long replacementId) {
        teamMembershipService.removeMember(securityUtils.getCurrentUser(), userId, replacementId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/requests")
    @Operation(summary = "Requests sent to agents that are still unanswered")
    public ResponseEntity<List<JoinRequestResponse>> getRequests() {
        return ResponseEntity.ok(teamMembershipService.getOutgoingRequests(securityUtils.getCurrentUser()));
    }

    @DeleteMapping("/requests/{requestId}")
    @Operation(summary = "Withdraw a request")
    public ResponseEntity<Void> cancelRequest(@PathVariable Long requestId) {
        teamMembershipService.cancelRequest(securityUtils.getCurrentUser(), requestId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Invite-by-email only, in the shape the shipped app expects.
     *
     * <p>Kept exactly as it was — including the response body — because a build already in the
     * store parses it. New clients use {@code POST /team/members}, which also handles agents who
     * already have an account.
     *
     * @deprecated use {@code POST /team/members}
     */
    @Deprecated
    @PostMapping("/agents")
    @Operation(summary = "Deprecated: invite an agent by email (see POST /team/members)")
    public ResponseEntity<AgentResponse> inviteAgent(@Valid @RequestBody CreateAgentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(
                adminService.inviteAgentToManagerTeam(request, securityUtils.getCurrentUser()));
    }
}
