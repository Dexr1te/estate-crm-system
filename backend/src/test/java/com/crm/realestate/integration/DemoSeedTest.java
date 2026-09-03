package com.crm.realestate.integration;

import com.crm.realestate.config.DemoDataSeeder;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.DocumentStorage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The account App Review signs in with.
 *
 * <p>The seeder is built by hand here rather than switched on with {@code app.demo.enabled}: it is
 * an {@code ApplicationRunner}, so enabling it would fire it once at context startup, into an
 * in-memory database this class shares with every other test in the run.
 *
 * <p>What is worth testing is not the wording of the fake clients. It is that a reviewer can sign
 * in, that they see demo records rather than the agency's, that they can delete the account when
 * they try it — Guideline 5.1.1(v) is checked by hand and a blocked deletion reads as a missing
 * feature — and that running the seeder again after that does not collide with what it left behind.
 */
@SpringBootTest
@Transactional
public class DemoSeedTest {

    private static final String REVIEWER = "reviewer@demo.estatecrm.app";
    private static final String PASSWORD = "review-me-please";

    @Autowired private UserRepository     userRepository;
    @Autowired private ClientRepository   clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private DealRepository     dealRepository;
    @Autowired private MeetingRepository  meetingRepository;
    @Autowired private DocumentRepository documentRepository;
    @Autowired private DocumentStorage    documentStorage;
    @Autowired private PasswordEncoder    passwordEncoder;
    @Autowired private AccountRemovalService accountRemovalService;

    private DemoDataSeeder seeder;

    @BeforeEach
    public void setUp() {
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();

        seeder = new DemoDataSeeder(userRepository, clientRepository, propertyRepository,
                dealRepository, meetingRepository, documentRepository, documentStorage,
                passwordEncoder);
        configure(PASSWORD);
    }

    private void configure(String password) {
        ReflectionTestUtils.setField(seeder, "reviewerEmail", REVIEWER);
        ReflectionTestUtils.setField(seeder, "reviewerPassword", password);
        ReflectionTestUtils.setField(seeder, "reviewerName", "App Review");
    }

    private User reviewer() {
        return userRepository.findByEmail(REVIEWER).orElseThrow();
    }

    @Test
    @DisplayName("the reviewer gets an account they can actually sign in with")
    public void createsASignInAbleAccount() {
        seeder.run(null);

        User reviewer = reviewer();
        assertThat(reviewer.getRole()).isEqualTo(Role.AGENT);
        assertThat(reviewer.getStatus()).isEqualTo(UserStatus.ACTIVE);
        assertThat(reviewer.isActive()).isTrue();
        assertThat(reviewer.isEnabled()).isTrue();
        // A forced password change would strand a reviewer holding one password.
        assertThat(reviewer.isMustChangePassword()).isFalse();
        assertThat(passwordEncoder.matches(PASSWORD, reviewer.getPassword())).isTrue();
    }

    @Test
    @DisplayName("every screen has something on it, and none of it is the agency's")
    public void seedsRecordsOwnedByTheReviewer() {
        User realAgent = userRepository.save(User.builder()
                .email("agent@agency.example").password("x").fullName("Real Agent")
                .role(Role.AGENT).dataScope(DataScope.OWN)
                .status(UserStatus.ACTIVE).isActive(true).build());

        seeder.run(null);
        Long reviewerId = reviewer().getId();

        assertThat(clientRepository.findByAgentId(reviewerId)).hasSize(6);
        assertThat(propertyRepository.findByAgentId(reviewerId)).hasSize(5);
        assertThat(meetingRepository.findByAgentId(reviewerId)).hasSize(4);

        // Own-data scope means the reviewer sees exactly these and nothing of the agency's.
        assertThat(clientRepository.findByAgentId(realAgent.getId())).isEmpty();
        assertThat(reviewer().getDataScope()).isEqualTo(DataScope.OWN);

        // One deal per column, or the pipeline board has an empty lane to explain.
        assertThat(dealRepository.findByAgentId(reviewerId))
                .extracting(d -> d.getStatus())
                .contains(DealStatus.LEAD, DealStatus.NEGOTIATION,
                        DealStatus.CLOSED_WON, DealStatus.CLOSED_LOST);

        // Two of the four meetings are ahead of now, so the dashboard counter is not a zero.
        assertThat(meetingRepository.countByAgentIdInAndScheduledAtAfter(
                List.of(reviewerId), java.time.LocalDateTime.now())).isEqualTo(2);
    }

    @Test
    @DisplayName("the reviewer can delete the account, which is the thing Apple checks by hand")
    public void theAccountCanBeDeleted() {
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@example.com");
        seeder.run(null);

        User reviewer = reviewer();
        // The successor the seeder plants, so the records do not land on a real employee.
        User handover = userRepository.findByEmail("handover@demo.estatecrm.app").orElseThrow();

        accountRemovalService.removeOwnAccount(reviewer, handover.getId());

        assertThat(userRepository.findByEmail(REVIEWER)).isEmpty();
        assertThat(dealRepository.findByAgentId(handover.getId())).hasSize(5);
    }

    @Test
    @DisplayName("re-seeding after a review clears the last run instead of colliding on it")
    public void reSeedingClearsWhatTheLastRunLeft() {
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@example.com");
        seeder.run(null);
        User handover = userRepository.findByEmail("handover@demo.estatecrm.app").orElseThrow();
        accountRemovalService.removeOwnAccount(reviewer(), handover.getId());

        // The old records are still there, owned by the successor. Client email is unique, so a
        // seeder that only ever added would fail here.
        seeder.run(null);

        List<Client> demoClients =
                clientRepository.findByEmailEndingWithIgnoreCase("@demo.estatecrm.app");
        assertThat(demoClients).hasSize(6);
        assertThat(demoClients).allMatch(c -> c.getAgent().getId().equals(reviewer().getId()));
    }

    @Test
    @DisplayName("running twice over a live demo account leaves it alone")
    public void isANoOpWhileTheAccountExists() {
        seeder.run(null);
        long users = userRepository.count();

        seeder.run(null);

        assertThat(userRepository.count()).isEqualTo(users);
        assertThat(clientRepository.count()).isEqualTo(6);
    }

    @Test
    @DisplayName("no password configured, no account — rather than a guessable one in production")
    public void refusesWithoutAPassword() {
        configure("  ");

        seeder.run(null);

        assertThat(userRepository.findByEmail(REVIEWER)).isEmpty();
    }
}
