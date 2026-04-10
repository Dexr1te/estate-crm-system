package com.crm.realestate.controller;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "Overview statistics")
@SecurityRequirement(name = "bearerAuth")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/summary")
    @Operation(summary = "Get dashboard summary - total deals, clients, upcoming meetings")
    public ResponseEntity<DashboardSummary> getSummary() {
        return ResponseEntity.ok(dashboardService.getSummary());
    }
}