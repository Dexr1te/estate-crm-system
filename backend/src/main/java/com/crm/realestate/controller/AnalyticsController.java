package com.crm.realestate.controller;

import com.crm.realestate.dto.response.FunnelResponse;
import com.crm.realestate.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
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
}
