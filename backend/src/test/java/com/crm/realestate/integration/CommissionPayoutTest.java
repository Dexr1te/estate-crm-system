package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.CommissionSplitRepository;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Paying out the shares of a split commission (V58), worked out by hand. Aigul (on her own
 * records) won a 10m sale at 3%: 300 000 of commission, split 50 / 30 / 20 with Dana (also on her
 * own records) and Ivan Petrov of Etazhi: Dana is owed 90 000, Ivan 60 000. An older won rent of
 * Aigul's, 500 000 a month at 50%, gives Timur 40% of 250 000: 100 000. A deal still in
 * negotiation gives Dana a share that is nobody's payout yet. Asel manages Almaty; Yerlan manages
 * Astana, which must learn nothing.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class CommissionPayoutTest extends ChecklistFixture {

    @Autowired private CommissionSplitRepository splitRepository;

    private Deal sale;
    private Deal rent;
    private Deal open;

    @BeforeEach
    void seed() throws Exception {
        LocalDate monthStart = LocalDate.now().withDayOfMonth(1);
        sale = deal("Abay 10", DealStatus.CLOSED_WON, monthStart.atTime(12, 0));
        rent = dealRepository.save(Deal.builder()
                .title("Flat to let").status(DealStatus.CLOSED_WON)
                .kind(com.crm.realestate.enums.DealKind.RENT).client(sale.getClient())
                .agent(agent).team(almaty).monthlyRent(new BigDecimal("500000"))
                .leaseStart(monthStart).leaseEnd(monthStart.plusYears(1))
                .commissionPercent(new BigDecimal("50")).closedAt(monthStart.minusMonths(1).atTime(9, 0))
                .build());
        open = deal("Dostyk 5", DealStatus.NEGOTIATION, null);
        flushAndClear();

        split(sale, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 30),
                Map.of("coBrokerName", "Ivan Petrov", "coBrokerAgency", "Etazhi", "percent", 20))
                .andExpect(status().isOk());
        split(rent, Map.of("userId", agent.getId(), "percent", 60), Map.of("userId", colleague.getId(), "percent", 40))
                .andExpect(status().isOk());
        split(open, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", ownOnly.getId(), "percent", 50))
                .andExpect(status().isOk());
        flushAndClear();
    }

    // Marking paid ----------------------------------------------------------------------------

    @Test
    @DisplayName("the manager marks a share paid with a note, the split says so, and undoing makes it owed again")
    void markAndUndo() throws Exception {
        long dana = shareOf(sale, ownOnly);
        JsonNode body = json(as(manager, pay(sale, dana, "Transfer 4411")).andExpect(status().isOk()));
        JsonNode share = body.get("shares").get(1);
        assertThat(share.get("id").asLong()).isEqualTo(dana);
        assertThat(share.get("paid").asBoolean()).isTrue();
        assertThat(share.get("paidAt").isNull()).isFalse();
        assertThat(share.get("paidById").asLong()).isEqualTo(manager.getId());
        assertThat(share.get("paidByName").asText()).isEqualTo("Asel Nurlanovna");
        assertThat(share.get("payoutNote").asText()).isEqualTo("Transfer 4411");
        assertThat(body.get("shares").get(2).get("paid").asBoolean()).as("Ivan is still owed").isFalse();
        assertThat(body.get("shares").get(0).get("id").isNull()).as("the agent's line has no row").isTrue();
        assertThat(body.get("won").asBoolean()).isTrue();
        assertThat(body.get("payoutsEditable").asBoolean()).isTrue();

        flushAndClear();
        CommissionSplit stored = splitRepository.findById(dana).orElseThrow();
        assertThat(stored.getPaidAt()).isNotNull();
        assertThat(stored.getPayoutNote()).isEqualTo("Transfer 4411");

        // Whoever sees the split sees the payout; only a manager may change it.
        as(agent, get(url(sale))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].paid").value(true))
                .andExpect(jsonPath("$.shares[1].paidByName").value("Asel Nurlanovna"))
                .andExpect(jsonPath("$.payoutsEditable").value(false));

        as(manager, pay(sale, dana, null)).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_PAID"));

        as(manager, delete(payout(sale, dana))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].paid").value(false))
                .andExpect(jsonPath("$.shares[1].paidAt").isEmpty())
                .andExpect(jsonPath("$.shares[1].payoutNote").isEmpty());
        as(manager, delete(payout(sale, dana))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("NOT_PAID"));

        // No body at all is a payout without a note; a blank note is none.
        as(manager, post(payout(sale, dana))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].paid").value(true))
                .andExpect(jsonPath("$.shares[1].payoutNote").isEmpty());
        long ivan = shareOf(sale, null);
        as(manager, pay(sale, ivan, "   ")).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[2].paid").value(true))
                .andExpect(jsonPath("$.shares[2].payoutNote").isEmpty());
    }

    @Test
    @DisplayName("agents get 403 — the deal's agent and the share holder included; an admin may")
    void onlyManagersPay() throws Exception {
        long dana = shareOf(sale, ownOnly);
        for (User who : List.of(agent, ownOnly, colleague)) {
            as(who, pay(sale, dana, null)).andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.code").value("MANAGER_ONLY"));
        }
        as(manager, pay(sale, dana, null)).andExpect(status().isOk());
        as(agent, delete(payout(sale, dana))).andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("MANAGER_ONLY"));

        User admin = user("po-admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        as(admin, delete(payout(sale, dana))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].paid").value(false));
    }

    @Test
    @DisplayName("a share of a deal that is not won cannot be paid; one paid before the deal reopened can be undone")
    void onlyWonDeals() throws Exception {
        as(manager, pay(open, shareOf(open, ownOnly), null)).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DEAL_NOT_WON"));
        as(manager, get(url(open))).andExpect(status().isOk())
                .andExpect(jsonPath("$.won").value(false));

        long dana = shareOf(sale, ownOnly);
        as(manager, pay(sale, dana, null)).andExpect(status().isOk());
        Deal reopened = dealRepository.findById(sale.getId()).orElseThrow();
        reopened.setStatus(DealStatus.NEGOTIATION);
        dealRepository.save(reopened);
        flushAndClear();
        as(manager, delete(payout(sale, dana))).andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[1].paid").value(false));
        as(manager, pay(sale, dana, null)).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DEAL_NOT_WON"));
    }

    @Test
    @DisplayName("another agency's share answers 404, and so does a share named under the wrong deal")
    void teamIsolation() throws Exception {
        long dana = shareOf(sale, ownOnly);
        as(stranger, pay(sale, dana, null)).andExpect(status().isNotFound());
        as(stranger, delete(payout(sale, dana))).andExpect(status().isNotFound());
        as(manager, pay(rent, dana, null)).andExpect(status().isNotFound());
        as(manager, pay(sale, 999_999L, null)).andExpect(status().isNotFound());
        assertThat(splitRepository.findById(dana).orElseThrow().getPaidAt()).isNull();

        JsonNode theirs = json(as(stranger, get("/payouts")).andExpect(status().isOk()));
        assertThat(theirs.get("items")).isEmpty();
        assertThat(theirs.get("unpaidTotal").decimalValue()).isEqualByComparingTo("0");
        as(stranger, get("/payouts").param("agentId", ownOnly.getId().toString()))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("a note takes at most 500 characters")
    void noteLength() throws Exception {
        as(manager, pay(sale, shareOf(sale, ownOnly), "x".repeat(501))).andExpect(status().isBadRequest());
        as(manager, pay(sale, shareOf(sale, ownOnly), "x".repeat(500))).andExpect(status().isOk());
    }

    // Editing a split with a paid share -------------------------------------------------------

    @Test
    @DisplayName("a paid share outlives an edit around it, and refuses one that drops or changes it")
    void paidShareStaysAsPaid() throws Exception {
        as(manager, pay(sale, shareOf(sale, ownOnly), "Cash")).andExpect(status().isOk());
        flushAndClear();

        // Ivan's 20 goes to Aigul; Dana's paid 30 is untouched.
        JsonNode body = json(split(sale, Map.of("userId", agent.getId(), "percent", 70),
                Map.of("userId", ownOnly.getId(), "percent", 30)).andExpect(status().isOk()));
        assertThat(body.get("shares")).hasSize(2);
        assertThat(body.get("shares").get(1).get("paid").asBoolean()).isTrue();
        assertThat(body.get("shares").get(1).get("payoutNote").asText()).isEqualTo("Cash");
        flushAndClear();
        assertThat(splitRepository.findById(shareOf(sale, ownOnly)).orElseThrow().getPaidAt()).isNotNull();

        split(sale, Map.of("userId", agent.getId(), "percent", 60), Map.of("userId", ownOnly.getId(), "percent", 40))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("SHARE_PAID"));
        split(sale, Map.of("userId", agent.getId(), "percent", 100))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("SHARE_PAID"));
        as(agent, delete(url(sale))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("SHARE_PAID"));

        // A paid co-broker is the same party by name and agency, whatever the case.
        long ivanRent = paidCoBrokerOnRent();
        split(rent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", colleague.getId(), "percent", 40),
                Map.of("coBrokerName", "olga kim", "coBrokerAgency", "ETAZHI", "percent", 10))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.shares[2].paid").value(true));
        assertThat(ivanRent).isPositive();
    }

    // The list --------------------------------------------------------------------------------

    @Test
    @DisplayName("the manager sees every unpaid share of the agency's won deals, with the totals and who is owed what")
    void managerList() throws Exception {
        JsonNode body = json(as(manager, get("/payouts")).andExpect(status().isOk()));
        assertThat(body.get("status").asText()).isEqualTo("UNPAID");
        assertThat(body.get("wholeTeam").asBoolean()).isTrue();
        assertThat(body.get("unpaidTotal").decimalValue()).isEqualByComparingTo("250000");
        assertThat(body.get("paidTotal").decimalValue()).isEqualByComparingTo("0");
        assertThat(items(body)).as("the oldest won first; the open deal's share is not a payout").containsExactly(
                "Flat to let / Timur Aliev / 100000.00",
                "Abay 10 / Dana Seitova / 90000.00",
                "Abay 10 / Ivan Petrov / 60000.00");
        JsonNode first = body.get("items").get(1);
        assertThat(first.get("dealId").asLong()).isEqualTo(sale.getId());
        assertThat(first.get("agentId").asLong()).isEqualTo(ownOnly.getId());
        assertThat(first.get("kind").asText()).isEqualTo("COLLEAGUE");
        assertThat(first.get("percent").decimalValue()).isEqualByComparingTo("30");
        assertThat(body.get("items").get(2).get("kind").asText()).isEqualTo("CO_BROKER");
        assertThat(body.get("items").get(2).get("agency").asText()).isEqualTo("Etazhi");
        assertThat(body.get("items").get(2).get("agentId").isNull()).isTrue();
        assertThat(owed(body)).containsExactly(
                "Timur Aliev 100000.00", "Dana Seitova 90000.00", "Ivan Petrov 60000.00");

        as(manager, pay(sale, shareOf(sale, ownOnly), "Transfer 4411")).andExpect(status().isOk());
        flushAndClear();

        body = json(as(manager, get("/payouts")).andExpect(status().isOk()));
        assertThat(body.get("unpaidTotal").decimalValue()).isEqualByComparingTo("160000");
        assertThat(body.get("paidTotal").decimalValue()).isEqualByComparingTo("90000");
        assertThat(items(body)).hasSize(2).noneMatch(line -> line.contains("Dana"));
        assertThat(owed(body)).containsExactly("Timur Aliev 100000.00", "Ivan Petrov 60000.00");

        JsonNode paid = json(as(manager, get("/payouts").param("status", "PAID")).andExpect(status().isOk()));
        assertThat(paid.get("status").asText()).isEqualTo("PAID");
        assertThat(items(paid)).containsExactly("Abay 10 / Dana Seitova / 90000.00");
        JsonNode line = paid.get("items").get(0);
        assertThat(line.get("paid").asBoolean()).isTrue();
        assertThat(line.get("paidAt").isNull()).isFalse();
        assertThat(line.get("paidById").asLong()).isEqualTo(manager.getId());
        assertThat(line.get("paidByName").asText()).isEqualTo("Asel Nurlanovna");
        assertThat(line.get("note").asText()).isEqualTo("Transfer 4411");
        assertThat(paid.get("unpaidTotal").decimalValue()).as("the totals cover both").isEqualByComparingTo("160000");

        // One colleague's, narrowed by agentId.
        JsonNode timur = json(as(manager, get("/payouts").param("agentId", colleague.getId().toString()))
                .andExpect(status().isOk()));
        assertThat(items(timur)).containsExactly("Flat to let / Timur Aliev / 100000.00");
        assertThat(timur.get("unpaidTotal").decimalValue()).isEqualByComparingTo("100000");
        assertThat(timur.get("paidTotal").decimalValue()).isEqualByComparingTo("0");
        as(manager, get("/payouts").param("agentId", stranger.getId().toString())).andExpect(status().isNotFound());
        as(manager, get("/payouts").param("status", "SOMETIME")).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("a reopened deal's shares drop out of the lists, paid or not")
    void reopenedDealDropsOut() throws Exception {
        as(manager, pay(sale, shareOf(sale, ownOnly), null)).andExpect(status().isOk());
        Deal reopened = dealRepository.findById(sale.getId()).orElseThrow();
        reopened.setStatus(DealStatus.NEGOTIATION);
        dealRepository.save(reopened);
        flushAndClear();
        JsonNode body = json(as(manager, get("/payouts")).andExpect(status().isOk()));
        assertThat(items(body)).containsExactly("Flat to let / Timur Aliev / 100000.00");
        assertThat(body.get("paidTotal").decimalValue()).isEqualByComparingTo("0");
    }

    @Test
    @DisplayName("an agent sees only their own shares, whatever their data scope, and is refused someone else's")
    void agentSeesOwn() throws Exception {
        JsonNode dana = json(as(ownOnly, get("/payouts")).andExpect(status().isOk()));
        assertThat(dana.get("wholeTeam").asBoolean()).isFalse();
        assertThat(items(dana)).containsExactly("Abay 10 / Dana Seitova / 90000.00");
        assertThat(dana.get("unpaidTotal").decimalValue()).isEqualByComparingTo("90000");
        assertThat(owed(dana)).containsExactly("Dana Seitova 90000.00");

        JsonNode timur = json(as(colleague, get("/payouts")).andExpect(status().isOk()));
        assertThat(items(timur)).as("Timur sees the whole team's deals, but only his own payouts")
                .containsExactly("Flat to let / Timur Aliev / 100000.00");

        as(ownOnly, get("/payouts").param("agentId", ownOnly.getId().toString())).andExpect(status().isOk());
        as(ownOnly, get("/payouts").param("agentId", colleague.getId().toString()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("OWN_PAYOUTS_ONLY"));

        JsonNode aigul = json(as(agent, get("/payouts")).andExpect(status().isOk()));
        assertThat(aigul.get("items")).as("the deal's agent holds no row of her own").isEmpty();

        as(manager, pay(sale, shareOf(sale, ownOnly), null)).andExpect(status().isOk());
        flushAndClear();
        dana = json(as(ownOnly, get("/payouts").param("status", "PAID")).andExpect(status().isOk()));
        assertThat(items(dana)).containsExactly("Abay 10 / Dana Seitova / 90000.00");
        assertThat(dana.get("unpaidTotal").decimalValue()).isEqualByComparingTo("0");
        assertThat(dana.get("paidTotal").decimalValue()).isEqualByComparingTo("90000");
    }

    @Test
    @DisplayName("an admin names the agency; without one, or without a team, the list asks which")
    void adminNamesTheTeam() throws Exception {
        User admin = user("po-admin2@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        as(admin, get("/payouts")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
        JsonNode body = json(as(admin, get("/payouts").param("teamId", almaty.getId().toString()))
                .andExpect(status().isOk()));
        assertThat(body.get("items")).hasSize(3);
        assertThat(body.get("wholeTeam").asBoolean()).isTrue();
        as(admin, get("/payouts").param("teamId", "999999")).andExpect(status().isNotFound());

        User loner = user("po-loner@almaty.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        as(loner, get("/payouts")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // Fixtures ---------------------------------------------------------------------------------

    private long paidCoBrokerOnRent() throws Exception {
        split(rent, Map.of("userId", agent.getId(), "percent", 50), Map.of("userId", colleague.getId(), "percent", 40),
                Map.of("coBrokerName", "Olga Kim", "coBrokerAgency", "Etazhi", "percent", 10))
                .andExpect(status().isOk());
        flushAndClear();
        long olga = shareOf(rent, null);
        as(manager, pay(rent, olga, null)).andExpect(status().isOk());
        flushAndClear();
        return olga;
    }

    private Deal deal(String title, DealStatus status, LocalDateTime closedAt) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer of " + title).type(ClientType.BUYER).agent(agent).team(almaty).build());
        return dealRepository.save(Deal.builder()
                .title(title).status(status).client(client).agent(agent).team(almaty)
                .dealPrice(new BigDecimal("10000000")).commissionPercent(new BigDecimal("3.00"))
                .closedAt(closedAt).build());
    }

    @SafeVarargs
    private ResultActions split(Deal deal, Map<String, Object>... lines) throws Exception {
        return as(agent, put(url(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of("shares", List.of(lines)))));
    }

    /** The id of the share {@code holder} has on {@code deal}; null for its co-broker's. */
    private long shareOf(Deal deal, User holder) {
        return splitRepository.findByDealIdOrderByPositionAscIdAsc(deal.getId()).stream()
                .filter(s -> holder == null ? s.getUser() == null
                        : s.getUser() != null && s.getUser().getId().equals(holder.getId()))
                .findFirst().orElseThrow().getId();
    }

    private MockHttpServletRequestBuilder pay(Deal deal, long shareId, String note) throws Exception {
        Map<String, Object> body = new java.util.HashMap<>();
        body.put("note", note);
        return post(payout(deal, shareId)).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body));
    }

    private static String url(Deal deal) {
        return "/deals/" + deal.getId() + "/commission-split";
    }

    private static String payout(Deal deal, long shareId) {
        return url(deal) + "/shares/" + shareId + "/payout";
    }

    /** "deal / who / amount", in the list's order. */
    private static List<String> items(JsonNode body) {
        List<String> out = new ArrayList<>();
        body.get("items").forEach(i -> out.add(i.get("dealTitle").asText() + " / " + i.get("agentName").asText()
                + " / " + i.get("amount").decimalValue().setScale(2).toPlainString()));
        return out;
    }

    /** "who amount" for each person still owed, in the list's order. */
    private static List<String> owed(JsonNode body) {
        List<String> out = new ArrayList<>();
        body.get("byAgent").forEach(p -> out.add(p.get("name").asText() + " "
                + p.get("unpaid").decimalValue().setScale(2).toPlainString()));
        return out;
    }
}
