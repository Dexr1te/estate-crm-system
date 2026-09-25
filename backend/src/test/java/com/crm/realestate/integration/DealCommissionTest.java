package com.crm.realestate.integration;

import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DashboardService;
import com.crm.realestate.service.DealService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Agents are paid a share of what they sell. These tests pin the three things that follow from
 * that: the amount on a deal is its price times its rate, a rate outside (0, 100] is refused, and
 * the month's total counts only deals won this month that the caller is allowed to see.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class DealCommissionTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private DealService dealService;
    @Autowired private DashboardService dashboardService;

    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private EntityManager entityManager;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private Team almaty;
    private Team astana;
    private User almatyManager;
    private User almatyAgent;
    private User almatyColleague;
    private User astanaManager;
    private User admin;
    private Client agentClient;
    private Client colleagueClient;
    private Client astanaClient;

    @BeforeEach
    void setUp() {
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        almatyManager = user("manager@almaty.kz", Role.MANAGER, DataScope.TEAM, almaty);
        almatyAgent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        almatyColleague = user("colleague@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        astanaManager = user("manager@astana.kz", Role.MANAGER, DataScope.TEAM, astana);
        admin = user("admin@estatecrm.app", Role.ADMIN, DataScope.ALL, null);

        agentClient = client("Aigerim", almatyAgent);
        colleagueClient = client("Daniyar", almatyColleague);
        astanaClient = client("Madina", astanaManager);
    }

    // The amount on a deal -----------------------------------------------------------

    @Test
    @DisplayName("the commission is the price times the rate, and absent while either is")
    void commissionIsPriceTimesRate() {
        signIn(almatyAgent);

        DealResponse priced = dealService.create(request(agentClient, "48500000", "2.5"));
        assertThat(priced.getCommissionPercent()).isEqualByComparingTo("2.5");
        assertThat(priced.getCommission()).isEqualByComparingTo("1212500.00");

        assertThat(dealService.create(request(agentClient, null, "3")).getCommission())
                .as("no price yet").isNull();
        assertThat(dealService.create(request(agentClient, "30000000", null)).getCommission())
                .as("no rate yet").isNull();

        DealRequest edit = request(agentClient, "48500000", "1.75");
        DealResponse edited = dealService.update(priced.getId(), edit);
        assertThat(edited.getCommission()).isEqualByComparingTo("848750.00");
        assertThat(dealService.getById(priced.getId()).getCommissionPercent())
                .isEqualByComparingTo("1.75");
    }

    @Test
    @DisplayName("a rate of zero, over a hundred or with three decimals is refused; a hundred is not")
    void rateOutsideTheRangeIsRefused() throws Exception {
        signIn(almatyAgent);

        assertThat(postDeal("0").getResponse().getStatus()).isEqualTo(400);
        assertThat(postDeal("-1").getResponse().getStatus()).isEqualTo(400);
        assertThat(postDeal("100.01").getResponse().getStatus()).isEqualTo(400);
        assertThat(postDeal("2.555").getResponse().getStatus()).isEqualTo(400);

        MvcResult whole = postDeal("100");
        assertThat(whole.getResponse().getStatus()).isEqualTo(201);
        JsonNode body = objectMapper.readTree(whole.getResponse().getContentAsString());
        assertThat(body.get("commission").decimalValue()).isEqualByComparingTo("10000000");

        MvcResult none = postDeal(null);
        assertThat(none.getResponse().getStatus()).isEqualTo(201);
        JsonNode noneBody = objectMapper.readTree(none.getResponse().getContentAsString());
        assertThat(noneBody.get("commission").isNull()).isTrue();
    }

    // The month's total --------------------------------------------------------------

    /**
     * Almaty, this month: the agent won 50M at 2% (1,000,000) and 20M at 3% (600,000), lost 40M at
     * 2%, has 10M at 5% still negotiating, and won 15M with no rate agreed. Last month they won 90M
     * at 3%. Their colleague won 30M at 2.5% (750,000) this month. Astana won 100M at 3% this month.
     */
    private void seedMonth() {
        LocalDateTime thisMonth = LocalDate.now().withDayOfMonth(1).atTime(0, 0, 1);
        LocalDateTime lastMonth = LocalDate.now().withDayOfMonth(1).minusDays(1).atTime(23, 59);

        closed(agentClient, DealStatus.CLOSED_WON, "50000000", "2", thisMonth);
        closed(agentClient, DealStatus.CLOSED_WON, "20000000", "3", LocalDateTime.now());
        closed(agentClient, DealStatus.CLOSED_LOST, "40000000", "2", thisMonth);
        closed(agentClient, DealStatus.NEGOTIATION, "10000000", "5", null);
        closed(agentClient, DealStatus.CLOSED_WON, "15000000", null, thisMonth);
        closed(agentClient, DealStatus.CLOSED_WON, "90000000", "3", lastMonth);
        closed(colleagueClient, DealStatus.CLOSED_WON, "30000000", "2.5", thisMonth);
        closed(astanaClient, DealStatus.CLOSED_WON, "100000000", "3", thisMonth);

        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("an agent's month counts only their own deals won this month")
    void agentSeesOwnMonth() {
        seedMonth();
        signIn(almatyAgent);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("1600000.00");
    }

    @Test
    @DisplayName("a manager's month counts the whole team, and nothing from another agency")
    void managerSeesTeamMonth() {
        seedMonth();
        signIn(almatyManager);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("2350000.00");
        assertThat(dashboardService.getSummary(almatyColleague.getId(), null).getCommissionThisMonth())
                .as("narrowed to one agent").isEqualByComparingTo("750000.00");
        assertThat(dashboardService.getSummary(null, astana.getId()).getCommissionThisMonth())
                .as("asking about another agency returns zero, not their figures")
                .isEqualByComparingTo("0");
    }

    @Test
    @DisplayName("an admin's month counts every agency; an empty month is zero, not null")
    void adminSeesEverythingAndEmptyIsZero() {
        signIn(almatyAgent);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isNotNull().isEqualByComparingTo("0");

        seedMonth();
        signIn(admin);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("5350000.00");
    }

    @Test
    @DisplayName("correcting the rate on a deal won last month leaves it in last month")
    void resavingAWonDealKeepsItsMonth() {
        LocalDateTime lastMonth = LocalDate.now().withDayOfMonth(1).minusDays(3).atTime(12, 0);
        Deal won = closed(agentClient, DealStatus.CLOSED_WON, "50000000", "2", lastMonth);
        entityManager.flush();
        entityManager.clear();

        signIn(almatyAgent);
        DealRequest edit = request(agentClient, "50000000", "2.5");
        edit.setStatus(DealStatus.CLOSED_WON);
        dealService.update(won.getId(), edit);
        dealService.updateStatus(won.getId(), DealStatus.CLOSED_WON);
        entityManager.flush();
        entityManager.clear();

        assertThat(dealRepository.findById(won.getId()).orElseThrow().getClosedAt()).isEqualTo(lastMonth);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("0");
    }

    @Test
    @DisplayName("a deal entered as already won counts toward this month")
    void dealCreatedAsWonCountsThisMonth() {
        signIn(almatyAgent);
        DealRequest request = request(agentClient, "40000000", "2");
        request.setStatus(DealStatus.CLOSED_WON);
        DealResponse created = dealService.create(request);
        entityManager.flush();
        entityManager.clear();

        assertThat(created.getClosedAt()).isNotNull();
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("800000.00");
    }

    // Helpers ------------------------------------------------------------------------

    private MvcResult postDeal(String percent) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("title", "Dostyk 210");
        body.put("clientId", agentClient.getId());
        body.put("agentId", almatyAgent.getId());
        body.put("dealPrice", new BigDecimal("10000000"));
        if (percent != null) {
            body.put("commissionPercent", new BigDecimal(percent));
        }
        return mockMvc.perform(post("/deals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andReturn();
    }

    private DealRequest request(Client client, String price, String percent) {
        DealRequest request = new DealRequest();
        request.setTitle("Deal for " + client.getFullName());
        request.setClientId(client.getId());
        request.setAgentId(client.getAgent().getId());
        request.setDealPrice(price == null ? null : new BigDecimal(price));
        request.setCommissionPercent(percent == null ? null : new BigDecimal(percent));
        return request;
    }

    private Deal closed(Client client, DealStatus status, String price, String percent,
                        LocalDateTime closedAt) {
        return dealRepository.save(Deal.builder()
                .title(status.name()).status(status)
                .client(client).agent(client.getAgent()).team(client.getTeam())
                .dealPrice(new BigDecimal(price))
                .commissionPercent(percent == null ? null : new BigDecimal(percent))
                .closedAt(closedAt)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private User user(String email, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private Client client(String name, User agent) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .agent(agent).team(agent.getTeam())
                .build());
    }
}
