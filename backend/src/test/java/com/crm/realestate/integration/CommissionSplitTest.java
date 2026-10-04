package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.CommissionSplitRepository;
import com.crm.realestate.repository.RecordChangeRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.RecordHandoverService;
import com.crm.realestate.service.TeamMembershipService;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A deal's commission split, worked out by hand. Aigul (on her own records) won a 10m sale at 3%
 * this month: 300 000 of commission. She shares it 50 / 30 / 20 with Dana (also on her own
 * records) and Ivan Petrov of Etazhi, an outside co-broker: Aigul 150 000, Dana 90 000, Ivan
 * 60 000, and the agency's total is 240 000. Timur sees the whole team; Asel manages it; Yerlan
 * manages Astana, which must learn nothing.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class CommissionSplitTest extends ChecklistFixture {

    @Autowired private CommissionSplitRepository splitRepository;
    @Autowired private RecordChangeRepository changeRepository;
    @Autowired private TeamMembershipService membershipService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private RecordHandoverService recordHandoverService;

    private Deal sale;
    private LocalDate monthStart;

    @BeforeEach
    void seed() {
        monthStart = LocalDate.now().withDayOfMonth(1);
        sale = won(agent, "10000000", "3.00", monthStart.atTime(12, 0));
        flushAndClear();
    }

    // Reading and writing ---------------------------------------------------------------------

    @Test
    @DisplayName("an unsplit deal is all its agent's, and the editor offers the agency's active people")
    void unsplit() throws Exception {
        JsonNode body = json(as(agent, get(url(sale))).andExpect(status().isOk()));
        assertThat(body.get("split").asBoolean()).isFalse();
        assertThat(body.get("editable").asBoolean()).isTrue();
        assertThat(body.get("commission").decimalValue()).isEqualByComparingTo("300000");
        assertThat(body.get("shares")).hasSize(1);
        JsonNode mine = body.get("shares").get(0);
        assertThat(mine.get("kind").asText()).isEqualTo("AGENT");
        assertThat(mine.get("userId").asLong()).isEqualTo(agent.getId());
        assertThat(mine.get("percent").decimalValue()).isEqualByComparingTo("100");
        assertThat(mine.get("amount").decimalValue()).isEqualByComparingTo("300000");

        List<String> colleagues = new ArrayList<>();
        body.get("colleagues").forEach(c -> colleagues.add(c.get("fullName").asText()));
        assertThat(colleagues).containsExactly("Asel Nurlanovna", "Dana Seitova", "Timur Aliev");
    }

    @Test
    @DisplayName("the agent splits it: each share's amount, the agent's the rest, and a line in the change log")
    void split() throws Exception {
        JsonNode body = json(as(agent, splitAs(agent, 50, ownOnly, 30, "Ivan Petrov", "Etazhi", 20))
                .andExpect(status().isOk()));
        assertThat(body.get("split").asBoolean()).isTrue();
        assertThat(amounts(body)).containsExactly(
                Map.entry("AGENT Aigul Bekova", "150000.00"),
                Map.entry("COLLEAGUE Dana Seitova", "90000.00"),
                Map.entry("CO_BROKER Ivan Petrov", "60000.00"));
        assertThat(body.get("shares").get(2).get("agency").asText()).isEqualTo("Etazhi");
        assertThat(splitRepository.findByDealIdOrderByPositionAscIdAsc(sale.getId()))
                .as("the agent holds the rest and has no row").hasSize(2);

        assertThat(splitLines()).containsExactly(new String[]{
                null, "Aigul Bekova 50%, Dana Seitova 30%, Ivan Petrov (Etazhi) 20%"});

        as(manager, delete(url(sale))).andExpect(status().isOk())
                .andExpect(jsonPath("$.split").value(false))
                .andExpect(jsonPath("$.shares[0].amount").value(300000.0));
        assertThat(splitRepository.findByDealIdOrderByPositionAscIdAsc(sale.getId())).isEmpty();
        assertThat(splitLines()).hasSize(2);
        assertThat(splitLines().get(1)[1]).as("cleared reads as not split").isNull();
    }

    @Test
    @DisplayName("a rent's split is a share of one month's rent at the rate")
    void rent() throws Exception {
        Client tenant = clientRepository.save(Client.builder()
                .fullName("Tenant").type(ClientType.BUYER).agent(agent).team(almaty).build());
        Deal rent = dealRepository.save(Deal.builder()
                .title("Flat to let").status(DealStatus.CLOSED_WON).kind(DealKind.RENT).client(tenant)
                .agent(agent).team(almaty).monthlyRent(new BigDecimal("500000"))
                .leaseStart(monthStart).leaseEnd(monthStart.plusYears(1))
                .commissionPercent(new BigDecimal("50")).closedAt(monthStart.atTime(13, 0)).build());
        flushAndClear();

        JsonNode body = json(as(agent, put(url(rent)).contentType(MediaType.APPLICATION_JSON)
                .content(shares(Map.of("userId", agent.getId(), "percent", 60),
                        Map.of("userId", colleague.getId(), "percent", 40))))
                .andExpect(status().isOk()));
        assertThat(body.get("commission").decimalValue()).isEqualByComparingTo("250000");
        assertThat(amounts(body)).containsExactly(
                Map.entry("AGENT Aigul Bekova", "150000.00"),
                Map.entry("COLLEAGUE Timur Aliev", "100000.00"));
    }

    @Test
    @DisplayName("the shares total 100, each to one party, each person once, from the deal's agency and active")
    void rules() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 40))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("SPLIT_TOTAL_NOT_100"));
        save(agent, Map.of("userId", agent.getId(), "percent", 50),
                Map.of("userId", ownOnly.getId(), "coBrokerName", "Ivan", "percent", 50))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("SPLIT_PARTY_REQUIRED"));
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("coBrokerName", " ", "percent", 50))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("SPLIT_PARTY_REQUIRED"));
        save(agent, Map.of("userId", ownOnly.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 50))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("SPLIT_DUPLICATE_PERSON"));
        save(agent, Map.of("userId", agent.getId(), "percent", 0), Map.of("userId", ownOnly.getId(), "percent", 100))
                .andExpect(status().isBadRequest());
        save(agent, Map.of("userId", agent.getId(), "percent", 50.005), Map.of("userId", ownOnly.getId(), "percent", 49.995))
                .andExpect(status().isBadRequest());
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", stranger.getId(), "percent", 50))
                .andExpect(status().isNotFound());

        User gone = user("cs-gone@almaty.kz", "Bolat Omarov", Role.AGENT, DataScope.OWN, almaty);
        gone.setActive(false);
        userRepository.save(gone);
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", gone.getId(), "percent", 50))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("SPLIT_COLLEAGUE_INACTIVE"));

        assertThat(splitRepository.findByDealIdOrderByPositionAscIdAsc(sale.getId())).isEmpty();

        // Leaving the agent out gives them nothing; a deactivated colleague already on the split may stay.
        save(agent, Map.of("userId", colleague.getId(), "percent", 70), Map.of("coBrokerName", "Ivan", "percent", 30))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[0].percent").value(0));
        save(manager, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", colleague.getId(), "percent", 50))
                .andExpect(status().isOk());
        colleague.setActive(false);
        userRepository.save(colleague);
        save(manager, Map.of("userId", agent.getId(), "percent", 40), Map.of("userId", colleague.getId(), "percent", 60))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].active").value(false));
    }

    @Test
    @DisplayName("the deal's agent, a manager or an admin may change it; a colleague with a share may only read it")
    void whoMayEdit() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 70), Map.of("userId", ownOnly.getId(), "percent", 30))
                .andExpect(status().isOk());

        as(ownOnly, get(url(sale))).andExpect(status().isOk())
                .andExpect(jsonPath("$.editable").value(false))
                .andExpect(jsonPath("$.colleagues.length()").value(0));
        save(ownOnly, Map.of("userId", ownOnly.getId(), "percent", 100)).andExpect(status().isForbidden());
        as(ownOnly, delete(url(sale))).andExpect(status().isForbidden());
        save(colleague, Map.of("userId", agent.getId(), "percent", 100))
                .andExpect(status().isForbidden());

        save(manager, Map.of("userId", agent.getId(), "percent", 60), Map.of("userId", ownOnly.getId(), "percent", 40))
                .andExpect(status().isOk());
        User admin = user("cs-admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        save(admin, Map.of("userId", agent.getId(), "percent", 100)).andExpect(status().isOk())
                .andExpect(jsonPath("$.split").value(false));

        as(stranger, get(url(sale))).andExpect(status().isNotFound());
        save(stranger, Map.of("userId", agent.getId(), "percent", 100)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("a colleague on their own records sees a deal they share in, and loses it when the share goes")
    void shareHolderSeesTheDeal() throws Exception {
        as(ownOnly, get("/deals/" + sale.getId())).andExpect(status().isNotFound());
        as(ownOnly, get(url(sale))).andExpect(status().isNotFound());

        save(agent, Map.of("userId", agent.getId(), "percent", 70), Map.of("userId", ownOnly.getId(), "percent", 30))
                .andExpect(status().isOk());
        as(ownOnly, get("/deals/" + sale.getId())).andExpect(status().isOk())
                .andExpect(jsonPath("$.agentName").value("Aigul Bekova"));
        JsonNode list = json(as(ownOnly, get("/deals")).andExpect(status().isOk()));
        assertThat(list).extracting(d -> d.get("id").asLong()).containsExactly(sale.getId());
        as(ownOnly, get("/deals/" + sale.getId() + "/comments")).andExpect(status().isOk());

        as(agent, delete(url(sale))).andExpect(status().isOk());
        as(ownOnly, get("/deals/" + sale.getId())).andExpect(status().isNotFound());
        assertThat(json(as(ownOnly, get("/deals")).andExpect(status().isOk()))).isEmpty();
    }

    // Who is credited --------------------------------------------------------------------------

    @Test
    @DisplayName("the leaderboard credits each person their share; the co-broker's leaves the agency's total")
    void leaderboard() throws Exception {
        splitThreeWays();
        JsonNode board = json(as(manager, get("/analytics/leaderboard")
                .param("from", monthStart.toString()).param("to", monthStart.plusMonths(1).toString()))
                .andExpect(status().isOk()));
        Map<String, BigDecimal> byName = new LinkedHashMap<>();
        Map<String, Long> wonBy = new LinkedHashMap<>();
        board.get("agents").forEach(r -> {
            byName.put(r.get("fullName").asText(), r.get("commission").decimalValue());
            wonBy.put(r.get("fullName").asText(), r.get("dealsWon").asLong());
        });
        assertThat(byName).containsKeys("Aigul Bekova", "Dana Seitova");
        assertThat(byName.get("Aigul Bekova")).isEqualByComparingTo("150000");
        assertThat(byName.get("Dana Seitova")).isEqualByComparingTo("90000");
        assertThat(byName.get("Timur Aliev")).isEqualByComparingTo("0");
        assertThat(wonBy.get("Aigul Bekova")).as("the deal is still Aigul's").isEqualTo(1);
        assertThat(wonBy.get("Dana Seitova")).isZero();
        assertThat(board.get("agents").get(0).get("fullName").asText()).isEqualTo("Aigul Bekova");
        assertThat(board.get("agents").get(1).get("fullName").asText()).isEqualTo("Dana Seitova");
        assertThat(board.get("totals").get("commission").decimalValue()).isEqualByComparingTo("240000");
    }

    @Test
    @DisplayName("monthly goals count each person's share, and the agency's without the co-broker's")
    void goals() throws Exception {
        splitThreeWays();
        String month = YearMonth.now().toString();
        JsonNode team = json(as(manager, get("/goals/team").param("month", month)).andExpect(status().isOk()));
        assertThat(team.get("agency").get("commissionAchieved").decimalValue()).isEqualByComparingTo("240000");
        assertThat(team.get("agency").get("dealsWon").asLong()).isEqualTo(1);
        Map<String, JsonNode> byName = new LinkedHashMap<>();
        team.get("agents").forEach(a -> byName.put(a.get("agentName").asText(), a));
        assertThat(byName.get("Aigul Bekova").get("commissionAchieved").decimalValue()).isEqualByComparingTo("150000");
        assertThat(byName.get("Dana Seitova").get("commissionAchieved").decimalValue()).isEqualByComparingTo("90000");
        assertThat(byName.get("Dana Seitova").get("dealsWon").asLong()).isZero();

        as(ownOnly, get("/goals/me").param("month", month)).andExpect(status().isOk())
                .andExpect(jsonPath("$.commissionAchieved").value(90000.0));
    }

    @Test
    @DisplayName("the dashboard's month: a person's shares, an agency's total less the co-broker, nothing about others on own records")
    void dashboard() throws Exception {
        splitThreeWays();
        assertThat(commission(agent, null)).isEqualByComparingTo("150000");
        assertThat(commission(ownOnly, null)).isEqualByComparingTo("90000");
        assertThat(commission(manager, null)).isEqualByComparingTo("240000");
        assertThat(commission(colleague, null)).as("Timur sees the team").isEqualByComparingTo("240000");
        assertThat(commission(manager, ownOnly.getId())).isEqualByComparingTo("90000");
        assertThat(commission(manager, agent.getId())).isEqualByComparingTo("150000");
        assertThat(commission(ownOnly, agent.getId())).as("own records only").isEqualByComparingTo("0");
        assertThat(commission(stranger, null)).isEqualByComparingTo("0");
        assertThat(commission(stranger, ownOnly.getId())).isEqualByComparingTo("0");
    }

    @Test
    @DisplayName("the CSV export says who gets what")
    void export() throws Exception {
        splitThreeWays();
        byte[] bytes = as(manager, get("/export/deals").param("lang", "en"))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsByteArray();
        String text = new String(bytes, StandardCharsets.UTF_8);
        assertThat(text).contains("Lost note,Commission split\r\n")
                .contains(",\"Aigul Bekova 50%, Dana Seitova 30%, Ivan Petrov (Etazhi) 20%\"\r\n");
    }

    // Handing over -----------------------------------------------------------------------------

    @Test
    @DisplayName("someone taken off the team hands their share to the successor, added to one the successor has")
    void removedMemberHandsOverTheShare() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 30),
                Map.of("userId", colleague.getId(), "percent", 20)).andExpect(status().isOk());

        membershipService.removeMember(userRepository.findById(manager.getId()).orElseThrow(),
                ownOnly.getId(), colleague.getId());
        flushAndClear();

        assertThat(shares()).containsExactly(Map.entry("Timur Aliev", "50.00"));
        assertThat(splitLines()).last().satisfies(line -> assertThat(line).containsExactly(
                "Aigul Bekova 50%, Dana Seitova 30%, Timur Aliev 20%", "Aigul Bekova 50%, Timur Aliev 50%"));
    }

    @Test
    @DisplayName("a share handed to the deal's own agent becomes part of what they hold")
    void shareHandedToTheDealsAgent() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 70), Map.of("userId", ownOnly.getId(), "percent", 30))
                .andExpect(status().isOk());
        membershipService.removeMember(userRepository.findById(manager.getId()).orElseThrow(),
                ownOnly.getId(), agent.getId());
        flushAndClear();
        assertThat(shares()).isEmpty();
    }

    @Test
    @DisplayName("when the deal's agent leaves, a successor who had a share holds the deal and the share is theirs")
    void agentLeavesToAShareHolder() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", colleague.getId(), "percent", 30),
                Map.of("coBrokerName", "Ivan Petrov", "percent", 20)).andExpect(status().isOk());
        membershipService.removeMember(userRepository.findById(manager.getId()).orElseThrow(),
                agent.getId(), colleague.getId());
        flushAndClear();

        JsonNode body = json(as(colleague, get(url(sale))).andExpect(status().isOk()));
        assertThat(amounts(body)).containsExactly(
                Map.entry("AGENT Timur Aliev", "240000.00"),
                Map.entry("CO_BROKER Ivan Petrov", "60000.00"));
    }

    @Test
    @DisplayName("a deal given to someone with a share in it folds the share in; their other shares are not records")
    void dealMovedByHand() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 60), Map.of("userId", colleague.getId(), "percent", 40))
                .andExpect(status().isOk());
        flushAndClear();
        Deal deal = dealRepository.findById(sale.getId()).orElseThrow();
        User timur = userRepository.findById(colleague.getId()).orElseThrow();
        recordHandoverService.move(RecordHandoverService.Records.of(List.of(), List.of(), List.of(deal),
                List.of(), List.of()), timur, userRepository.findById(manager.getId()).orElseThrow());
        flushAndClear();
        assertThat(shares()).isEmpty();
        assertThat(splitLines()).last().satisfies(line -> assertThat(line)
                .containsExactly("Aigul Bekova 60%, Timur Aliev 40%", null));
    }

    @Test
    @DisplayName("a closed account's share goes to its successor, or back to the deal's agent with none")
    void closedAccount() throws Exception {
        User admin = user("cs-admin2@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        save(agent, Map.of("userId", agent.getId(), "percent", 70), Map.of("userId", ownOnly.getId(), "percent", 30))
                .andExpect(status().isOk());
        accountRemovalService.remove(admin, userRepository.findById(ownOnly.getId()).orElseThrow(),
                colleague.getId(), "DELETE_USER");
        flushAndClear();
        assertThat(shares()).containsExactly(Map.entry("Timur Aliev", "30.00"));

        accountRemovalService.remove(admin, userRepository.findById(colleague.getId()).orElseThrow(),
                null, "DELETE_USER");
        flushAndClear();
        assertThat(shares()).isEmpty();
        as(agent, get(url(sale))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[0].percent").value(100));
    }

    // Helpers ----------------------------------------------------------------------------------

    private void splitThreeWays() throws Exception {
        save(agent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 30),
                Map.of("coBrokerName", "Ivan Petrov", "coBrokerAgency", "Etazhi", "percent", 20))
                .andExpect(status().isOk());
        flushAndClear();
    }

    private Deal won(User holder, String price, String rate, LocalDateTime closedAt) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer").type(ClientType.BUYER).agent(holder).team(holder.getTeam()).build());
        return dealRepository.save(Deal.builder()
                .title("Abay 10").status(DealStatus.CLOSED_WON).client(client).agent(holder).team(holder.getTeam())
                .dealPrice(new BigDecimal(price)).commissionPercent(new BigDecimal(rate))
                .closedAt(closedAt).build());
    }

    private static String url(Deal deal) {
        return "/deals/" + deal.getId() + "/commission-split";
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder splitAs(
            User who, int mine, User other, int theirs, String coBroker, String agency, int brokers) throws Exception {
        return put(url(sale)).contentType(MediaType.APPLICATION_JSON).content(shares(
                Map.of("userId", who.getId(), "percent", mine),
                Map.of("userId", other.getId(), "percent", theirs),
                Map.of("coBrokerName", coBroker, "coBrokerAgency", agency, "percent", brokers)));
    }

    @SafeVarargs
    private org.springframework.test.web.servlet.ResultActions save(User who, Map<String, Object>... lines) throws Exception {
        return as(who, put(url(sale)).contentType(MediaType.APPLICATION_JSON).content(shares(lines)));
    }

    @SafeVarargs
    private String shares(Map<String, Object>... lines) throws Exception {
        return objectMapper.writeValueAsString(Map.of("shares", List.of(lines)));
    }

    /** "KIND name" to the amount, in the response's order. */
    private static List<Map.Entry<String, String>> amounts(JsonNode body) {
        List<Map.Entry<String, String>> out = new ArrayList<>();
        body.get("shares").forEach(s -> out.add(Map.entry(
                s.get("kind").asText() + " " + s.get("name").asText(),
                s.get("amount").decimalValue().setScale(2).toPlainString())));
        return out;
    }

    /** The stored shares of the sale: name to percent. */
    private List<Map.Entry<String, String>> shares() {
        List<Map.Entry<String, String>> out = new ArrayList<>();
        for (CommissionSplit s : splitRepository.findByDealIdOrderByPositionAscIdAsc(sale.getId())) {
            out.add(Map.entry(s.getUser() == null ? s.getCoBrokerName() : s.getUser().getFullName(),
                    s.getSharePercent().setScale(2).toPlainString()));
        }
        return out;
    }

    /** The sale's change log lines for its split, oldest first: [before, after]. */
    private List<String[]> splitLines() {
        return changeRepository.findAll().stream()
                .filter(c -> c.getEntityType() == ChangeEntityType.DEAL && c.getEntityId().equals(sale.getId()))
                .filter(c -> "commissionSplit".equals(c.getField()))
                .sorted(java.util.Comparator.comparing(RecordChange::getId))
                .map(c -> new String[]{c.getOldValue(), c.getNewValue()})
                .toList();
    }

    private BigDecimal commission(User who, Long agentId) throws Exception {
        var request = get("/dashboard/summary");
        if (agentId != null) request.param("agentId", agentId.toString());
        return json(as(who, request).andExpect(status().isOk())).get("commissionThisMonth").decimalValue();
    }
}
