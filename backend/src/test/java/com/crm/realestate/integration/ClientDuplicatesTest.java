package com.crm.realestate.integration;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
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
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The same buyer entered twice — spotted however the phone was typed, and folded into one card.
 *
 * <p>The lookup is agency-wide even for an agent on their own clients, and never crosses agencies.
 * The merge is a manager's call, moves everything hanging off the duplicate, and is journalled.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ClientDuplicatesTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private EntityManager entityManager;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private Team almaty;
    private User manager;
    private User agent;
    private User colleague;
    private User stranger;
    private Client aigerim;
    private Client aigerimAgain;
    private Client madina;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        auditLogRepository.deleteAll();
        taskRepository.deleteAll();
        activityRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);

        aigerim = client("Aigerim Bekova", "+7 916 220-84-11", "Aigerim@Mail.kz", agent, almaty);
        aigerimAgain = client("Aigerim B.", "89162208411", null, colleague, almaty);
        madina = client("Madina", "8 (916) 220 84 11", "aigerim@mail.kz", stranger, astana);
    }

    // Lookup ----------------------------------------------------------------------------

    @Test
    @DisplayName("a phone typed any way finds the colleague's card, and never another agency's")
    void phoneInAnyFormat() throws Exception {
        signIn(agent);
        for (String typed : List.of("+7 (916) 220 84 11", "89162208411", "79162208411")) {
            duplicates("phone", typed)
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(2))
                    .andExpect(jsonPath("$[*].id").value(containsInAnyOrder(
                            aigerim.getId().intValue(), aigerimAgain.getId().intValue())));
        }
    }

    @Test
    @DisplayName("an agent on their own clients sees the colleague's card, with only the minimal fields")
    void minimalFieldsAgencyWide() throws Exception {
        signIn(agent);
        duplicates("phone", "89162208411", "excludeId", aigerim.getId().toString())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].id").value(aigerimAgain.getId()))
                .andExpect(jsonPath("$[0].fullName").value("Aigerim B."))
                .andExpect(jsonPath("$[0].type").value("BUYER"))
                .andExpect(jsonPath("$[0].agentName").value("Timur Aliev"))
                .andExpect(jsonPath("$[0].matchedOn").value("PHONE"))
                .andExpect(jsonPath("$[0].visible").value(false))
                .andExpect(jsonPath("$[0].notes").doesNotExist())
                .andExpect(jsonPath("$[0].budgetMax").doesNotExist());
    }

    @Test
    @DisplayName("an email matches trimmed and without case; both at once reads as both")
    void emailCaseInsensitive() throws Exception {
        signIn(manager);
        duplicates("email", "  AIGERIM@mail.KZ ")
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].id").value(aigerim.getId()))
                .andExpect(jsonPath("$[0].matchedOn").value("EMAIL"))
                .andExpect(jsonPath("$[0].visible").value(true));
        duplicates("email", "aigerim@mail.kz", "phone", "87162208411")
                .andExpect(jsonPath("$.length()").value(1));
        duplicates("email", "aigerim@mail.kz", "phone", "89162208411",
                "excludeId", aigerimAgain.getId().toString())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].matchedOn").value("PHONE_AND_EMAIL"));
    }

    @Test
    @DisplayName("nothing to compare, or another agency asking, finds nothing of ours")
    void emptyAndOtherAgency() throws Exception {
        signIn(agent);
        duplicates("phone", "12").andExpect(jsonPath("$.length()").value(0));
        duplicates().andExpect(jsonPath("$.length()").value(0));

        signIn(stranger);
        duplicates("phone", "89162208411")
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].id").value(madina.getId()));
    }

    // Merge -----------------------------------------------------------------------------

    @Test
    @DisplayName("a merge moves every deal, viewing, contact and task, fills the gaps and deletes the source")
    void mergeMovesEverything() throws Exception {
        aigerim.setPhone(null);
        aigerim.setNotes("Prefers the left bank");
        aigerim.setBudgetMax(new BigDecimal("90000000"));
        aigerimAgain.setEmail("a.bekova@work.kz");
        aigerimAgain.setNotes("Called from the Krisha ad");
        aigerimAgain.setWantedType(PropertyType.APARTMENT);
        aigerimAgain.setBudgetMax(new BigDecimal("50000000"));
        aigerimAgain.setMinRooms(3);
        clientRepository.saveAndFlush(aigerim);
        clientRepository.saveAndFlush(aigerimAgain);

        Deal deal = dealRepository.save(Deal.builder().title("Flat on Dostyk").status(DealStatus.LEAD)
                .client(aigerimAgain).agent(colleague).team(almaty).build());
        Meeting viewing = meetingRepository.save(Meeting.builder().title("Viewing")
                .scheduledAt(LocalDateTime.now().minusDays(1)).outcome(ViewingOutcome.INTERESTED)
                .client(aigerimAgain).agent(colleague).team(almaty).build());
        ClientActivity call = activityRepository.save(ClientActivity.builder().type(ActivityType.CALL)
                .occurredAt(LocalDateTime.now()).client(aigerimAgain).author(colleague)
                .authorName("Timur Aliev").team(almaty).build());
        Task task = taskRepository.save(Task.builder().title("Send the listing")
                .dueAt(LocalDateTime.now().plusDays(1)).client(aigerimAgain)
                .assignee(colleague).createdBy(colleague).team(almaty).build());
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        merge(aigerim, aigerimAgain)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(aigerim.getId()))
                .andExpect(jsonPath("$.fullName").value("Aigerim Bekova"));
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(aigerimAgain.getId())).isEmpty();
        Client merged = clientRepository.findById(aigerim.getId()).orElseThrow();
        assertThat(merged.getPhone()).as("empty phone filled").isEqualTo("89162208411");
        assertThat(merged.getPhoneNormalized()).isEqualTo("79162208411");
        assertThat(merged.getEmail()).as("own email kept").isEqualTo("Aigerim@Mail.kz");
        assertThat(merged.getNotes()).isEqualTo("Prefers the left bank\n\nCalled from the Krisha ad");
        assertThat(merged.getBudgetMax()).as("own budget kept").isEqualByComparingTo("90000000");
        assertThat(merged.getWantedType()).isEqualTo(PropertyType.APARTMENT);
        assertThat(merged.getMinRooms()).isEqualTo(3);

        assertThat(dealRepository.findById(deal.getId()).orElseThrow().getClient().getId())
                .isEqualTo(aigerim.getId());
        Meeting movedViewing = meetingRepository.findById(viewing.getId()).orElseThrow();
        assertThat(movedViewing.getClient().getId()).isEqualTo(aigerim.getId());
        assertThat(movedViewing.getOutcome()).isEqualTo(ViewingOutcome.INTERESTED);
        assertThat(activityRepository.findById(call.getId()).orElseThrow().getClient().getId())
                .isEqualTo(aigerim.getId());
        assertThat(taskRepository.findById(task.getId()).orElseThrow().getClient().getId())
                .isEqualTo(aigerim.getId());

        List<AuditLog> journal = auditLogRepository.findAll();
        assertThat(journal).hasSize(1);
        assertThat(journal.get(0).getAction()).isEqualTo("MERGE_CLIENT");
        assertThat(journal.get(0).getEntityId()).isEqualTo(aigerim.getId());
        assertThat(journal.get(0).getActor().getId()).isEqualTo(manager.getId());
        assertThat(journal.get(0).getMetadata())
                .contains("source=" + aigerimAgain.getId(), "deals=1", "meetings=1", "activities=1", "tasks=1");
    }

    @Test
    @DisplayName("the source's email moves over when the target had none, without tripping uniqueness")
    void emailMovesOver() throws Exception {
        aigerimAgain.setEmail("second@mail.kz");
        clientRepository.saveAndFlush(aigerimAgain);
        Client noEmail = client("Aigerim", null, null, agent, almaty);

        signIn(manager);
        merge(noEmail, aigerimAgain).andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("second@mail.kz"))
                .andExpect(jsonPath("$.phone").value("89162208411"));
    }

    @Test
    @DisplayName("an agent may not merge, another agency's card is not found, and a card cannot absorb itself")
    void mergeGuards() throws Exception {
        signIn(agent);
        merge(aigerim, aigerimAgain).andExpect(status().isForbidden());

        signIn(manager);
        merge(aigerim, madina).andExpect(status().isNotFound());
        merge(madina, aigerim).andExpect(status().isNotFound());
        merge(aigerim, aigerim).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("MERGE_SAME_CLIENT"));
        mockMvc.perform(post("/clients/" + aigerim.getId() + "/merge")
                        .contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest());

        assertThat(clientRepository.findAll()).hasSize(3);
        assertThat(auditLogRepository.findAll()).isEmpty();
    }

    // Helpers ---------------------------------------------------------------------------

    private ResultActions duplicates(String... params) throws Exception {
        var request = get("/clients/duplicates");
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        return mockMvc.perform(request);
    }

    private ResultActions merge(Client target, Client source) throws Exception {
        return mockMvc.perform(post("/clients/" + target.getId() + "/merge")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"sourceId\":" + source.getId() + "}"));
    }

    private Client client(String name, String phone, String email, User holder, Team team) {
        return clientRepository.save(Client.builder()
                .fullName(name).phone(phone).email(email).type(ClientType.BUYER)
                .agent(holder).team(team).build());
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
