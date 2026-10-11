package com.crm.realestate.service;

import com.crm.realestate.dto.request.RegisterRequest;
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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Opening an account without being invited.
 *
 * <p>A manager signs up to start an agency, an agent signs up to be added to one. Either way the
 * account does nothing until its owner opens the link Firebase emails them: without that, anyone
 * could register someone else's address and be the one a manager adds to their team. See
 * {@link FirebaseIdentityService} for why Firebase sends it.
 */
@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final UserRepository          userRepository;
    private final PasswordEncoder         passwordEncoder;
    private final EmailDomainValidator    emailDomainValidator;
    private final AuthResponseFactory     authResponseFactory;
    private final FirebaseIdentityService firebaseIdentity;

    /**
     * Off only as an escape hatch, for when Firebase cannot be reached at all: new accounts are
     * then signed in straight away, with nothing proving the address.
     */
    @Value("${app.signup.verify-email:true}")
    private boolean verifyEmail;

    /**
     * Creates the account, or refreshes one that was never confirmed.
     *
     * <p>Signing up again over an unconfirmed account replaces it rather than refusing: someone who
     * mistyped their password, or lost the email, would otherwise be locked out of their own
     * address for good. Nothing is lost, because nothing could have been done with it yet.
     *
     * <p>A Firebase failure rolls the account back with it, so the address stays free to try again.
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
        user.setStatus(verifyEmail ? UserStatus.PENDING_VERIFICATION : UserStatus.ACTIVE);
        user.setActive(true);
        user.setMustChangePassword(false);

        if (!verifyEmail) {
            return RegisterResponse.builder()
                    .email(user.getEmail())
                    .auth(authResponseFactory.withNewTokens(userRepository.save(user)))
                    .build();
        }
        user.setFirebaseUid(firebaseIdentity.prepare(email, user.getFullName(), true));
        return pending(userRepository.save(user));
    }

    /**
     * Hands out a fresh token for an account still waiting on its link — after a sign-in, or once
     * the first token has expired. Answers a wrong password exactly as a failed sign-in does.
     */
    @Transactional
    public RegisterResponse resumeVerification(String email, String password) {
        User user = userRepository.findFirstByEmailIgnoreCase(email.trim())
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFICATION)
                .filter(u -> u.getPassword() != null && passwordEncoder.matches(password, u.getPassword()))
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));
        // Looked up again rather than trusted: the Firebase user may have been deleted since.
        user.setFirebaseUid(firebaseIdentity.prepare(user.getEmail(), user.getFullName(), false));
        return pending(userRepository.save(user));
    }

    /** Signs the account in once Firebase says its link has been opened. */
    @Transactional
    public AuthResponse verifyEmail(String idToken) {
        FirebaseIdentityService.Identity identity = firebaseIdentity.identify(idToken);
        User user = userRepository.findByFirebaseUid(identity.uid())
                .filter(u -> u.getStatus() == UserStatus.PENDING_VERIFICATION)
                // The app is signed in to this Firebase user and could change its address to one
                // it controls; only the address that signed up counts.
                .filter(u -> u.getEmail().equalsIgnoreCase(identity.email()))
                .orElseThrow(FirebaseIdentityService::invalid);
        if (!identity.emailVerified()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EMAIL_NOT_CONFIRMED",
                    "Open the link we emailed you first, then try again.");
        }
        user.setStatus(UserStatus.ACTIVE);
        return authResponseFactory.withNewTokens(userRepository.save(user));
    }

    private RegisterResponse pending(User user) {
        return RegisterResponse.builder()
                .email(user.getEmail())
                .verificationRequired(true)
                .firebaseToken(firebaseIdentity.customToken(user.getFirebaseUid()))
                .build();
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
