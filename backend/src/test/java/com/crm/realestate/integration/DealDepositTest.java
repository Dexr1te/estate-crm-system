package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.DealDeposit;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.AgencyCurrency;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.DepositHolder;
import com.crm.realestate.enums.DepositOutcome;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealDepositRepository;
import com.crm.realestate.repository.PropertyRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The deposit a buyer puts down on a deal: recorded, corrected and closed by the deal's agent or a
 * manager, written into the deal's discussion, holding the deal's listing — reserved on the listing
 * and kept out of matching — and listed when its hold runs out. Behind exactly the deal's walls.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DealDepositTest extends ChecklistFixture {

    @Autowired private DealDepositRepository depositRepository;
    @Autowired private DealCommentRepository commentRepository;
    @Autowired private PropertyRepository propertyRepository;

    private final LocalDate today = LocalDate.now();

    // Recording -------------------------------------------------------------------------------

    @Test
    @DisplayName("a recorded deposit comes back, reserves the listing and is written into the discussion")
    void recordAndHold() throws Exception {
        almaty.setCurrency(AgencyCurrency.KZT);
        teamRepository.save(almaty);
        Deal deal = dealOn("Dostyk 5", agent, almaty, listing("Dostyk 5", almaty));

        as(agent, post(depositsUrl(deal)).header("Accept-Language", "en")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body("500000", "2026-10-01", "2026-10-20", "AGENCY", "\"Receipt 12\"")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(500000))
                .andExpect(jsonPath("$.receivedOn").value("2026-10-01"))
                .andExpect(jsonPath("$.holdUntil").value("2026-10-20"))
                .andExpect(jsonPath("$.holder").value("AGENCY"))
                .andExpect(jsonPath("$.note").value("Receipt 12"))
                .andExpect(jsonPath("$.active").value(true))
                .andExpect(jsonPath("$.outcome").value(nullValue()))
                .andExpect(jsonPath("$.dealTitle").value("Dostyk 5"))
                .andExpect(jsonPath("$.propertyTitle").value("Dostyk 5"))
                .andExpect(jsonPath("$.clientName").value("Buyer of Dostyk 5"));

        as(colleague, get(depositsUrl(deal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1));
        as(agent, get("/properties/" + deal.getProperty().getId()))
                .andExpect(jsonPath("$.depositHoldUntil").value("2026-10-20"));
        as(agent, get("/properties"))
                .andExpect(jsonPath("$[0].depositHoldUntil").value("2026-10-20"));
        as(agent, get("/properties").param("page", "0"))
                .andExpect(jsonPath("$.content[0].depositHoldUntil").value("2026-10-20"));

        assertThat(notes(deal)).containsExactly(
                "Deposit recorded: 500,000\u00a0₸, held by the agency until 20.10.2026.");
    }

    @Test
    @DisplayName("what is refused: a bad amount or dates, a second active deposit, a closed deal")
    void validation() throws Exception {
        Deal deal = dealOn("Flat", agent, almaty, null);
        for (String bad : List.of(
                body("0", "2026-10-01", "2026-10-20", "AGENCY", "null"),
                body("-5", "2026-10-01", "2026-10-20", "AGENCY", "null"),
                body("100", null, "2026-10-20", "AGENCY", "null"),
                body("100", "2026-10-01", "2026-10-20", "BANK", "null"),
                body("100", "2026-10-01", "2026-10-20", null, "null"))) {
            as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON).content(bad))
                    .andExpect(status().isBadRequest());
        }
        as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(body("100", "2026-10-10", "2026-10-09", "SELLER", "null")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("DEPOSIT_HOLD_BEFORE_RECEIVED"));
        assertThat(depositRepository.findByDealIdOrderByIdDesc(deal.getId())).isEmpty();

        as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(body("100", "2026-10-10", "2026-10-10", "NOTARY", "null")))
                .andExpect(status().isCreated());
        as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(body("200", "2026-10-11", "2026-10-20", "NOTARY", "null")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DEPOSIT_ALREADY_ACTIVE"));

        Deal lost = dealOn("Lost flat", agent, almaty, null);
        lost.setStatus(DealStatus.CLOSED_LOST);
        dealRepository.save(lost);
        as(agent, post(depositsUrl(lost)).contentType(MediaType.APPLICATION_JSON)
                .content(body("100", "2026-10-10", "2026-10-20", "AGENCY", "null")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DEAL_CLOSED"));
    }

    @Test
    @DisplayName("the deal's agent or a manager changes it; others read it or do not see it at all")
    void rights() throws Exception {
        Deal deal = dealOn("Flat", agent, almaty, null);
        String body = body("100", "2026-10-01", "2026-10-20", "AGENCY", "null");
        as(colleague, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isForbidden());
        as(ownOnly, get(depositsUrl(deal))).andExpect(status().isNotFound());
        as(stranger, get(depositsUrl(deal))).andExpect(status().isNotFound());
        as(stranger, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isNotFound());

        long id = json(as(manager, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())).get("id").asLong();
        as(colleague, put(depositsUrl(deal) + "/" + id).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isForbidden());
        as(stranger, post(depositsUrl(deal) + "/" + id + "/close").contentType(MediaType.APPLICATION_JSON)
                .content("{\"outcome\":\"REFUNDED\",\"closedOn\":\"2026-10-05\"}"))
                .andExpect(status().isNotFound());

        // A deposit of another deal is not reachable through this one.
        Deal other = dealOn("Other", agent, almaty, null);
        as(agent, put(depositsUrl(other) + "/" + id).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isNotFound());
    }

    // Changing and closing --------------------------------------------------------------------

    @Test
    @DisplayName("an active deposit is corrected; once closed it frees the listing and stays as history")
    void editAndClose() throws Exception {
        Deal deal = dealOn("Flat", agent, almaty, listing("Flat", almaty));
        long id = json(as(agent, post(depositsUrl(deal)).header("Accept-Language", "ru")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body("100000", "2026-10-01", "2026-10-20", "SELLER", "null")))).get("id").asLong();

        as(agent, put(depositsUrl(deal) + "/" + id).header("Accept-Language", "ru")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body("150000", "2026-10-01", "2026-10-25", "NOTARY", "\"  \"")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.amount").value(150000))
                .andExpect(jsonPath("$.holdUntil").value("2026-10-25"))
                .andExpect(jsonPath("$.holder").value("NOTARY"))
                .andExpect(jsonPath("$.note").value(nullValue()));
        // Saving the same again writes nothing new into the discussion.
        as(agent, put(depositsUrl(deal) + "/" + id).contentType(MediaType.APPLICATION_JSON)
                .content(body("150000.00", "2026-10-01", "2026-10-25", "NOTARY", "null")))
                .andExpect(status().isOk());

        as(agent, post(depositsUrl(deal) + "/" + id + "/close").contentType(MediaType.APPLICATION_JSON)
                .content("{\"outcome\":\"REFUNDED\",\"closedOn\":\"2026-09-30\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("DEPOSIT_CLOSED_BEFORE_RECEIVED"));
        as(agent, post(depositsUrl(deal) + "/" + id + "/close").contentType(MediaType.APPLICATION_JSON)
                .content("{\"outcome\":\"SPENT\",\"closedOn\":\"2026-10-05\"}"))
                .andExpect(status().isBadRequest());
        as(agent, post(depositsUrl(deal) + "/" + id + "/close").header("Accept-Language", "ru")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"outcome\":\"REFUNDED\",\"closedOn\":\"2026-10-05\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.active").value(false))
                .andExpect(jsonPath("$.outcome").value("REFUNDED"))
                .andExpect(jsonPath("$.closedOn").value("2026-10-05"));

        as(agent, put(depositsUrl(deal) + "/" + id).contentType(MediaType.APPLICATION_JSON)
                .content(body("1", "2026-10-01", "2026-10-25", "NOTARY", "null")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DEPOSIT_CLOSED"));
        as(agent, get("/properties/" + deal.getProperty().getId()))
                .andExpect(jsonPath("$.depositHoldUntil").value(nullValue()));

        // A new deposit may follow; the old one stays below it.
        as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(body("90000", "2026-10-06", "2026-10-30", "AGENCY", "null")))
                .andExpect(status().isCreated());
        as(agent, get(depositsUrl(deal)))
                .andExpect(jsonPath("$[*].active").value(contains(true, false)));

        // No Accept-Language means Russian, like the agency's defaults.
        assertThat(notes(deal)).containsExactly(
                "Внесён задаток: 100\u00a0000\u00a0$, хранится у продавца до 20.10.2026.",
                "Задаток изменён: 150\u00a0000\u00a0$, хранится у нотариуса до 25.10.2026.",
                "Задаток возвращён покупателю 05.10.2026.",
                "Внесён задаток: 90\u00a0000\u00a0$, хранится у агентства до 30.10.2026.");
    }

    @Test
    @DisplayName("winning the deal applies the active deposit to the purchase, today")
    void winApplies() throws Exception {
        Deal deal = dealOn("Flat", agent, almaty, listing("Flat", almaty));
        long id = json(as(agent, post(depositsUrl(deal)).contentType(MediaType.APPLICATION_JSON)
                .content(body("100", today.minusDays(3).toString(), today.plusDays(10).toString(), "AGENCY",
                        "null")))).get("id").asLong();

        as(agent, patch("/deals/" + deal.getId() + "/status").header("Accept-Language", "kk")
                .param("status", "CLOSED_WON"))
                .andExpect(status().isOk());
        flushAndClear();
        DealDeposit applied = depositRepository.findById(id).orElseThrow();
        assertThat(applied.getOutcome()).isEqualTo(DepositOutcome.APPLIED);
        assertThat(applied.getClosedOn()).isEqualTo(today);
        assertThat(notes(deal)).last().asString().startsWith("Кепілпұл ").endsWith("сатып алу есебіне жатқызылды.");
    }

    // Ending ----------------------------------------------------------------------------------

    @Test
    @DisplayName("ending: active holds within seven days or gone, soonest first, scoped like deals")
    void ending() throws Exception {
        deposit(dealOn("Gone", agent, almaty, null), today.minusDays(2), null);
        deposit(dealOn("Today", colleague, almaty, null), today, null);
        deposit(dealOn("In seven", agent, almaty, null), today.plusDays(7), null);
        // None of these belong on it.
        deposit(dealOn("In eight", agent, almaty, null), today.plusDays(8), null);
        deposit(dealOn("Refunded", agent, almaty, null), today.minusDays(1), DepositOutcome.REFUNDED);
        deposit(dealOn("Theirs", stranger, astana, null), today, null);

        as(agent, get("/deals/deposits-ending"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].dealTitle").value(contains("Gone", "In seven")));
        as(manager, get("/deals/deposits-ending"))
                .andExpect(jsonPath("$[*].dealTitle").value(contains("Gone", "Today", "In seven")))
                .andExpect(jsonPath("$[1].agentName").value("Timur Aliev"));
        as(stranger, get("/deals/deposits-ending"))
                .andExpect(jsonPath("$[*].dealTitle").value(contains("Theirs")));
        as(ownOnly, get("/deals/deposits-ending"))
                .andExpect(jsonPath("$").value(empty()));
    }

    // Matching --------------------------------------------------------------------------------

    @Test
    @DisplayName("a listing held by a deposit is not offered as a match, until the deposit ends")
    void heldListingsAreNotMatches() throws Exception {
        Property held = listing("Held flat", almaty);
        Property free = listing("Free flat", almaty);
        Client buyer = clientRepository.save(Client.builder()
                .fullName("Irina Sokolova").type(ClientType.BUYER).wantedType(PropertyType.APARTMENT)
                .budgetMax(new BigDecimal("40000000")).agent(agent).team(almaty).build());
        Deal deal = dealOn("Someone else's deal", agent, almaty, held);
        // Whatever the status says: someone set it back to available by hand.
        held.setStatus(PropertyStatus.AVAILABLE);
        propertyRepository.save(held);
        DealDeposit deposit = deposit(deal, today.plusDays(10), null);

        as(agent, get("/clients/" + buyer.getId() + "/matches"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].property.title").value(contains("Free flat")));

        deposit.setOutcome(DepositOutcome.FORFEITED);
        deposit.setClosedOn(today);
        depositRepository.save(deposit);
        as(agent, get("/clients/" + buyer.getId() + "/matches"))
                .andExpect(jsonPath("$.length()").value(2));
    }

    private static String depositsUrl(Deal deal) {
        return "/deals/" + deal.getId() + "/deposits";
    }

    private static String body(String amount, String received, String until, String holder, String note) {
        return """
                {"amount":%s,"receivedOn":%s,"holdUntil":%s,"holder":%s,"note":%s}
                """.formatted(amount, quoted(received), quoted(until), quoted(holder), note);
    }

    private static String quoted(String value) {
        return value == null ? "null" : "\"" + value + "\"";
    }

    private List<String> notes(Deal deal) {
        flushAndClear();
        List<DealComment> latest = new java.util.ArrayList<>(
                commentRepository.findLatest(deal.getId(), null, PageRequest.of(0, 50)));
        java.util.Collections.reverse(latest);
        return latest.stream().map(DealComment::getBody).toList();
    }

    private Property listing(String title, Team team) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Almaty street").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("30000000"))
                .agent(manager).team(team).build());
    }

    private Deal dealOn(String title, User holder, Team team, Property property) {
        Deal deal = oldDeal(title, holder, team);
        if (property != null) {
            deal.setProperty(property);
            property.setStatus(PropertyStatus.RESERVED);
            propertyRepository.save(property);
            deal = dealRepository.save(deal);
        }
        return deal;
    }

    private DealDeposit deposit(Deal deal, LocalDate holdUntil, DepositOutcome outcome) {
        return depositRepository.save(DealDeposit.builder()
                .deal(deal).team(deal.getTeam())
                .amount(new BigDecimal("100000"))
                .receivedOn(holdUntil.minusDays(20)).holdUntil(holdUntil)
                .holder(DepositHolder.AGENCY)
                .outcome(outcome).closedOn(outcome == null ? null : holdUntil)
                .build());
    }
}
