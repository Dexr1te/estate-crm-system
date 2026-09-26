package com.crm.realestate.integration;

import com.crm.realestate.dto.response.FunnelResponse;
import com.crm.realestate.dto.response.FunnelResponse.LostReasonShare;
import com.crm.realestate.dto.response.FunnelResponse.MonthPoint;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealStatusChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DealStatusChangeRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AnalyticsService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

/**
 * The funnel on a seeded set whose every figure is worked out by hand below, seen by an agent, a
 * manager, an admin and a manager of another agency, and a guard that it costs the same number of
 * statements for ten deals as for forty.
 *
 * <p>All deals are created at {@code t0}, 10:00 on the first of this month, so the period is this
 * month. Almaty agent: A1 lead; A2 in negotiation; A3 won for 10m in 4 days by its history; A4 won
 * for 20m with no history, created → closed 10 days; A5 lost for PRICE after negotiating; A6 lost
 * before reasons were asked, no history; A7 lost for PRICE straight from lead; A8 won two months
 * ago, outside the period. Almaty colleague: C1 won for 5m in 1 day; C2 lost for FINANCING.
 * Astana: S1 won for 99m, S2 lost for OTHER.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class FunnelAnalyticsTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private AnalyticsService analyticsService;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private DealStatusChangeRepository changeRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private LocalDate from;
    private LocalDate to;
    private LocalDateTime t0;

    private User almatyManager;
    private User almatyAgent;
    private User colleague;
    private User astanaManager;
    private User astanaAgent;
    private User admin;
    private Client agentClient;
    private Client colleagueClient;
    private Client astanaClient;

    @BeforeEach
    void setUp() {
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        from = LocalDate.now().withDayOfMonth(1);
        to = from.plusMonths(1);
        t0 = from.atTime(10, 0);

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        almatyManager = user("manager@almaty.kz", Role.MANAGER, DataScope.TEAM, almaty);
        almatyAgent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        astanaManager = user("manager@astana.kz", Role.MANAGER, DataScope.TEAM, astana);
        astanaAgent = user("agent@astana.kz", Role.AGENT, DataScope.OWN, astana);
        admin = user("admin@estatecrm.app", Role.ADMIN, DataScope.ALL, null);

        agentClient = client("Aigerim", almatyAgent);
        colleagueClient = client("Daniyar", colleague);
        astanaClient = client("Madina", astanaAgent);

        seed();
        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("an agent's funnel: stage counts, rates, won value, days to win and lost reasons")
    void agentFunnel() {
        FunnelResponse f = funnel(almatyAgent, null);

        assertThat(f.getCreated()).isEqualTo(7);
        assertThat(f.getReachedNegotiation()).as("A2, A3, A4 (won), A5 (history)").isEqualTo(4);
        assertThat(f.getWon()).isEqualTo(2);
        assertThat(f.getLost()).isEqualTo(3);
        assertThat(f.getLeadToNegotiationRate()).isCloseTo(4.0 / 7, within(1e-9));
        assertThat(f.getNegotiationToWonRate()).isCloseTo(0.5, within(1e-9));
        assertThat(f.getLeadToWonRate()).isCloseTo(2.0 / 7, within(1e-9));
        assertThat(f.getWonValue()).isEqualByComparingTo("30000000.00");
        assertThat(f.getAvgDaysToWin()).as("(4 by history + 10 by dates) / 2").isEqualTo(7.0);

        assertThat(f.getLostReasons()).extracting(LostReasonShare::getReason)
                .containsExactly("PRICE", "UNSPECIFIED");
        assertThat(f.getLostReasons()).extracting(LostReasonShare::getCount).containsExactly(2L, 1L);
        assertThat(f.getLostReasons().get(0).getShare()).isCloseTo(2.0 / 3, within(1e-9));
    }

    @Test
    @DisplayName("the monthly series is the last six months: created by creation, outcomes by closing")
    void monthlySeries() {
        List<MonthPoint> months = funnel(almatyAgent, null).getMonthly();

        assertThat(months).hasSize(6);
        assertThat(months.get(0).getMonth()).isEqualTo(from.minusMonths(5));
        assertThat(months.get(5).getMonth()).isEqualTo(from);
        assertThat(months).extracting(MonthPoint::getCreated).containsExactly(0L, 0L, 0L, 1L, 0L, 7L);
        assertThat(months).extracting(MonthPoint::getWon).containsExactly(0L, 0L, 0L, 1L, 0L, 2L);
        assertThat(months).extracting(MonthPoint::getLost).containsExactly(0L, 0L, 0L, 0L, 0L, 3L);
    }

    @Test
    @DisplayName("a manager sees the agency, and never another agency's deals")
    void managerSeesTheTeam() {
        FunnelResponse f = funnel(almatyManager, null);

        assertThat(f.getCreated()).isEqualTo(9);
        assertThat(f.getReachedNegotiation()).isEqualTo(5);
        assertThat(f.getWon()).isEqualTo(3);
        assertThat(f.getLost()).isEqualTo(4);
        assertThat(f.getWonValue()).isEqualByComparingTo("35000000.00");
        assertThat(f.getAvgDaysToWin()).as("(4 + 10 + 1) / 3").isEqualTo(5.0);
        assertThat(f.getLostReasons()).extracting(LostReasonShare::getReason)
                .containsExactly("PRICE", "FINANCING", "UNSPECIFIED");
        assertThat(f.getLostReasons()).extracting(LostReasonShare::getShare)
                .containsExactly(0.5, 0.25, 0.25);

        FunnelResponse astana = funnel(astanaManager, null);
        assertThat(astana.getCreated()).isEqualTo(2);
        assertThat(astana.getWonValue()).isEqualByComparingTo("99000000.00");
    }

    @Test
    @DisplayName("agentId narrows a manager's view; it never widens anyone's")
    void agentIdOnlyNarrows() {
        assertThat(funnel(almatyManager, almatyAgent.getId()).getCreated()).isEqualTo(7);
        assertThat(funnel(almatyManager, colleague.getId()).getCreated()).isEqualTo(2);

        FunnelResponse otherAgency = funnel(almatyManager, astanaAgent.getId());
        assertThat(otherAgency.getCreated()).isZero();
        assertThat(otherAgency.getLeadToNegotiationRate()).as("nothing to divide by").isNull();
        assertThat(otherAgency.getAvgDaysToWin()).isNull();
        assertThat(otherAgency.getLostReasons()).isEmpty();
        assertThat(otherAgency.getWonValue()).isEqualByComparingTo("0");

        assertThat(funnel(almatyAgent, colleague.getId()).getCreated())
                .as("an agent asking for a colleague gets nothing").isZero();
    }

    @Test
    @DisplayName("an admin sees every agency")
    void adminSeesEverything() {
        FunnelResponse f = funnel(admin, null);
        assertThat(f.getCreated()).isEqualTo(11);
        assertThat(f.getReachedNegotiation()).isEqualTo(6);
        assertThat(f.getWon()).isEqualTo(4);
        assertThat(f.getLost()).isEqualTo(5);
        assertThat(f.getWonValue()).isEqualByComparingTo("134000000.00");
        assertThat(funnel(admin, astanaAgent.getId()).getCreated()).isEqualTo(2);
    }

    @Test
    @DisplayName("the endpoint takes ISO dates and refuses a period that ends before it starts")
    void endpoint() throws Exception {
        signIn(almatyManager);
        MvcResult ok = mockMvc.perform(get("/analytics/funnel")
                .param("from", from.toString()).param("to", to.toString())
                .param("agentId", almatyAgent.getId().toString())).andReturn();
        assertThat(ok.getResponse().getStatus()).isEqualTo(200);
        JsonNode body = objectMapper.readTree(ok.getResponse().getContentAsString());
        assertThat(body.get("created").asLong()).isEqualTo(7);
        assertThat(body.get("lostReasons").get(1).get("reason").asText()).isEqualTo("UNSPECIFIED");
        assertThat(body.get("monthly")).hasSize(6);

        MvcResult bad = mockMvc.perform(get("/analytics/funnel")
                .param("from", to.toString()).param("to", from.toString())).andReturn();
        assertThat(bad.getResponse().getStatus()).isEqualTo(400);
    }

    @Test
    @DisplayName("the funnel costs the same statements for forty deals as for ten")
    void queryCountIsFlat() {
        signIn(almatyManager);
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        stats.clear();
        analyticsService.funnel(from, to, null);
        long few = stats.getPrepareStatementCount();

        for (int i = 0; i < 30; i++) {
            deal(agentClient, i % 2 == 0 ? DealStatus.CLOSED_WON : DealStatus.CLOSED_LOST, "1000000",
                    i % 2 == 0 ? null : DealLostReason.NO_RESPONSE, t0.plusDays(1), t0,
                    DealStatus.LEAD, DealStatus.NEGOTIATION);
        }
        entityManager.flush();
        entityManager.clear();

        stats.clear();
        FunnelResponse f = analyticsService.funnel(from, to, null);
        assertThat(f.getCreated()).isEqualTo(39);
        assertThat(stats.getPrepareStatementCount()).isEqualTo(few).isLessThanOrEqualTo(6);
    }

    private void seed() {
        deal(agentClient, DealStatus.LEAD, null, null, null, t0, DealStatus.LEAD);
        deal(agentClient, DealStatus.NEGOTIATION, null, null, null, t0,
                DealStatus.LEAD, DealStatus.NEGOTIATION);
        Deal a3 = deal(agentClient, DealStatus.CLOSED_WON, "10000000", null, t0.plusDays(4), t0);
        history(a3, null, DealStatus.LEAD, t0);
        history(a3, DealStatus.LEAD, DealStatus.NEGOTIATION, t0.plusDays(2));
        history(a3, DealStatus.NEGOTIATION, DealStatus.CLOSED_WON, t0.plusDays(4));
        deal(agentClient, DealStatus.CLOSED_WON, "20000000", null, t0.plusDays(10), t0);
        deal(agentClient, DealStatus.CLOSED_LOST, null, DealLostReason.PRICE, t0.plusDays(5), t0,
                DealStatus.LEAD, DealStatus.NEGOTIATION, DealStatus.CLOSED_LOST);
        deal(agentClient, DealStatus.CLOSED_LOST, null, null, t0.plusDays(5), t0);
        deal(agentClient, DealStatus.CLOSED_LOST, null, DealLostReason.PRICE, t0.plusDays(5), t0,
                DealStatus.LEAD, DealStatus.CLOSED_LOST);
        LocalDateTime twoMonthsAgo = t0.minusMonths(2);
        deal(agentClient, DealStatus.CLOSED_WON, "7000000", null, twoMonthsAgo.plusDays(3), twoMonthsAgo);

        Deal c1 = deal(colleagueClient, DealStatus.CLOSED_WON, "5000000", null, t0.plusDays(1), t0);
        history(c1, null, DealStatus.LEAD, t0);
        history(c1, DealStatus.LEAD, DealStatus.CLOSED_WON, t0.plusDays(1));
        deal(colleagueClient, DealStatus.CLOSED_LOST, null, DealLostReason.FINANCING, t0.plusDays(2), t0);

        deal(astanaClient, DealStatus.CLOSED_WON, "99000000", null, t0.plusDays(3), t0);
        deal(astanaClient, DealStatus.CLOSED_LOST, null, DealLostReason.OTHER, t0.plusDays(3), t0);
    }

    /**
     * A deal created at {@code createdAt}, with a history row per status in {@code path}, all at
     * {@code createdAt} — only won deals' timings are asserted, and those have explicit rows.
     */
    private Deal deal(Client client, DealStatus status, String price, DealLostReason reason,
                      LocalDateTime closedAt, LocalDateTime createdAt, DealStatus... path) {
        Deal deal = dealRepository.save(Deal.builder()
                .title(status.name()).status(status)
                .client(client).agent(client.getAgent()).team(client.getTeam())
                .dealPrice(price == null ? null : new BigDecimal(price))
                .lostReason(reason).closedAt(closedAt).build());
        entityManager.flush();
        // created_at is stamped on insert and not updatable through the entity.
        entityManager.createNativeQuery("UPDATE deals SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, createdAt).setParameter(2, deal.getId()).executeUpdate();
        DealStatus previous = null;
        for (DealStatus next : path) {
            history(deal, previous, next, createdAt);
            previous = next;
        }
        return deal;
    }

    private void history(Deal deal, DealStatus fromStatus, DealStatus toStatus, LocalDateTime at) {
        changeRepository.save(DealStatusChange.builder().deal(deal)
                .fromStatus(fromStatus).toStatus(toStatus).changedAt(at).build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private User user(String email, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true).build());
    }

    private Client client(String name, User agent) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .agent(agent).team(agent.getTeam()).build());
    }

    private FunnelResponse funnel(User who, Long agentId) {
        signIn(who);
        return analyticsService.funnel(from, to, agentId);
    }
}
