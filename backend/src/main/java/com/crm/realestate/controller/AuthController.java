package com.crm.realestate.controller;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.request.UpdateProfileRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Register, Login, Refresh Token, Me")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Login and get JWT tokens")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/accept-invite")
    @Operation(summary = "Accept an invite and set a password")
    public ResponseEntity<AuthResponse> acceptInvite(@Valid @RequestBody com.crm.realestate.dto.request.AcceptInviteRequest request) {
        return ResponseEntity.ok(authService.acceptInvite(request));
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Request a password reset email")
    public ResponseEntity<String> forgotPassword(@Valid @RequestBody com.crm.realestate.dto.request.ForgotPasswordRequest request) {
        authService.requestPasswordReset(request.getEmail());
        return ResponseEntity.ok("Password reset requested if that email exists.");
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset password using a reset token")
    public ResponseEntity<AuthResponse> resetPassword(@Valid @RequestBody com.crm.realestate.dto.request.ResetPasswordRequest request) {
        return ResponseEntity.ok(authService.resetPassword(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Get new access token using refresh token")
    public ResponseEntity<AuthResponse> refresh(@RequestHeader("Authorization") String bearerToken) {
        String refreshToken = bearerToken.replace("Bearer ", "");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }

    @GetMapping("/me")
    @Operation(summary = "Get current authenticated user info")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<AuthResponse> me(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(authService.getMe(userDetails.getUsername()));
    }

    @PutMapping("/me")
    @Operation(summary = "Update current authenticated user profile (fullName, email)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<AuthResponse> updateMe(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(authService.updateMe(userDetails.getUsername(), request));
    }
}
