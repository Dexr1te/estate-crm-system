package com.crm.realestate.service;

import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.response.AuthResponse;
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

/**
 * Opening an account without being invited.
 *
 * <p>A manager signs up to start an agency, an agent signs up to be added to one. The account is
 * signed in straight away: there is no code to confirm the address with, because the host cannot
 * be relied on to send one.
 */
@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final UserRepository       userRepository;
    private final PasswordEncoder      passwordEncoder;
    private final EmailDomainValidator emailDomainValidator;
    private final AuthResponseFactory  authResponseFactory;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (request.getRole() != Role.MANAGER && request.getRole() != Role.AGENT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "ROLE_NOT_ALLOWED",
                    "Sign up as a manager or as an agent");
        }
        String email = request.getEmail().trim();

        User existing = userRepository.findFirstByEmailIgnoreCase(email).orElse(null);
        if (existing != null && existing.getStatus() == UserStatus.PENDING_INVITE) {
            throw new BusinessException(HttpStatus.CONFLICT, "INVITE_PENDING",
                    "This email already has an invite waiting. Use the link in that email to set your password.");
        }
        if (existing != null) {
            throw new BusinessException(HttpStatus.CONFLICT, "EMAIL_TAKEN",
                    "An account with this email already exists");
        }
        // Still worth asking with nothing to confirm: a mistyped domain is an account whose
        // owner can never be invited, reset a password or be found by their manager.
        if (!emailDomainValidator.acceptsMail(email)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EMAIL_UNDELIVERABLE",
                    "That email domain cannot receive mail: " + email);
        }

        User user = User.builder()
                .email(email)
                .fullName(request.getFullName().trim())
                .phone(blankToNull(request.getPhone()))
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                // A manager runs the whole agency; an agent starts on their own work.
                .dataScope(request.getRole() == Role.MANAGER ? DataScope.TEAM : DataScope.OWN)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .mustChangePassword(false)
                .build();
        return authResponseFactory.withNewTokens(userRepository.save(user));
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
