package com.crm.realestate.integration;

import com.crm.realestate.dto.request.LoginRequest;
import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.dto.response.RegisterResponse;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AuthService;
import com.crm.realestate.service.FirebaseIdentityService;
import com.crm.realestate.service.FirebaseIdentityService.Identity;
import com.crm.realestate.service.RegistrationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.AccountStatusException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Signing up without an invite.
 *
 * <p>The account is worthless until the address is proven, because the address is what a manager
 * later adds to their team. Firebase emails the link and reports whether it was opened; it is
 * mocked here, and what is under test is what this backend does with its answers.
 */
@SpringBootTest
@Transactional
class RegistrationFlowTest {

    private static final String EMAIL = "boss@almaty.kz";
    private static final String PASSWORD = "correct horse";
    private static final String UID = "firebase-uid-1";
    private static final String ID_TOKEN = "id-token";

    @Autowired private RegistrationService registrationService;
    @Autowired private AuthService authService;
    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    @MockBean private FirebaseIdentityService firebaseIdentity;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        when(firebaseIdentity.prepare(anyString(), any(), anyBoolean())).thenReturn(UID);
        when(firebaseIdentity.customToken(UID)).thenReturn("custom-token");
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

    /** What Firebase says about the user behind {@link #ID_TOKEN}. */
    private void firebaseSays(String uid, String email, boolean verified) {
        when(firebaseIdentity.identify(ID_TOKEN)).thenReturn(new Identity(uid, email, verified));
    }

    private LoginRequest login(String password) {
        LoginRequest login = new LoginRequest();
        login.setEmail(EMAIL);
        login.setPassword(password);
        return login;
    }

    @Test
    @DisplayName("signing up creates an account that cannot be used yet, and a token to get the link with")
    void registerLeavesTheAccountPending() {
        RegisterResponse response = registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThat(response.isVerificationRequired()).isTrue();
        assertThat(response.getFirebaseToken()).isEqualTo("custom-token");
        assertThat(response.getAuth()).as("no session before the address is proven").isNull();

        User user = stored();
        assertThat(user.getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
        assertThat(user.isEnabled()).as("an unconfirmed account must not be able to sign in").isFalse();
        assertThat(user.getFirebaseUid()).isEqualTo(UID);
        assertThat(user.getDataScope()).as("a manager runs the whole agency").isEqualTo(DataScope.TEAM);
        verify(firebaseIdentity).prepare(EMAIL, "Aigerim Serikbaykyzy", true);
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
    @DisplayName("once the link has been opened, the account is confirmed and signed in")
    void openingTheLinkSignsIn() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        firebaseSays(UID, EMAIL, true);

        AuthResponse auth = registrationService.verifyEmail(ID_TOKEN);

        assertThat(auth.getAccessToken()).isNotBlank();
        assertThat(auth.getRefreshToken()).isNotBlank();
        assertThat(auth.getRole()).isEqualTo(Role.MANAGER);
        assertThat(auth.getTeamId()).as("a fresh manager has no agency yet").isNull();
        assertThat(stored().getStatus()).isEqualTo(UserStatus.ACTIVE);
    }

    @Test
    @DisplayName("before the link is opened, confirming is refused and the account stays pending")
    void confirmingTooEarlyIsRefused() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        firebaseSays(UID, EMAIL, false);

        assertThatThrownBy(() -> registrationService.verifyEmail(ID_TOKEN))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("EMAIL_NOT_CONFIRMED");
        assertThat(stored().getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
    }

    @Test
    @DisplayName("a Firebase user moved to another address does not confirm the one that signed up")
    void anotherAddressDoesNotCount() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        // The app is signed in to this Firebase user, so it could verify an inbox it controls.
        firebaseSays(UID, "someone.else@almaty.kz", true);

        assertThatThrownBy(() -> registrationService.verifyEmail(ID_TOKEN))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("VERIFICATION_INVALID");
        assertThat(stored().getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
    }

    @Test
    @DisplayName("a Firebase user no account points at confirms nothing")
    void unknownFirebaseUserIsInvalid() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));
        firebaseSays("someone-elses-uid", EMAIL, true);

        assertThatThrownBy(() -> registrationService.verifyEmail(ID_TOKEN))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("VERIFICATION_INVALID");
    }

    @Test
    @DisplayName("signing in before confirming says so, so the app can ask for a new link")
    void signingInUnconfirmedAsksForTheLink() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThatThrownBy(() -> authService.login(login(PASSWORD)))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("EMAIL_NOT_VERIFIED");
    }

    @Test
    @DisplayName("a stranger guessing the password is told nothing about the account")
    void wrongPasswordDoesNotRevealAPendingAccount() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        assertThatThrownBy(() -> authService.login(login("not the password")))
                .as("EMAIL_NOT_VERIFIED here would confirm that this address has signed up")
                .isInstanceOf(AccountStatusException.class);
    }

    @Test
    @DisplayName("a new link needs the password, and does not throw away a click already made")
    void resumingNeedsThePassword() {
        registrationService.register(request(EMAIL, Role.MANAGER, PASSWORD));

        RegisterResponse response = registrationService.resumeVerification(EMAIL, PASSWORD);

        assertThat(response.getFirebaseToken()).isEqualTo("custom-token");
        verify(firebaseIdentity).prepare(eq(EMAIL), any(), eq(false));
        assertThatThrownBy(() -> registrationService.resumeVerification(EMAIL, "not the password"))
                .isInstanceOf(BadCredentialsException.class);
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
        firebaseSays(UID, EMAIL, true);
        registrationService.verifyEmail(ID_TOKEN);

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
