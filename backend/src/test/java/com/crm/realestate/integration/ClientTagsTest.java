package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.ClientTagRepository;
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
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Tags on clients: typed any way, kept in the agency's own spelling, limited, filtered on, offered
 * back as suggestions with counts, carried through a merge, an export and an import — and never
 * seen from another agency.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ClientTagsTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private EntityManager entityManager;
    @Autowired private ClientRepository clientRepository;
    @Autowired private ClientTagRepository tagRepository;
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
        clientRepository.deleteAll();
        tagRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);
    }

    // Typing ------------------------------------------------------------------------------------

    @Test
    @DisplayName("tags are normalised, repeats dropped, and the agency's first spelling is kept")
    void normalisedAndAgencySpelling() throws Exception {
        signIn(manager);
        create("Aigerim", "BUYER", "  #vip ", "Investor", "investor", "new   build")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tags").value(contains("Investor", "new build", "vip")));

        signIn(colleague);
        create("Madina", "BUYER", "VIP", "INVESTOR, urgent")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tags").value(contains("Investor", "urgent", "vip")));

        assertThat(tagRepository.findAll()).extracting("name")
                .containsExactlyInAnyOrder("vip", "Investor", "new build", "urgent");
    }

    @Test
    @DisplayName("eleven tags or a 33-character one are refused with a code, and nothing is saved")
    void limits() throws Exception {
        signIn(agent);
        String[] eleven = IntStream.range(0, 11).mapToObj(i -> "tag" + i).toArray(String[]::new);
        create("Too many", "BUYER", eleven)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("TOO_MANY_TAGS"));
        create("Too long", "BUYER", "x".repeat(33))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("TAG_TOO_LONG"));
        String[] ten = IntStream.range(0, 10).mapToObj(i -> "tag" + i).toArray(String[]::new);
        create("Ten", "BUYER", ten).andExpect(status().isCreated())
                .andExpect(jsonPath("$.tags.length()").value(10));

        entityManager.flush();
        assertThat(clientRepository.findAll()).extracting(Client::getFullName).containsExactly("Ten");
    }

    @Test
    @DisplayName("saving without tags keeps them, an empty list clears them, and a forgotten tag's casing is free again")
    void updateKeepsClearsAndForgets() throws Exception {
        signIn(agent);
        long id = id(create("Aigerim", "BUYER", "VIP", "urgent"));

        update(id, "Aigerim B.", null).andExpect(status().isOk())
                .andExpect(jsonPath("$.tags").value(contains("urgent", "VIP")));
        get(id).andExpect(jsonPath("$.tags").value(contains("urgent", "VIP")));

        update(id, "Aigerim B.", List.of("urgent")).andExpect(jsonPath("$.tags").value(contains("urgent")));
        update(id, "Aigerim B.", List.of()).andExpect(jsonPath("$.tags.length()").value(0));
        entityManager.flush();
        assertThat(tagRepository.findAll()).as("nobody carries them any more").isEmpty();

        create("Madina", "BUYER", "vip").andExpect(jsonPath("$.tags").value(contains("vip")));
    }

    // Filtering ---------------------------------------------------------------------------------

    @Test
    @DisplayName("the list filters on every tag asked for, in any case, with the other filters and paging")
    void filter() throws Exception {
        signIn(manager);
        long aigerim = id(create("Aigerim", "BUYER", "VIP", "investor"));
        long madina = id(create("Madina", "BUYER", "vip"));
        long timur = id(create("Timur", "SELLER", "Investor"));
        create("Untagged", "BUYER");

        list("tags", "vip").andExpect(status().isOk())
                .andExpect(jsonPath("$[*].id").value(containsInAnyOrder((int) aigerim, (int) madina)));
        list("tags", "VIP", "tags", "#Investor").andExpect(jsonPath("$[*].id").value(contains((int) aigerim)));
        list("tags", "vip,investor").andExpect(jsonPath("$[*].id").value(contains((int) aigerim)));
        list("tags", "investor", "type", "SELLER").andExpect(jsonPath("$[*].id").value(contains((int) timur)));
        list("tags", "vip", "search", "mad").andExpect(jsonPath("$[*].id").value(contains((int) madina)));
        list("tags", "nobody").andExpect(jsonPath("$.length()").value(0));

        list("tags", "vip", "page", "0", "size", "1", "sort", "fullName")
                .andExpect(jsonPath("$.totalElements").value(2))
                .andExpect(jsonPath("$.content.length()").value(1))
                .andExpect(jsonPath("$.content[0].id").value(aigerim));

        // The older unpaged filters answer as they always did.
        list("type", "SELLER").andExpect(jsonPath("$[*].id").value(contains((int) timur)));
        list().andExpect(jsonPath("$.length()").value(4));
    }

    @Test
    @DisplayName("an agent on their own clients filters only what they can see")
    void filterRespectsScope() throws Exception {
        signIn(agent);
        long mine = id(create("Mine", "BUYER", "vip"));
        signIn(colleague);
        create("Theirs", "BUYER", "vip");

        signIn(agent);
        list("tags", "vip").andExpect(jsonPath("$[*].id").value(contains((int) mine)));
    }

    // Suggestions -------------------------------------------------------------------------------

    @Test
    @DisplayName("suggestions are the agency's tags in use, most used first, counted agency-wide")
    void suggestionsWithCounts() throws Exception {
        signIn(colleague);
        create("A", "BUYER", "VIP", "urgent");
        create("B", "BUYER", "vip", "Investor");
        signIn(agent);
        create("C", "BUYER", "vip", "investor");
        create("D", "BUYER", "Ипотека");

        tags().andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(4))
                .andExpect(jsonPath("$[0].name").value("VIP"))
                .andExpect(jsonPath("$[0].count").value(3))
                .andExpect(jsonPath("$[1].name").value("Investor"))
                .andExpect(jsonPath("$[1].count").value(2))
                .andExpect(jsonPath("$[2].name").value("urgent"))
                .andExpect(jsonPath("$[2].count").value(1))
                .andExpect(jsonPath("$[3].name").value("Ипотека"));
    }

    // The tenant wall ---------------------------------------------------------------------------

    @Test
    @DisplayName("another agency's tags are its own words: never suggested, never filtered on, never shared")
    void tenantWall() throws Exception {
        signIn(manager);
        long ours = id(create("Ours", "BUYER", "VIP", "Secret deal"));

        signIn(stranger);
        long theirs = id(create("Theirs", "BUYER", "vip"));
        get(theirs).andExpect(jsonPath("$.tags").value(contains("vip")));
        tags().andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].name").value("vip"))
                .andExpect(jsonPath("$[0].count").value(1));
        list("tags", "secret deal").andExpect(jsonPath("$.length()").value(0));
        list("tags", "vip").andExpect(jsonPath("$[*].id").value(contains((int) theirs)));

        signIn(manager);
        tags().andExpect(jsonPath("$[*].name").value(containsInAnyOrder("VIP", "Secret deal")))
                .andExpect(jsonPath("$[?(@.name == 'VIP')].count").value(contains(1)));
        list("tags", "vip").andExpect(jsonPath("$[*].id").value(contains((int) ours)));

        entityManager.flush();
        assertThat(tagRepository.findAll()).hasSize(3);
    }

    // Merge -------------------------------------------------------------------------------------

    @Test
    @DisplayName("a merge keeps both cards' tags, once each, in the agency's spelling")
    void mergeUnion() throws Exception {
        signIn(manager);
        long target = id(create("Aigerim", "BUYER", "VIP", "investor"));
        long source = id(create("Aigerim B.", "BUYER", "vip", "Urgent"));

        merge(target, source).andExpect(status().isOk())
                .andExpect(jsonPath("$.tags").value(contains("investor", "Urgent", "VIP")));
        entityManager.flush();
        entityManager.clear();
        get(target).andExpect(jsonPath("$.tags").value(contains("investor", "Urgent", "VIP")));
        tags().andExpect(jsonPath("$[?(@.name == 'VIP')].count").value(contains(1)));
        assertThat(auditLogRepository.findAll().get(0).getMetadata()).contains("tags=1");
    }

    @Test
    @DisplayName("a merge past ten tags keeps the target's own first and forgets what did not fit")
    void mergeCapped() throws Exception {
        signIn(manager);
        String[] eight = IntStream.range(0, 8).mapToObj(i -> "own" + i).toArray(String[]::new);
        String[] five = IntStream.range(0, 5).mapToObj(i -> "other" + i).toArray(String[]::new);
        long target = id(create("Target", "BUYER", eight));
        long source = id(create("Source", "BUYER", five));

        String body = merge(target, source).andExpect(status().isOk())
                .andExpect(jsonPath("$.tags.length()").value(10))
                .andReturn().getResponse().getContentAsString();
        List<String> merged = objectMapper.convertValue(objectMapper.readTree(body).get("tags"),
                objectMapper.getTypeFactory().constructCollectionType(List.class, String.class));
        assertThat(merged).containsAll(List.of(eight)).contains("other0", "other1");

        entityManager.flush();
        assertThat(tagRepository.findAll()).as("the three that did not fit are carried by nobody").hasSize(10);
    }

    // Spreadsheets ------------------------------------------------------------------------------

    @Test
    @DisplayName("the export writes the tags in one cell and narrows by them like the list")
    void export() throws Exception {
        signIn(manager);
        create("Aigerim", "BUYER", "VIP", "investor");
        create("Madina", "BUYER");

        String all = exportText();
        assertThat(all).startsWith("Full name,Phone,Email,Type,Agent,City,Property type,Budget from,"
                + "Budget to,Rooms,Area,Notes,Tags,Lead source,Lead source detail,Source,Created\r\n");
        assertThat(all).contains("Aigerim,,,Buyer,Asel Nurlanovna,,,,,,,,\"investor, VIP\",,,Manual,");

        String tagged = exportText("tags", "vip");
        assertThat(tagged).contains("Aigerim").doesNotContain("Madina");
    }

    @Test
    @DisplayName("an imported tags column is read, limited and resolved into the agency's spelling")
    void importTags() throws Exception {
        signIn(manager);
        create("Existing", "BUYER", "VIP");

        String csv = "Full name,Phone,Tags\r\n"
                + "Aigerim,+77011112233,\"vip, #Investor\"\r\n"
                + "Madina,+77022223344,\r\n"
                + "Too many,+77033334455,\"a,b,c,d,e,f,g,h,i,j,k\"\r\n";
        MockMultipartFile file = new MockMultipartFile("file", "clients.csv", "text/csv",
                csv.getBytes(StandardCharsets.UTF_8));

        mockMvc.perform(multipart("/import/clients/preview").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mapping").value(contains("fullName", "phone", "tags")))
                .andExpect(jsonPath("$.validRows").value(2))
                .andExpect(jsonPath("$.problems[0].errors.tags").value("OUT_OF_RANGE"))
                .andExpect(jsonPath("$.sample[0].values.tags").value("vip, Investor"));

        mockMvc.perform(multipart("/import/clients/commit").file(file))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created").value(2));
        entityManager.flush();
        entityManager.clear();

        list("tags", "investor").andExpect(jsonPath("$[0].fullName").value("Aigerim"))
                .andExpect(jsonPath("$[0].tags").value(contains("Investor", "VIP")));
        tags().andExpect(jsonPath("$[0].name").value("VIP")).andExpect(jsonPath("$[0].count").value(2));
    }

    // Helpers -----------------------------------------------------------------------------------

    private ResultActions create(String name, String type, String... tags) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("fullName", name);
        body.put("type", type);
        body.put("tags", List.of(tags));
        return mockMvc.perform(post("/clients").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private ResultActions update(long id, String name, List<String> tags) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("fullName", name);
        body.put("type", "BUYER");
        if (tags != null) {
            body.put("tags", tags);
        }
        return mockMvc.perform(put("/clients/" + id).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private ResultActions get(long id) throws Exception {
        return mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                .get("/clients/" + id));
    }

    private ResultActions list(String... params) throws Exception {
        var request = org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/clients");
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        return mockMvc.perform(request);
    }

    private ResultActions tags() throws Exception {
        return mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                .get("/clients/tags"));
    }

    private ResultActions merge(long target, long source) throws Exception {
        return mockMvc.perform(post("/clients/" + target + "/merge")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"sourceId\":" + source + "}"));
    }

    private String exportText(String... params) throws Exception {
        var request = org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/export/clients");
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
