package com.crm.realestate.integration;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.request.VerifyEmailRequest;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AuthService;
import com.crm.realestate.service.EmailService;
import com.crm.realestate.service.RegistrationService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * What sign-up does on a host that cannot send the code.
 *
 * <p>It used to answer 201 and create the account anyway, which left the address taken by a row
 * nobody could confirm: the owner could not sign in, could not verify, and could not tell the
 * difference between a slow inbox and a host with no SMTP configured at all.
 *
 * <p>Deliberately not {@code @Transactional}, unlike its neighbours: what is under test is that
 * the account is rolled back, and a test that shares its transaction with the service would see
 * the row it is supposed to prove is gone.
 */
@SpringBootTest
class SignUpWithoutMailTest {

    private static final String EMAIL = "boss@almaty.kz";
    private static final String PASSWORD = "correct horse";

    @Autowired private RegistrationService registrationService;
    @Autowired private AuthService authService;
    @Autowired private UserRepository userRepository;

    @MockBean private EmailService emailService;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @AfterEach
    void tearDown() {
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("an account is not created when its code could not be sent")
    void noAccountSurvivesAFailedSend() {
        when(emailService.sendVerificationCode(any(), any(), any())).thenReturn(false);

        assertThatThrownBy(() -> registrationService.register(request()))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("status", HttpStatus.SERVICE_UNAVAILABLE)
                .hasFieldOrPropertyWithValue("code", "CODE_NOT_SENT");

        assertThat(userRepository.findFirstByEmailIgnoreCase(EMAIL))
                .withFailMessage("the address must be free to try again with, not held by an "
                        + "account whose code never left")
                .isEmpty();
    }

    @Test
    @DisplayName("a failed resend leaves the code already in somebody's inbox working")
    void aFailedResendDoesNotRetireTheLiveCode() {
        when(emailService.sendVerificationCode(any(), any(), any())).thenReturn(true);
        registrationService.register(request());
        String mailed = mailedCode();
        allowAnotherSend();

        when(emailService.sendVerificationCode(any(), any(), any())).thenReturn(false);
        assertThatThrownBy(() -> registrationService.resendCode(EMAIL))
                .isInstanceOf(BusinessException.class);

        // The first code still works: replacing it with one that never left would have made the
        // account unconfirmable even after mail came back.
        VerifyEmailRequest verify = new VerifyEmailRequest();
        verify.setEmail(EMAIL);
        verify.setCode(mailed);
        assertThat(registrationService.verifyEmail(verify).getAccessToken()).isNotBlank();
    }

    @Test
    @DisplayName("signing in stops promising a code that cannot be sent")
    void signInSaysWhatItCanActuallyDo() {
        when(emailService.sendVerificationCode(any(), any(), any())).thenReturn(true);
        registrationService.register(request());
        allowAnotherSend();

        when(emailService.sendVerificationCode(any(), any(), any())).thenReturn(false);
        LoginRequest login = new LoginRequest();
        login.setEmail(EMAIL);
        login.setPassword(PASSWORD);

        assertThatThrownBy(() -> authService.login(login))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("code", "EMAIL_NOT_VERIFIED")
                .hasMessageContaining("could not send");
    }

    /** Moves the last send out of the one-minute cooldown, so the next one is really attempted. */
    private void allowAnotherSend() {
        User user = userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow();
        user.setEmailVerificationSentAt(LocalDateTime.now().minusMinutes(2));
        userRepository.save(user);
    }

    private String mailedCode() {
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        verify(emailService, atLeastOnce()).sendVerificationCode(any(), any(), code.capture());
        return code.getValue();
    }

    private RegisterRequest request() {
        RegisterRequest request = new RegisterRequest();
        request.setFullName("Aigerim Serikbaykyzy");
        request.setEmail(EMAIL);
        request.setPassword(PASSWORD);
        request.setRole(Role.MANAGER);
        return request;
    }
}
