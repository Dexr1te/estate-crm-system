package com.crm.realestate.integration;

import com.crm.realestate.dto.request.TimeOffRequest;
import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.dto.response.TimeOffResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.TimeOff;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.TimeOffKind;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.TimeOffRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.AgencyCalendar;
import com.crm.realestate.service.NotificationEvents;
import com.crm.realestate.service.NotificationService;
import com.crm.realestate.service.TeamMembershipService;
import com.crm.realestate.service.TimeOffService;
import com.crm.realestate.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
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
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * An agent's time off: written down by them or their manager, never two at once, with a colleague
 * covering who hears what the absent person hears while they are away. Nothing changes hands, the
 * meetings on those days are a warning, and none of it reaches outside the agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class TimeOffTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private TimeOffService timeOffService;
    @Autowired private NotificationEvents notificationEvents;
    @Autowired private NotificationService notificationService;
    @Autowired private UserService userService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private TeamMembershipService membershipService;
    @Autowired private AgencyCalendar calendar;
    @Autowired private TimeOffRepository timeOffRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private Team astana;
    private User agent;
    private User colleague;
    private User third;
    private User manager;
    private User stranger;
    private LocalDate today;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("to-manager@almaty.kz", "Marat Manager", Role.MANAGER, almaty);
        almaty.setManager(manager);
        teamRepository.save(almaty);
        agent = user("to-agent@almaty.kz", "Aigul Bekova", Role.AGENT, almaty);
        colleague = user("to-colleague@almaty.kz", "Timur Aliev", Role.AGENT, almaty);
        third = user("to-third@almaty.kz", "Dana Seitova", Role.AGENT, almaty);
        stranger = user("to-stranger@astana.kz", "Erlan Other", Role.AGENT, astana);
        today = calendar.today();
        signIn(agent);
    }

    // Writing it down -------------------------------------------------------------------

    @Test
    @DisplayName("an agent writes down their own holiday with a cover, who is told")
    void agentWritesOwn() {
        TimeOffResponse saved = timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(10), today.plusDays(16), colleague));
        assertThat(saved.getUserId()).isEqualTo(agent.getId());
        assertThat(saved.getCoverName()).isEqualTo("Timur Aliev");
        assertThat(saved.getDays()).isEqualTo(7);
        assertThat(saved.isCurrent()).isFalse();
        assertThat(saved.isCanEdit()).isTrue();
        assertThat(saved.getCreatedByName()).isEqualTo("Aigul Bekova");

        List<Notification> told = notificationRepository.findAll().stream()
                .filter(n -> n.getRecipient().getId().equals(colleague.getId())).toList();
        assertThat(told).extracting(Notification::getType).containsExactly(NotificationType.TIME_OFF_COVER);
        assertThat(told.get(0).getTargetId()).isEqualTo(saved.getId());
        assertThat(params(told.get(0))).containsEntry("absentName", "Aigul Bekova")
                .containsEntry("kind", "VACATION")
                .containsEntry("startDate", today.plusDays(10).toString());
    }

    @Test
    @DisplayName("a manager writes down an agent's sick leave; an agent may not write down a colleague's")
    void managerOnBehalf() {
        TimeOffResponse sick = timeOffService.create(manager, null,
                request(agent.getId(), TimeOffKind.SICK_LEAVE, today, today.plusDays(2), null));
        assertThat(sick.getUserName()).isEqualTo("Aigul Bekova");
        assertThat(sick.isCurrent()).isTrue();
        assertThat(sick.getCreatedByName()).isEqualTo("Marat Manager");

        assertCode(() -> timeOffService.create(colleague, null,
                request(agent.getId(), TimeOffKind.DAY_OFF, today.plusDays(5), today.plusDays(5), null)),
                "MANAGER_ONLY");
        // The absent person may change what the manager wrote down; a colleague may not.
        assertThat(timeOffService.get(agent, sick.getId()).isCanEdit()).isTrue();
        assertThat(timeOffService.get(colleague, sick.getId()).isCanEdit()).isFalse();
        assertCode(() -> timeOffService.delete(colleague, sick.getId()), "NOT_YOUR_TIME_OFF");
        timeOffService.delete(agent, sick.getId());
        assertThat(timeOffRepository.findById(sick.getId())).isEmpty();
    }

    @Test
    @DisplayName("the days, the cover and overlaps are checked; editing does not collide with itself")
    void rules() {
        assertCode(() -> timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(3), today.plusDays(2), null)), "END_BEFORE_START");
        assertCode(() -> timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today, today.plusDays(366), null)), "TIME_OFF_TOO_LONG");
        assertCode(() -> timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today, today, agent)), "COVER_IS_ABSENT_PERSON");
        assertThatThrownBy(() -> timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today, today, stranger)))
                .isInstanceOf(ResourceNotFoundException.class);

        TimeOffResponse first = timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(10), today.plusDays(14), colleague));
        assertCode(() -> timeOffService.create(agent, null,
                request(null, TimeOffKind.DAY_OFF, today.plusDays(14), today.plusDays(14), null)), "TIME_OFF_OVERLAPS");
        // The day after is free, and somebody else's time off on the same days is no clash.
        timeOffService.create(agent, null, request(null, TimeOffKind.DAY_OFF, today.plusDays(15), today.plusDays(15), null));
        timeOffService.create(colleague, null,
                request(null, TimeOffKind.VACATION, today.plusDays(10), today.plusDays(14), third));

        TimeOffResponse moved = timeOffService.update(agent, first.getId(),
                request(null, TimeOffKind.VACATION, today.plusDays(9), today.plusDays(13), third));
        assertThat(moved.getStartDate()).isEqualTo(today.plusDays(9));
        assertThat(moved.getCoverName()).isEqualTo("Dana Seitova");
        assertCode(() -> timeOffService.update(agent, first.getId(),
                request(null, TimeOffKind.VACATION, today.plusDays(9), today.plusDays(15), third)), "TIME_OFF_OVERLAPS");
    }

    // Seeing it -------------------------------------------------------------------------

    @Test
    @DisplayName("the whole agency sees who is out; another agency is told it does not exist")
    void visibility() {
        TimeOffResponse holiday = timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.minusDays(1), today.plusDays(3), colleague));
        timeOffService.create(colleague, null,
                request(null, TimeOffKind.DAY_OFF, today.plusDays(30), today.plusDays(30), null));
        timeOffService.create(third, null,
                request(null, TimeOffKind.VACATION, today.plusDays(200), today.plusDays(210), null));

        List<TimeOffResponse> seen = timeOffService.list(third, null, null, null, null);
        assertThat(seen).extracting(TimeOffResponse::getUserName).containsExactly("Aigul Bekova", "Timur Aliev");
        assertThat(seen.get(0).isCurrent()).isTrue();
        assertThat(timeOffService.list(third, null, today.plusDays(100), today.plusDays(300), null))
                .extracting(TimeOffResponse::getUserName).containsExactly("Dana Seitova");
        assertThat(timeOffService.list(manager, null, null, null, colleague.getId()))
                .extracting(TimeOffResponse::getUserName).containsExactly("Timur Aliev");

        assertThat(timeOffService.list(stranger, null, null, null, null)).isEmpty();
        assertThatThrownBy(() -> timeOffService.get(stranger, holiday.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> timeOffService.delete(stranger, holiday.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> timeOffService.list(stranger, null, null, null, agent.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertCode(() -> timeOffService.list(agent, null, today, today.minusDays(1), null), "RANGE_REQUIRED");
        assertCode(() -> timeOffService.list(agent, null, today, today.plusDays(400), null), "RANGE_TOO_WIDE");
    }

    @Test
    @DisplayName("the meetings on the days off are a warning, spelled out only to those who may see them")
    void conflicts() {
        Client buyer = clientRepository.save(Client.builder()
                .fullName("Aliya Buyer").type(ClientType.BUYER).agent(agent).team(almaty).build());
        Meeting during = meeting(buyer, agent, today.plusDays(11).atTime(15, 0), false);
        meeting(buyer, agent, today.plusDays(11).atTime(16, 0), true);
        meeting(buyer, agent, today.plusDays(20).atTime(15, 0), false);
        meeting(buyer, colleague, today.plusDays(11).atTime(15, 0), false);

        TimeOffResponse saved = timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(10), today.plusDays(14), null));
        assertThat(saved.getConflictCount()).isEqualTo(1);
        assertThat(saved.getConflicts()).extracting(TimeOffResponse.Conflict::getMeetingId)
                .containsExactly(during.getId());
        assertThat(saved.getConflicts().get(0).getClientName()).isEqualTo("Aliya Buyer");

        // A colleague on their own records hears there is one, not whose.
        TimeOffResponse toColleague = timeOffService.get(colleague, saved.getId());
        assertThat(toColleague.getConflictCount()).isEqualTo(1);
        assertThat(toColleague.getConflicts()).isEmpty();
        assertThat(timeOffService.get(manager, saved.getId()).getConflicts()).hasSize(1);
    }

    @Test
    @DisplayName("the agency's agent list says who is away and when")
    void agentPicker() {
        timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.minusDays(2), today.plusDays(4), colleague));
        timeOffService.create(colleague, null,
                request(null, TimeOffKind.DAY_OFF, today.plusDays(7), today.plusDays(7), null));
        timeOffService.create(third, null,
                request(null, TimeOffKind.DAY_OFF, today.minusDays(9), today.minusDays(8), null));
        signIn(manager);
        Map<String, AgentOptionResponse> byName = new java.util.HashMap<>();
        userService.getAgentOptions().forEach(o -> byName.put(o.getFullName(), o));
        assertThat(byName.get("Aigul Bekova").getAwayUntil()).isEqualTo(today.plusDays(4));
        assertThat(byName.get("Timur Aliev").getAwayUntil()).isNull();
        assertThat(byName.get("Timur Aliev").getTimeOff()).extracting(AgentOptionResponse.Away::getStartDate)
                .containsExactly(today.plusDays(7));
        assertThat(byName.get("Dana Seitova").getTimeOff()).as("what is over is left out").isEmpty();
    }

    // Covering --------------------------------------------------------------------------

    @Test
    @DisplayName("while somebody is away their cover hears what they hear, marked; the absent person keeps theirs")
    void coverHears() {
        timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.minusDays(1), today.plusDays(1), colleague));
        notificationRepository.deleteAll();

        Task task = taskRepository.save(Task.builder()
                .title("Call the bank").dueAt(today.plusDays(1).atTime(10, 0))
                .assignee(agent).createdBy(manager).team(almaty).build());
        notificationEvents.taskAssigned(task, manager);
        Client buyer = clientRepository.save(Client.builder()
                .fullName("Aliya Buyer").type(ClientType.BUYER).agent(agent).team(almaty).build());
        notificationEvents.clientDate(agent, buyer, NotificationType.CLIENT_BIRTHDAY, 40, null);
        flush();

        List<Notification> mine = forUser(agent);
        assertThat(mine).extracting(Notification::getType)
                .containsExactlyInAnyOrder(NotificationType.TASK_ASSIGNED, NotificationType.CLIENT_BIRTHDAY);
        assertThat(mine).noneMatch(Notification::isCovering);

        List<Notification> covering = forUser(colleague);
        assertThat(covering).extracting(Notification::getType)
                .containsExactlyInAnyOrder(NotificationType.TASK_ASSIGNED, NotificationType.CLIENT_BIRTHDAY);
        assertThat(covering).allMatch(Notification::isCovering);
        Notification copy = covering.stream()
                .filter(n -> n.getType() == NotificationType.TASK_ASSIGNED).findFirst().orElseThrow();
        assertThat(copy.getTargetId()).isEqualTo(task.getId());
        assertThat(params(copy)).containsEntry("taskTitle", "Call the bank")
                .containsEntry("coveringForName", "Aigul Bekova")
                .containsEntry("coveringForId", agent.getId().intValue());
        // The cover's copy is not something they were told themselves.
        assertThat(notificationService.alreadyTold(colleague, NotificationType.TASK_ASSIGNED, task.getId())).isFalse();
        assertThat(notificationService.alreadyTold(agent, NotificationType.TASK_ASSIGNED, task.getId())).isTrue();

        // Through the API the copy reads like any other, with the name in its params.
        try {
            mockMvc.perform(get("/notifications").header(HttpHeaders.AUTHORIZATION, bearer(colleague)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.content[0].params.coveringForName").value("Aigul Bekova"));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    @Test
    @DisplayName("nobody covers before or after the days, the cover is not told what they did, and covering does not chain")
    void coverLimits() {
        timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(1), today.plusDays(3), colleague));
        timeOffService.create(colleague, null,
                request(null, TimeOffKind.VACATION, today.minusDays(1), today.plusDays(1), third));
        notificationRepository.deleteAll();

        // The agent is not away yet: only they hear.
        notificationEvents.taskAssigned(task("Before", agent), manager);
        flush();
        assertThat(forUser(colleague)).isEmpty();

        // The colleague is away and covered by the third; the third gets a copy, nobody else.
        notificationEvents.taskAssigned(task("For the colleague", colleague), manager);
        // The third assigning work to the colleague they cover is not news to themselves.
        notificationEvents.taskAssigned(task("By the cover", colleague), third);
        flush();
        assertThat(forUser(third)).extracting(n -> params(n).get("taskTitle"))
                .containsExactly("For the colleague");
        assertThat(forUser(agent)).extracting(n -> params(n).get("taskTitle")).containsExactly("Before");

        // A cover who is no longer active hears nothing.
        third.setActive(false);
        userRepository.save(third);
        notificationEvents.taskAssigned(task("Inactive cover", colleague), manager);
        flush();
        assertThat(forUser(third)).hasSize(1);
    }

    @Test
    @DisplayName("an invitation to join an agency is nobody else's to cover")
    void personalIsNotCovered() {
        timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.minusDays(1), today.plusDays(1), colleague));
        notificationRepository.deleteAll();
        notificationService.notify(agent, manager, null, NotificationType.JOIN_REQUEST, 1L, Map.of());
        flush();
        assertThat(forUser(agent)).hasSize(1);
        assertThat(forUser(colleague)).isEmpty();
    }

    // People leaving --------------------------------------------------------------------

    @Test
    @DisplayName("a leaver's time off goes, and what they covered passes to whoever takes their work")
    void leaverLeavesTheCover() {
        TimeOffResponse agentsHoliday = timeOffService.create(agent, null,
                request(null, TimeOffKind.VACATION, today.plusDays(5), today.plusDays(8), colleague));
        TimeOffResponse thirdsHoliday = timeOffService.create(third, null,
                request(null, TimeOffKind.VACATION, today.plusDays(5), today.plusDays(8), colleague));
        TimeOffResponse colleaguesOwn = timeOffService.create(colleague, null,
                request(null, TimeOffKind.DAY_OFF, today.plusDays(20), today.plusDays(20), null));

        signIn(manager);
        // The colleague leaves; the agent takes their work, so the agent cannot cover their own holiday.
        membershipService.removeMember(manager, colleague.getId(), agent.getId());
        flush();
        assertThat(timeOffRepository.findById(colleaguesOwn.getId())).isEmpty();
        assertThat(timeOffRepository.findById(agentsHoliday.getId()).orElseThrow().getCover()).isNull();
        assertThat(timeOffRepository.findById(thirdsHoliday.getId()).orElseThrow().getCover().getId())
                .isEqualTo(agent.getId());
    }

    @Test
    @DisplayName("a closed account takes its time off along, and hands its covers to the successor")
    void closedAccount() {
        TimeOffResponse thirdsHoliday = timeOffService.create(third, null,
                request(null, TimeOffKind.VACATION, today.plusDays(5), today.plusDays(8), colleague));
        TimeOffResponse colleaguesOwn = timeOffService.create(colleague, null,
                request(null, TimeOffKind.DAY_OFF, today.plusDays(20), today.plusDays(20), third));

        accountRemovalService.remove(manager, colleague, agent.getId(), "DELETE_USER");
        flush();
        assertThat(timeOffRepository.findById(colleaguesOwn.getId())).isEmpty();
        TimeOff left = timeOffRepository.findById(thirdsHoliday.getId()).orElseThrow();
        assertThat(left.getCover().getId()).isEqualTo(agent.getId());
    }

    // Through the API -------------------------------------------------------------------

    @Test
    @DisplayName("the endpoints answer with the rules' codes and sit behind the agency wall")
    void endpoints() throws Exception {
        String body = "{\"kind\":\"VACATION\",\"startDate\":\"" + today.plusDays(3)
                + "\",\"endDate\":\"" + today.plusDays(5) + "\",\"coverId\":" + colleague.getId() + "}";
        mockMvc.perform(post("/time-off").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.days").value(3))
                .andExpect(jsonPath("$.coverName").value("Timur Aliev"));
        mockMvc.perform(post("/time-off").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("TIME_OFF_OVERLAPS"));
        mockMvc.perform(post("/time-off").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"kind\":\"VACATION\"}"))
                .andExpect(status().isBadRequest());
        mockMvc.perform(get("/time-off").header(HttpHeaders.AUTHORIZATION, bearer(third))
                        .param("from", today.toString()).param("to", today.plusDays(30).toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].userName").value("Aigul Bekova"))
                .andExpect(jsonPath("$[0].kind").value("VACATION"));
        mockMvc.perform(get("/users/agents").header(HttpHeaders.AUTHORIZATION, bearer(third)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.fullName == 'Aigul Bekova')].timeOff[0].startDate")
                        .value(today.plusDays(3).toString()));

        User loner = user("to-loner@nowhere.kz", "Loner", Role.AGENT, null);
        mockMvc.perform(get("/time-off").header(HttpHeaders.AUTHORIZATION, bearer(loner)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // Helpers ---------------------------------------------------------------------------

    private static TimeOffRequest request(Long userId, TimeOffKind kind, LocalDate start, LocalDate end, User cover) {
        TimeOffRequest request = new TimeOffRequest();
        request.setUserId(userId);
        request.setKind(kind);
        request.setStartDate(start);
        request.setEndDate(end);
        request.setCoverId(cover == null ? null : cover.getId());
        return request;
    }

    private static void assertCode(org.assertj.core.api.ThrowableAssert.ThrowingCallable call, String code) {
        assertThatThrownBy(call).isInstanceOf(BusinessException.class)
                .satisfies(e -> assertThat(((BusinessException) e).getCode()).isEqualTo(code));
    }

    private void flush() {
        entityManager.flush();
        entityManager.clear();
    }

    private List<Notification> forUser(User who) {
        return notificationRepository.findAll().stream()
                .filter(n -> n.getRecipient().getId().equals(who.getId()))
                .toList();
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> params(Notification n) {
        try {
            return objectMapper.readValue(n.getPayload(), Map.class);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private Task task(String title, User assignee) {
        return taskRepository.save(Task.builder()
                .title(title).dueAt(today.plusDays(1).atTime(10, 0))
                .assignee(assignee).createdBy(manager).team(almaty).build());
    }

    private Meeting meeting(Client client, User holder, java.time.LocalDateTime at, boolean completed) {
        return meetingRepository.save(Meeting.builder()
                .title("Viewing").scheduledAt(at).completed(completed)
                .client(client).agent(holder).team(client.getTeam()).build());
    }

    private User user(String email, String name, Role role, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(role == Role.AGENT ? DataScope.OWN : DataScope.TEAM).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /** The token alone decides who is asking: the filter keeps an authentication already there. */
    private String bearer(User who) {
        SecurityContextHolder.clearContext();
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, who.getAuthorities()));
    }
}
