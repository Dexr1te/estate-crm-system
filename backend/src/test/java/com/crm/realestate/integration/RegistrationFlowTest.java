package com.crm.realestate.integration;

import com.crm.realestate.dto.request.LoginRequest;
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
import com.crm.realestate.service.AuthService;
import com.crm.realestate.service.EmailService;
import com.crm.realestate.service.RegistrationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.AccountStatusException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;

/**
 * Signing up without an invite.
 *
 * <p>The account is worthless until the address is proven, because the address is what a manager
 * later adds to their team — so the code, its expiry and the guess limit are the whole point of
 * these tests. Mail is mocked to read the code that was actually sent.
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

    /** The code that actually left the building. */
    private String mailedCode() {
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        verify(emailService, atLeastOnce()).sendVerificationCode(eq(EMAIL), any(), code.capture());
        return code.getValue();
    }

    private User stored() {
        return userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow();
    }

    private AuthResponse submitCode(String code) {
        VerifyEmailRequest request = new VerifyEmailRequest();
        request.setEmail(EMAIL);
        request.setCode(code);
        return registrationService.verifyEmail(request);
    }

    @Test
    @DisplayName("signing up creates an account that cannot be used yet")
    void registerLeavesTheAccountPending() {
        RegisterResponse response = registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThat(response.getEmail()).isEqualTo(EMAIL);
        assertThat(response.getResendAvailableInSeconds()).isPositive();

        User user = stored();
        assertThat(user.getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
        assertThat(user.isEnabled()).as("an unconfirmed account must not be able to sign in").isFalse();
        assertThat(user.getTeam()).isNull();
        assertThat(user.getDataScope())
                .as("a manager runs the whole agency")
                .isEqualTo(DataScope.TEAM);
        assertThat(user.getEmailVerificationCodeHash())
                .as("the code is stored hashed, never in the clear")
                .isNotBlank()
                .isNotEqualTo(mailedCode());
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
    @DisplayName("the right code confirms the address and signs the account in")
    void verifyingSignsIn() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        AuthResponse auth = submitCode(mailedCode());

        assertThat(auth.getAccessToken()).isNotBlank();
        assertThat(auth.getRefreshToken()).isNotBlank();
        assertThat(auth.getRole()).isEqualTo(Role.MANAGER);
        assertThat(auth.getTeamId()).as("a fresh manager has no agency yet").isNull();
        User user = stored();
        assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
        assertThat(user.getEmailVerificationCodeHash()).isNull();
    }

    @Test
    @DisplayName("signing in before confirming says so, and sends the code again")
    void signingInUnconfirmedAsksForTheCode() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        LoginRequest login = new LoginRequest();
        login.setEmail(EMAIL);
        login.setPassword(PASSWORD);

        assertThatThrownBy(() -> authService.login(login))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("EMAIL_NOT_VERIFIED");
    }

    @Test
    @DisplayName("a stranger guessing the password is told nothing about the account")
    void wrongPasswordDoesNotRevealAPendingAccount() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        LoginRequest login = new LoginRequest();
        login.setEmail(EMAIL);
        login.setPassword("not the password");

        assertThatThrownBy(() -> authService.login(login))
                .as("EMAIL_NOT_VERIFIED here would confirm that this address has signed up")
                .isInstanceOf(AccountStatusException.class);
    }

    @Test
    @DisplayName("an expired code is refused as expired, not as wrong")
    void expiredCodeIsRefused() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        String code = mailedCode();
        User user = stored();
        user.setEmailVerificationExpiresAt(LocalDateTime.now().minusMinutes(1));
        userRepository.save(user);

        assertThatThrownBy(() -> submitCode(code))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("CODE_EXPIRED");
    }

    @Test
    @DisplayName("six digits survive only five guesses, and a new code clears the slate")
    void guessesAreLimited() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        String realCode = mailedCode();

        for (int i = 0; i < RegistrationService.MAX_ATTEMPTS; i++) {
            assertThatThrownBy(() -> submitCode("000000"))
                    .isInstanceOf(BusinessException.class);
        }
        assertThat(stored().getEmailVerificationAttempts())
                .as("the count has to survive the failed request, or the limit is no limit")
                .isEqualTo(RegistrationService.MAX_ATTEMPTS);
        assertThatThrownBy(() -> submitCode(realCode))
                .as("even the right code is refused once the tries are used up")
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("CODE_ATTEMPTS_EXCEEDED");

        // Asking for a new code is the way back, once the minute's cooldown has passed.
        User user = stored();
        user.setEmailVerificationSentAt(LocalDateTime.now().minusMinutes(2));
        userRepository.save(user);
        registrationService.resendCode(EMAIL);

        assertThat(stored().getEmailVerificationAttempts()).isZero();
        assertThat(submitCode(mailedCode()).getAccessToken()).isNotBlank();
    }

    @Test
    @DisplayName("a code just sent is not sent again a second later")
    void resendIsRateLimited() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        verify(emailService).sendVerificationCode(eq(EMAIL), any(), any());

        RegisterResponse response = registrationService.resendCode(EMAIL);

        assertThat(response.getResendAvailableInSeconds()).isPositive();
        verifyNoMoreInteractions(emailService);
    }

    @Test
    @DisplayName("an address nobody has registered is answered the same way")
    void resendSaysNothingAboutWhoExists() {
        RegisterResponse response = registrationService.resendCode("nobody@nowhere.kz");

        assertThat(response.getEmail()).isEqualTo("nobody@nowhere.kz");
        assertThat(response.getResendAvailableInSeconds()).isPositive();
    }

    @Test
    @DisplayName("signing up again over an unconfirmed account replaces it")
    void registeringTwiceBeforeConfirmingIsAllowed() {
        registrationService.register(request(EMAIL, Role.MANAGER, "first attempt"));

        registrationService.register(request(EMAIL, Role.AGENT, PASSWORD));

        User user = stored();
        assertThat(userRepository.count()).isEqualTo(1);
        assertThat(user.getRole()).isEqualTo(Role.AGENT);
        assertThat(passwordEncoder.matches(PASSWORD, user.getPassword()))
                .as("someone who mistyped their password must not be locked out of their own address")
                .isTrue();
    }

    @Test
    @DisplayName("a confirmed address cannot be signed up for twice")
    void confirmedEmailIsTaken() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        submitCode(mailedCode());

        assertThatThrownBy(() -> registrationService.register(request(EMAIL.toUpperCase(), Role.AGENT, PASSWORD)))
                .as("case is not a second account")
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("EMAIL_TAKEN");
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
