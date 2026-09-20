package com.crm.realestate.integration;

import com.crm.realestate.config.AdminAccountBootstrap;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The administrator, now that the migrations no longer carry one.
 *
 * <p>V8, V11 and V12 each seeded an ADMIN whose password was written in the migration, so the
 * password to every deployment of this repository was published with it — on the one account whose
 * data scope is every agency at once. V18 takes those passwords away, and this is what puts an
 * administrator back: a password from the environment, on a host that has one.
 */
@SpringBootTest
@Transactional
class AdminBootstrapTest {

    private static final String EMAIL = "admin@gmail.com";
    private static final String PASSWORD = "a password from the environment";

    @Autowired private UserRepository  userRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    private AdminAccountBootstrap bootstrap;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        bootstrap = new AdminAccountBootstrap(userRepository, passwordEncoder);
        configure(PASSWORD);
    }

    private void configure(String password) {
        ReflectionTestUtils.setField(bootstrap, "adminEmail", EMAIL);
        ReflectionTestUtils.setField(bootstrap, "adminPassword", password);
        ReflectionTestUtils.setField(bootstrap, "adminName", "Admin");
    }

    @Test
    @DisplayName("a configured password creates the administrator")
    void createsTheAdministrator() {
        bootstrap.run(null);

        User admin = userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow();
        assertThat(admin.getRole()).isEqualTo(Role.ADMIN);
        assertThat(admin.getDataScope()).isEqualTo(DataScope.ALL);
        assertThat(admin.isEnabled()).isTrue();
        assertThat(passwordEncoder.matches(PASSWORD, admin.getPassword())).isTrue();
    }

    @Test
    @DisplayName("it repairs the account V18 left without a password")
    void repairsTheRetiredSeedAccount() {
        // What V18 leaves behind: the row, minus the password that was published with it.
        userRepository.save(User.builder()
                .email(EMAIL)
                .fullName("Admin")
                .password(null)
                .role(Role.ADMIN)
                .dataScope(DataScope.ALL)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .mustChangePassword(true)
                .build());

        bootstrap.run(null);

        User admin = userRepository.findFirstByEmailIgnoreCase(EMAIL).orElseThrow();
        assertThat(passwordEncoder.matches(PASSWORD, admin.getPassword())).isTrue();
        assertThat(admin.isMustChangePassword()).isFalse();
        assertThat(userRepository.findAll()).hasSize(1);
    }

    @Test
    @DisplayName("no password means no account — never a guessable one")
    void withoutAPasswordItCreatesNothing() {
        configure("");

        bootstrap.run(null);

        assertThat(userRepository.findAll())
                .withFailMessage("an administrator created without a configured password would "
                        + "have to carry a default one, which is the whole problem")
                .isEmpty();
    }
}
