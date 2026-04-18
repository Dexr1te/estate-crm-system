package com.crm.realestate.controller;

import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User management")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @GetMapping("/agents")
    @Operation(
        summary = "Get all agents for dropdown select",
        description = "Returns list of agents (id + fullName) sorted by name. Used by frontend for agent selection."
    )
    public ResponseEntity<List<AgentOptionResponse>> getAgentOptions() {
        return ResponseEntity.ok(userService.getAgentOptions());
    }
}