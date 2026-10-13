package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.demo.DemoRateLimiter;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class TryTheDemoTest {

    static ResultActions startDemo(MockMvc mockMvc, String address) throws Exception {
        SecurityContextHolder.clearContext();
        return mockMvc.perform(post("/auth/demo").with(request -> {
            request.setRemoteAddr(address);
            return request;
        }));
    }

    @Nested
    @SpringBootTest
    @AutoConfigureMockMvc
    @Transactional
    class WhenEnabled {

        @Autowired private MockMvc mockMvc;
        @Autowired private ObjectMapper objectMapper;
        @Autowired private DemoRateLimiter rateLimiter;
        @Autowired private UserRepository userRepository;
        @Autowired private TeamRepository teamRepository;
        @Autowired private ClientRepository clientRepository;
        @Autowired private PropertyRepository propertyRepository;
        @Autowired private DealRepository dealRepository;
        @Autowired private MeetingRepository meetingRepository;

        @BeforeEach
        void setUp() {
            rateLimiter.reset();
            SecurityContextHolder.clearContext();
        }

        private JsonNode start(String address) throws Exception {
            String body = startDemo(mockMvc, address)
                    .andExpect(status().isCreated())
                    .andReturn().getResponse().getContentAsString();
            return objectMapper.readTree(body);
        }

        private JsonNode clientsSeenBy(JsonNode session) throws Exception {
            SecurityContextHolder.clearContext();
            String body = mockMvc.perform(get("/clients")
                            .header(HttpHeaders.AUTHORIZATION, "Bearer " + session.get("accessToken").asText()))
                    .andExpect(status().isOk())
                    .andReturn().getResponse().getContentAsString();
            return objectMapper.readTree(body);
        }

        @Test
        @DisplayName("a demo is a fresh agency with one agent, sample records and a session")
        void createsAnIsolatedAgency() throws Exception {
            Team realAgency = teamRepository.save(Team.builder().name("Almaty Realty").build());
            User realAgent = userRepository.save(User.builder()
                    .email("real-agent@almaty.kz").password("x").fullName("Real Agent")
                    .role(Role.AGENT).dataScope(DataScope.OWN).team(realAgency)
                    .status(UserStatus.ACTIVE).isActive(true).build());
            clientRepository.save(Client.builder().fullName("Real Client").email("real@client.kz")
                    .type(ClientType.BUYER).agent(realAgent).team(realAgency).build());

            JsonNode session = start("10.0.0.1");

            assertThat(session.get("accessToken").asText()).isNotBlank();
            assertThat(session.get("refreshToken").asText()).isNotBlank();
            assertThat(session.get("role").asText()).isEqualTo("AGENT");
            assertThat(session.get("dataScope").asText()).isEqualTo("OWN");
            assertThat(session.get("teamName").asText()).isEqualTo("[Demo] Agency");
            assertThat(session.get("email").asText()).matches("demo-[0-9a-f]{24}@demo\\.estatecrm\\.app");

            User agent = userRepository.findById(session.get("userId").asLong()).orElseThrow();
            Long teamId = session.get("teamId").asLong();
            assertThat(agent.getStatus()).isEqualTo(UserStatus.ACTIVE);
            assertThat(agent.isMustChangePassword()).isFalse();
            assertThat(agent.getPassword()).isNotBlank();
            assertThat(agent.getTeam().getId()).isEqualTo(teamId);
            assertThat(userRepository.findByTeamId(teamId))
                    .extracting(User::getEmail)
                    .allMatch(email -> email.startsWith("demo-") && email.endsWith("@demo.estatecrm.app"))
                    .hasSize(2);

            assertThat(clientRepository.findByAgentId(agent.getId())).hasSize(6)
                    .allMatch(c -> c.getTeam().getId().equals(teamId));
            assertThat(propertyRepository.findByAgentId(agent.getId())).hasSize(5)
                    .allMatch(p -> p.getTeam().getId().equals(teamId));
            assertThat(dealRepository.findByAgentId(agent.getId())).hasSize(5)
                    .allMatch(d -> d.getTeam().getId().equals(teamId));
            assertThat(meetingRepository.findByAgentId(agent.getId())).hasSize(4);

            JsonNode seen = clientsSeenBy(session);
            assertThat(seen).hasSize(6);
            seen.forEach(c -> assertThat(c.get("fullName").asText()).startsWith("[Demo] "));
        }

        @Test
        @DisplayName("every call opens its own agency, and neither sees the other")
        void twoCallsTwoAgencies() throws Exception {
            JsonNode first = start("10.0.0.2");
            JsonNode second = start("10.0.0.2");

            assertThat(first.get("teamId").asLong()).isNotEqualTo(second.get("teamId").asLong());
            assertThat(first.get("userId").asLong()).isNotEqualTo(second.get("userId").asLong());
            assertThat(first.get("email").asText()).isNotEqualTo(second.get("email").asText());

            List<Long> firstClients = clientRepository.findByAgentId(first.get("userId").asLong())
                    .stream().map(Client::getId).toList();
            JsonNode seenBySecond = clientsSeenBy(second);
            assertThat(seenBySecond).hasSize(6);
            seenBySecond.forEach(c -> assertThat(firstClients).doesNotContain(c.get("id").asLong()));
        }

        @Test
        @DisplayName("five demos an hour from one address, then 429; another address still gets one")
        void rateLimitedPerAddress() throws Exception {
            for (int i = 0; i < 5; i++) {
                start("10.0.0.3");
            }
            long teams = teamRepository.count();

            startDemo(mockMvc, "10.0.0.3")
                    .andExpect(status().isTooManyRequests())
                    .andExpect(jsonPath("$.code").value("DEMO_RATE_LIMITED"));
            assertThat(teamRepository.count()).isEqualTo(teams);

            start("10.0.0.4");
        }

        @Test
        @DisplayName("a demo account cannot take another address, so it stays a demo and never mails anyone")
        void addressIsLocked() throws Exception {
            JsonNode session = start("10.0.0.5");
            SecurityContextHolder.clearContext();

            mockMvc.perform(put("/auth/me")
                            .header(HttpHeaders.AUTHORIZATION, "Bearer " + session.get("accessToken").asText())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"fullName\":\"Someone\",\"email\":\"someone@gmail.com\"}"))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.code").value("DEMO_EMAIL_LOCKED"));

            assertThat(userRepository.findById(session.get("userId").asLong()).orElseThrow().getEmail())
                    .isEqualTo(session.get("email").asText());
        }

        @Test
        @DisplayName("deleting a demo account works, handing its records to the demo's own colleague")
        void accountCanBeDeleted() throws Exception {
            JsonNode session = start("10.0.0.6");
            Long agentId = session.get("userId").asLong();
            User handover = userRepository.findByTeamId(session.get("teamId").asLong()).stream()
                    .filter(u -> !u.getId().equals(agentId))
                    .findFirst().orElseThrow();
            SecurityContextHolder.clearContext();

            mockMvc.perform(delete("/auth/me")
                            .param("replacementId", handover.getId().toString())
                            .header(HttpHeaders.AUTHORIZATION, "Bearer " + session.get("accessToken").asText()))
                    .andExpect(status().isNoContent());

            assertThat(userRepository.findById(agentId)).isEmpty();
            assertThat(dealRepository.findByAgentId(handover.getId())).hasSize(5);
        }
    }

    @Nested
    @SpringBootTest(properties = "app.demo.try-enabled=false")
    @AutoConfigureMockMvc
    @Transactional
    class WhenSwitchedOff {

        @Autowired private MockMvc mockMvc;
        @Autowired private TeamRepository teamRepository;
        @Autowired private DemoRateLimiter rateLimiter;

        @Test
        @DisplayName("the endpoint answers 404 and creates nothing")
        void answersNotFound() throws Exception {
            rateLimiter.reset();
            long teams = teamRepository.count();

            startDemo(mockMvc, "10.0.0.7")
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.code").value("DEMO_UNAVAILABLE"));

            assertThat(teamRepository.count()).isEqualTo(teams);
        }
    }
}
