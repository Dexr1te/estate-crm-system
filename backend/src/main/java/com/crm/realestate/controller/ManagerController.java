package com.crm.realestate.controller;

import com.crm.realestate.dto.request.CreateAgentRequest;
import com.crm.realestate.dto.response.AgentResponse;
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

@RestController
@RequestMapping("/team")
@RequiredArgsConstructor
@Tag(name = "Team", description = "Manager team operations")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('MANAGER')")
public class ManagerController {

    private final AdminService adminService;
    private final com.crm.realestate.security.SecurityUtils securityUtils;

    @PostMapping("/agents")
    @Operation(summary = "Invite a new agent into the manager's team")
    public ResponseEntity<AgentResponse> inviteAgent(@Valid @RequestBody CreateAgentRequest request) {
        com.crm.realestate.entity.User currentManager = securityUtils.getCurrentUser();
        return ResponseEntity.status(HttpStatus.CREATED).body(adminService.inviteAgentToManagerTeam(request, currentManager));
    }
}
