package com.crm.realestate.integration;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtProperties;
import com.crm.realestate.security.JwtService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
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

import java.util.Date;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UnauthenticatedStatusTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private JwtProperties jwtProperties;
    @Autowired private TeamRepository teamRepository;
    @Autowired private UserRepository userRepository;

    private User agent;
    private User loner;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        Team team = teamRepository.save(Team.builder().name("Expiry Realty").build());
        agent = user("agent@expiry.kz", team);
        loner = user("loner@expiry.kz", null);
    }

    @Test
    @DisplayName("an expired access token is answered 401, so the app knows to refresh it")
    void expiredTokenIsUnauthorized() throws Exception {
        String expired = Jwts.builder()
                .setSubject(agent.getEmail())
                .setIssuedAt(new Date(System.currentTimeMillis() - 2 * 86_400_000L))
                .setExpiration(new Date(System.currentTimeMillis() - 86_400_000L))
                .signWith(Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtProperties.getSecret())),
                        SignatureAlgorithm.HS256)
                .compact();

        mockMvc.perform(get("/clients").header(HttpHeaders.AUTHORIZATION, "Bearer " + expired))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("no token or a garbled one is 401 too")
    void missingOrBrokenTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get("/clients"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/clients").header(HttpHeaders.AUTHORIZATION, "Bearer not-a-token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("a signed-in user who may not do something still gets 403")
    void forbiddenStaysForbidden() throws Exception {
        mockMvc.perform(get("/clients")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + jwtService.generateAccessToken(agent)))
                .andExpect(status().isOk());
        mockMvc.perform(get("/clients")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + jwtService.generateAccessToken(loner)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
        mockMvc.perform(get("/admin/users")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + jwtService.generateAccessToken(agent)))
                .andExpect(status().isForbidden());
    }

    private User user(String email, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email).role(Role.AGENT)
                .dataScope(DataScope.OWN).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
