package com.crm.realestate.service;

import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.request.VerifyEmailRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.dto.response.RegisterResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.AuthResponseFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HexFormat;

/**
 * Opening an account without being invited.
 *
 * <p>A manager signs up to start an agency, an agent signs up to be added to one. Either way the
 * account does nothing until its owner proves the address with a six-digit code: without that,
 * anyone could register someone else's email and be the one a manager adds to their team.
 */
@Service
@RequiredArgsConstructor
public class RegistrationService {

    public static final Duration CODE_TTL = Duration.ofMinutes(15);
    public static final Duration RESEND_COOLDOWN = Duration.ofSeconds(60);
    /** Six digits are a million possibilities — enough against five tries, nothing against many. */
    public static final int MAX_ATTEMPTS = 5;

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserRepository       userRepository;
    private final PasswordEncoder      passwordEncoder;
    private final EmailService         emailService;
    private final EmailDomainValidator emailDomainValidator;
    private final AuthResponseFactory  authResponseFactory;

    /**
     * Creates the account, or refreshes one that was never confirmed.
     *
     * <p>Signing up again over an unconfirmed account replaces it rather than refusing: someone who
     * mistyped their password, or lost the email, would otherwise be locked out of their own
     * address for good. Nothing is lost, because nothing could have been done with it yet.
     */
    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        if (request.getRole() != Role.MANAGER && request.getRole() != Role.AGENT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "ROLE_NOT_ALLOWED",
                    "Sign up as a manager or as an agent");
        }
        String email = request.getEmail().trim();

        User user = userRepository.findFirstByEmailIgnoreCase(email).orElse(null);
        if (user != null && user.getStatus() == UserStatus.PENDING_INVITE) {
            throw new BusinessException(HttpStatus.CONFLICT, "INVITE_PENDING",
                    "This email already has an invite waiting. Use the link in that email to set your password.");
        }
        if (user != null && user.getStatus() != UserStatus.PENDING_VERIFICATION) {
            throw new BusinessException(HttpStatus.CONFLICT, "EMAIL_TAKEN",
                    "An account with this email already exists");
        }
        if (user == null && !emailDomainValidator.acceptsMail(email)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EMAIL_UNDELIVERABLE",
                    "That email domain cannot receive mail: " + email);
        }

        if (user == null) {
            user = User.builder().email(email).build();
        }
        user.setFullName(request.getFullName().trim());
        user.setPhone(blankToNull(request.getPhone()));
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole());
        // A manager runs the whole agency; an agent starts on their own work.
        user.setDataScope(request.getRole() == Role.MANAGER ? DataScope.TEAM : DataScope.OWN);
        user.setStatus(UserStatus.PENDING_VERIFICATION);
        user.setActive(true);
        user.setMustChangePassword(false);
        user = userRepository.save(user);

        // Rolls the account back with it. An account whose code never went out is one its owner
        // can neither confirm nor sign into, and — since the address is now taken by a row in
        // PENDING_VERIFICATION — one they can only escape by registering over it and hoping mail
        // works the second time.
        if (!sendCodeIfDue(user)) {
            throw cannotSendCode();
        }
        return pendingResponse(user);
    }

    /**
     * Spends the code and signs the new account in.
     *
     * <p>Wrong guesses are counted and survive the failed request — that is what the no-rollback is
     * for. Six digits are a million possibilities, which is plenty against five tries and nothing
     * against unlimited ones.
     */
    @Transactional(noRollbackFor = BusinessException.class)
    public AuthResponse verifyEmail(VerifyEmailRequest request) {
        User user = userRepository.findFirstByEmailIgnoreCase(request.getEmail().trim())
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFICATION)
                // Unknown and already-confirmed addresses read like a wrong code: nothing to learn here.
                .orElseThrow(RegistrationService::invalidCode);

        if (user.getEmailVerificationAttempts() >= MAX_ATTEMPTS) {
            throw attemptsExceeded();
        }
        if (user.getEmailVerificationExpiresAt() == null
                || user.getEmailVerificationExpiresAt().isBefore(LocalDateTime.now())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "CODE_EXPIRED",
                    "This code has expired. Ask for a new one.");
        }
        if (!matches(request.getCode(), user.getEmailVerificationCodeHash())) {
            user.setEmailVerificationAttempts(user.getEmailVerificationAttempts() + 1);
            userRepository.save(user);
            throw user.getEmailVerificationAttempts() >= MAX_ATTEMPTS ? attemptsExceeded() : invalidCode();
        }

        user.setStatus(UserStatus.ACTIVE);
        user.setEmailVerificationCodeHash(null);
        user.setEmailVerificationExpiresAt(null);
        user.setEmailVerificationSentAt(null);
        user.setEmailVerificationAttempts(0);
        return authResponseFactory.withNewTokens(userRepository.save(user));
    }

    /**
     * Sends a new code, unless one went out less than a minute ago.
     *
     * <p>Answers the same way for an address with no pending account, so this cannot be used to find
     * out who has signed up.
     */
    @Transactional
    public RegisterResponse resendCode(String email) {
        String trimmed = email.trim();
        return userRepository.findFirstByEmailIgnoreCase(trimmed)
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFICATION)
                .map(user -> {
                    if (!sendCodeIfDue(user)) {
                        throw cannotSendCode();
                    }
                    return pendingResponse(user);
                })
                .orElseGet(() -> RegisterResponse.builder()
                        .email(trimmed)
                        .resendAvailableInSeconds(RESEND_COOLDOWN.toSeconds())
                        .codeExpiresInSeconds(CODE_TTL.toSeconds())
                        .build());
    }

    /**
     * Called when an unconfirmed account signs in with the right password: that person is plainly
     * the owner and has lost the code, so a new one is on its way.
     *
     * @return whether a code is actually on its way, so the sign-in error can stop promising one
     */
    @Transactional
    public boolean resendForSignIn(User user) {
        return user.getStatus() == UserStatus.PENDING_VERIFICATION && sendCodeIfDue(user);
    }

    /**
     * Sends a code unless one went out less than a minute ago, and records it only once it has
     * gone.
     *
     * <p>That order matters: writing the new code first would retire the one already in somebody's
     * inbox in favour of one that never left, turning a mail outage into an account that cannot be
     * confirmed even after mail comes back.
     *
     * @return false only when nothing could be sent at all
     */
    private boolean sendCodeIfDue(User user) {
        if (secondsUntilResend(user) > 0) {
            return true;
        }
        String code = "%06d".formatted(RANDOM.nextInt(1_000_000));
        if (!emailService.sendVerificationCode(user.getEmail(), user.getFullName(), code)) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        user.setEmailVerificationCodeHash(hash(code));
        user.setEmailVerificationExpiresAt(now.plus(CODE_TTL));
        user.setEmailVerificationSentAt(now);
        user.setEmailVerificationAttempts(0);
        userRepository.save(user);
        return true;
    }

    private RegisterResponse pendingResponse(User user) {
        long expiresIn = user.getEmailVerificationExpiresAt() == null ? 0
                : Math.max(0, Duration.between(LocalDateTime.now(), user.getEmailVerificationExpiresAt()).toSeconds());
        return RegisterResponse.builder()
                .email(user.getEmail())
                .resendAvailableInSeconds(secondsUntilResend(user))
                .codeExpiresInSeconds(expiresIn)
                .build();
    }

    private long secondsUntilResend(User user) {
        if (user.getEmailVerificationSentAt() == null) {
            return 0;
        }
        LocalDateTime next = user.getEmailVerificationSentAt().plus(RESEND_COOLDOWN);
        return Math.max(0, Duration.between(LocalDateTime.now(), next).toSeconds());
    }

    private static boolean matches(String code, String expectedHash) {
        if (code == null || expectedHash == null) {
            return false;
        }
        return MessageDigest.isEqual(
                hash(code.trim()).getBytes(StandardCharsets.UTF_8),
                expectedHash.getBytes(StandardCharsets.UTF_8));
    }

    private static String hash(String code) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(code.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 is not available", e);
        }
    }

    private static BusinessException invalidCode() {
        return new BusinessException(HttpStatus.BAD_REQUEST, "CODE_INVALID", "The code is incorrect");
    }

    /**
     * The host cannot mail anything right now. A 503 and not a 500: nothing is broken in the
     * request, and it is worth repeating once the deployment can send again.
     */
    private static BusinessException cannotSendCode() {
        return new BusinessException(HttpStatus.SERVICE_UNAVAILABLE, "CODE_NOT_SENT",
                "We could not send your code. Please try again in a few minutes.");
    }

    private static BusinessException attemptsExceeded() {
        return new BusinessException(HttpStatus.TOO_MANY_REQUESTS, "CODE_ATTEMPTS_EXCEEDED",
                "Too many wrong codes. Ask for a new one.");
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
