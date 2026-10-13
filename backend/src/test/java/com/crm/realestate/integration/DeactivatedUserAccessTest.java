package com.crm.realestate.integration;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DeactivatedUserAccessTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private TeamRepository teamRepository;
    @Autowired private UserRepository userRepository;

    private User agent;
    private User admin;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        Team team = teamRepository.save(Team.builder().name("Deactivation Realty").build());
        agent = user("fired.agent@deactivation.kz", Role.AGENT, team);
        admin = user("operator@deactivation.kz", Role.ADMIN, null);
    }

    @Test
    @DisplayName("a token issued before deactivation stops working, and so does its refresh")
    void deactivationCutsExistingSessions() throws Exception {
        String access = "Bearer " + jwtService.generateAccessToken(agent);
        String refresh = "Bearer " + jwtService.generateRefreshToken(agent);

        mockMvc.perform(get("/auth/me").header(HttpHeaders.AUTHORIZATION, access))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/admin/users/{id}/deactivate", agent.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/auth/me").header(HttpHeaders.AUTHORIZATION, access))
                .andExpect(status().is4xxClientError());
        mockMvc.perform(get("/clients").header(HttpHeaders.AUTHORIZATION, access))
                .andExpect(status().is4xxClientError());
        mockMvc.perform(post("/auth/refresh").header(HttpHeaders.AUTHORIZATION, refresh))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("an account switched back on can use its session again")
    void reactivationRestoresAccess() throws Exception {
        String access = "Bearer " + jwtService.generateAccessToken(agent);
        String refresh = "Bearer " + jwtService.generateRefreshToken(agent);

        mockMvc.perform(patch("/admin/users/{id}/deactivate", agent.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isOk());
        mockMvc.perform(patch("/admin/users/{id}/activate", agent.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/auth/me").header(HttpHeaders.AUTHORIZATION, access))
                .andExpect(status().isOk());
        mockMvc.perform(post("/auth/refresh").header(HttpHeaders.AUTHORIZATION, refresh))
                .andExpect(status().isOk());
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private User user(String email, Role role, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email).role(role)
                .dataScope(role == Role.AGENT ? DataScope.OWN : DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
