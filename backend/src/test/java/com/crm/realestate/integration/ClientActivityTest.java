package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientActivityRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.dto.response.ClientListItem;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.ClientActivityService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.RecordHandoverService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A client's history of contact — every call, message, email and note.
 *
 * <p>The history hangs off the client and sits behind exactly the client's walls: another agency's
 * client answers not found, and an agent on their own clients cannot read a colleague's. It goes
 * with the client when the client is deleted, and stays when the person who wrote it leaves.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ClientActivityTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ClientActivityService activityService;
    @Autowired private ClientService clientService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private RecordHandoverService recordHandoverService;

    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private Team almaty;
    private Team astana;
    private User manager;
    private User agent;
    private User colleague;
    private User stranger;
    private Client aigerim;
    private Client daniyar;
    private Client madina;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        activityRepository.deleteAll();
        meetingRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estatecrm.app");

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);

        aigerim = client("Aigerim", agent, almaty);
        daniyar = client("Daniyar", colleague, almaty);
        madina = client("Madina", stranger, astana);
    }

    // Logging and reading -------------------------------------------------------------

    @Test
    @DisplayName("a logged call reads back with who made it, and when defaults to now")
    void logsACall() {
        signIn(agent);
        LocalDateTime before = LocalDateTime.now().minusSeconds(1);

        ClientActivityResponse logged = activityService.create(aigerim.getId(),
                request(ActivityType.CALL, "  Wants to see flats on the left bank  ", null));

        assertThat(logged.getType()).isEqualTo(ActivityType.CALL);
        assertThat(logged.getNote()).isEqualTo("Wants to see flats on the left bank");
        assertThat(logged.getAuthorId()).isEqualTo(agent.getId());
        assertThat(logged.getAuthorName()).isEqualTo("Aigul Bekova");
        assertThat(logged.getOccurredAt()).isAfter(before);
        assertThat(activityRepository.findById(logged.getId()).orElseThrow().getTeam().getId())
                .as("the entry lives in the client's agency")
                .isEqualTo(almaty.getId());
    }

    @Test
    @DisplayName("the history reads newest first, by when it happened rather than when it was typed")
    void newestFirst() {
        signIn(agent);
        LocalDateTime now = LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS);
        activityService.create(aigerim.getId(), request(ActivityType.EMAIL, null, now.minusDays(1)));
        activityService.create(aigerim.getId(), request(ActivityType.CALL, null, now.minusHours(1)));
        activityService.create(aigerim.getId(), request(ActivityType.MESSAGE, null, now.minusDays(3)));

        assertThat(activityService.list(aigerim.getId()))
                .extracting(ClientActivityResponse::getType)
                .containsExactly(ActivityType.CALL, ActivityType.EMAIL, ActivityType.MESSAGE);
    }

    @Test
    @DisplayName("over HTTP: created is 201, the list is an array, a removed entry is 204")
    void endpoints() throws Exception {
        signIn(agent);

        mockMvc.perform(post("/clients/" + aigerim.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"note\":\"Sent the Dostyk listing\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.type").value("MESSAGE"))
                .andExpect(jsonPath("$.authorName").value("Aigul Bekova"));

        mockMvc.perform(get("/clients/" + aigerim.getId() + "/activities"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].note").value("Sent the Dostyk listing"));

        Long id = activityRepository.findAll().get(0).getId();
        mockMvc.perform(delete("/clients/" + aigerim.getId() + "/activities/" + id))
                .andExpect(status().isNoContent());
        assertThat(activityRepository.findById(id)).isEmpty();
    }

    // Validation ----------------------------------------------------------------------

    @Test
    @DisplayName("a note with nothing written in it is refused; a call without one is fine")
    void aNoteNeedsText() throws Exception {
        signIn(agent);

        logVia(aigerim, "{\"type\":\"NOTE\",\"note\":\"   \"}").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("NOTE_REQUIRED"));
        logVia(aigerim, "{\"type\":\"CALL\"}").andExpect(status().isCreated());
    }

    @Test
    @DisplayName("the kind of contact is required")
    void typeIsRequired() throws Exception {
        signIn(agent);
        logVia(aigerim, "{\"note\":\"Called\"}").andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("a note longer than 2000 characters is refused")
    void noteHasALimit() throws Exception {
        signIn(agent);
        String tooLong = "a".repeat(2001);
        logVia(aigerim, "{\"type\":\"NOTE\",\"note\":\"" + tooLong + "\"}").andExpect(status().isBadRequest());
        logVia(aigerim, "{\"type\":\"NOTE\",\"note\":\"" + "a".repeat(2000) + "\"}").andExpect(status().isCreated());
    }

    @Test
    @DisplayName("a contact cannot be logged before it has happened")
    void notInTheFuture() {
        signIn(agent);

        assertThatThrownBy(() -> activityService.create(aigerim.getId(),
                request(ActivityType.CALL, null, LocalDateTime.now().plusDays(1))))
                .hasMessageContaining("before it has happened");
        assertThat(activityRepository.findAll()).isEmpty();
    }

    // Walls ---------------------------------------------------------------------------

    @Test
    @DisplayName("another agency's client has no history as far as we can tell — 404, not 403")
    void anotherAgencyReadsAsMissing() throws Exception {
        signIn(stranger);
        Long madinasEntry = activityService.create(madina.getId(),
                request(ActivityType.CALL, null, null)).getId();

        signIn(manager);
        mockMvc.perform(get("/clients/" + madina.getId() + "/activities")).andExpect(status().isNotFound());
        logVia(madina, "{\"type\":\"CALL\"}").andExpect(status().isNotFound());
        mockMvc.perform(delete("/clients/" + madina.getId() + "/activities/" + madinasEntry))
                .andExpect(status().isNotFound());
        assertThat(activityRepository.findById(madinasEntry)).isPresent();
    }

    @Test
    @DisplayName("an agent on their own clients does not see a colleague's client's history")
    void dataScopeApplies() {
        signIn(colleague);
        activityService.create(daniyar.getId(), request(ActivityType.CALL, "Private", null));

        signIn(agent);
        assertThatThrownBy(() -> activityService.list(daniyar.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> activityService.create(daniyar.getId(), request(ActivityType.CALL, null, null)))
                .isInstanceOf(ResourceNotFoundException.class);

        signIn(manager);
        assertThat(activityService.list(daniyar.getId())).hasSize(1);
    }

    @Test
    @DisplayName("an entry is reached only through its own client")
    void entryMustBelongToTheClientInTheUrl() {
        signIn(colleague);
        Long onDaniyar = activityService.create(daniyar.getId(), request(ActivityType.CALL, null, null)).getId();

        signIn(manager);
        assertThatThrownBy(() -> activityService.delete(aigerim.getId(), onDaniyar))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThat(activityRepository.findById(onDaniyar)).isPresent();
    }

    // Removing ------------------------------------------------------------------------

    @Test
    @DisplayName("a colleague who can see the client still cannot take back someone else's entry")
    void onlyTheAuthorOrAManagerRemoves() throws Exception {
        signIn(agent);
        Long entry = activityService.create(aigerim.getId(), request(ActivityType.CALL, null, null)).getId();

        signIn(colleague);
        assertThat(activityService.list(aigerim.getId())).hasSize(1);
        mockMvc.perform(delete("/clients/" + aigerim.getId() + "/activities/" + entry))
                .andExpect(status().isForbidden());
        assertThatThrownBy(() -> activityService.delete(aigerim.getId(), entry))
                .isInstanceOf(AccessDeniedException.class);

        signIn(manager);
        activityService.delete(aigerim.getId(), entry);
        assertThat(activityRepository.findById(entry)).isEmpty();
    }

    // What happens around it -----------------------------------------------------------

    @Test
    @DisplayName("deleting a client takes its history with it")
    void deletingAClientCascades() {
        signIn(agent);
        activityService.create(aigerim.getId(), request(ActivityType.CALL, null, null));
        activityService.create(aigerim.getId(), request(ActivityType.NOTE, "Prefers WhatsApp", null));
        entityManager.flush();
        entityManager.clear();

        signIn(user("admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null));
        clientService.delete(aigerim.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(aigerim.getId())).isEmpty();
        assertThat(activityRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("when the author's account is closed the entry stays, under the name it was written with")
    void historyOutlivesItsAuthor() {
        signIn(agent);
        Long entry = activityService.create(aigerim.getId(),
                request(ActivityType.CALL, "Offered 3 viewings", null)).getId();
        entityManager.flush();
        entityManager.clear();

        accountRemovalService.removeOwnAccount(userRepository.findById(agent.getId()).orElseThrow(),
                colleague.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(userRepository.findById(agent.getId())).isEmpty();
        ClientActivity kept = activityRepository.findById(entry).orElseThrow();
        assertThat(kept.getAuthor())
                .as("not handed to the successor: they did not make that call")
                .isNull();

        signIn(manager);
        ClientActivityResponse read = activityService.list(aigerim.getId()).get(0);
        assertThat(read.getAuthorId()).isNull();
        assertThat(read.getAuthorName()).isEqualTo("Aigul Bekova");
        assertThat(read.getNote()).isEqualTo("Offered 3 viewings");
    }

    @Test
    @DisplayName("a team-less client's history follows it into the team its agent joins")
    void historyFollowsTheClientIntoATeam() {
        User loner = user("loner@mail.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        Client theirs = client("Ruslan", loner, null);
        signIn(loner);
        Long entry = activityService.create(theirs.getId(), request(ActivityType.CALL, null, null)).getId();

        loner.setTeam(almaty);
        userRepository.save(loner);
        recordHandoverService.adoptTeamlessRecords(loner);
        entityManager.flush();
        entityManager.clear();

        assertThat(activityRepository.findById(entry).orElseThrow().getTeam().getId())
                .isEqualTo(almaty.getId());
    }

    // The client list -----------------------------------------------------------------

    @Test
    @DisplayName("the client list shows the latest touch; a meeting still ahead is not contact yet")
    void lastContactOnTheList() {
        LocalDateTime now = LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS);
        signIn(agent);
        meeting(aigerim, agent, now.plusDays(2));
        meeting(aigerim, agent, now.minusDays(5));
        activityService.create(aigerim.getId(), request(ActivityType.CALL, null, now.minusDays(1)));
        Client quiet = client("Quiet", agent, almaty);
        Client onlyMet = client("Only met", agent, almaty);
        meeting(onlyMet, agent, now.minusDays(3));
        entityManager.flush();
        entityManager.clear();

        List<ClientListItem> list = clientService.getClientsWithDetails();

        assertThat(byName(list, "Aigerim").getLastContactAt()).isEqualTo(now.minusDays(1));
        assertThat(byName(list, "Only met").getLastContactAt()).isEqualTo(now.minusDays(3));
        assertThat(byName(list, quiet.getFullName()).getLastContactAt()).isNull();
    }

    @Test
    @DisplayName("the last contact costs no extra statement per client")
    void lastContactIsOneStatement() {
        signIn(agent);
        seedClientsWithHistory(3);
        long few = countStatementsListingClients();

        seedClientsWithHistory(12);
        long many = countStatementsListingClients();

        assertThat(many)
                .as("3 clients took %d statements, 15 took %d", few, many)
                .isEqualTo(few);
    }

    // Helpers -------------------------------------------------------------------------

    private void seedClientsWithHistory(int count) {
        IntStream.range(0, count).forEach(i -> {
            Client c = client("Seeded " + i + " " + System.nanoTime(), agent, almaty);
            activityService.create(c.getId(), request(ActivityType.CALL, null, null));
        });
        entityManager.flush();
        entityManager.clear();
    }

    private long countStatementsListingClients() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        clientService.getClientsWithDetails();
        return stats.getPrepareStatementCount();
    }

    private static ClientListItem byName(List<ClientListItem> list, String name) {
        return list.stream().filter(i -> i.getFullName().equals(name)).findFirst().orElseThrow();
    }

    private org.springframework.test.web.servlet.ResultActions logVia(Client client, String json) throws Exception {
        return mockMvc.perform(
                post("/clients/" + client.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json));
    }

    private static ClientActivityRequest request(ActivityType type, String note, LocalDateTime when) {
        ClientActivityRequest request = new ClientActivityRequest();
        request.setType(type);
        request.setNote(note);
        request.setOccurredAt(when);
        return request;
    }

    private void meeting(Client client, User who, LocalDateTime when) {
        meetingRepository.save(Meeting.builder()
                .title("Viewing").scheduledAt(when)
                .client(client).agent(who).team(client.getTeam())
                .build());
    }

    private Client client(String name, User holder, Team team) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
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
