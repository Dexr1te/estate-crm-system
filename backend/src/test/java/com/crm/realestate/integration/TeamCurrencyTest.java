package com.crm.realestate.integration;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.AgencyCurrency;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ListingShareService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The currency an agency's prices are shown in: USD until a manager says otherwise, set by that
 * agency's manager (or an admin) and nobody else, never converting a single amount.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class TeamCurrencyTest {

    private static final String NB = " ";

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private TeamRepository teamRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private PropertyShareLinkRepository linkRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private ListingShareService shareService;

    private Team almaty;
    private Team astana;
    private User manager;
    private User agent;
    private User otherManager;
    private User admin;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        linkRepository.deleteAll();
        propertyRepository.deleteAll();
        auditLogRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", Role.MANAGER, almaty);
        agent = user("agent@almaty.kz", Role.AGENT, almaty);
        otherManager = user("manager@astana.kz", Role.MANAGER, astana);
        admin = user("admin@crm.kz", Role.ADMIN, null);
    }

    @Test
    @DisplayName("an agency that never chose reads USD, on the team and in the session")
    void defaultsToUsd() throws Exception {
        mockMvc.perform(get("/team").header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("USD"));
        mockMvc.perform(get("/auth/me").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.teamCurrency").value("USD"));
    }

    @Test
    @DisplayName("the manager switches to tenge; amounts stay, the session and audit follow")
    void managerChangesIt() throws Exception {
        Property flat = listing(almaty);

        changeAs(manager, "KZT")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("KZT"))
                .andExpect(jsonPath("$.name").value("Almaty Realty"));

        assertThat(teamRepository.findById(almaty.getId()).orElseThrow().getCurrency())
                .isEqualTo(AgencyCurrency.KZT);
        assertThat(propertyRepository.findById(flat.getId()).orElseThrow().getPrice())
                .as("nothing is converted")
                .isEqualByComparingTo("28000000");
        mockMvc.perform(get("/auth/me").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(jsonPath("$.teamCurrency").value("KZT"))
                .andExpect(jsonPath("$.teamName").value("Almaty Realty"));

        List<AuditLog> entries = auditLogRepository.findAll().stream()
                .filter(a -> a.getAction().equals("CHANGE_TEAM_CURRENCY")).toList();
        assertThat(entries).hasSize(1);
        assertThat(entries.get(0).getEntityId()).isEqualTo(almaty.getId());
        assertThat(entries.get(0).getMetadata()).contains("from=USD").contains("to=KZT");

        changeAs(manager, "KZT").andExpect(status().isOk());
        assertThat(auditLogRepository.findAll().stream()
                .filter(a -> a.getAction().equals("CHANGE_TEAM_CURRENCY")).count())
                .as("choosing the same currency again records nothing")
                .isEqualTo(1);
    }

    @Test
    @DisplayName("an agent cannot change it")
    void agentForbidden() throws Exception {
        changeAs(agent, "KZT").andExpect(status().isForbidden());
        assertThat(teamRepository.findById(almaty.getId()).orElseThrow().getCurrency())
                .isEqualTo(AgencyCurrency.USD);
    }

    @Test
    @DisplayName("another agency's manager changes only their own agency")
    void otherAgencyUntouched() throws Exception {
        changeAs(otherManager, "RUB").andExpect(status().isOk());
        assertThat(teamRepository.findById(astana.getId()).orElseThrow().getCurrency())
                .isEqualTo(AgencyCurrency.RUB);
        assertThat(teamRepository.findById(almaty.getId()).orElseThrow().getCurrency())
                .isEqualTo(AgencyCurrency.USD);
    }

    @Test
    @DisplayName("an unknown or missing code is a 400 and changes nothing")
    void invalidCode() throws Exception {
        changeAs(manager, "GBP").andExpect(status().isBadRequest());
        changeAs(manager, "kzt").andExpect(status().isBadRequest());
        mockMvc.perform(put("/team/currency").header(HttpHeaders.AUTHORIZATION, bearer(manager))
                        .contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest());
        assertThat(teamRepository.findById(almaty.getId()).orElseThrow().getCurrency())
                .isEqualTo(AgencyCurrency.USD);
    }

    @Test
    @DisplayName("an admin sets it through the team update, with a bad code refused")
    void adminSetsIt() throws Exception {
        mockMvc.perform(put("/teams/{id}", astana.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Astana Homes\",\"currency\":\"EUR\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("EUR"));
        mockMvc.perform(put("/teams/{id}", astana.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Astana Homes\",\"currency\":\"XYZ\"}"))
                .andExpect(status().isBadRequest());
        assertThat(auditLogRepository.findAll().stream()
                .anyMatch(a -> a.getAction().equals("CHANGE_TEAM_CURRENCY")
                        && a.getMetadata().contains("to=EUR"))).isTrue();
    }

    @Test
    @DisplayName("the public page prints the price and the price per m² in the agency's currency")
    void publicPageUsesIt() throws Exception {
        Property flat = listing(almaty);
        changeAs(manager, "KZT").andExpect(status().isOk());
        String token = linkFor(flat);

        String ru = page(token, "ru");
        assertThat(ru).contains("28" + NB + "000" + NB + "000" + NB + "₸")
                .contains("448" + NB + "000" + NB + "₸")
                .contains("Цена за м²")
                .doesNotContain("$28");

        String en = page(token, "en");
        assertThat(en).contains("28,000,000" + NB + "₸").contains("448,000" + NB + "₸");

        changeAs(manager, "USD").andExpect(status().isOk());
        assertThat(page(token, "en")).contains("$28,000,000").contains("$448,000");
    }

    // Helpers ------------------------------------------------------------------------------

    private ResultActions changeAs(User who, String code) throws Exception {
        return mockMvc.perform(put("/team/currency")
                .header(HttpHeaders.AUTHORIZATION, bearer(who))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"currency\":\"" + code + "\"}"));
    }

    private String page(String token, String language) throws Exception {
        return mockMvc.perform(get("/l/{token}", token)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, language))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
    }

    private String linkFor(Property which) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
        String url = shareService.create(which.getId()).getUrl();
        SecurityContextHolder.clearContext();
        return url.substring(url.lastIndexOf('/') + 1);
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private Property listing(Team where) {
        return propertyRepository.save(Property.builder()
                .title("Severny Residence, apt 84").address("Dostyk 5").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3).areaSqm(62.5)
                .agent(agent).team(where).build());
    }

    private User user(String email, Role role, Team where) {
        User saved = userRepository.save(User.builder()
                .email(email).password("x").fullName(email).role(role)
                .dataScope(role == Role.AGENT ? DataScope.OWN : DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
        if (role == Role.MANAGER && where != null) {
            where.setManager(saved);
            teamRepository.save(where);
        }
        return saved;
    }
}
