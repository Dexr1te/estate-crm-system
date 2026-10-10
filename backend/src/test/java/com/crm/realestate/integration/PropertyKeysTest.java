package com.crm.realestate.integration;

import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyKeyHandover;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.PropertyKeyHandoverRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.AgencyCalendar;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A listing's keys, handed out and taken back. Almaty Realty holds Dostyk 5, Aigul's listing. Aigul
 * and Dana see only their own records, Timur the whole team, Asel manages it; Yerlan manages Astana
 * Homes, which must learn nothing — nor a manager there who was wrongly given the whole platform.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PropertyKeysTest extends ChecklistFixture {

    @Autowired private PropertyRepository propertyRepository;
    @Autowired private PropertyKeyHandoverRepository handoverRepository;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private AgencyCalendar calendar;

    private Property dostyk;
    private LocalDate today;

    @BeforeEach
    void seed() {
        today = calendar.today();
        dostyk = listing("Dostyk 5, flat 12", "Dostyk 5", agent);
        flushAndClear();
    }

    // Reading and writing ---------------------------------------------------------------------

    @Test
    @DisplayName("keys nobody has taken are in the office, with no history")
    void inTheOffice() throws Exception {
        as(agent, get(url(dostyk))).andExpect(status().isOk())
                .andExpect(jsonPath("$.current").value(nullValue()))
                .andExpect(jsonPath("$.history.length()").value(0));
    }

    @Test
    @DisplayName("handed to a colleague, taken back by another, then to the owner by name; history newest first")
    void handOutAndBack() throws Exception {
        JsonNode out = json(handOut(agent, Map.of("holderUserId", colleague.getId(),
                "dueBackAt", today.plusDays(3).toString(), "note", "  Both keys and the fob  "))
                .andExpect(status().isCreated()));
        JsonNode current = out.get("current");
        assertThat(current.get("propertyId").asLong()).isEqualTo(dostyk.getId());
        assertThat(current.get("propertyTitle").asText()).isEqualTo("Dostyk 5, flat 12");
        assertThat(current.get("holderUserId").asLong()).isEqualTo(colleague.getId());
        assertThat(current.get("holderName").asText()).isEqualTo("Timur Aliev");
        assertThat(current.get("note").asText()).isEqualTo("Both keys and the fob");
        assertThat(current.get("dueBackAt").asText()).isEqualTo(today.plusDays(3).toString());
        assertThat(current.get("handedOutByName").asText()).isEqualTo("Aigul Bekova");
        assertThat(current.get("returnedAt").isNull()).isTrue();
        assertThat(current.get("overdue").asBoolean()).isFalse();
        assertThat(out.get("history")).isEmpty();

        as(ownOnly, post(url(dostyk) + "/return")).andExpect(status().isOk())
                .andExpect(jsonPath("$.current").value(nullValue()))
                .andExpect(jsonPath("$.history.length()").value(1))
                .andExpect(jsonPath("$.history[0].holderName").value("Timur Aliev"))
                .andExpect(jsonPath("$.history[0].returnedByName").value("Dana Seitova"))
                .andExpect(jsonPath("$.history[0].returnedAt").isNotEmpty());

        handOut(manager, Map.of("holderName", " Saule, the owner ")).andExpect(status().isCreated())
                .andExpect(jsonPath("$.current.holderUserId").value(nullValue()))
                .andExpect(jsonPath("$.current.holderName").value("Saule, the owner"))
                .andExpect(jsonPath("$.current.dueBackAt").value(nullValue()))
                .andExpect(jsonPath("$.current.handedOutByName").value("Asel Nurlanovna"));
        as(manager, post(url(dostyk) + "/return")).andExpect(status().isOk());

        JsonNode keys = json(as(colleague, get(url(dostyk))).andExpect(status().isOk()));
        assertThat(keys.get("current").isNull()).isTrue();
        List<String> holders = new ArrayList<>();
        keys.get("history").forEach(h -> holders.add(h.get("holderName").asText()));
        assertThat(holders).containsExactly("Saule, the owner", "Timur Aliev");
    }

    @Test
    @DisplayName("the history shows the newest 50")
    void historyIsCapped() throws Exception {
        LocalDateTime start = LocalDateTime.now().minusDays(60);
        for (int i = 0; i < 52; i++) {
            handoverRepository.save(PropertyKeyHandover.builder()
                    .team(almaty).property(dostyk).holderName("Cleaner " + i)
                    .handedOutAt(start.plusDays(i)).returnedAt(start.plusDays(i).plusHours(2))
                    .handedOutBy(agent).returnedBy(agent).build());
        }
        flushAndClear();
        JsonNode keys = json(as(agent, get(url(dostyk))).andExpect(status().isOk()));
        assertThat(keys.get("history")).hasSize(50);
        assertThat(keys.get("history").get(0).get("holderName").asText()).isEqualTo("Cleaner 51");
        assertThat(keys.get("history").get(49).get("holderName").asText()).isEqualTo("Cleaner 2");
    }

    @Test
    @DisplayName("exactly one holder, a due day not past, a short note, and a colleague from the agency")
    void rules() throws Exception {
        handOut(agent, Map.of("holderUserId", colleague.getId(), "holderName", "Saule"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("KEY_HOLDER_REQUIRED"));
        handOut(agent, Map.of()).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("KEY_HOLDER_REQUIRED"));
        handOut(agent, Map.of("holderName", "   ")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("KEY_HOLDER_REQUIRED"));
        handOut(agent, Map.of("holderName", "Saule", "dueBackAt", today.minusDays(1).toString()))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("KEY_DUE_IN_PAST"));
        handOut(agent, Map.of("holderName", "Saule", "note", "x".repeat(501)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.validationErrors.note").exists());
        handOut(agent, Map.of("holderUserId", stranger.getId())).andExpect(status().isNotFound());
        handOut(agent, Map.of("holderUserId", 999_999L)).andExpect(status().isNotFound());

        User gone = user("keys-gone@almaty.kz", "Bolat Omarov", Role.AGENT, DataScope.OWN, almaty);
        gone.setActive(false);
        userRepository.save(gone);
        handOut(agent, Map.of("holderUserId", gone.getId())).andExpect(status().isNotFound());

        assertThat(handoverRepository.findAll()).isEmpty();

        handOut(agent, Map.of("holderUserId", agent.getId(), "dueBackAt", today.toString()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.current.holderName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.current.overdue").value(false));
    }

    @Test
    @DisplayName("keys already out cannot go out again, and keys in the office cannot come back")
    void conflicts() throws Exception {
        as(agent, post(url(dostyk) + "/return")).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("KEY_NOT_OUT"));

        handOut(agent, Map.of("holderName", "Saule")).andExpect(status().isCreated());
        handOut(colleague, Map.of("holderUserId", colleague.getId())).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("KEY_ALREADY_OUT"));

        as(colleague, post(url(dostyk) + "/return")).andExpect(status().isOk());
        as(colleague, post(url(dostyk) + "/return")).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("KEY_NOT_OUT"));
        assertThat(handoverRepository.findAll()).hasSize(1);
    }

    @Test
    @DisplayName("anyone who sees the listing hands its keys out, whatever their data scope; admins too")
    void whoMay() throws Exception {
        Property timurs = listing("Abay 10", "Abay 10", colleague);
        flushAndClear();
        handOut(ownOnly, timurs, Map.of("holderUserId", ownOnly.getId())).andExpect(status().isCreated());
        as(agent, post(url(timurs) + "/return")).andExpect(status().isOk());

        User admin = user("keys-admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        handOut(admin, timurs, Map.of("holderUserId", manager.getId())).andExpect(status().isCreated())
                .andExpect(jsonPath("$.current.holderName").value("Asel Nurlanovna"));
        handOut(admin, dostyk, Map.of("holderUserId", stranger.getId())).andExpect(status().isNotFound());
        assertThat(ids(as(admin, get("/keys/out")))).containsExactly(timurs.getId());
    }

    @Test
    @DisplayName("another agency's listing reads as not found, its keys never show, even to a manager given ALL")
    void otherAgency() throws Exception {
        handOut(agent, Map.of("holderName", "Saule")).andExpect(status().isCreated());
        User wideOpen = user("keys-all@astana.kz", "Nurlan Abenov", Role.MANAGER, DataScope.ALL, astana);
        Property astanas = listing("Mangilik El 20", "Mangilik El 20", stranger);
        flushAndClear();

        for (User outsider : List.of(stranger, wideOpen)) {
            as(outsider, get(url(dostyk))).andExpect(status().isNotFound());
            handOut(outsider, Map.of("holderName", "Someone")).andExpect(status().isNotFound());
            as(outsider, post(url(dostyk) + "/return")).andExpect(status().isNotFound());
            assertThat(ids(as(outsider, get("/keys/out")))).isEmpty();
        }
        handOut(agent, astanas, Map.of("holderName", "Someone")).andExpect(status().isNotFound());
        handOut(stranger, astanas, Map.of("holderUserId", agent.getId())).andExpect(status().isNotFound());
        assertThat(handoverRepository.findAll()).hasSize(1);
        assertThat(handoverRepository.findAll().get(0).getHolderName()).isEqualTo("Saule");
    }

    // Keys out ---------------------------------------------------------------------------------

    @Test
    @DisplayName("the agency's keys out: overdue first, then by the day due, none last; returned ones gone")
    void keysOut() throws Exception {
        Property dueLater = listing("Abay 10", "Abay 10, flat 3", colleague);
        Property noDay = listing("Kok-Tobe house", "Kok-Tobe 1", manager);
        Property dueToday = listing("Esentai Park", "Al-Farabi 77", agent);
        Property returned = listing("Satpayev 30", "Satpayev 30", agent);
        open(dueLater, today.plusDays(5), 3);
        open(noDay, null, 10);
        open(dueToday, today, 1);
        open(dostyk, today.minusDays(2), 6);
        open(returned, today.minusDays(9), 12).setReturnedAt(LocalDateTime.now());
        flushAndClear();

        JsonNode out = json(as(ownOnly, get("/keys/out")).andExpect(status().isOk()));
        assertThat(ids(out)).containsExactly(dostyk.getId(), dueToday.getId(), dueLater.getId(), noDay.getId());
        assertThat(out.get(0).get("overdue").asBoolean()).isTrue();
        assertThat(out.get(0).get("propertyTitle").asText()).isEqualTo("Dostyk 5, flat 12");
        assertThat(out.get(0).get("propertyAddress").asText()).isEqualTo("Dostyk 5");
        assertThat(out.get(0).get("holderName").asText()).isEqualTo("Holder of Dostyk 5, flat 12");
        assertThat(out.get(1).get("overdue").asBoolean()).as("due today is not late yet").isFalse();
        assertThat(out.get(3).get("dueBackAt").isNull()).isTrue();

        assertThat(ids(as(manager, get("/keys/out")))).hasSize(4);
        as(stranger, get("/keys/out")).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
    }

    // Accounts and listings going ---------------------------------------------------------------

    @Test
    @DisplayName("a closed account's keys stay written down under its name; who handed them out is forgotten")
    void closedAccount() throws Exception {
        handOut(ownOnly, Map.of("holderUserId", ownOnly.getId())).andExpect(status().isCreated());
        flushAndClear();
        User admin = user("keys-admin2@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null);
        accountRemovalService.remove(admin, userRepository.findById(ownOnly.getId()).orElseThrow(), null,
                "DELETE_USER");
        flushAndClear();

        as(agent, get(url(dostyk))).andExpect(status().isOk())
                .andExpect(jsonPath("$.current.holderUserId").value(nullValue()))
                .andExpect(jsonPath("$.current.holderName").value("Dana Seitova"))
                .andExpect(jsonPath("$.current.handedOutById").value(nullValue()));
        as(agent, post(url(dostyk) + "/return")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("a deleted listing takes its keys' story with it")
    void deletedListing() throws Exception {
        handOut(agent, Map.of("holderName", "Saule")).andExpect(status().isCreated());
        as(agent, post(url(dostyk) + "/return")).andExpect(status().isOk());
        handOut(agent, Map.of("holderName", "Cleaner")).andExpect(status().isCreated());
        flushAndClear();
        as(manager, delete("/properties/" + dostyk.getId())).andExpect(status().is2xxSuccessful());
        flushAndClear();
        assertThat(handoverRepository.findAll()).isEmpty();
        assertThat(ids(as(manager, get("/keys/out")))).isEmpty();
    }

    // Helpers ----------------------------------------------------------------------------------

    private Property listing(String title, String address, User holder) {
        return propertyRepository.save(Property.builder()
                .title(title).address(address).city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).agent(holder).team(holder.getTeam()).build());
    }

    /** Keys of [property] out to somebody by name for [daysAgo] days, due back on [due]. */
    private PropertyKeyHandover open(Property property, LocalDate due, int daysAgo) {
        return handoverRepository.save(PropertyKeyHandover.builder()
                .team(property.getTeam()).property(property).holderName("Holder of " + property.getTitle())
                .handedOutAt(LocalDateTime.now().minusDays(daysAgo)).dueBackAt(due).handedOutBy(manager).build());
    }

    private static String url(Property property) {
        return "/properties/" + property.getId() + "/keys";
    }

    private ResultActions handOut(User who, Map<String, Object> body) throws Exception {
        return handOut(who, dostyk, body);
    }

    private ResultActions handOut(User who, Property property, Map<String, Object> body) throws Exception {
        return as(who, post(url(property) + "/handover").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(new HashMap<>(body))));
    }

    private List<Long> ids(ResultActions result) throws Exception {
        return ids(json(result.andExpect(status().isOk())));
    }

    private static List<Long> ids(JsonNode list) {
        List<Long> out = new ArrayList<>();
        list.forEach(h -> out.add(h.get("propertyId").asLong()));
        return out;
    }
}
