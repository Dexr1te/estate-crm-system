package com.crm.realestate.service;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.request.UpdateProfileRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository        userRepository;
    private final PasswordEncoder       passwordEncoder;
    private final JwtService            jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        throw new UnsupportedOperationException("Self registration is disabled. Users must be invited by an admin or manager.");
    }

    public AuthResponse acceptInvite(com.crm.realestate.dto.request.AcceptInviteRequest request) {
        User user = userRepository.findByInviteToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Invalid invite token"));
        if (user.getInviteTokenExpiresAt() == null || user.getInviteTokenExpiresAt().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("Invite token expired");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setStatus(com.crm.realestate.enums.UserStatus.ACTIVE);
        user.setMustChangePassword(false);
        user.setInviteToken(null);
        user.setInviteTokenExpiresAt(null);
        userRepository.save(user);

        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public void requestPasswordReset(String email) {
        userRepository.findByEmail(email).ifPresent(user -> {
            user.setPasswordResetToken(java.util.UUID.randomUUID().toString());
            user.setPasswordResetTokenExpiresAt(java.time.LocalDateTime.now().plusHours(24));
            userRepository.save(user);
        });
    }

    public AuthResponse resetPassword(com.crm.realestate.dto.request.ResetPasswordRequest request) {
        User user = userRepository.findByPasswordResetToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Invalid reset token"));
        if (user.getPasswordResetTokenExpiresAt() == null || user.getPasswordResetTokenExpiresAt().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("Reset token expired");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordResetToken(null);
        user.setPasswordResetTokenExpiresAt(null);
        userRepository.save(user);

        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String accessToken  = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public AuthResponse refreshToken(String refreshToken) {
        String email = jwtService.extractUsername(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!jwtService.isTokenValid(refreshToken, user)) {
            throw new RuntimeException("Invalid refresh token");
        }

        String newAccessToken = jwtService.generateAccessToken(user);
        return buildAuthResponse(user, newAccessToken, refreshToken);
    }

    public AuthResponse getMe(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return buildAuthResponse(user, null, null);
    }

    @Transactional
    public AuthResponse updateMe(String currentEmail, UpdateProfileRequest request) {
        User user = userRepository.findByEmail(currentEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.getEmail().equalsIgnoreCase(request.getEmail())
                && userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        userRepository.save(user);

        String accessToken  = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        return buildAuthResponse(user, accessToken, refreshToken);
    }

    private AuthResponse buildAuthResponse(User user, String accessToken, String refreshToken) {
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }
}
