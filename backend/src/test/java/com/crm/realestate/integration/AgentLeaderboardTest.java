package com.crm.realestate.integration;

import com.crm.realestate.dto.response.LeaderboardResponse;
import com.crm.realestate.dto.response.LeaderboardResponse.Row;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.service.LeaderboardService;
import com.fasterxml.jackson.databind.JsonNode;
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
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The leaderboard over last month, worked out by hand. Almaty: Timur won 40m at 3% and 5m with no
 * rate; Aigul won 10m at 3% and 20m at 2.5% and lost one, held two viewings (a third was a
 * no-show, a fourth was not a viewing) and took on two clients; Asel, the manager, won 8m at 1%;
 * Dana did nothing; Bolat, deactivated, won 10m at 1%; an invitation nobody accepted holds nothing.
 * Aigul also won a deal two months ago and one this month, outside the period. Astana won 99m at 5%,
 * which Almaty must never see.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class AgentLeaderboardTest extends ChecklistFixture {

    private static final String URL = "/analytics/leaderboard";

    @Autowired private LeaderboardService leaderboardService;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private LocalDate from;
    private LocalDate to;
    private LocalDateTime p0;
    private User bolat;
    private User astanaAgent;
    private User admin;

    @BeforeEach
    void seed() {
        to = LocalDate.now().withDayOfMonth(1);
        from = to.minusMonths(1);
        p0 = from.atTime(10, 0);

        bolat = userRepository.save(User.builder()
                .email("lb-bolat@almaty.kz").password("x").fullName("Bolat Omarov")
                .role(Role.AGENT).dataScope(DataScope.OWN).team(almaty)
                .status(UserStatus.ACTIVE).isActive(false).build());
        userRepository.save(User.builder()
                .email("lb-invited@almaty.kz").fullName("Invited")
                .role(Role.AGENT).dataScope(DataScope.OWN).team(almaty)
                .status(UserStatus.PENDING_INVITE).isActive(false).build());
        astanaAgent = user("lb-agent@astana.kz", "Madina", Role.AGENT, DataScope.OWN, astana);
        admin = user("lb-admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);

        won(colleague, "40000000", "3.00", p0.plusDays(2));
        won(colleague, "5000000", null, p0.plusDays(3));

        won(agent, "10000000", "3.00", p0.plusDays(4));
        won(agent, "20000000", "2.50", p0.plusDays(5));
        closed(agent, DealStatus.CLOSED_LOST, null, null, p0.plusDays(6));
        won(agent, "50000000", "2.00", p0.minusMonths(1));
        won(agent, "50000000", "2.00", to.atTime(0, 0));

        Property flat = propertyRepository.save(Property.builder()
                .title("Abay 10").address("Abay 10").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("30000000")).agent(agent).team(almaty).build());
        meeting(agent, flat, p0.plusDays(1), true, null);
        meeting(agent, flat, p0.plusDays(2), false, ViewingOutcome.INTERESTED);
        meeting(agent, flat, p0.plusDays(3), false, ViewingOutcome.NO_SHOW);
        meeting(agent, null, p0.plusDays(4), true, null);
        newClient(agent, p0.plusDays(1));
        newClient(agent, p0.plusDays(8));
        newClient(agent, p0.minusDays(1));

        won(manager, "8000000", "1.00", p0.plusDays(7));
        won(bolat, "10000000", "1.00", p0.plusDays(7));

        won(astanaAgent, "99000000", "5.00", p0.plusDays(2));
        Property astanaFlat = propertyRepository.save(Property.builder()
                .title("Mangilik 1").address("Mangilik 1").city("Astana")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("99000000")).agent(astanaAgent).team(astana).build());
        meeting(astanaAgent, astanaFlat, p0.plusDays(1), true, null);
        newClient(astanaAgent, p0.plusDays(1));

        flushAndClear();
    }

    @Test
    @DisplayName("a manager sees their agency ranked by commission, every figure per person")
    void managerSeesRankedAgency() {
        LeaderboardResponse board = board(manager, null);

        assertThat(board.getFrom()).isEqualTo(from);
        assertThat(board.getTo()).isEqualTo(to);
        assertThat(board.getCurrency()).isEqualTo("USD");
        assertThat(board.getAgents()).extracting(Row::getFullName)
                .containsExactly("Timur Aliev", "Aigul Bekova", "Asel Nurlanovna", "Dana Seitova");
        assertThat(board.getAgents()).extracting(Row::getRank).containsExactly(1, 2, 3, 4);

        Row timur = board.getAgents().get(0);
        assertThat(timur.getCommission()).isEqualByComparingTo("1200000.00");
        assertThat(timur.getWonValue()).as("the deal with no rate still sold").isEqualByComparingTo("45000000");
        assertThat(timur.getDealsWon()).isEqualTo(2);
        assertThat(timur.getWinRate()).isEqualTo(1.0);

        Row aigul = board.getAgents().get(1);
        assertThat(aigul.getCommission()).isEqualByComparingTo("800000.00");
        assertThat(aigul.getDealsWon()).isEqualTo(2);
        assertThat(aigul.getDealsLost()).isEqualTo(1);
        assertThat(aigul.getWinRate()).isCloseTo(2.0 / 3, within(1e-9));
        assertThat(aigul.getViewingsHeld()).as("no-show and a plain meeting do not count").isEqualTo(2);
        assertThat(aigul.getNewClients()).isEqualTo(2);

        Row asel = board.getAgents().get(2);
        assertThat(asel.getRole()).isEqualTo("MANAGER");
        assertThat(asel.getCommission()).isEqualByComparingTo("80000.00");

        Row dana = board.getAgents().get(3);
        assertThat(dana.getCommission()).isEqualByComparingTo("0");
        assertThat(dana.getWinRate()).as("nothing closed").isNull();
    }

    @Test
    @DisplayName("a deactivated member is listed apart; an unaccepted invitation is not listed")
    void inactiveApartAndTotals() {
        LeaderboardResponse board = board(manager, null);

        assertThat(board.getInactive()).extracting(Row::getFullName).containsExactly("Bolat Omarov");
        assertThat(board.getInactive().get(0).getRank()).isEqualTo(1);
        assertThat(board.getInactive().get(0).getCommission()).isEqualByComparingTo("100000.00");
        assertThat(board.getAgents()).extracting(Row::getFullName).doesNotContain("Invited", "Bolat Omarov");

        Row totals = board.getTotals();
        assertThat(totals.getRank()).isNull();
        assertThat(totals.getDealsWon()).isEqualTo(6);
        assertThat(totals.getDealsLost()).isEqualTo(1);
        assertThat(totals.getCommission()).isEqualByComparingTo("2180000.00");
        assertThat(totals.getViewingsHeld()).isEqualTo(2);
        assertThat(totals.getNewClients()).isEqualTo(2);
        assertThat(totals.getWinRate()).isCloseTo(6.0 / 7, within(1e-9));
    }

    @Test
    @DisplayName("another agency's manager sees only their own; Almaty never counts Astana")
    void tenantIsolation() {
        LeaderboardResponse astanaBoard = board(stranger, almaty.getId());
        assertThat(astanaBoard.getAgents()).extracting(Row::getFullName)
                .containsExactly("Madina", "Yerlan Sadykov");
        assertThat(astanaBoard.getTotals().getCommission()).isEqualByComparingTo("4950000.00");
        assertThat(astanaBoard.getTotals().getViewingsHeld()).isEqualTo(1);

        assertThat(board(manager, astana.getId()).getTotals().getCommission())
                .as("teamId from a manager is ignored").isEqualByComparingTo("2180000.00");
    }

    @Test
    @DisplayName("an agent is refused; a manager and an admin naming the agency are answered")
    void whoMayAsk() throws Exception {
        as(agent, get(URL)).andExpect(status().isForbidden());
        as(colleague, get(URL)).andExpect(status().isForbidden());

        JsonNode body = json(as(manager, get(URL)
                .param("from", from.toString()).param("to", to.toString()))
                .andExpect(status().isOk()));
        assertThat(body.get("agents").get(0).get("fullName").asText()).isEqualTo("Timur Aliev");
        assertThat(body.get("agents").get(0).get("commission").decimalValue()).isEqualByComparingTo("1200000");
        assertThat(body.get("inactive")).hasSize(1);

        as(admin, get(URL)).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
        as(admin, get(URL).param("teamId", "999999")).andExpect(status().isNotFound());
        as(admin, get(URL).param("teamId", almaty.getId().toString())
                .param("from", from.toString()).param("to", to.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totals.dealsWon").value(6));
    }

    @Test
    @DisplayName("the period is this month by default and must end after it starts")
    void period() throws Exception {
        JsonNode body = json(as(manager, get(URL)).andExpect(status().isOk()));
        assertThat(body.get("from").asText()).isEqualTo(to.toString());
        assertThat(body.get("to").asText()).isEqualTo(to.plusMonths(1).toString());
        assertThat(body.get("totals").get("dealsWon").asLong())
                .as("only Aigul's deal won on the first of this month").isEqualTo(1);

        as(manager, get(URL).param("from", to.toString()).param("to", from.toString()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_PERIOD"));
    }

    @Test
    @DisplayName("the board costs the same statements for many records as for few")
    void queryCountIsFlat() {
        signIn(manager);
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        stats.clear();
        leaderboardService.leaderboard(from, to, null);
        long few = stats.getPrepareStatementCount();

        for (int i = 0; i < 20; i++) {
            won(i % 2 == 0 ? agent : ownOnly, "1000000", "1.00", p0.plusDays(9));
            newClient(ownOnly, p0.plusDays(9));
        }
        flushAndClear();

        stats.clear();
        signIn(manager);
        leaderboardService.leaderboard(from, to, null);
        assertThat(stats.getPrepareStatementCount()).isEqualTo(few).isLessThanOrEqualTo(6);
    }

    private LeaderboardResponse board(User who, Long teamId) {
        signIn(who);
        return leaderboardService.leaderboard(from, to, teamId);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private void won(User holder, String price, String rate, LocalDateTime closedAt) {
        closed(holder, DealStatus.CLOSED_WON, price, rate, closedAt);
    }

    private void closed(User holder, DealStatus status, String price, String rate, LocalDateTime closedAt) {
        Team team = holder.getTeam();
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer").type(ClientType.BUYER).agent(holder).team(team).build());
        dealRepository.save(Deal.builder()
                .title(status.name()).status(status).client(client).agent(holder).team(team)
                .dealPrice(price == null ? null : new BigDecimal(price))
                .commissionPercent(rate == null ? null : new BigDecimal(rate))
                .closedAt(closedAt).build());
    }

    private void meeting(User holder, Property flat, LocalDateTime at, boolean completed, ViewingOutcome outcome) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Viewer").type(ClientType.BUYER).agent(holder).team(holder.getTeam()).build());
        meetingRepository.save(Meeting.builder()
                .title("Viewing").scheduledAt(at).completed(completed).outcome(outcome)
                .agent(holder).client(client).property(flat).team(holder.getTeam()).build());
    }

    private void newClient(User holder, LocalDateTime createdAt) {
        Client client = clientRepository.save(Client.builder()
                .fullName("New").type(ClientType.BUYER).agent(holder).team(holder.getTeam()).build());
        entityManager.flush();
        // created_at is stamped on insert and not updatable through the entity.
        entityManager.createNativeQuery("UPDATE clients SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, createdAt).setParameter(2, client.getId()).executeUpdate();
    }
}
