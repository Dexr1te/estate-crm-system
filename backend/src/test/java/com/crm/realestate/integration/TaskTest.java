package com.crm.realestate.integration;

import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.dto.response.TaskResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.DealService;
import com.crm.realestate.service.RecordHandoverService;
import com.crm.realestate.service.TaskService;
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
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Tasks: something to do by a certain time, optionally about a client or a deal.
 *
 * <p>They sit behind the same walls as meetings, with the assignee in the agent's place: another
 * agency's task answers not found, an agent on their own records sees only what they have to do,
 * and a task cannot be pinned to a client or deal the writer cannot see. When an account closes,
 * its tasks go to the successor with the rest of its work.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class TaskTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private TaskService taskService;
    @Autowired private ClientService clientService;
    @Autowired private DealService dealService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private RecordHandoverService recordHandoverService;

    @Autowired private TaskRepository taskRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
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
    private LocalDateTime now;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        taskRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
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
        now = LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS);
    }

    // Writing and reading -------------------------------------------------------------

    @Test
    @DisplayName("a new task goes to whoever wrote it, in the agency of the client it is about")
    void createsATask() {
        signIn(agent);

        TaskResponse task = taskService.create(request("  Call Aigerim back  ", " About the Dostyk flat ",
                now.plusDays(2), aigerim.getId(), null, null));

        assertThat(task.getTitle()).isEqualTo("Call Aigerim back");
        assertThat(task.getNote()).isEqualTo("About the Dostyk flat");
        assertThat(task.getAssigneeId()).isEqualTo(agent.getId());
        assertThat(task.getCreatedById()).isEqualTo(agent.getId());
        assertThat(task.getClientName()).isEqualTo("Aigerim");
        assertThat(task.getCompletedAt()).isNull();
        assertThat(taskRepository.findById(task.getId()).orElseThrow().getTeam().getId())
                .isEqualTo(almaty.getId());
    }

    @Test
    @DisplayName("over HTTP: create is 201, edit, complete, reopen and delete each answer")
    void endpoints() throws Exception {
        signIn(agent);

        String created = mockMvc.perform(post("/tasks")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json("Send the contract", now.plusDays(1), aigerim.getId(), null)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Send the contract"))
                .andExpect(jsonPath("$.assigneeName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.clientId").value(aigerim.getId()))
                .andReturn().getResponse().getContentAsString();
        Long id = taskRepository.findAll().get(0).getId();
        assertThat(created).contains("\"completedAt\":null");

        mockMvc.perform(put("/tasks/" + id)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json("Send the signed contract", now.plusDays(3), null, null)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Send the signed contract"))
                .andExpect(jsonPath("$.clientId").doesNotExist());

        mockMvc.perform(post("/tasks/" + id + "/complete"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completedAt").isNotEmpty());
        mockMvc.perform(get("/tasks")).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        mockMvc.perform(get("/tasks").param("status", "done"))
                .andExpect(jsonPath("$.length()").value(1));

        mockMvc.perform(post("/tasks/" + id + "/reopen"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completedAt").doesNotExist());
        mockMvc.perform(get("/tasks")).andExpect(jsonPath("$.length()").value(1));

        mockMvc.perform(delete("/tasks/" + id)).andExpect(status().isNoContent());
        assertThat(taskRepository.findById(id)).isEmpty();
    }

    @Test
    @DisplayName("completing a done task again keeps when it was first done")
    void completeIsIdempotent() {
        signIn(agent);
        Long id = taskService.create(request("Call", null, now.plusDays(1), null, null, null)).getId();

        LocalDateTime first = taskService.complete(id).getCompletedAt();
        assertThat(taskService.complete(id).getCompletedAt()).isEqualTo(first);
    }

    // Validation ----------------------------------------------------------------------

    @Test
    @DisplayName("a title and a due time are required; the title stops at 200, the note at 2000")
    void validation() throws Exception {
        signIn(agent);
        String due = now.plusDays(1).toString();

        create("{\"title\":\"   \",\"dueAt\":\"" + due + "\"}").andExpect(status().isBadRequest());
        create("{\"title\":\"Call\"}").andExpect(status().isBadRequest());
        create("{\"title\":\"" + "a".repeat(201) + "\",\"dueAt\":\"" + due + "\"}")
                .andExpect(status().isBadRequest());
        create("{\"title\":\"Call\",\"note\":\"" + "a".repeat(2001) + "\",\"dueAt\":\"" + due + "\"}")
                .andExpect(status().isBadRequest());
        assertThat(taskRepository.findAll()).isEmpty();

        create("{\"title\":\"" + "a".repeat(200) + "\",\"note\":\"" + "a".repeat(2000)
                + "\",\"dueAt\":\"" + due + "\"}").andExpect(status().isCreated());
    }

    @Test
    @DisplayName("a follow-up can be written down after its time has passed")
    void pastDueIsAllowed() throws Exception {
        signIn(agent);
        create(json("Forgot to call", now.minusHours(3), null, null)).andExpect(status().isCreated());
    }

    @Test
    @DisplayName("an unknown status filter is a bad request, not an empty list")
    void unknownStatus() throws Exception {
        signIn(agent);
        mockMvc.perform(get("/tasks").param("status", "later"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_TASK_STATUS"));
    }

    // Filters and order -----------------------------------------------------------------

    @Test
    @DisplayName("open tasks read soonest first, so the overdue ones lead")
    void openSoonestFirst() {
        signIn(agent);
        taskService.create(request("Next week", null, now.plusDays(7), null, null, null));
        taskService.create(request("Yesterday", null, now.minusDays(1), null, null, null));
        taskService.create(request("Tomorrow", null, now.plusDays(1), null, null, null));
        Long done = taskService.create(request("Done", null, now.minusDays(2), null, null, null)).getId();
        taskService.complete(done);

        assertThat(taskService.list(null, null, null, null))
                .extracting(TaskResponse::getTitle)
                .containsExactly("Yesterday", "Tomorrow", "Next week");
        assertThat(taskService.list("done", null, null, null))
                .extracting(TaskResponse::getTitle)
                .containsExactly("Done");
    }

    @Test
    @DisplayName("the list narrows to one client, one deal or one assignee")
    void filters() {
        Deal deal = deal(aigerim, agent);
        signIn(manager);
        taskService.create(request("On Aigerim", null, now.plusDays(1), aigerim.getId(), null, agent.getId()));
        taskService.create(request("On the deal", null, now.plusDays(2), null, deal.getId(), agent.getId()));
        taskService.create(request("On Daniyar", null, now.plusDays(3), daniyar.getId(), null, colleague.getId()));
        taskService.create(request("Mine", null, now.plusDays(4), null, null, null));

        assertThat(taskService.list("open", aigerim.getId(), null, null))
                .extracting(TaskResponse::getTitle).containsExactly("On Aigerim");
        assertThat(taskService.list("open", null, deal.getId(), null))
                .extracting(TaskResponse::getTitle).containsExactly("On the deal");
        assertThat(taskService.list("open", null, null, colleague.getId()))
                .extracting(TaskResponse::getTitle).containsExactly("On Daniyar");
        assertThat(taskService.list("open", null, null, null)).hasSize(4);
    }

    // Walls ---------------------------------------------------------------------------

    @Test
    @DisplayName("another agency's task does not exist as far as we can tell — 404, not 403")
    void anotherAgencyReadsAsMissing() throws Exception {
        signIn(stranger);
        Long theirs = taskService.create(request("Call Madina", null, now.plusDays(1),
                madina.getId(), null, null)).getId();

        signIn(manager);
        assertThat(taskService.list(null, null, null, null)).isEmpty();
        mockMvc.perform(get("/tasks/" + theirs)).andExpect(status().isNotFound());
        mockMvc.perform(put("/tasks/" + theirs).contentType(MediaType.APPLICATION_JSON)
                .content(json("Mine now", now.plusDays(1), null, null))).andExpect(status().isNotFound());
        mockMvc.perform(post("/tasks/" + theirs + "/complete")).andExpect(status().isNotFound());
        mockMvc.perform(post("/tasks/" + theirs + "/reopen")).andExpect(status().isNotFound());
        mockMvc.perform(delete("/tasks/" + theirs)).andExpect(status().isNotFound());
        assertThat(taskRepository.findById(theirs).orElseThrow().getCompletedAt()).isNull();
    }

    @Test
    @DisplayName("an agent on their own records sees what they have to do; the team sees the agency")
    void dataScopeApplies() {
        signIn(manager);
        taskService.create(request("For Aigul", null, now.plusDays(1), null, null, agent.getId()));
        taskService.create(request("For Timur", null, now.plusDays(2), null, null, colleague.getId()));

        signIn(agent);
        assertThat(taskService.list(null, null, null, null))
                .extracting(TaskResponse::getTitle).containsExactly("For Aigul");
        Long timurs = taskRepository.findAll().stream()
                .filter(t -> t.getTitle().equals("For Timur")).findFirst().orElseThrow().getId();
        assertThatThrownBy(() -> taskService.complete(timurs)).isInstanceOf(ResourceNotFoundException.class);

        signIn(colleague);
        assertThat(taskService.list(null, null, null, null)).hasSize(2);

        signIn(user("admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null));
        assertThat(taskService.list(null, null, null, null)).hasSize(2);
    }

    @Test
    @DisplayName("a task cannot be pinned to a client or deal the writer cannot see")
    void linkingToTheInvisibleIsNotFound() throws Exception {
        Deal daniyarsDeal = deal(daniyar, colleague);
        Deal madinasDeal = deal(madina, stranger);
        signIn(agent);

        create(json("Snoop", now.plusDays(1), madina.getId(), null)).andExpect(status().isNotFound());
        create(json("Snoop", now.plusDays(1), null, madinasDeal.getId())).andExpect(status().isNotFound());
        create(json("Colleague's", now.plusDays(1), daniyar.getId(), null)).andExpect(status().isNotFound());
        create(json("Colleague's", now.plusDays(1), null, daniyarsDeal.getId())).andExpect(status().isNotFound());
        create(json("Nobody", now.plusDays(1), 999_999L, null)).andExpect(status().isNotFound());
        assertThat(taskRepository.findAll()).isEmpty();

        Long mine = taskService.create(request("Mine", null, now.plusDays(1), null, null, null)).getId();
        mockMvc.perform(put("/tasks/" + mine).contentType(MediaType.APPLICATION_JSON)
                .content(json("Mine", now.plusDays(1), madina.getId(), null))).andExpect(status().isNotFound());
        assertThat(taskRepository.findById(mine).orElseThrow().getClient()).isNull();
    }

    // Who does it -----------------------------------------------------------------------

    @Test
    @DisplayName("a manager hands a task to someone in their agency, not to another agency")
    void managerAssigns() {
        signIn(manager);

        TaskResponse given = taskService.create(request("Visit", null, now.plusDays(1),
                aigerim.getId(), null, agent.getId()));
        assertThat(given.getAssigneeId()).isEqualTo(agent.getId());
        assertThat(given.getCreatedById()).isEqualTo(manager.getId());

        assertThatThrownBy(() -> taskService.create(request("Poach", null, now.plusDays(1),
                null, null, stranger.getId()))).isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("an agent cannot give work to a colleague, but can edit a task they were given")
    void agentCannotAssign() throws Exception {
        signIn(agent);
        assertThatThrownBy(() -> taskService.create(request("Yours", null, now.plusDays(1),
                null, null, colleague.getId()))).isInstanceOf(AccessDeniedException.class);

        signIn(manager);
        Long given = taskService.create(request("Visit", null, now.plusDays(1),
                null, null, agent.getId())).getId();

        signIn(agent);
        TaskResponse edited = taskService.update(given, request("Visit on Friday", null, now.plusDays(2),
                null, null, agent.getId()));
        assertThat(edited.getTitle()).isEqualTo("Visit on Friday");
        mockMvc.perform(put("/tasks/" + given).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"x\",\"dueAt\":\"" + now.plusDays(2) + "\",\"assigneeId\":"
                                + colleague.getId() + "}"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("editing without naming anyone leaves the task with whoever has it")
    void editKeepsTheAssignee() {
        signIn(manager);
        Long given = taskService.create(request("Visit", null, now.plusDays(1),
                null, null, agent.getId())).getId();

        TaskResponse edited = taskService.update(given, request("Visit", "Bring keys", now.plusDays(1),
                null, null, null));
        assertThat(edited.getAssigneeId()).isEqualTo(agent.getId());
    }

    // What happens around it -----------------------------------------------------------

    @Test
    @DisplayName("deleting a client or a deal takes its tasks with it")
    void deletingTheRecordCascades() {
        Deal deal = deal(aigerim, agent);
        signIn(agent);
        taskService.create(request("On the client", null, now.plusDays(1), aigerim.getId(), null, null));
        Long onDeal = taskService.create(request("On the deal", null, now.plusDays(1), null, deal.getId(), null)).getId();
        Long loose = taskService.create(request("Loose", null, now.plusDays(1), null, null, null)).getId();
        entityManager.flush();
        entityManager.clear();

        signIn(user("admin@estatecrm.app", "Admin", Role.ADMIN, DataScope.ALL, null));
        dealService.delete(deal.getId());
        entityManager.flush();
        entityManager.clear();
        assertThat(taskRepository.findById(onDeal)).isEmpty();

        clientService.delete(aigerim.getId());
        entityManager.flush();
        entityManager.clear();
        assertThat(taskRepository.findAll()).extracting(Task::getId).containsExactly(loose);
    }

    @Test
    @DisplayName("a closed account's tasks go to the successor with the rest of its work")
    void handedToTheSuccessor() {
        signIn(agent);
        Long open = taskService.create(request("Call back", null, now.plusDays(1), aigerim.getId(), null, null)).getId();
        Long done = taskService.create(request("Called", null, now.minusDays(1), null, null, null)).getId();
        taskService.complete(done);
        signIn(manager);
        Long written = taskService.create(request("For Timur", null, now.plusDays(1), null, null, colleague.getId())).getId();
        entityManager.flush();
        entityManager.clear();

        accountRemovalService.removeOwnAccount(userRepository.findById(agent.getId()).orElseThrow(),
                colleague.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(taskRepository.findById(open).orElseThrow().getAssignee().getId()).isEqualTo(colleague.getId());
        assertThat(taskRepository.findById(done).orElseThrow().getAssignee().getId()).isEqualTo(colleague.getId());
        assertThat(taskRepository.findById(written)).isPresent();

        signIn(colleague);
        TaskResponse inherited = taskService.get(open);
        assertThat(inherited.getAssigneeName()).isEqualTo("Timur Aliev");
        assertThat(inherited.getCreatedById()).as("who wrote it is history, and that account is gone").isNull();
    }

    @Test
    @DisplayName("open tasks with nobody to take them hold the account open; done ones do not")
    void openTasksNeedASuccessor() {
        User newcomer = user("new@almaty.kz", "Newcomer", Role.AGENT, DataScope.OWN, almaty);
        signIn(newcomer);
        Long open = taskService.create(request("Call back", null, now.plusDays(1), null, null, null)).getId();
        User leaver = userRepository.findById(newcomer.getId()).orElseThrow();

        assertThatThrownBy(() -> accountRemovalService.removeOwnAccount(leaver, null))
                .hasMessageContaining("1 open task(s)");
        assertThat(userRepository.findById(newcomer.getId())).isPresent();

        taskService.complete(open);
        entityManager.flush();
        entityManager.clear();
        accountRemovalService.removeOwnAccount(userRepository.findById(newcomer.getId()).orElseThrow(), null);
        entityManager.flush();
        entityManager.clear();

        assertThat(userRepository.findById(newcomer.getId())).isEmpty();
        assertThat(taskRepository.findById(open)).as("finished work goes with the account").isEmpty();
    }

    @Test
    @DisplayName("an agent taken off a team leaves their tasks there with a colleague")
    void handedOverInTheTeam() {
        signIn(agent);
        Long open = taskService.create(request("Call back", null, now.plusDays(1), null, null, null)).getId();

        recordHandoverService.reassignTeamRecords(agent, colleague, almaty);
        entityManager.flush();
        entityManager.clear();

        assertThat(taskRepository.findById(open).orElseThrow().getAssignee().getId()).isEqualTo(colleague.getId());
    }

    @Test
    @DisplayName("a team-less task follows its assignee into the team they join")
    void followsIntoATeam() {
        User loner = user("loner@mail.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        signIn(loner);
        Long id = taskService.create(request("Before the team", null, now.plusDays(1), null, null, null)).getId();
        assertThat(taskRepository.findById(id).orElseThrow().getTeam()).isNull();

        loner.setTeam(almaty);
        userRepository.save(loner);
        recordHandoverService.adoptTeamlessRecords(loner);
        entityManager.flush();
        entityManager.clear();

        assertThat(taskRepository.findById(id).orElseThrow().getTeam().getId()).isEqualTo(almaty.getId());
    }

    @Test
    @DisplayName("the list costs the same number of statements for 3 tasks as for 15")
    void listIsOneStatement() {
        signIn(manager);
        seedTasks(3);
        long few = statementsListing();
        seedTasks(12);
        long many = statementsListing();

        assertThat(many).as("3 tasks took %d statements, 15 took %d", few, many).isEqualTo(few);
    }

    // Helpers -------------------------------------------------------------------------

    private void seedTasks(int count) {
        for (int i = 0; i < count; i++) {
            Deal deal = deal(aigerim, agent);
            taskService.create(request("Seeded " + i, null, now.plusDays(i + 1),
                    aigerim.getId(), deal.getId(), agent.getId()));
        }
        entityManager.flush();
        entityManager.clear();
    }

    private long statementsListing() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        taskService.list(null, null, null, null);
        return stats.getPrepareStatementCount();
    }

    private ResultActions create(String body) throws Exception {
        return mockMvc.perform(post("/tasks").contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private static String json(String title, LocalDateTime due, Long clientId, Long dealId) {
        return "{\"title\":\"" + title + "\",\"dueAt\":\"" + due + "\""
                + (clientId == null ? "" : ",\"clientId\":" + clientId)
                + (dealId == null ? "" : ",\"dealId\":" + dealId)
                + "}";
    }

    private static TaskRequest request(String title, String note, LocalDateTime due,
                                       Long clientId, Long dealId, Long assigneeId) {
        TaskRequest request = new TaskRequest();
        request.setTitle(title);
        request.setNote(note);
        request.setDueAt(due);
        request.setClientId(clientId);
        request.setDealId(dealId);
        request.setAssigneeId(assigneeId);
        return request;
    }

    private Deal deal(Client client, User holder) {
        return dealRepository.save(Deal.builder()
                .title("Deal for " + client.getFullName()).status(DealStatus.LEAD)
                .client(client).agent(holder).team(client.getTeam()).build());
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
