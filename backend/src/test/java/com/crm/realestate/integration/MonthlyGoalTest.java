package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.MonthlyGoal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.AgencyCurrency;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.GoalSource;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.MonthlyGoalRepository;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Monthly targets: counted from the deals won in the calendar month, the manager's target winning
 * over a member's own, the manager seeing everybody's month and copying last month forward, an
 * agent reaching only their own, and nothing crossing the agency wall.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class MonthlyGoalTest extends ChecklistFixture {

    private static final String ME = "/goals/me";
    private static final String TEAM = "/goals/team";

    @Autowired private MonthlyGoalRepository goalRepository;

    private YearMonth thisMonth;
    private LocalDateTime inThisMonth;

    @BeforeEach
    void seedDeals() {
        thisMonth = YearMonth.now();
        inThisMonth = thisMonth.atDay(1).atStartOfDay().plusHours(1);
        almaty.setCurrency(AgencyCurrency.KZT);
        teamRepository.save(almaty);

        // The agent: two won this month, one of them without a rate; one won last month; one lost.
        deal(agent, almaty, DealStatus.CLOSED_WON, "40000000", "2.5", inThisMonth);
        deal(agent, almaty, DealStatus.CLOSED_WON, "30000000", null, inThisMonth.plusDays(1));
        deal(agent, almaty, DealStatus.CLOSED_WON, "90000000", "3", inThisMonth.minusMonths(1));
        deal(agent, almaty, DealStatus.CLOSED_LOST, "50000000", "3", inThisMonth);
        // A colleague's win this month.
        deal(colleague, almaty, DealStatus.CLOSED_WON, "20000000", "2", inThisMonth);
        // Another agency's win.
        deal(stranger, astana, DealStatus.CLOSED_WON, "99000000", "5", inThisMonth);
    }

    @Test
    @DisplayName("with no target, an agent still sees what the month's won deals came to")
    void progressWithoutTarget() throws Exception {
        as(agent, get(ME))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.month").value(thisMonth.toString()))
                .andExpect(jsonPath("$.currency").value("KZT"))
                .andExpect(jsonPath("$.agentId").value(agent.getId()))
                .andExpect(jsonPath("$.source").isEmpty())
                .andExpect(jsonPath("$.commissionAchieved").value(1000000.00))
                .andExpect(jsonPath("$.dealsWon").value(2))
                .andExpect(jsonPath("$.commissionPercent").isEmpty())
                .andExpect(jsonPath("$.daysLeft").value(daysLeftToday()))
                .andExpect(jsonPath("$.personalEditable").value(true));

        as(agent, get(ME).param("month", thisMonth.minusMonths(1).toString()))
                .andExpect(jsonPath("$.commissionAchieved").value(2700000.00))
                .andExpect(jsonPath("$.dealsWon").value(1))
                .andExpect(jsonPath("$.daysLeft").value(0))
                .andExpect(jsonPath("$.personalEditable").value(false));
    }

    @Test
    @DisplayName("an agent sets their own target and sees percent, days left and what each day needs")
    void personalTarget() throws Exception {
        JsonNode mine = json(write(agent, put(ME), "{\"commissionTarget\":4000000,\"dealsTarget\":4}")
                .andExpect(status().isOk()));
        int days = daysLeftToday();
        assertThat(mine.get("source").asText()).isEqualTo("PERSONAL");
        assertThat(mine.get("commissionPercent").asInt()).isEqualTo(25);
        assertThat(mine.get("dealsPercent").asInt()).isEqualTo(50);
        assertThat(mine.get("commissionPerDay").decimalValue())
                .isEqualByComparingTo(BigDecimal.valueOf(3000000)
                        .divide(BigDecimal.valueOf(days), 0, RoundingMode.CEILING));
        assertThat(mine.get("dealsPerDay").decimalValue())
                .isEqualByComparingTo(BigDecimal.valueOf(2)
                        .divide(BigDecimal.valueOf(days), 2, RoundingMode.CEILING));

        // Only the deals target this time: the commission one goes.
        write(agent, put(ME), "{\"dealsTarget\":2}")
                .andExpect(jsonPath("$.commissionTarget").isEmpty())
                .andExpect(jsonPath("$.dealsPercent").value(100))
                .andExpect(jsonPath("$.dealsPerDay").isEmpty());

        as(agent, delete(ME))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").isEmpty());
        assertThat(goalRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("the manager's target wins; the agent's own is locked, and back when the manager's goes")
    void managerWins() throws Exception {
        write(agent, put(ME), "{\"dealsTarget\":3}").andExpect(status().isOk());

        write(manager, put(TEAM + "/agents/" + agent.getId()), "{\"commissionTarget\":2000000}")
                .andExpect(status().isOk());

        as(agent, get(ME))
                .andExpect(jsonPath("$.source").value("MANAGER"))
                .andExpect(jsonPath("$.commissionTarget").value(2000000.00))
                .andExpect(jsonPath("$.dealsTarget").isEmpty())
                .andExpect(jsonPath("$.commissionPercent").value(50))
                .andExpect(jsonPath("$.personalDealsTarget").value(3))
                .andExpect(jsonPath("$.personalEditable").value(false));

        write(agent, put(ME), "{\"dealsTarget\":1}")
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("GOAL_SET_BY_MANAGER"));
        as(agent, delete(ME)).andExpect(status().isConflict());

        as(manager, delete(TEAM + "/agents/" + agent.getId())).andExpect(status().isOk());
        as(agent, get(ME))
                .andExpect(jsonPath("$.source").value("PERSONAL"))
                .andExpect(jsonPath("$.dealsTarget").value(3))
                .andExpect(jsonPath("$.personalEditable").value(true));

        assertThat(auditLogRepository.findAll())
                .extracting(log -> log.getAction())
                .contains("SET_GOAL", "CLEAR_GOAL");
    }

    @Test
    @DisplayName("the manager sees every member's month and the agency's, in the agency's currency")
    void teamView() throws Exception {
        write(manager, put(TEAM + "/agency"), "{\"commissionTarget\":5000000,\"dealsTarget\":10}")
                .andExpect(status().isOk());
        write(colleague, put(ME), "{\"dealsTarget\":5}").andExpect(status().isOk());

        JsonNode team = json(as(manager, get(TEAM)).andExpect(status().isOk()));
        assertThat(team.get("currency").asText()).isEqualTo("KZT");
        assertThat(team.get("daysLeft").asInt()).isEqualTo(daysLeftToday());

        JsonNode agency = team.get("agency");
        assertThat(agency.get("agentId").isNull()).isTrue();
        assertThat(agency.get("commissionAchieved").decimalValue()).isEqualByComparingTo("1400000");
        assertThat(agency.get("dealsWon").asLong()).isEqualTo(3);
        assertThat(agency.get("commissionPercent").asInt()).isEqualTo(28);
        assertThat(agency.get("dealsPercent").asInt()).isEqualTo(30);

        JsonNode agents = team.get("agents");
        assertThat(agents).extracting(a -> a.get("agentName").asText())
                .containsExactly("Aigul Bekova", "Asel Nurlanovna", "Dana Seitova", "Timur Aliev");
        JsonNode timur = agents.get(3);
        assertThat(timur.get("source").asText()).isEqualTo("PERSONAL");
        assertThat(timur.get("commissionAchieved").decimalValue()).isEqualByComparingTo("400000");
        assertThat(timur.get("dealsPercent").asInt()).isEqualTo(20);
        assertThat(agents.toString()).doesNotContain("Yerlan");
    }

    @Test
    @DisplayName("an agent reaches no one else's target, whatever their data scope")
    void agentsOnlyTheirOwn() throws Exception {
        as(agent, get(TEAM)).andExpect(status().isForbidden());
        as(colleague, get(TEAM)).andExpect(status().isForbidden());
        write(agent, put(TEAM + "/agents/" + colleague.getId()), "{\"dealsTarget\":1}")
                .andExpect(status().isForbidden());
        write(agent, put(TEAM + "/agency"), "{\"dealsTarget\":1}").andExpect(status().isForbidden());
        as(agent, post(TEAM + "/copy-previous")).andExpect(status().isForbidden());
        assertThat(goalRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("another agency's people are not found, and its targets and deals never show")
    void tenantWall() throws Exception {
        User astanaAgent = user("goal-agent@astana.kz", "Bolat Ospanov", Role.AGENT, DataScope.OWN, astana);
        write(stranger, put(TEAM + "/agents/" + astanaAgent.getId()), "{\"dealsTarget\":7}")
                .andExpect(status().isOk());
        write(stranger, put(TEAM + "/agency"), "{\"dealsTarget\":70}").andExpect(status().isOk());

        write(manager, put(TEAM + "/agents/" + astanaAgent.getId()), "{\"dealsTarget\":1}")
                .andExpect(status().isNotFound());
        as(manager, delete(TEAM + "/agents/" + astanaAgent.getId())).andExpect(status().isNotFound());
        write(stranger, put(TEAM + "/agents/" + agent.getId()), "{\"dealsTarget\":1}")
                .andExpect(status().isNotFound());

        JsonNode ours = json(as(manager, get(TEAM)));
        assertThat(ours.get("agency").get("source").isNull()).isTrue();
        assertThat(ours.get("agency").get("dealsWon").asLong()).isEqualTo(3);
        assertThat(ours.toString()).doesNotContain("Bolat");

        as(agent, get(ME)).andExpect(jsonPath("$.source").isEmpty());
        as(astanaAgent, get(ME))
                .andExpect(jsonPath("$.dealsTarget").value(7))
                .andExpect(jsonPath("$.dealsWon").value(0));
    }

    @Test
    @DisplayName("last month's targets come forward: the manager's, for people still here, not over this month's")
    void copyPrevious() throws Exception {
        LocalDate last = thisMonth.minusMonths(1).atDay(1);
        User gone = user("goal-gone@almaty.kz", "Former Agent", Role.AGENT, DataScope.OWN, null);
        goal(null, last, GoalSource.MANAGER, "6000000", 12);
        goal(agent, last, GoalSource.MANAGER, "1500000", 3);
        goal(colleague, last, GoalSource.MANAGER, null, 2);
        goal(ownOnly, last, GoalSource.PERSONAL, null, 9);
        goalRepository.save(MonthlyGoal.builder().team(almaty).agent(gone).monthStart(last)
                .source(GoalSource.MANAGER).dealsTarget(4).build());
        // Already set for this month: left alone.
        write(manager, put(TEAM + "/agents/" + colleague.getId()), "{\"dealsTarget\":8}").andExpect(status().isOk());

        JsonNode team = json(as(manager, post(TEAM + "/copy-previous")).andExpect(status().isOk()));
        assertThat(team.get("copied").asInt()).isEqualTo(2);
        assertThat(team.get("agency").get("dealsTarget").asInt()).isEqualTo(12);
        JsonNode agents = team.get("agents");
        assertThat(agents.get(0).get("commissionTarget").decimalValue()).isEqualByComparingTo("1500000");
        assertThat(agents.get(2).get("source").isNull()).as("a member's own target is theirs to set").isTrue();
        assertThat(agents.get(3).get("dealsTarget").asInt()).isEqualTo(8);

        as(manager, post(TEAM + "/copy-previous")).andExpect(jsonPath("$.copied").value(0));
    }

    @Test
    @DisplayName("a target needs a positive figure, a real month, and a month not yet over")
    void validated() throws Exception {
        write(agent, put(ME), "{}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("GOAL_TARGET_REQUIRED"));
        write(agent, put(ME), "{\"commissionTarget\":-5}").andExpect(status().isBadRequest());
        write(agent, put(ME), "{\"commissionTarget\":10.555}").andExpect(status().isBadRequest());
        write(agent, put(ME), "{\"dealsTarget\":0}").andExpect(status().isBadRequest());
        write(agent, put(ME), "{\"dealsTarget\":1001}").andExpect(status().isBadRequest());
        write(agent, put(ME).param("month", "October"), "{\"dealsTarget\":1}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("BAD_MONTH"));
        write(manager, put(TEAM + "/agency").param("month", thisMonth.minusMonths(1).toString()),
                "{\"dealsTarget\":1}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("GOAL_MONTH_PAST"));
        write(agent, put(ME).param("month", thisMonth.plusMonths(1).toString()), "{\"dealsTarget\":1}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.daysLeft").value(thisMonth.plusMonths(1).lengthOfMonth()));
    }

    @Test
    @DisplayName("an admin names the agency")
    void adminNamesTheAgency() throws Exception {
        User admin = user("goal-admin@crm.kz", "Platform Admin", Role.ADMIN, DataScope.ALL, null);
        as(admin, get(TEAM)).andExpect(status().isBadRequest());
        write(admin, put(TEAM + "/agency").param("teamId", String.valueOf(almaty.getId())), "{\"dealsTarget\":4}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.agency.dealsTarget").value(4))
                .andExpect(jsonPath("$.agents.length()").value(4));
        as(admin, get(ME)).andExpect(status().isForbidden());
    }

    private int daysLeftToday() {
        LocalDate today = LocalDate.now();
        return today.lengthOfMonth() - today.getDayOfMonth() + 1;
    }

    private void deal(User holder, Team team, DealStatus status, String price, String rate, LocalDateTime closedAt) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer for " + holder.getFullName()).type(ClientType.BUYER)
                .agent(holder).team(team).build());
        dealRepository.save(Deal.builder()
                .title("Deal").status(status).client(client).agent(holder).team(team)
                .dealPrice(new BigDecimal(price))
                .commissionPercent(rate == null ? null : new BigDecimal(rate))
                .closedAt(closedAt)
                .build());
    }

    private void goal(User person, LocalDate month, GoalSource source, String commission, Integer deals) {
        goalRepository.save(MonthlyGoal.builder().team(almaty).agent(person).monthStart(month).source(source)
                .commissionTarget(commission == null ? null : new BigDecimal(commission))
                .dealsTarget(deals).build());
    }

    private ResultActions write(User who, MockHttpServletRequestBuilder request, String body) throws Exception {
        return as(who, request.contentType(MediaType.APPLICATION_JSON).content(body));
    }
}
