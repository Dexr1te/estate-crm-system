package com.crm.realestate.integration;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDateTime;
import java.util.List;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DashboardService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

/**
 * The summary is five integers. It used to produce them by loading every closed deal and every
 * upcoming meeting into memory, so these tests pin both halves: that the numbers are what they
 * always were, and that getting them no longer costs a scan per figure.
 */
@SpringBootTest
@Transactional
class DashboardSummaryTest {

    @Autowired private DashboardService dashboardService;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private EntityManagerFactory entityManagerFactory;
    @Autowired private EntityManager entityManager;

    private User admin;
    private User agent;

    private User user(String email, Role role, DataScope scope) {
        return userRepository.save(User.builder()
                .fullName(email)
                .email(email)
                .password("x")
                .role(role)
                .dataScope(scope)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private Client client(User owner, String name) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER).agent(owner).build());
    }

    private void deal(User owner, Client c, DealStatus status) {
        dealRepository.save(Deal.builder()
                .title(status.name()).status(status).client(c).agent(owner).build());
    }

    private void meeting(User owner, Client c, LocalDateTime at) {
        meetingRepository.save(Meeting.builder()
                .title("m").scheduledAt(at).client(c).agent(owner).build());
    }

    private void task(User owner, LocalDateTime due, boolean done) {
        taskRepository.save(Task.builder()
                .title("t").dueAt(due).assignee(owner).createdBy(owner)
                .completedAt(done ? due : null).build());
    }

    /** Halfway between now and midnight: still today, and not yet past when the summary runs. */
    private static LocalDateTime laterToday(LocalDateTime now) {
        LocalDateTime midnight = now.toLocalDate().plusDays(1).atStartOfDay();
        return now.plus(java.time.Duration.between(now, midnight).dividedBy(2));
    }

    @BeforeEach
    void setUp() {
        taskRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();

        admin = user("admin@estate.crm", Role.ADMIN, DataScope.ALL);
        agent = user("agent@estate.crm", Role.AGENT, DataScope.OWN);

        Client mine = client(agent, "Mine");
        Client theirs = client(admin, "Theirs");

        // agent: 2 open, 1 won, 1 lost
        deal(agent, mine, DealStatus.LEAD);
        deal(agent, mine, DealStatus.NEGOTIATION);
        deal(agent, mine, DealStatus.CLOSED_WON);
        deal(agent, mine, DealStatus.CLOSED_LOST);
        // admin: 1 open
        deal(admin, theirs, DealStatus.LEAD);

        LocalDateTime now = LocalDateTime.now();
        meeting(agent, mine, now.plusDays(1));
        meeting(agent, mine, now.plusDays(2));
        meeting(agent, mine, now.minusDays(1)); // past, must not count
        meeting(admin, theirs, now.plusDays(3));

        // agent: 1 overdue, 1 later today, 1 tomorrow, 1 overdue but done; admin: 1 overdue
        task(agent, now.minusHours(2), false);
        task(agent, laterToday(now), false);
        task(agent, now.toLocalDate().plusDays(1).atTime(10, 0), false);
        task(agent, now.minusDays(1), true);
        task(admin, now.minusDays(3), false);

        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("an admin sees every agent's figures")
    void adminSeesEverything() {
        signIn(admin);
        DashboardSummary s = dashboardService.getSummary(null, null);

        assertThat(s.getTotalDeals()).isEqualTo(5);
        assertThat(s.getClosedDeals()).isEqualTo(2);
        assertThat(s.getActiveDeals()).isEqualTo(3);
        assertThat(s.getTotalClients()).isEqualTo(2);
        assertThat(s.getUpcomingMeetings())
                .as("the meeting that already happened must not be counted")
                .isEqualTo(3);
    }

    @Test
    @DisplayName("an agent sees only their own")
    void agentSeesOwnScope() {
        signIn(agent);
        DashboardSummary s = dashboardService.getSummary(null, null);

        assertThat(s.getTotalDeals()).isEqualTo(4);
        assertThat(s.getClosedDeals()).isEqualTo(2);
        assertThat(s.getActiveDeals()).isEqualTo(2);
        assertThat(s.getTotalClients()).isEqualTo(1);
        assertThat(s.getUpcomingMeetings()).isEqualTo(2);
    }

    @Test
    @DisplayName("overdue and due-today tasks are counted apart, open ones only, within scope")
    void taskCounts() {
        signIn(admin);
        DashboardSummary all = dashboardService.getSummary(null, null);
        assertThat(all.getTasksOverdue()).isEqualTo(2);
        assertThat(all.getTasksDueToday())
                .as("tomorrow's task is not today's, and an overdue one is not counted twice")
                .isEqualTo(1);

        DashboardSummary narrowed = dashboardService.getSummary(agent.getId(), null);
        assertThat(narrowed.getTasksOverdue()).as("the agent filter reads the assignee").isEqualTo(1);

        signIn(agent);
        DashboardSummary own = dashboardService.getSummary(null, null);
        assertThat(own.getTasksOverdue()).as("a finished task is not overdue").isEqualTo(1);
        assertThat(own.getTasksDueToday()).isEqualTo(1);
    }

    /**
     * Rows hydrated, not statements issued. Statement count is the wrong yardstick here: loading
     * every closed deal to call .size() on it is a single query too. What costs money over a link
     * to another region is the rows crossing it.
     */
    private long entitiesLoadedForSummary() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        dashboardService.getSummary(null, null);
        return stats.getEntityLoadCount();
    }

    private void seedMore(int deals) {
        Client c = client(admin, "Bulk");
        LocalDateTime now = LocalDateTime.now();
        for (int i = 0; i < deals; i++) {
            deal(admin, c, i % 2 == 0 ? DealStatus.CLOSED_WON : DealStatus.LEAD);
            meeting(admin, c, now.plusDays(i + 1));
            task(admin, now.minusDays(i + 1), false);
        }
        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("the summary counts rows in the database instead of fetching them")
    void summaryDoesNotFetchRowsItOnlyCounts() {
        signIn(admin);
        seedMore(5);
        long small = entitiesLoadedForSummary();

        seedMore(40);
        long large = entitiesLoadedForSummary();

        assertThat(large)
                .as("5 extra rows hydrated %d entities, 45 hydrated %d — the summary is pulling "
                        + "rows across the wire to count them in memory", small, large)
                .isEqualTo(small);
    }
}
