package com.crm.realestate.integration;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Who can be put on a deal or a meeting.
 *
 * <p>This list used to be Role.AGENT only, which meant a young agency whose only
 * accounts were an admin and a manager got an empty picker — and since the
 * meeting form requires someone to assign, no meeting could be created at all.
 */
@SpringBootTest
@Transactional
public class AgentOptionsTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    public void setUp() {
        userRepository.deleteAll();
    }

    private void save(String email, Role role, boolean active) {
        userRepository.save(User.builder()
                .email(email)
                .password("secret")
                .fullName(email)
                .role(role)
                .dataScope(DataScope.OWN)
                .status(UserStatus.ACTIVE)
                .isActive(active)
                .build());
    }

    @Test
    @DisplayName("managers and admins run viewings too, so they are assignable")
    public void includesEveryoneWhoCanHoldWork() {
        save("agent@example.com", Role.AGENT, true);
        save("manager@example.com", Role.MANAGER, true);
        save("admin@example.com", Role.ADMIN, true);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactlyInAnyOrder(
                        "agent@example.com", "manager@example.com", "admin@example.com");
    }

    @Test
    @DisplayName("an admin-only workspace can still schedule something")
    public void isNeverEmptyJustBecauseNobodyHasTheAgentRole() {
        save("owner@example.com", Role.ADMIN, true);

        assertThat(userService.getAgentOptions())
                .as("an empty list here is a meeting form that cannot be submitted")
                .hasSize(1);
    }

    @Test
    @DisplayName("someone deactivated is not assignable")
    public void leavesOutDeactivatedAccounts() {
        save("active@example.com", Role.AGENT, true);
        save("gone@example.com", Role.AGENT, false);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactly("active@example.com");
    }
}
