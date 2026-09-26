package com.crm.realestate.integration;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.NotificationWriter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Telling somebody is never allowed to undo the thing being told. */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class NotificationFailureTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private TaskRepository taskRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    @MockBean private NotificationWriter writer;

    @Test
    @DisplayName("a task is still created when its notification cannot be written")
    void failingNotificationKeepsTheTask() throws Exception {
        doThrow(new IllegalStateException("database said no"))
                .when(writer).write(any(), any(), any(), any(), any());
        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        User manager = user("manager@almaty.kz", Role.MANAGER, almaty);
        User agent = user("agent@almaty.kz", Role.AGENT, almaty);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(manager.getEmail(), null, List.of()));
        long before = taskRepository.count();

        mockMvc.perform(post("/tasks").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Call Irina back\",\"dueAt\":\"2030-01-01T10:00:00\",\"assigneeId\":"
                                + agent.getId() + "}"))
                .andExpect(status().isCreated());

        verify(writer).write(any(), any(), any(), any(), any());
        assertThat(taskRepository.count()).isEqualTo(before + 1);
    }

    private User user(String email, Role role, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(DataScope.TEAM).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
