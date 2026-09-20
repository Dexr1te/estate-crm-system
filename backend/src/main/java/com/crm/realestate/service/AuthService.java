package com.crm.realestate.service;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.UpdateProfileRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.AuthResponseFactory;
import com.crm.realestate.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AccountStatusException;
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
    private final AccountRemovalService accountRemovalService;
    private final EmailService          emailService;
    private final RegistrationService   registrationService;
    private final AuthResponseFactory   authResponseFactory;

    /**
     * Closes the caller's own account, handing their records to {@code replacementId}.
     *
     * <p>The rules and the reassignment are the same ones an admin deletion goes through — see
     * {@link AccountRemovalService}.
     */
    @Transactional
    public void deleteMe(String email, Long replacementId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Authenticated user not found"));
        accountRemovalService.removeOwnAccount(user, replacementId);
    }

    public AuthResponse acceptInvite(com.crm.realestate.dto.request.AcceptInviteRequest request) {
        User user = userRepository.findByInviteToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Invalid invite token"));
        if (user.getInviteTokenExpiresAt() == null || user.getInviteTokenExpiresAt().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("Invite token expired");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setStatus(UserStatus.ACTIVE);
        user.setMustChangePassword(false);
        user.setInviteToken(null);
        user.setInviteTokenExpiresAt(null);
        userRepository.save(user);

        return authResponseFactory.withNewTokens(user);
    }

    public void requestPasswordReset(String email) {
        userRepository.findByEmail(email).ifPresent(user -> {
            user.setPasswordResetToken(java.util.UUID.randomUUID().toString());
            user.setPasswordResetTokenExpiresAt(java.time.LocalDateTime.now().plusHours(24));
            userRepository.save(user);
            emailService.sendPasswordReset(
                    user.getEmail(), user.getFullName(), user.getPasswordResetToken());
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

        return authResponseFactory.withNewTokens(user);
    }

    public AuthResponse login(LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (AccountStatusException e) {
            throw unverifiedOr(e, request);
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return authResponseFactory.withNewTokens(user);
    }

    /**
     * Turns "account disabled" into "confirm your email" — but only for the owner.
     *
     * <p>Spring checks whether an account is enabled before it checks the password, so the
     * exception alone says nothing about who is asking. Saying EMAIL_NOT_VERIFIED to anyone would
     * tell a stranger that the address has signed up, so the password is compared here first.
     */
    private RuntimeException unverifiedOr(AccountStatusException original, LoginRequest request) {
        return userRepository.findByEmail(request.getEmail())
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFICATION)
                .filter(u -> u.getPassword() != null
                        && passwordEncoder.matches(request.getPassword(), u.getPassword()))
                .<RuntimeException>map(user -> {
                    // Only promise the code if one is really on its way: a host that cannot send
                    // mail would otherwise leave someone waiting on an inbox forever, which is the
                    // one thing this message must not do.
                    boolean sent = registrationService.resendForSignIn(user);
                    return new BusinessException(HttpStatus.FORBIDDEN, "EMAIL_NOT_VERIFIED",
                            sent ? "Confirm your email first. We have sent you a code."
                                 : "Confirm your email first. We could not send a code just now — "
                                         + "please try again in a few minutes.");
                })
                .orElse(original);
    }

    public AuthResponse refreshToken(String refreshToken) {
        String email = jwtService.extractUsername(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!jwtService.isTokenValid(refreshToken, user)) {
            throw new RuntimeException("Invalid refresh token");
        }

        String newAccessToken = jwtService.generateAccessToken(user);
        return authResponseFactory.build(user, newAccessToken, refreshToken);
    }

    public AuthResponse getMe(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return authResponseFactory.build(user, null, null);
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

        return authResponseFactory.withNewTokens(user);
    }
}
