package com.crm.realestate.controller;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.request.ResendVerificationRequest;
import com.crm.realestate.dto.request.UpdateProfileRequest;
import com.crm.realestate.dto.request.VerifyEmailRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.dto.response.RegisterResponse;
import com.crm.realestate.service.AuthService;
import com.crm.realestate.service.RegistrationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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
    private final RegistrationService registrationService;

    /**
     * Opens an account. No tokens come back: the address has to be confirmed first with the code
     * this mails out, which is what stops anyone signing up as someone else.
     */
    @PostMapping("/register")
    @Operation(summary = "Sign up as a manager or an agent")
    public ResponseEntity<RegisterResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(registrationService.register(request));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Confirm a new account with the code from the email")
    public ResponseEntity<AuthResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        return ResponseEntity.ok(registrationService.verifyEmail(request));
    }

    @PostMapping("/resend-verification")
    @Operation(summary = "Send another sign-up code")
    public ResponseEntity<RegisterResponse> resendVerification(
            @Valid @RequestBody ResendVerificationRequest request) {
        return ResponseEntity.ok(registrationService.resendCode(request.getEmail()));
    }

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

    /**
     * Closes the caller's own account.
     *
     * <p>Required by App Store Review Guideline 5.1.1(v): an app that holds an account has to let
     * the person holding it leave without going through anyone else. {@code replacementId} names
     * who takes over their deals, meetings and documents — the same handover an admin does — and is
     * mandatory for anyone who still holds records.
     */
    @DeleteMapping("/me")
    @Operation(summary = "Delete the current user's own account")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deleteMe(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) Long replacementId) {
        authService.deleteMe(userDetails.getUsername(), replacementId);
        return ResponseEntity.noContent().build();
    }
}
