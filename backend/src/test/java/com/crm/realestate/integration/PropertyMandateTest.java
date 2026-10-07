package com.crm.realestate.integration;

import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.MandateType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The seller's agreement on a listing, and the listings whose agreement is running out.
 *
 * <p>An agreement is a type and an optional last day; a day without a type is refused. The
 * running-out list is the agency's listings still on the market whose last day is at most
 * fourteen days away or already gone, soonest first, and never another agency's.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PropertyMandateTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private final LocalDate today = LocalDate.now();

    private Team almaty;
    private Team astana;
    private User agent;
    private User colleague;
    private User stranger;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("manager@astana.kz", Role.MANAGER, DataScope.TEAM, astana);
    }

    // Saving an agreement ---------------------------------------------------------------------

    @Test
    @DisplayName("an agreement sent on create comes back, and an edit can change or clear it")
    void agreementIsSavedAndReturned() throws Exception {
        String created = mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("\"EXCLUSIVE\"", "\"2026-10-12\"")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mandateType").value("EXCLUSIVE"))
                .andExpect(jsonPath("$.mandateEndDate").value("2026-10-12"))
                .andReturn().getResponse().getContentAsString();
        long id = Long.parseLong(created.replaceAll(".*\"id\":(\\d+).*", "$1"));

        mockMvc.perform(get("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(jsonPath("$.mandateType").value("EXCLUSIVE"))
                .andExpect(jsonPath("$.mandateEndDate").value("2026-10-12"));

        mockMvc.perform(put("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("\"OPEN\"", "\"2027-01-31\"")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mandateType").value("OPEN"))
                .andExpect(jsonPath("$.mandateEndDate").value("2027-01-31"));

        mockMvc.perform(put("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("null", "null")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mandateType").value(nullValue()))
                .andExpect(jsonPath("$.mandateEndDate").value(nullValue()));
        Property saved = propertyRepository.findById(id).orElseThrow();
        assertThat(saved.getMandateType()).isNull();
        assertThat(saved.getMandateEndDate()).isNull();
    }

    @Test
    @DisplayName("an exclusive agreement with no end date is fine; a date with no agreement is a 400")
    void endDateNeedsAType() throws Exception {
        mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("\"EXCLUSIVE\"", "null")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mandateType").value("EXCLUSIVE"))
                .andExpect(jsonPath("$.mandateEndDate").value(nullValue()));

        long before = propertyRepository.count();
        for (String bad : List.of(body("null", "\"2026-10-12\""), body("\"SOLE\"", "null"),
                body("\"OPEN\"", "\"12.10.2026\""))) {
            mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                            .contentType(MediaType.APPLICATION_JSON).content(bad))
                    .andExpect(status().isBadRequest());
        }
        assertThat(propertyRepository.count()).isEqualTo(before);

        // Leaving both out records that there is no agreement, as every older listing has.
        mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"title":"No agreement","address":"Abaya 10","type":"APARTMENT","price":1}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mandateType").value(nullValue()));
    }

    // Running out -----------------------------------------------------------------------------

    @Test
    @DisplayName("the running-out list: within fourteen days or gone, still on the market, soonest first")
    void windowQuery() throws Exception {
        listing("Ended last week", PropertyStatus.RESERVED, MandateType.EXCLUSIVE, today.minusDays(7), agent, almaty);
        listing("Ends today", PropertyStatus.AVAILABLE, MandateType.OPEN, today, colleague, almaty);
        listing("Ends in three days", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, today.plusDays(3), agent, almaty);
        listing("Ends in fourteen", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, today.plusDays(14), agent, almaty);
        // None of these belong on it.
        listing("Ends in fifteen", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, today.plusDays(15), agent, almaty);
        listing("No end date", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, null, agent, almaty);
        listing("Sold, ended", PropertyStatus.SOLD, MandateType.EXCLUSIVE, today.minusDays(2), agent, almaty);
        listing("No agreement", PropertyStatus.AVAILABLE, null, null, agent, almaty);

        mockMvc.perform(get("/properties/mandates-ending").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].title").value(contains(
                        "Ended last week", "Ends today", "Ends in three days", "Ends in fourteen")))
                .andExpect(jsonPath("$[0].mandateType").value("EXCLUSIVE"))
                .andExpect(jsonPath("$[0].mandateEndDate").value(today.minusDays(7).toString()))
                .andExpect(jsonPath("$[1].agentName").value("colleague@almaty.kz"));
    }

    @Test
    @DisplayName("the running-out list stays behind the agency wall, and is the whole team's")
    void tenantWall() throws Exception {
        listing("Ours", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, today.plusDays(2), colleague, almaty);
        listing("Theirs", PropertyStatus.AVAILABLE, MandateType.EXCLUSIVE, today.plusDays(1), stranger, astana);

        // An agent with an OWN data scope still sees the colleague's listing: stock is team-wide.
        mockMvc.perform(get("/properties/mandates-ending").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(jsonPath("$[*].title").value(contains("Ours")));
        mockMvc.perform(get("/properties/mandates-ending").header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(jsonPath("$[*].title").value(contains("Theirs")));
    }

    private static String body(String type, String endDate) {
        return """
                {"title":"Agreed flat","address":"Abaya 10","city":"Almaty","type":"APARTMENT",
                 "price":30000000,"mandateType":%s,"mandateEndDate":%s}
                """.formatted(type, endDate);
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private Property listing(String title, PropertyStatus status, MandateType type, LocalDate ends,
                             User owner, Team where) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Almaty street").city("Almaty")
                .type(PropertyType.APARTMENT).status(status)
                .price(new BigDecimal("28000000"))
                .mandateType(type).mandateEndDate(ends)
                .agent(owner).team(where).build());
    }

    private User user(String email, Role role, DataScope scope, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email).phone(null)
                .role(role).dataScope(scope).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
