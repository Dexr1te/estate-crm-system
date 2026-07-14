package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.repository.ClientRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
public class ClientControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ClientRepository clientRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    public void setUp() {
        clientRepository.deleteAll();
    }

    @Test
    public void testGetAllClientsLegacy_returnsArray() throws Exception {
        clientRepository.save(Client.builder().fullName("Alice").type(ClientType.BUYER).email("a@example.com").build());
        clientRepository.save(Client.builder().fullName("Bob").type(ClientType.SELLER).email("b@example.com").build());

        String json = mockMvc.perform(get("/api/clients"))
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
                .build()));

        String json = mockMvc.perform(get("/api/clients?page=0&size=10"))
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
                .save(Client.builder().fullName("Buyer One").type(ClientType.BUYER).email("b1@example.com").build());
        clientRepository
                .save(Client.builder().fullName("Seller One").type(ClientType.SELLER).email("s1@example.com").build());

        String json = mockMvc.perform(get("/api/clients?type=BUYER"))
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
                .save(Client.builder().fullName("Example User").type(ClientType.BUYER).email("ex@example.com").build());
        clientRepository
                .save(Client.builder().fullName("Another").type(ClientType.SELLER).email("a@example.com").build());

        String json = mockMvc.perform(get("/api/clients?search=Example"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        JsonNode root = objectMapper.readTree(json);
        assertThat(root.isArray()).isTrue();
        assertThat(root.size()).isEqualTo(1);
        assertThat(root.get(0).get("fullName").asText()).isEqualTo("Example User");
    }

    @Test
    public void testInvalidDateParam_returnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/clients?createdFrom=not-a-date&page=0&size=10"))
                .andExpect(status().isBadRequest());
    }
}
