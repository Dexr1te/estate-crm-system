package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.LeadSource;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
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
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * How a client reached the agency: recorded, kept by an older app, cleared, filtered on, carried
 * through a merge, an export and an import, and counted by channel with the ones that bought —
 * and never another agency's clients in any of it.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class LeadSourceTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private EntityManager entityManager;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private User manager;
    private User agent;
    private User colleague;
    private User stranger;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        auditLogRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Arman", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Dana", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("manager@astana.kz", "Timur", Role.MANAGER, DataScope.TEAM, astana);
    }

    @Test
    @DisplayName("a source and its detail are saved, trimmed, and the detail goes with a cleared source")
    void recorded() throws Exception {
        signIn(agent);
        long id = id(create("Aigerim", "REFERRAL", "  Dana, the neighbour  "));
        fetch(id).andExpect(jsonPath("$.leadSource").value("REFERRAL"))
                .andExpect(jsonPath("$.leadSourceDetail").value("Dana, the neighbour"));

        long plain = id(create("Madina", null, "nobody"));
        fetch(plain).andExpect(jsonPath("$.leadSource").doesNotExist())
                .andExpect(jsonPath("$.leadSourceDetail").doesNotExist());

        create("Typo", "BILLBOARD", null).andExpect(status().isBadRequest());
        create("Long", "OTHER", "x".repeat(256)).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("saving without the field keeps the source; an explicit null clears it")
    void olderAppKeepsIt() throws Exception {
        signIn(agent);
        long id = id(create("Aigerim", "PORTAL", "krisha.kz"));

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("fullName", "Aigerim B.");
        body.put("type", "BUYER");
        save(id, body).andExpect(status().isOk())
                .andExpect(jsonPath("$.leadSource").value("PORTAL"))
                .andExpect(jsonPath("$.leadSourceDetail").value("krisha.kz"));

        body.put("leadSource", "SOCIAL");
        body.put("leadSourceDetail", "Instagram");
        save(id, body).andExpect(jsonPath("$.leadSource").value("SOCIAL"))
                .andExpect(jsonPath("$.leadSourceDetail").value("Instagram"));

        body.put("leadSource", null);
        save(id, body).andExpect(jsonPath("$.leadSource").doesNotExist())
                .andExpect(jsonPath("$.leadSourceDetail").doesNotExist());
    }

    @Test
    @DisplayName("the list narrows by source, with the other filters, inside the caller's scope")
    void filter() throws Exception {
        signIn(agent);
        create("Aigerim", "REFERRAL", null);
        create("Madina", "WEBSITE", null);
        create("Seller", "REFERRAL", null, "SELLER");
        signIn(colleague);
        create("Colleague's", "REFERRAL", null);
        signIn(stranger);
        create("Astana", "REFERRAL", null);

        signIn(manager);
        list("leadSource", "REFERRAL").andExpect(jsonPath("$[*].fullName")
                .value(containsInAnyOrder("Aigerim", "Seller", "Colleague's")));
        list("leadSource", "REFERRAL", "type", "BUYER").andExpect(jsonPath("$[*].fullName")
                .value(containsInAnyOrder("Aigerim", "Colleague's")));
        list("leadSource", "REFERRAL", "page", "0", "size", "10")
                .andExpect(jsonPath("$.totalElements").value(3));

        signIn(agent);
        list("leadSource", "REFERRAL").andExpect(jsonPath("$[*].fullName")
                .value(containsInAnyOrder("Aigerim", "Seller")));
        list("leadSource", "NEWSPAPER").andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("a merge keeps the target's own source and fills a blank one from the other card")
    void merge() throws Exception {
        signIn(manager);
        long known = id(create("Aigerim", "REFERRAL", "Dana"));
        long other = id(create("Aigerim B", "PORTAL", "krisha.kz"));
        long blank = id(create("Madina", null, null));
        long source = id(create("Madina K", "WALK_IN", null));

        merge(known, other).andExpect(jsonPath("$.leadSource").value("REFERRAL"))
                .andExpect(jsonPath("$.leadSourceDetail").value("Dana"));
        merge(blank, source).andExpect(jsonPath("$.leadSource").value("WALK_IN"));
    }

    @Test
    @DisplayName("the export writes the source and narrows by it; the import reads it back")
    void exportAndImport() throws Exception {
        signIn(manager);
        create("Aigerim", "REFERRAL", "Dana");
        create("Madina", null, null);

        String all = exportText("lang", "ru");
        assertThat(all).contains("Теги;Источник лида;Источник лида: подробности;Источник;Создан\r\n");
        assertThat(all).contains(";Рекомендация;Dana;Вручную;");
        assertThat(exportText("leadSource", "REFERRAL")).contains("Aigerim").doesNotContain("Madina");
        mockMvc.perform(get("/export/clients").param("leadSource", "NEWSPAPER"))
                .andExpect(status().isBadRequest());

        String csv = "Full name,Phone,Откуда пришёл,Кто порекомендовал\r\n"
                + "Bolat,+77011112233,krisha.kz,\r\n"
                + "Erlan,+77022223344,по рекомендации,Aigerim\r\n"
                + "Gulnara,+77033334455,,\r\n"
                + "Nope,+77044445566,billboard,\r\n";
        MockMultipartFile file = new MockMultipartFile("file", "clients.csv", "text/csv",
                csv.getBytes(StandardCharsets.UTF_8));
        mockMvc.perform(multipart("/import/clients/preview").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mapping[2]").value("leadSource"))
                .andExpect(jsonPath("$.mapping[3]").value("leadSourceDetail"))
                .andExpect(jsonPath("$.validRows").value(3))
                .andExpect(jsonPath("$.problems[0].errors.leadSource").exists());
        mockMvc.perform(multipart("/import/clients/commit").file(file))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created").value(3));
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Bolat"))
                .extracting(Client::getLeadSource).containsExactly(LeadSource.PORTAL);
        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Erlan"))
                .extracting(Client::getLeadSource, Client::getLeadSourceDetail)
                .containsExactly(org.assertj.core.groups.Tuple.tuple(LeadSource.REFERRAL, "Aigerim"));
        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Gulnara"))
                .extracting(Client::getLeadSource).containsOnlyNulls();
    }

    @Test
    @DisplayName("the breakdown counts the period's clients per source and those with a won deal")
    void breakdown() throws Exception {
        LocalDate from = LocalDate.now().withDayOfMonth(1);
        LocalDateTime inPeriod = from.atTime(10, 0);

        Client r1 = client("R1", agent, LeadSource.REFERRAL, inPeriod);
        Client r2 = client("R2", agent, LeadSource.REFERRAL, inPeriod);
        client("R3", colleague, LeadSource.REFERRAL, inPeriod);
        Client p1 = client("P1", agent, LeadSource.PORTAL, inPeriod);
        client("U1", colleague, null, inPeriod);
        Client old = client("Old", agent, LeadSource.PORTAL, from.minusMonths(2).atTime(10, 0));
        Client astana = client("Astana", stranger, LeadSource.REFERRAL, inPeriod);

        deal(r1, DealStatus.CLOSED_WON);
        deal(r1, DealStatus.CLOSED_WON);           // two wins are still one client
        deal(r2, DealStatus.CLOSED_LOST);
        deal(p1, DealStatus.NEGOTIATION);
        deal(old, DealStatus.CLOSED_WON);          // outside the period
        deal(astana, DealStatus.CLOSED_WON);       // another agency
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        breakdown(from, null).andExpect(status().isOk())
                .andExpect(jsonPath("$.clients").value(5))
                .andExpect(jsonPath("$.won").value(1))
                .andExpect(jsonPath("$.sources", hasSize(3)))
                .andExpect(jsonPath("$.sources[0].source").value("REFERRAL"))
                .andExpect(jsonPath("$.sources[0].clients").value(3))
                .andExpect(jsonPath("$.sources[0].won").value(1))
                .andExpect(jsonPath("$.sources[0].conversionRate").value(1.0 / 3))
                .andExpect(jsonPath("$.sources[1].source").value("PORTAL"))
                .andExpect(jsonPath("$.sources[1].clients").value(1))
                .andExpect(jsonPath("$.sources[1].won").value(0))
                .andExpect(jsonPath("$.sources[2].source").value("UNKNOWN"));

        breakdown(from, colleague.getId())
                .andExpect(jsonPath("$.clients").value(2))
                .andExpect(jsonPath("$.won").value(0));

        signIn(agent);
        breakdown(from, null).andExpect(jsonPath("$.clients").value(3))
                .andExpect(jsonPath("$.sources[0].source").value("REFERRAL"))
                .andExpect(jsonPath("$.sources[0].clients").value(2));

        signIn(stranger);
        breakdown(from, null).andExpect(jsonPath("$.clients").value(1))
                .andExpect(jsonPath("$.won").value(1));
        breakdown(from, agent.getId()).andExpect(jsonPath("$.clients").value(0))
                .andExpect(jsonPath("$.sources", hasSize(0)));

        mockMvc.perform(get("/analytics/lead-sources")
                        .param("from", from.toString()).param("to", from.toString()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_PERIOD"));
    }

    // Helpers -----------------------------------------------------------------------------------

    private ResultActions create(String name, String source, String detail) throws Exception {
        return create(name, source, detail, "BUYER");
    }

    private ResultActions create(String name, String source, String detail, String type) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("fullName", name);
        body.put("type", type);
        body.put("leadSource", source);
        body.put("leadSourceDetail", detail);
        return mockMvc.perform(post("/clients").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private ResultActions save(long id, Map<String, Object> body) throws Exception {
        return mockMvc.perform(put("/clients/" + id).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private ResultActions fetch(long id) throws Exception {
        return mockMvc.perform(get("/clients/" + id));
    }

    private ResultActions list(String... params) throws Exception {
        MockHttpServletRequestBuilder request = get("/clients");
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        return mockMvc.perform(request);
    }

    private ResultActions merge(long target, long source) throws Exception {
        return mockMvc.perform(post("/clients/" + target + "/merge")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"sourceId\":" + source + "}"));
    }

    private ResultActions breakdown(LocalDate from, Long agentId) throws Exception {
        MockHttpServletRequestBuilder request = get("/analytics/lead-sources")
                .param("from", from.toString()).param("to", from.plusMonths(1).toString());
        if (agentId != null) {
            request.param("agentId", agentId.toString());
        }
        return mockMvc.perform(request);
    }

    private String exportText(String... params) throws Exception {
        MockHttpServletRequestBuilder request = get("/export/clients");
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        byte[] bytes = mockMvc.perform(request).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsByteArray();
        return new String(bytes, 3, bytes.length - 3, StandardCharsets.UTF_8);
    }

    private long id(ResultActions created) throws Exception {
        JsonNode json = objectMapper.readTree(created.andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString());
        return json.get("id").asLong();
    }

    private Client client(String name, User holder, LeadSource source, LocalDateTime createdAt) {
        Client client = clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER).leadSource(source)
                .agent(holder).team(holder.getTeam()).build());
        entityManager.flush();
        // created_at is stamped on insert and not updatable through the entity.
        entityManager.createNativeQuery("UPDATE clients SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, createdAt).setParameter(2, client.getId()).executeUpdate();
        return client;
    }

    private void deal(Client client, DealStatus status) {
        dealRepository.save(Deal.builder().title(status.name()).status(status)
                .client(client).agent(client.getAgent()).team(client.getTeam()).build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
