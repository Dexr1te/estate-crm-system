package com.crm.realestate.controller;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AgentStatsResponse;
import com.crm.realestate.dto.response.AuditLogResponse;
import com.crm.realestate.enums.Role;
import com.crm.realestate.service.AdminService;
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
@RequestMapping("/admin")
@RequiredArgsConstructor
@Tag(name = "Admin", description = "Admin only - manage users, teams and audit")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/users")
    @Operation(summary = "Get all users")
    public ResponseEntity<List<AgentResponse>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @PostMapping("/users")
    @Operation(summary = "Invite a new user")
    public ResponseEntity<AgentResponse> createUser(@Valid @RequestBody CreateAgentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminService.createUser(request));
    }

    @GetMapping("/users/{id}/stats")
    @Operation(summary = "Get user work statistics")
    public ResponseEntity<AgentStatsResponse> getUserStats(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getAgentStats(id));
    }

    @PatchMapping("/users/{id}/deactivate")
    @Operation(summary = "Deactivate a user")
    public ResponseEntity<AgentResponse> deactivateUser(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.deactivateUser(id));
    }

    @PatchMapping("/users/{id}/activate")
    @Operation(summary = "Activate a user")
    public ResponseEntity<AgentResponse> activateUser(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.activateUser(id));
    }

    @PutMapping("/users/{id}/role")
    @Operation(summary = "Change user role")
    public ResponseEntity<AgentResponse> changeRole(@PathVariable Long id,
                                                   @RequestParam Role role) {
        return ResponseEntity.ok(adminService.changeRole(id, role));
    }

    @PatchMapping("/users/{id}/team")
    @Operation(summary = "Assign a user to a team")
    public ResponseEntity<AgentResponse> assignTeam(@PathVariable Long id,
                                                    @RequestParam Long teamId) {
        return ResponseEntity.ok(adminService.assignTeam(id, teamId));
    }

    @PostMapping("/users/{id}/resend-invite")
    @Operation(summary = "Resend invite email to a pending user")
    public ResponseEntity<AgentResponse> resendInvite(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.resendInvite(id));
    }

    @GetMapping("/audit-log")
    @Operation(summary = "Get audit log entries")
    public ResponseEntity<List<AuditLogResponse>> getAuditLog(
            @RequestParam(required = false) Long actorId,
            @RequestParam(required = false) String entityType,
            @RequestParam(required = false) java.time.LocalDate dateFrom,
            @RequestParam(required = false) java.time.LocalDate dateTo) {
        return ResponseEntity.ok(adminService.getAuditLogs(actorId, entityType, dateFrom, dateTo));
    }
}
