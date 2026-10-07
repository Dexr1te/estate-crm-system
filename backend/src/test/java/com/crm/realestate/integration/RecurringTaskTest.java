package com.crm.realestate.integration;

import com.crm.realestate.dto.request.HandoverRequest;
import com.crm.realestate.dto.request.TaskRepeatRequest;
import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.dto.response.TaskResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.RepeatFrequency;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TaskSeriesRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.RecordHandoverService;
import com.crm.realestate.service.TaskService;
import com.crm.realestate.service.WorkHandoverService;
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
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Repeating tasks: completing an occurrence writes the next one, once, where the rule puts it,
 * for whoever held the one completed, behind the same walls as any task.
 *
 * <p>Due times are years ahead so "never in the past" stays out of the way, except in the test
 * about it.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class RecurringTaskTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private TaskService taskService;
    @Autowired private RecordHandoverService recordHandoverService;
    @Autowired private WorkHandoverService workHandoverService;
    @Autowired private AccountRemovalService accountRemovalService;

    @Autowired private TaskRepository taskRepository;
    @Autowired private TaskSeriesRepository seriesRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User manager;
    private User agent;
    private User colleague;
    private User stranger;
    private Client aigerim;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        taskRepository.deleteAll();
        seriesRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estatecrm.app");

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);
        aigerim = clientRepository.save(Client.builder()
                .fullName("Aigerim").type(ClientType.BUYER).agent(agent).team(almaty).build());
    }

    // The rule ----------------------------------------------------------------------------

    @Test
    @DisplayName("a task without a repeat repeats nothing, and completing it writes nothing")
    void plainTaskIsUnchanged() {
        signIn(agent);
        TaskResponse task = taskService.create(request("Call", at(2031, 3, 3), null));

        assertThat(task.getRepeat()).isNull();
        assertThat(task.getSeriesId()).isNull();
        taskService.complete(task.getId());
        assertThat(taskRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("completing a weekly occurrence writes the next, for the same person on the same client")
    void completingWritesTheNext() {
        signIn(agent);
        TaskResponse first = taskService.create(request("Call the landlord", at(2031, 3, 3),
                repeat("WEEKLY", List.of("monday", "THURSDAY"), null, null), aigerim.getId()));

        assertThat(first.getRepeat().getFrequency()).isEqualTo(RepeatFrequency.WEEKLY);
        assertThat(first.getRepeat().getWeekdays()).containsExactly(DayOfWeek.MONDAY, DayOfWeek.THURSDAY);
        assertThat(first.getOccurrence()).isEqualTo(1);

        taskService.complete(first.getId());
        TaskResponse second = open().get(0);
        assertThat(second.getDueAt()).isEqualTo(at(2031, 3, 6));
        assertThat(second.getSeriesId()).isEqualTo(first.getSeriesId());
        assertThat(second.getOccurrence()).isEqualTo(2);
        assertThat(second.getTitle()).isEqualTo("Call the landlord");
        assertThat(second.getClientId()).isEqualTo(aigerim.getId());
        assertThat(second.getAssigneeId()).isEqualTo(agent.getId());
        assertThat(second.getRepeat().getWeekdays()).containsExactly(DayOfWeek.MONDAY, DayOfWeek.THURSDAY);

        taskService.complete(second.getId());
        assertThat(open().get(0).getDueAt()).isEqualTo(at(2031, 3, 10));
    }

    @Test
    @DisplayName("a weekly rule without days repeats on the due day's weekday")
    void weeklyDefaultsToTheDueDay() {
        signIn(agent);
        // 2031-03-05 is a Wednesday.
        TaskResponse task = taskService.create(request("Check the photos", at(2031, 3, 5),
                repeat("WEEKLY", null, null, null)));

        assertThat(task.getRepeat().getWeekdays()).containsExactly(DayOfWeek.WEDNESDAY);
        taskService.complete(task.getId());
        assertThat(open().get(0).getDueAt()).isEqualTo(at(2031, 3, 12));
    }

    @Test
    @DisplayName("monthly from 31 January: 28 February, then back to 31 March")
    void monthlyFromJanuary31() {
        signIn(agent);
        Long id = taskService.create(request("Rent reminder", at(2031, 1, 31),
                repeat("MONTHLY", List.of("MONDAY"), null, null))).getId();
        assertThat(taskService.get(id).getRepeat().getWeekdays()).as("weekdays are for weekly only").isEmpty();

        assertThat(completeAndNext(id).getDueAt()).isEqualTo(at(2031, 2, 28));
        TaskResponse february = open().get(0);
        assertThat(february.getRepeat().getAnchorAt()).isEqualTo(at(2031, 1, 31));

        // Saving the clamped occurrence with the same rule and day does not move the series off the 31st.
        TaskRequest edit = request("Rent reminder, call first", february.getDueAt(),
                repeat("MONTHLY", null, null, null));
        taskService.update(february.getId(), edit);

        assertThat(completeAndNext(february.getId()).getDueAt()).isEqualTo(at(2031, 3, 31));
    }

    @Test
    @DisplayName("yearly from 29 February: the 28th in an ordinary year")
    void yearlyFromLeapDay() {
        signIn(agent);
        Long id = taskService.create(request("Anniversary call", at(2032, 2, 29),
                repeat("YEARLY", null, null, null))).getId();

        assertThat(completeAndNext(id).getDueAt()).isEqualTo(at(2033, 2, 28));
    }

    @Test
    @DisplayName("quarterly, three months on")
    void quarterly() {
        signIn(agent);
        Long id = taskService.create(request("Quarterly report", at(2031, 1, 15),
                repeat("QUARTERLY", null, null, null))).getId();

        assertThat(completeAndNext(id).getDueAt()).isEqualTo(at(2031, 4, 15));
    }

    @Test
    @DisplayName("a daily task done a week late comes back after now, not seven times overdue")
    void neverInThePast() {
        signIn(agent);
        LocalDateTime weekAgo = LocalDateTime.now().minusDays(7).withHour(9).withMinute(30)
                .truncatedTo(ChronoUnit.MINUTES);
        Long id = taskService.create(request("Daily round", weekAgo, repeat("DAILY", null, null, null))).getId();

        TaskResponse next = completeAndNext(id);
        LocalDateTime now = LocalDateTime.now();
        assertThat(next.getDueAt()).isAfter(now).isBefore(now.plusDays(1).plusMinutes(1));
        assertThat(next.getDueAt().toLocalTime()).isEqualTo(weekAgo.toLocalTime());
        assertThat(taskRepository.count()).isEqualTo(2);
    }

    // Ends --------------------------------------------------------------------------------

    @Test
    @DisplayName("an end after 2 times writes one more and then stops")
    void endsAfterCount() {
        signIn(agent);
        Long id = taskService.create(request("Twice", at(2031, 3, 3), repeat("DAILY", null, null, 2))).getId();

        TaskResponse second = completeAndNext(id);
        taskService.complete(second.getId());

        assertThat(open()).isEmpty();
        assertThat(taskRepository.count()).isEqualTo(2);
    }

    @Test
    @DisplayName("an end on a day writes nothing after it")
    void endsOnADay() {
        signIn(agent);
        Long id = taskService.create(request("Until Wednesday", at(2031, 3, 3),
                repeat("DAILY", null, LocalDate.of(2031, 3, 4), null))).getId();

        TaskResponse second = completeAndNext(id);
        assertThat(second.getDueAt()).isEqualTo(at(2031, 3, 4));
        taskService.complete(second.getId());
        assertThat(open()).isEmpty();
    }

    @Test
    @DisplayName("bad rules are refused with their own codes")
    void validation() throws Exception {
        signIn(agent);
        assertCode(repeat("HOURLY", null, null, null), "INVALID_REPEAT_FREQUENCY");
        assertCode(repeat("WEEKLY", List.of("FUNDAY"), null, null), "INVALID_WEEKDAY");
        assertCode(repeat("DAILY", null, LocalDate.of(2031, 4, 1), 3), "REPEAT_ENDS_TWICE");
        assertCode(repeat("DAILY", null, null, 0), "INVALID_REPEAT_COUNT");
        assertCode(repeat("DAILY", null, null, 1000), "INVALID_REPEAT_COUNT");
        assertCode(repeat("DAILY", null, LocalDate.of(2031, 3, 2), null), "REPEAT_UNTIL_BEFORE_DUE");
        assertThat(taskRepository.count()).isZero();

        mockMvc.perform(post("/tasks").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Call\",\"dueAt\":\"2031-03-03T09:30:00\","
                                + "\"repeat\":{\"frequency\":\"DAILY\",\"count\":0}}"))
                .andExpect(status().isBadRequest());
    }

    // Idempotency -------------------------------------------------------------------------

    @Test
    @DisplayName("reopening and completing again writes no second next, even after the next was deleted")
    void oneNextPerOccurrence() {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null))).getId();

        TaskResponse next = completeAndNext(id);
        taskService.reopen(id);
        taskService.complete(id);
        taskService.reopen(id);
        taskService.complete(id);
        assertThat(taskRepository.count()).isEqualTo(2);

        taskService.delete(next.getId());
        taskService.reopen(id);
        taskService.complete(id);
        assertThat(taskRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("over HTTP: create with a rule, complete, the next carries the series; stop-repeating ends it")
    void endpoints() throws Exception {
        signIn(agent);
        mockMvc.perform(post("/tasks").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Call\",\"dueAt\":\"2031-03-03T09:30:00\","
                                + "\"repeat\":{\"frequency\":\"weekly\",\"weekdays\":[\"MONDAY\",\"THURSDAY\"]}}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.repeat.frequency").value("WEEKLY"))
                .andExpect(jsonPath("$.repeat.weekdays[1]").value("THURSDAY"))
                .andExpect(jsonPath("$.repeat.anchorAt").value("2031-03-03T09:30:00"))
                .andExpect(jsonPath("$.occurrence").value(1));
        Task first = taskRepository.findAll().get(0);

        mockMvc.perform(post("/tasks/" + first.getId() + "/complete")).andExpect(status().isOk());
        Long seriesId = first.getSeries().getId();
        mockMvc.perform(get("/tasks").param("status", "all").param("seriesId", seriesId.toString()))
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[1].dueAt").value("2031-03-06T09:30:00"));
        Long second = open().get(0).getId();

        mockMvc.perform(post("/tasks/" + second + "/stop-repeating"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.repeat").doesNotExist())
                .andExpect(jsonPath("$.seriesId").value(seriesId));
        mockMvc.perform(post("/tasks/" + second + "/stop-repeating")).andExpect(status().isOk());
        mockMvc.perform(post("/tasks/" + second + "/complete")).andExpect(status().isOk());
        assertThat(open()).isEmpty();
        assertThat(taskRepository.count()).isEqualTo(2);
    }

    // Editing the rule --------------------------------------------------------------------

    @Test
    @DisplayName("saving without a repeat keeps the rule; NONE stops it")
    void leftOutKeepsNoneStops() {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null))).getId();

        assertThat(taskService.update(id, request("Call back", at(2031, 3, 3), null)).getRepeat()).isNotNull();
        assertThat(taskService.update(id, request("Call back", at(2031, 3, 3), repeat("NONE", null, null, null)))
                .getRepeat()).isNull();

        taskService.complete(id);
        assertThat(open()).isEmpty();
    }

    @Test
    @DisplayName("a changed rule counts for the occurrences still to come; the open one keeps its day")
    void editingTheRule() {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null))).getId();
        TaskResponse second = completeAndNext(id);
        assertThat(second.getDueAt()).isEqualTo(at(2031, 3, 4));

        TaskResponse edited = taskService.update(second.getId(),
                request("Call", second.getDueAt(), repeat("MONTHLY", null, null, 2)));
        assertThat(edited.getDueAt()).isEqualTo(at(2031, 3, 4));
        assertThat(edited.getRepeat().getFrequency()).isEqualTo(RepeatFrequency.MONTHLY);
        assertThat(edited.getRepeat().getAnchorAt()).isEqualTo(at(2031, 3, 4));

        TaskResponse third = completeAndNext(second.getId());
        assertThat(third.getDueAt()).isEqualTo(at(2031, 4, 4));
        taskService.complete(third.getId());
        assertThat(open()).as("2 times counted from where the end was set").isEmpty();
    }

    @Test
    @DisplayName("a rule given to a task whose series was stopped starts a new series from it")
    void restartAfterStop() {
        signIn(agent);
        TaskResponse first = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null)));
        TaskResponse second = completeAndNext(first.getId());
        taskService.stopRepeating(second.getId());

        TaskResponse restarted = taskService.update(second.getId(),
                request("Call", second.getDueAt(), repeat("WEEKLY", null, null, null)));

        assertThat(restarted.getSeriesId()).isNotEqualTo(first.getSeriesId());
        assertThat(restarted.getOccurrence()).isEqualTo(1);
        assertThat(completeAndNext(second.getId()).getDueAt()).isEqualTo(at(2031, 3, 11));
    }

    // Walls and handovers -----------------------------------------------------------------

    @Test
    @DisplayName("another agency cannot read, complete or stop a series' occurrence")
    void anotherAgency() throws Exception {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null))).getId();

        signIn(stranger);
        assertThatThrownBy(() -> taskService.stopRepeating(id)).isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> taskService.complete(id)).isInstanceOf(ResourceNotFoundException.class);
        mockMvc.perform(get("/tasks").param("seriesId", taskRepository.findById(id).orElseThrow()
                        .getSeries().getId().toString()))
                .andExpect(jsonPath("$.length()").value(0));
        mockMvc.perform(put("/tasks/" + id).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Mine\",\"dueAt\":\"2031-03-03T09:30:00\","
                                + "\"repeat\":{\"frequency\":\"NONE\"}}"))
                .andExpect(status().isNotFound());
        assertThat(taskRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("a manager completing an agent's occurrence writes the next for the agent")
    void nextFollowsTheHolder() {
        signIn(manager);
        Long id = taskService.create(request("For Aigul", at(2031, 3, 3), repeat("DAILY", null, null, null),
                null, agent.getId())).getId();

        TaskResponse next = completeAndNext(id);
        assertThat(next.getAssigneeId()).isEqualTo(agent.getId());
        assertThat(taskRepository.findById(next.getId()).orElseThrow().getTeam().getId()).isEqualTo(almaty.getId());
    }

    @Test
    @DisplayName("a series handed over with its open occurrence goes on with the new holder")
    void followsAHandover() {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null),
                aigerim.getId())).getId();
        entityManager.flush();
        entityManager.clear();

        workHandoverService.handOver(userRepository.findById(manager.getId()).orElseThrow(), almaty.getId(),
                HandoverRequest.builder().fromAgentId(agent.getId()).toAgentId(colleague.getId())
                        .upcoming(true).build());
        entityManager.flush();
        entityManager.clear();

        signIn(colleague);
        TaskResponse next = completeAndNext(id);
        assertThat(next.getAssigneeId()).isEqualTo(colleague.getId());

        recordHandoverService.reassignTeamRecords(colleague, agent, almaty);
        entityManager.flush();
        entityManager.clear();
        signIn(agent);
        assertThat(completeAndNext(next.getId()).getAssigneeId()).isEqualTo(agent.getId());
    }

    @Test
    @DisplayName("a closed account's series goes on with the successor")
    void followsTheSuccessor() {
        signIn(agent);
        Long id = taskService.create(request("Call", at(2031, 3, 3), repeat("DAILY", null, null, null))).getId();
        entityManager.flush();
        entityManager.clear();

        accountRemovalService.removeOwnAccount(userRepository.findById(agent.getId()).orElseThrow(),
                colleague.getId());
        entityManager.flush();
        entityManager.clear();

        signIn(colleague);
        assertThat(completeAndNext(id).getAssigneeId()).isEqualTo(colleague.getId());
    }

    /** Completes the task and returns the open occurrence it wrote. */
    private TaskResponse completeAndNext(Long id) {
        Long series = taskService.complete(id).getSeriesId();
        entityManager.flush();
        entityManager.clear();
        return taskRepository.findAll().stream()
                .filter(t -> t.getCompletedAt() == null && t.getSeries() != null
                        && t.getSeries().getId().equals(series))
                .max(Comparator.comparing(Task::getOccurrence))
                .map(t -> taskService.get(t.getId()))
                .orElseThrow(() -> new AssertionError("no next occurrence was written"));
    }

    private List<TaskResponse> open() {
        entityManager.flush();
        entityManager.clear();
        return taskService.list("open", null, null, null);
    }

    private void assertCode(TaskRepeatRequest repeat, String code) {
        assertThatThrownBy(() -> taskService.create(request("Call", at(2031, 3, 3), repeat)))
                .isInstanceOf(BusinessException.class)
                .extracting("code").isEqualTo(code);
    }

    private static TaskRepeatRequest repeat(String frequency, List<String> weekdays, LocalDate until, Integer count) {
        return TaskRepeatRequest.builder().frequency(frequency).weekdays(weekdays).until(until).count(count).build();
    }

    private static TaskRequest request(String title, LocalDateTime due, TaskRepeatRequest repeat) {
        return request(title, due, repeat, null, null);
    }

    private static TaskRequest request(String title, LocalDateTime due, TaskRepeatRequest repeat, Long clientId) {
        return request(title, due, repeat, clientId, null);
    }

    private static TaskRequest request(String title, LocalDateTime due, TaskRepeatRequest repeat,
                                       Long clientId, Long assigneeId) {
        TaskRequest request = new TaskRequest();
        request.setTitle(title);
        request.setDueAt(due);
        request.setRepeat(repeat);
        request.setClientId(clientId);
        request.setAssigneeId(assigneeId);
        return request;
    }

    private static LocalDateTime at(int year, int month, int day) {
        return LocalDateTime.of(year, month, day, 9, 30);
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
