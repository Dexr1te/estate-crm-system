package com.crm.realestate.integration;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AuthService;
import com.crm.realestate.service.EmailService;
import com.crm.realestate.service.RegistrationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verifyNoInteractions;

/**
 * Signing up without an invite.
 *
 * <p>There is no code to confirm the address with: the account is signed in the moment it is
 * created. Mail is mocked to prove sign-up does not depend on it.
 */
@SpringBootTest
@Transactional
class RegistrationFlowTest {

    private static final String EMAIL = "boss@almaty.kz";
    private static final String PASSWORD = "correct horse";

    @Autowired private RegistrationService registrationService;
    @Autowired private AuthService authService;
    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    @MockBean private EmailService emailService;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    private RegisterRequest request(String email, Role role, String password) {
        RegisterRequest request = new RegisterRequest();
        request.setFullName("Aigerim Serikbaykyzy");
        request.setEmail(email);
        request.setPassword(password);
        request.setRole(role);
        return request;
    }

    private User stored() {
        return userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow();
    }

    @Test
    @DisplayName("signing up signs the new account straight in")
    void registerSignsIn() {
        AuthResponse auth = registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThat(auth.getAccessToken()).isNotBlank();
        assertThat(auth.getRefreshToken()).isNotBlank();
        assertThat(auth.getRole()).isEqualTo(Role.MANAGER);
        assertThat(auth.getTeamId()).as("a fresh manager has no agency yet").isNull();

        User user = stored();
        assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
        assertThat(user.isEnabled()).isTrue();
        assertThat(user.getDataScope())
                .as("a manager runs the whole agency")
                .isEqualTo(DataScope.TEAM);
        assertThat(passwordEncoder.matches(PASSWORD, user.getPassword())).isTrue();
    }

    @Test
    @DisplayName("signing up sends no mail, so it works on a host that cannot send any")
    void registerNeedsNoMail() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        verifyNoInteractions(emailService);
    }

    @Test
    @DisplayName("the new account signs in again with its password")
    void registeredAccountCanSignIn() {
        registrationService.register(request(EMAIL, Role.AGENT, PASSWORD));
        LoginRequest login = new LoginRequest();
        login.setEmail(EMAIL);
        login.setPassword(PASSWORD);

        assertThat(authService.login(login).getAccessToken()).isNotBlank();
    }

    @Test
    @DisplayName("an agent signs up on their own data")
    void agentsStartOnTheirOwnRecords() {
        registrationService.register(request(EMAIL, Role.AGENT, PASSWORD));

        assertThat(stored().getDataScope()).isEqualTo(DataScope.OWN);
    }

    @Test
    @DisplayName("nobody signs up as an administrator")
    void adminCannotBeSignedUpFor() {
        assertThatThrownBy(() -> registrationService.register(request(EMAIL, Role.ADMIN, PASSWORD)))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("ROLE_NOT_ALLOWED");
    }

    @Test
    @DisplayName("an address cannot be signed up for twice")
    void emailIsTaken() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThatThrownBy(() -> registrationService.register(request(EMAIL.toUpperCase(), Role.AGENT, PASSWORD)))
                .as("case is not a second account")
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("EMAIL_TAKEN");
        assertThat(userRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("an address with an invite waiting is pointed at the invite")
    void pendingInviteIsNotOverwritten() {
        userRepository.save(User.builder()
                .email(EMAIL).fullName("Invited").role(Role.AGENT)
                .status(UserStatus.PENDING_INVITE).isActive(true)
                .inviteToken("token").inviteTokenExpiresAt(LocalDateTime.now().plusHours(1))
                .build());

        assertThatThrownBy(() -> registrationService.register(request(EMAIL, Role.AGENT, PASSWORD)))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("INVITE_PENDING");
    }
}
