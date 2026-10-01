package com.crm.realestate.controller;

import com.crm.realestate.dto.request.GoalRequest;
import com.crm.realestate.dto.response.GoalProgressResponse;
import com.crm.realestate.dto.response.TeamGoalsResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.GoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Monthly targets. {@code month} is "2026-10" and defaults to this month everywhere. An agent
 * reaches only their own; the manager (or an admin, naming the agency with {@code teamId}) sets
 * everybody's and the agency's.
 */
@RestController
@RequestMapping("/goals")
@RequiredArgsConstructor
@Tag(name = "Goals", description = "Monthly targets and progress towards them")
@SecurityRequirement(name = "bearerAuth")
public class GoalController {

    private final GoalService goalService;
    private final SecurityUtils securityUtils;

    @GetMapping("/me")
    @Operation(summary = "My target for the month that counts (the manager's wins) and my progress")
    public ResponseEntity<GoalProgressResponse> mine(@RequestParam(required = false) String month) {
        return ResponseEntity.ok(goalService.mine(securityUtils.getCurrentUser(), month));
    }

    @PutMapping("/me")
    @Operation(summary = "Set my own target; refused with GOAL_SET_BY_MANAGER once the manager has set one")
    public ResponseEntity<GoalProgressResponse> setMine(@RequestParam(required = false) String month,
                                                        @Valid @RequestBody GoalRequest request) {
        return ResponseEntity.ok(goalService.setMine(securityUtils.getCurrentUser(), month, request));
    }

    @DeleteMapping("/me")
    @Operation(summary = "Take my own target off")
    public ResponseEntity<GoalProgressResponse> clearMine(@RequestParam(required = false) String month) {
        return ResponseEntity.ok(goalService.clearMine(securityUtils.getCurrentUser(), month));
    }

    @GetMapping("/team")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Every member's target and progress for the month, and the agency's")
    public ResponseEntity<TeamGoalsResponse> team(@RequestParam(required = false) String month,
                                                  @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(goalService.team(securityUtils.getCurrentUser(), teamId, month));
    }

    @PutMapping("/team/agents/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Set a member's target; it overrides the member's own")
    public ResponseEntity<TeamGoalsResponse> setForMember(@PathVariable Long agentId,
                                                          @RequestParam(required = false) String month,
                                                          @RequestParam(required = false) Long teamId,
                                                          @Valid @RequestBody GoalRequest request) {
        return ResponseEntity.ok(goalService.setForMember(
                securityUtils.getCurrentUser(), teamId, agentId, month, request));
    }

    @DeleteMapping("/team/agents/{agentId}")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Take a member's target off; their own, if any, counts again")
    public ResponseEntity<TeamGoalsResponse> clearForMember(@PathVariable Long agentId,
                                                            @RequestParam(required = false) String month,
                                                            @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(goalService.clearForMember(securityUtils.getCurrentUser(), teamId, agentId, month));
    }

    @PutMapping("/team/agency")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Set the agency-wide target")
    public ResponseEntity<TeamGoalsResponse> setForAgency(@RequestParam(required = false) String month,
                                                          @RequestParam(required = false) Long teamId,
                                                          @Valid @RequestBody GoalRequest request) {
        return ResponseEntity.ok(goalService.setForAgency(securityUtils.getCurrentUser(), teamId, month, request));
    }

    @DeleteMapping("/team/agency")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Take the agency-wide target off")
    public ResponseEntity<TeamGoalsResponse> clearForAgency(@RequestParam(required = false) String month,
                                                            @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(goalService.clearForAgency(securityUtils.getCurrentUser(), teamId, month));
    }

    @PostMapping("/team/copy-previous")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Bring last month's targets into this one, leaving any already set")
    public ResponseEntity<TeamGoalsResponse> copyPrevious(@RequestParam(required = false) String month,
                                                          @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(goalService.copyPrevious(securityUtils.getCurrentUser(), teamId, month));
    }
}
