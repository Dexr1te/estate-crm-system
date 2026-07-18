package com.crm.realestate.controller;

import com.crm.realestate.dto.request.TeamRequest;
import com.crm.realestate.dto.response.TeamResponse;
import com.crm.realestate.dto.response.TeamStatsResponse;
import com.crm.realestate.service.TeamService;
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

@RestController
@RequestMapping("/teams")
@RequiredArgsConstructor
@Tag(name = "Teams", description = "Manage teams and team statistics")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
public class TeamController {

    private final TeamService teamService;

    @GetMapping
    @Operation(summary = "Get teams")
    public ResponseEntity<List<TeamResponse>> getTeams() {
        return ResponseEntity.ok(teamService.getTeams());
    }

    @PostMapping
    @Operation(summary = "Create a new team")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody TeamRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(teamService.createTeam(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update team details")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TeamResponse> updateTeam(@PathVariable Long id,
                                                   @Valid @RequestBody TeamRequest request) {
        return ResponseEntity.ok(teamService.updateTeam(id, request));
    }

    @GetMapping("/{id}/stats")
    @Operation(summary = "Get statistics for a team")
    public ResponseEntity<TeamStatsResponse> getTeamStats(@PathVariable Long id) {
        return ResponseEntity.ok(teamService.getTeamStats(id));
    }
}
