package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
public class ClientControllerTest {

        private static final String CLIENTS_URL = "/clients";

        @Autowired
        private MockMvc mockMvc;

        @Autowired
        private ClientRepository clientRepository;

        @Autowired
        private UserRepository userRepository;

        private User currentUser;

        private final ObjectMapper objectMapper = new ObjectMapper();

        @BeforeEach
        public void setUp() {
                SecurityContextHolder.clearContext();
                clientRepository.deleteAll();
                userRepository.deleteAll();

                currentUser = userRepository.save(User.builder()
                        .email("test-agent@example.com")
                        .password("secret")
                        .fullName("Test Agent")
                        .role(Role.AGENT)
                        .dataScope(DataScope.OWN)
                        .status(UserStatus.ACTIVE)
                        .isActive(true)
                        .build());

                SecurityContextHolder.getContext().setAuthentication(
                        new UsernamePasswordAuthenticationToken(currentUser.getEmail(), null, currentUser.getAuthorities()));
        }

        @Test
        public void testGetAllClientsLegacy_returnsArray() throws Exception {
                clientRepository.save(Client.builder()
                                .fullName("Alice")
                                .type(ClientType.BUYER)
                                .email("a@example.com")
                                .agent(currentUser)
                                .build());
                clientRepository.save(Client.builder()
                                .fullName("Bob")
                                .type(ClientType.SELLER)
                                .email("b@example.com")
                                .agent(currentUser)
                                .build());

                String json = mockMvc.perform(get(CLIENTS_URL))
                                .andExpect(status().isOk())
                                .andReturn().getResponse().getContentAsString();

                JsonNode root = objectMapper.readTree(json);
                assertThat(root.isArray()).isTrue();
                assertThat(root.size()).isEqualTo(2);
        }

        @Test
        public void testGetClientsPaged_returnsPage() throws Exception {
                IntStream.rangeClosed(1, 15).forEach(i -> clientRepository.save(Client.builder()
                                .fullName("Client " + i)
                                .type(i % 2 == 0 ? ClientType.BUYER : ClientType.SELLER)
                                .email("c" + i + "@ex.com")
                                .agent(currentUser)
                                .build()));

                String json = mockMvc.perform(get(CLIENTS_URL + "?page=0&size=10"))
                                .andExpect(status().isOk())
                                .andReturn().getResponse().getContentAsString();

                JsonNode root = objectMapper.readTree(json);
                // Should be a paged response object (not array)
                assertThat(root.isArray()).isFalse();
                assertThat(root.has("content")).isTrue();
                assertThat(root.get("content").isArray()).isTrue();
                assertThat(root.get("content").size()).isEqualTo(10);
                assertThat(root.get("totalElements").asInt()).isEqualTo(15);
        }

        @Test
        public void testGetClientsFilterType_withoutPaging_returnsArray() throws Exception {
                clientRepository
                                .save(Client.builder().fullName("Buyer One").type(ClientType.BUYER)
                                                .email("b1@example.com")
                                                .agent(currentUser)
                                                .build());
                clientRepository
                                .save(Client.builder().fullName("Seller One").type(ClientType.SELLER)
                                                .email("s1@example.com")
                                                .agent(currentUser)
                                                .build());

                String json = mockMvc.perform(get(CLIENTS_URL + "?type=BUYER"))
                                .andExpect(status().isOk())
                                .andReturn().getResponse().getContentAsString();

                JsonNode root = objectMapper.readTree(json);
                assertThat(root.isArray()).isTrue();
                assertThat(root.size()).isEqualTo(1);
                assertThat(root.get(0).get("fullName").asText()).isEqualTo("Buyer One");
        }

        @Test
        public void testGetClientsSearch_withoutPaging_returnsArray() throws Exception {
                clientRepository
                                .save(Client.builder().fullName("Example User").type(ClientType.BUYER)
                                                .email("ex@example.com")
                                                .agent(currentUser)
                                                .build());
                clientRepository
                                .save(Client.builder().fullName("Another").type(ClientType.SELLER)
                                                .email("another@foo.com")
                                                .agent(currentUser)
                                                .build());

                String json = mockMvc.perform(get(CLIENTS_URL + "?search=Example"))
                                .andExpect(status().isOk())
                                .andReturn().getResponse().getContentAsString();

                JsonNode root = objectMapper.readTree(json);
                assertThat(root.isArray()).isTrue();
                assertThat(root.size()).isEqualTo(1);
                assertThat(root.get(0).get("fullName").asText()).isEqualTo("Example User");
        }

        @Test
        public void testInvalidDateParam_returnsBadRequest() throws Exception {
                mockMvc.perform(get(CLIENTS_URL + "?createdFrom=not-a-date&page=0&size=10"))
                                .andExpect(status().isBadRequest());
        }
}
