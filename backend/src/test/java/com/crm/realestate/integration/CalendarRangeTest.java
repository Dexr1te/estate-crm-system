package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

import static org.hamcrest.Matchers.contains;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The calendar asks for one month at a time: meetings and tasks with a time in {@code [from, to)}.
 *
 * <p>The window only narrows what the caller could already see, so an agent on their own records
 * still gets only theirs and another agency gets nothing. Tasks can be asked for open and done
 * together, since a calendar shows finished ones too, muted.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class CalendarRangeTest {

    private static final LocalDateTime FROM = LocalDateTime.of(2026, 10, 1, 0, 0);
    private static final LocalDateTime TO = LocalDateTime.of(2026, 11, 1, 0, 0);

    @Autowired private MockMvc mockMvc;
    @Autowired private TaskRepository taskRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private User manager;
    private User agent;
    private User colleague;
    private User stranger;
    private Client aigerim;
    private Client daniyar;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        taskRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("manager@astana.kz", Role.MANAGER, DataScope.TEAM, astana);
        aigerim = client("Aigerim", agent, almaty);
        daniyar = client("Daniyar", colleague, almaty);
    }

    @Test
    @DisplayName("meetings: only those starting inside the window, soonest first")
    void meetingsInWindow() throws Exception {
        meeting("Before", FROM.minusMinutes(1), aigerim, agent);
        meeting("Late in month", LocalDateTime.of(2026, 10, 31, 23, 30), aigerim, agent);
        meeting("First thing", FROM, daniyar, colleague);
        meeting("After", TO, aigerim, agent);

        signIn(manager);
        mockMvc.perform(get("/meetings").param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].title").value(contains("First thing", "Late in month")));

        mockMvc.perform(get("/meetings"))
                .andExpect(jsonPath("$.length()").value(4));
    }

    @Test
    @DisplayName("meetings: the window keeps the caller's scope and the agent filter")
    void meetingsWindowKeepsScope() throws Exception {
        meeting("Mine", FROM.plusDays(3), aigerim, agent);
        meeting("Colleague's", FROM.plusDays(4), daniyar, colleague);

        signIn(agent);
        mockMvc.perform(get("/meetings").param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$[*].title").value(contains("Mine")));

        signIn(manager);
        mockMvc.perform(get("/meetings").param("agentId", colleague.getId().toString())
                        .param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$[*].title").value(contains("Colleague's")));

        signIn(stranger);
        mockMvc.perform(get("/meetings").param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("tasks: status=all brings open and done due inside the window, soonest first")
    void tasksInWindow() throws Exception {
        task("Done early", FROM.plusDays(1), agent, true);
        task("Open later", FROM.plusDays(9), agent, false);
        task("Last month", FROM.minusDays(1), agent, false);
        task("Next month", TO, agent, false);

        signIn(manager);
        mockMvc.perform(get("/tasks").param("status", "all")
                        .param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].title").value(contains("Done early", "Open later")));

        mockMvc.perform(get("/tasks").param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$[*].title").value(contains("Open later")));

        mockMvc.perform(get("/tasks"))
                .andExpect(jsonPath("$.length()").value(3));
    }

    @Test
    @DisplayName("tasks: the window keeps the caller's scope")
    void tasksWindowKeepsScope() throws Exception {
        task("Mine", FROM.plusDays(2), agent, false);
        task("Colleague's", FROM.plusDays(2), colleague, true);

        signIn(agent);
        mockMvc.perform(get("/tasks").param("status", "all")
                        .param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$[*].title").value(contains("Mine")));

        signIn(stranger);
        mockMvc.perform(get("/tasks").param("status", "all")
                        .param("from", FROM.toString()).param("to", TO.toString()))
                .andExpect(jsonPath("$.length()").value(0));
    }

    // Helpers -------------------------------------------------------------------------

    private void meeting(String title, LocalDateTime at, Client client, User holder) {
        meetingRepository.save(Meeting.builder()
                .title(title).scheduledAt(at)
                .client(client).agent(holder).team(client.getTeam())
                .build());
    }

    private void task(String title, LocalDateTime due, User holder, boolean done) {
        taskRepository.save(Task.builder()
                .title(title).dueAt(due)
                .assignee(holder).createdBy(holder).team(holder.getTeam())
                .completedAt(done ? due : null)
                .build());
    }

    private Client client(String name, User holder, Team team) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .agent(holder).team(team).build());
    }

    private User user(String email, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
