package com.crm.realestate.integration;

import com.crm.realestate.dto.request.RegisterRequest;
import com.crm.realestate.dto.response.RegisterResponse;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.FirebaseIdentityService;
import com.crm.realestate.service.RegistrationService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * What sign-up does when Firebase is not there to prove the address.
 *
 * <p>Deliberately not {@code @Transactional}, unlike its neighbours: what is under test is that
 * the account is rolled back, and a test that shares its transaction with the service would see
 * the row it is supposed to prove is gone.
 */
class SignUpWithoutFirebaseTest {

    private static final String EMAIL = "boss@almaty.kz";

    private static RegisterRequest request() {
        RegisterRequest request = new RegisterRequest();
        request.setFullName("Aigerim Serikbaykyzy");
        request.setEmail(EMAIL);
        request.setPassword("correct horse");
        request.setRole(Role.MANAGER);
        return request;
    }

    @Nested
    @SpringBootTest
    class WhenFirebaseFails {

        @Autowired private RegistrationService registrationService;
        @Autowired private UserRepository userRepository;

        @MockBean private FirebaseIdentityService firebaseIdentity;

        @BeforeEach
        @AfterEach
        void clean() {
            userRepository.deleteAll();
        }

        @Test
        @DisplayName("an account is not created when Firebase cannot hand out its token")
        void noAccountSurvivesAFailedToken() {
            when(firebaseIdentity.prepare(anyString(), any(), anyBoolean())).thenReturn("uid");
            when(firebaseIdentity.customToken("uid")).thenThrow(new BusinessException(
                    HttpStatus.SERVICE_UNAVAILABLE, "VERIFICATION_UNAVAILABLE", "down"));

            assertThatThrownBy(() -> registrationService.register(request()))
                    .isInstanceOf(BusinessException.class)
                    .hasFieldOrPropertyWithValue("code", "VERIFICATION_UNAVAILABLE");

            assertThat(userRepository.findFirstByEmailIgnoreCase(EMAIL))
                    .withFailMessage("the address must be free to try again with, not held by an "
                            + "account that can never be confirmed")
                    .isEmpty();
        }
    }

    @Nested
    @SpringBootTest(properties = "app.signup.verify-email=false")
    class WhenVerificationIsSwitchedOff {

        @Autowired private RegistrationService registrationService;
        @Autowired private UserRepository userRepository;

        @MockBean private FirebaseIdentityService firebaseIdentity;

        @BeforeEach
        @AfterEach
        void clean() {
            userRepository.deleteAll();
        }

        @Test
        @DisplayName("the escape hatch signs the account straight in, without Firebase")
        void signsInWithoutFirebase() {
            RegisterResponse response = registrationService.register(request());

            assertThat(response.isVerificationRequired()).isFalse();
            assertThat(response.getFirebaseToken()).isNull();
            assertThat(response.getAuth().getAccessToken()).isNotBlank();
            assertThat(userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow().getStatus())
                    .isEqualTo(UserStatus.ACTIVE);
            verifyNoInteractions(firebaseIdentity);
        }
    }
}
