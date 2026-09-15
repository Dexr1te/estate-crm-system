package com.crm.realestate.integration;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

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

    @Autowired
    private TeamRepository teamRepository;

    private Team team;

    @BeforeEach
    public void setUp() {
        userRepository.deleteAll();
        teamRepository.deleteAll();
        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
    }

    private User save(String email, Role role, boolean active, Team team) {
        return userRepository.save(User.builder()
                .email(email)
                .password("secret")
                .fullName(email)
                .role(role)
                .dataScope(DataScope.OWN)
                .team(team)
                .status(UserStatus.ACTIVE)
                .isActive(active)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    @Test
    @DisplayName("managers run viewings too, so they are assignable")
    public void includesEveryoneWhoCanHoldWork() {
        save("agent@example.com", Role.AGENT, true, team);
        User manager = save("manager@example.com", Role.MANAGER, true, team);
        save("admin@example.com", Role.ADMIN, true, null);

        signIn(manager);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactlyInAnyOrder("agent@example.com", "manager@example.com");
    }

    @Test
    @DisplayName("an admin-only workspace can still schedule something")
    public void isNeverEmptyJustBecauseNobodyHasTheAgentRole() {
        User owner = save("owner@example.com", Role.ADMIN, true, null);

        signIn(owner);

        assertThat(userService.getAgentOptions())
                .as("an empty list here is a meeting form that cannot be submitted")
                .hasSize(1);
    }

    @Test
    @DisplayName("someone deactivated is not assignable")
    public void leavesOutDeactivatedAccounts() {
        User active = save("active@example.com", Role.AGENT, true, team);
        save("gone@example.com", Role.AGENT, false, team);

        signIn(active);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactly("active@example.com");
    }

    @Test
    @DisplayName("nobody from another agency is offered")
    public void staysInsideTheCallersTeam() {
        User mine = save("mine@example.com", Role.AGENT, true, team);
        Team other = teamRepository.save(Team.builder().name("Astana Homes").build());
        save("theirs@example.com", Role.AGENT, true, other);

        signIn(mine);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactly("mine@example.com");
    }

    @Test
    @DisplayName("someone in no team can only assign themselves")
    public void offersOnlyYourselfOutsideATeam() {
        User loner = save("loner@example.com", Role.AGENT, true, null);
        save("colleague@example.com", Role.AGENT, true, team);

        signIn(loner);

        assertThat(userService.getAgentOptions())
                .extracting(o -> o.getFullName())
                .containsExactly("loner@example.com");
    }
}
