package com.crm.realestate.controller;

import com.crm.realestate.dto.response.FunnelResponse;
import com.crm.realestate.dto.response.LeaderboardResponse;
import com.crm.realestate.service.AnalyticsService;
import com.crm.realestate.service.LeaderboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "How deals move through the pipeline")
@SecurityRequirement(name = "bearerAuth")
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final LeaderboardService leaderboardService;
    private final com.crm.realestate.service.LeadSourceAnalyticsService leadSourceAnalyticsService;

    /**
     * Scoped like the dashboard: an agent gets their own figures, a manager their agency's, an
     * admin everyone's; {@code agentId} only narrows within that.
     */
    @GetMapping("/funnel")
    @Operation(summary = "Deal funnel for deals created in [from, to): stage counts, conversion, "
            + "won value, days to win, lost reasons and the last six months")
    public ResponseEntity<FunnelResponse> funnel(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long agentId) {
        return ResponseEntity.ok(analyticsService.funnel(from, to, agentId));
    }

    /**
     * The manager's view of their agency, person by person; an agent is refused. An admin names
     * the agency with {@code teamId}, which anyone else's request ignores.
     */
    @GetMapping("/leaderboard")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Per agent over [from, to) (this month by default): deals won and lost, "
            + "won value, commission, viewings held, new clients and win rate, ranked by commission")
    public ResponseEntity<LeaderboardResponse> leaderboard(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(leaderboardService.leaderboard(from, to, teamId));
    }

    /** Scoped like the funnel. Clients created in the period, by how they reached the agency. */
    @GetMapping("/lead-sources")
    @Operation(summary = "Clients created in [from, to) per lead source, and how many of each have a won deal")
    public ResponseEntity<com.crm.realestate.dto.response.LeadSourceBreakdown> leadSources(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long agentId) {
        return ResponseEntity.ok(leadSourceAnalyticsService.breakdown(from, to, agentId));
    }
}
