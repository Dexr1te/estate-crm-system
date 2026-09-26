package com.crm.realestate.integration;

import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.NotificationRepository;
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

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The feed over HTTP: always the caller's own, newest first, and somebody else's reads as missing.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class NotificationEndpointsTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private User agent;
    private User colleague;
    private Notification oldest;
    private Notification middle;
    private Notification newest;
    private Notification colleagues;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        notificationRepository.deleteAll();
        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("agent@almaty.kz", almaty);
        colleague = user("colleague@almaty.kz", almaty);

        LocalDateTime now = LocalDateTime.now();
        oldest = save(agent, NotificationType.TASK_ASSIGNED, now.minusDays(3), now.minusDays(2));
        middle = save(agent, NotificationType.NEW_MATCH, now.minusDays(1), null);
        newest = save(agent, NotificationType.DEAL_STATUS_CHANGED, now.minusMinutes(5), null);
        colleagues = save(colleague, NotificationType.TASK_ASSIGNED, now, null);
    }

    @Test
    @DisplayName("the feed is the caller's own, newest first, a page at a time, with its params")
    void listsOwnNewestFirst() throws Exception {
        signIn(agent);

        mockMvc.perform(get("/notifications").param("page", "0").param("size", "2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(3))
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.content[0].id").value(newest.getId()))
                .andExpect(jsonPath("$.content[0].type").value("DEAL_STATUS_CHANGED"))
                .andExpect(jsonPath("$.content[0].params.dealTitle").value("Dostyk flat"))
                .andExpect(jsonPath("$.content[0].readAt").value(nullValue()))
                .andExpect(jsonPath("$.content[1].id").value(middle.getId()));

        mockMvc.perform(get("/notifications").param("page", "1").param("size", "2"))
                .andExpect(jsonPath("$.content.length()").value(1))
                .andExpect(jsonPath("$.content[0].id").value(oldest.getId()))
                .andExpect(jsonPath("$.content[0].readAt").value(notNullValue()));
    }

    @Test
    @DisplayName("unread only leaves out what has been read, and the count agrees")
    void unreadOnlyAndCount() throws Exception {
        signIn(agent);

        mockMvc.perform(get("/notifications").param("unreadOnly", "true"))
                .andExpect(jsonPath("$.totalElements").value(2));
        mockMvc.perform(get("/notifications/unread-count"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(2));
    }

    @Test
    @DisplayName("reading one marks it, reading it again keeps the first time, somebody else's is 404")
    void markOneRead() throws Exception {
        signIn(agent);

        mockMvc.perform(post("/notifications/{id}/read", middle.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.readAt").value(notNullValue()));
        LocalDateTime firstRead = notificationRepository.findById(middle.getId()).orElseThrow().getReadAt();
        mockMvc.perform(post("/notifications/{id}/read", middle.getId())).andExpect(status().isOk());
        assertThat(notificationRepository.findById(middle.getId()).orElseThrow().getReadAt()).isEqualTo(firstRead);

        mockMvc.perform(post("/notifications/{id}/read", colleagues.getId()))
                .andExpect(status().isNotFound());
        assertThat(notificationRepository.findById(colleagues.getId()).orElseThrow().getReadAt()).isNull();
        mockMvc.perform(get("/notifications/unread-count")).andExpect(jsonPath("$.count").value(1));
    }

    @Test
    @DisplayName("read-all clears the caller's unread and nobody else's")
    void markAllRead() throws Exception {
        signIn(agent);

        mockMvc.perform(post("/notifications/read-all"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.updated").value(2));

        mockMvc.perform(get("/notifications/unread-count")).andExpect(jsonPath("$.count").value(0));
        signIn(colleague);
        mockMvc.perform(get("/notifications/unread-count")).andExpect(jsonPath("$.count").value(1));
    }

    @Test
    @DisplayName("somebody outside any team can still read their feed: that is where an invitation lands")
    void noTeamNeeded() throws Exception {
        User newcomer = user("newcomer@mail.kz", null);
        save(newcomer, NotificationType.JOIN_REQUEST, LocalDateTime.now(), null);
        signIn(newcomer);

        mockMvc.perform(get("/notifications"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].type").value("JOIN_REQUEST"));
        mockMvc.perform(get("/notifications/unread-count")).andExpect(jsonPath("$.count").value(1));
    }

    private Notification save(User recipient, NotificationType type, LocalDateTime at, LocalDateTime readAt) {
        return notificationRepository.save(Notification.builder()
                .recipient(recipient).team(recipient.getTeam()).type(type).targetId(7L)
                .payload("{\"dealTitle\":\"Dostyk flat\"}")
                .createdAt(at).readAt(readAt).build());
    }

    private User user(String email, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(DataScope.OWN).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
