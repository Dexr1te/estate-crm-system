package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealStatusChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DealStatusChangeRepository;
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
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;

/**
 * A lost deal says why, on every way a deal can get lost — creating it lost, editing it to lost,
 * or moving it on the board — and forgets why once it is reopened. Every move leaves a row in the
 * status history, which is what the funnel reads.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class DealLostReasonTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private DealStatusChangeRepository changeRepository;
    @Autowired private EntityManager entityManager;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private User agent;
    private Client client;

    @BeforeEach
    void setUp() {
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        Team team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = userRepository.save(User.builder()
                .email("agent@almaty.kz").password("x").fullName("Aigerim")
                .role(Role.AGENT).dataScope(DataScope.OWN).team(team)
                .status(UserStatus.ACTIVE).isActive(true).build());
        client = clientRepository.save(Client.builder()
                .fullName("Daniyar").type(ClientType.BUYER).agent(agent).team(team).build());
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
    }

    @Test
    @DisplayName("losing a deal without a reason is refused on create, edit and the board")
    void reasonIsRequiredOnEveryPath() throws Exception {
        MvcResult created = create("CLOSED_LOST", null, null);
        assertThat(created.getResponse().getStatus()).isEqualTo(400);
        assertThat(json(created).get("code").asText()).isEqualTo("LOST_REASON_REQUIRED");

        long id = newLead();
        assertThat(update(id, "CLOSED_LOST", null, null).getResponse().getStatus()).isEqualTo(400);
        MvcResult moved = move(id, "CLOSED_LOST", null, null);
        assertThat(moved.getResponse().getStatus()).isEqualTo(400);
        assertThat(json(moved).get("code").asText()).isEqualTo("LOST_REASON_REQUIRED");

        assertThat(json(mockMvc.perform(get("/deals/" + id)).andReturn()).get("status").asText())
                .as("a refused move leaves the deal where it was").isEqualTo("LEAD");
    }

    @Test
    @DisplayName("a reason and a note are kept on each path, and a note over 500 characters is refused")
    void reasonAndNoteAreStored() throws Exception {
        JsonNode created = json(create("CLOSED_LOST", "PRICE", "  Found it cheaper  "));
        assertThat(created.get("lostReason").asText()).isEqualTo("PRICE");
        assertThat(created.get("lostNote").asText()).isEqualTo("Found it cheaper");

        JsonNode edited = json(update(newLead(), "CLOSED_LOST", "FINANCING", null));
        assertThat(edited.get("lostReason").asText()).isEqualTo("FINANCING");
        assertThat(edited.get("lostNote").isNull()).isTrue();

        JsonNode moved = json(move(newLead(), "CLOSED_LOST", "NO_RESPONSE", "Stopped answering"));
        assertThat(moved.get("lostReason").asText()).isEqualTo("NO_RESPONSE");
        assertThat(moved.get("lostNote").asText()).isEqualTo("Stopped answering");

        String tooLong = "x".repeat(501);
        assertThat(create("CLOSED_LOST", "OTHER", tooLong).getResponse().getStatus()).isEqualTo(400);
        assertThat(move(newLead(), "CLOSED_LOST", "OTHER", tooLong).getResponse().getStatus())
                .isEqualTo(400);
    }

    @Test
    @DisplayName("reopening a lost deal clears the reason; re-saving it lost keeps what is there")
    void leavingLostClearsTheReason() throws Exception {
        long id = json(create("CLOSED_LOST", "CHOSE_ANOTHER", "Went with another agency"))
                .get("id").asLong();

        JsonNode resaved = json(update(id, "CLOSED_LOST", null, null));
        assertThat(resaved.get("lostReason").asText()).isEqualTo("CHOSE_ANOTHER");

        JsonNode reopened = json(move(id, "NEGOTIATION", null, null));
        assertThat(reopened.get("lostReason").isNull()).isTrue();
        assertThat(reopened.get("lostNote").isNull()).isTrue();

        JsonNode lostAgain = json(update(id, "CLOSED_LOST", "CHANGED_MIND", null));
        assertThat(lostAgain.get("lostReason").asText()).isEqualTo("CHANGED_MIND");
        JsonNode won = json(update(id, "CLOSED_WON", "PRICE", "ignored"));
        assertThat(won.get("lostReason").isNull()).as("a reason sent with another status is dropped")
                .isTrue();
    }

    @Test
    @DisplayName("a deal lost before reasons were asked reads with no reason and can still be edited")
    void oldLostDealsTolerateNoReason() throws Exception {
        Deal old = dealRepository.save(Deal.builder().title("Old").status(DealStatus.CLOSED_LOST)
                .client(client).agent(agent).team(client.getTeam()).build());
        entityManager.flush();

        JsonNode read = json(mockMvc.perform(get("/deals/" + old.getId())).andReturn());
        assertThat(read.get("lostReason").isNull()).isTrue();

        MvcResult edited = update(old.getId(), "CLOSED_LOST", null, null);
        assertThat(edited.getResponse().getStatus()).isEqualTo(200);
        assertThat(json(edited).get("lostReason").isNull()).isTrue();
    }

    @Test
    @DisplayName("creation and every real move write a history row; a re-save does not")
    void statusHistoryIsWritten() throws Exception {
        long id = newLead();
        move(id, "NEGOTIATION", null, null);
        update(id, "NEGOTIATION", null, null);
        move(id, "CLOSED_LOST", "PRICE", null);
        update(id, "CLOSED_WON", null, null);
        entityManager.flush();

        List<DealStatusChange> history = changeRepository.findHistory(id);
        assertThat(history).extracting(DealStatusChange::getFromStatus)
                .containsExactly(null, DealStatus.LEAD, DealStatus.NEGOTIATION, DealStatus.CLOSED_LOST);
        assertThat(history).extracting(DealStatusChange::getToStatus)
                .containsExactly(DealStatus.LEAD, DealStatus.NEGOTIATION,
                        DealStatus.CLOSED_LOST, DealStatus.CLOSED_WON);
        assertThat(history).allSatisfy(c -> {
            assertThat(c.getChangedBy().getId()).isEqualTo(agent.getId());
            assertThat(c.getChangedAt()).isNotNull();
        });
        assertThat(DealLostReason.values()).hasSize(6);
    }

    // Requests ------------------------------------------------------------------------

    private Map<String, Object> body(String status, String reason, String note) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("title", "Dostyk 210");
        body.put("clientId", client.getId());
        body.put("agentId", agent.getId());
        body.put("status", status);
        if (reason != null) body.put("lostReason", reason);
        if (note != null) body.put("lostNote", note);
        return body;
    }

    private MvcResult create(String status, String reason, String note) throws Exception {
        return mockMvc.perform(post("/deals").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body(status, reason, note)))).andReturn();
    }

    private MvcResult update(long id, String status, String reason, String note) throws Exception {
        return mockMvc.perform(put("/deals/" + id).contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body(status, reason, note)))).andReturn();
    }

    private MvcResult move(long id, String status, String reason, String note) throws Exception {
        var request = patch("/deals/" + id + "/status").param("status", status);
        if (reason != null) request = request.param("lostReason", reason);
        if (note != null) request = request.param("lostNote", note);
        return mockMvc.perform(request).andReturn();
    }

    private JsonNode json(MvcResult result) throws Exception {
        return objectMapper.readTree(result.getResponse().getContentAsString());
    }

    private long newLead() throws Exception {
        MvcResult result = create("LEAD", null, null);
        assertThat(result.getResponse().getStatus()).isEqualTo(201);
        return json(result).get("id").asLong();
    }
}
