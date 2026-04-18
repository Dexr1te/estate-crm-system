package com.crm.realestate.controller;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Register, Login, Refresh Token")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register a new agent/admin")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    @Operation(summary = "Login and get JWT tokens")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Get new access token using refresh token")
    public ResponseEntity<AuthResponse> refresh(@RequestHeader("Authorization") String bearerToken) {
        String refreshToken = bearerToken.replace("Bearer ", "");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }
}