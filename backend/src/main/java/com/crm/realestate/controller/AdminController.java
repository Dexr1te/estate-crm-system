package com.crm.realestate.controller;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
import com.crm.realestate.dto.response.AgentStatsResponse;
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
@Tag(name = "Admin", description = "Admin only - manage agents and system")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")   // only ADMIN can access these endpoints
public class AdminController {

    private final AdminService adminService;

    // list all agents (only ADMIN can see this)
    @GetMapping("/agents")
    @Operation(summary = "Get all agents (only ADMIN can do this)")
    public ResponseEntity<List<AgentResponse>> getAllAgents() {
        return ResponseEntity.ok(adminService.getAllAgents());
    }

    // create a new agent or admin  (only ADMIN can do this)
    @PostMapping("/agents")
    @Operation(summary = "Create new agent or admin (only ADMIN can do this)")
    public ResponseEntity<AgentResponse> createAgent(@Valid @RequestBody CreateAgentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminService.createAgent(request));
    }

    // statistics for a specific agent (total clients, total deals, active deals, closed deals, upcoming meetings)
    @GetMapping("/agents/{id}/stats")
    @Operation(summary = "Get agent work statistics (only ADMIN can do this)")
    public ResponseEntity<AgentStatsResponse> getAgentStats(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getAgentStats(id));
    }

    // deactivate agent - fire the agent 
    @PatchMapping("/agents/{id}/deactivate")
    @Operation(summary = "Deactivate agent - fires the agent (only ADMIN can do this)")
    public ResponseEntity<AgentResponse> deactivateAgent(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.deactivateAgent(id));
    }

    // activate agent - rehire the agent
    @PatchMapping("/agents/{id}/activate")
    @Operation(summary = "Activate agent - rehire the agent (only ADMIN can do this)")
    public ResponseEntity<AgentResponse> activateAgent(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.activateAgent(id));
    }

    // chage role 
    @PutMapping("/agents/{id}/role")
    @Operation(summary = "Change user role (only ADMIN can do this)")
    public ResponseEntity<AgentResponse> changeRole(@PathVariable Long id,
                                                     @RequestParam Role role) {
        return ResponseEntity.ok(adminService.changeRole(id, role));
    }
}