package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The paperwork on a deal: attaching it, listing it, reading it back and taking
 * it down again — plus the two things that must not happen, an unknown file
 * type getting in and another agent's deal being reachable at all.
 */
@SpringBootTest(properties = "app.documents.dir=target/test-documents")
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class DocumentControllerTest {

    private static final Path STORAGE = Paths.get("target/test-documents");

    @Autowired private MockMvc mockMvc;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private DocumentRepository documentRepository;
    @Autowired private TeamRepository teamRepository;

    private Team team;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private User agent;
    private Deal deal;
    private Deal someoneElsesDeal;

    @BeforeEach
    void setUp() throws Exception {
        clearStorage();
        SecurityContextHolder.clearContext();
        documentRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        // Same agency, different agents: what must stay unreachable here is a colleague's deal,
        // not another agency's.
        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = userRepository.save(user("agent@estate.crm", "Aigerim Serikbaykyzy"));
        User otherAgent = userRepository.save(user("other@estate.crm", "Daniyar Nurlanuly"));

        deal = dealRepository.save(deal("Severny Residence, apt 84", agent));
        someoneElsesDeal = dealRepository.save(deal("Dacha in Talgar", otherAgent));

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
    }

    @Test
    void uploadedFileIsListedDownloadedAndRemoved() throws Exception {
        byte[] bytes = "a signed contract".getBytes(StandardCharsets.UTF_8);

        MvcResult uploaded = mockMvc.perform(multipart(documentsUrl(deal))
                        .file(new MockMultipartFile("file", "Договор №14.pdf", "application/pdf", bytes)))
                .andExpect(status().isCreated())
                .andReturn();

        // Read as UTF-8 explicitly: MockMvc's response defaults to ISO-8859-1 when
        // the converter writes application/json without a charset, which real
        // clients read as UTF-8 anyway.
        JsonNode created = objectMapper.readTree(
                uploaded.getResponse().getContentAsString(StandardCharsets.UTF_8));
        assertThat(created.get("fileName").asText()).isEqualTo("Договор №14.pdf");
        assertThat(created.get("fileType").asText()).isEqualTo("pdf");
        assertThat(created.get("fileSize").asLong()).isEqualTo(bytes.length);
        assertThat(created.get("uploadedByName").asText()).isEqualTo(agent.getFullName());
        long documentId = created.get("id").asLong();

        MvcResult listed = mockMvc.perform(get(documentsUrl(deal)))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode list = objectMapper.readTree(
                listed.getResponse().getContentAsString(StandardCharsets.UTF_8));
        assertThat(list).hasSize(1);
        assertThat(list.get(0).get("id").asLong()).isEqualTo(documentId);

        MvcResult downloaded = mockMvc.perform(get(documentsUrl(deal) + "/" + documentId + "/content"))
                .andExpect(status().isOk())
                .andReturn();
        assertThat(downloaded.getResponse().getContentAsByteArray()).isEqualTo(bytes);
        // The name survives the trip in a form a Cyrillic filename can travel in.
        assertThat(downloaded.getResponse().getHeader(HttpHeaders.CONTENT_DISPOSITION))
                .contains("filename*=UTF-8''");

        mockMvc.perform(delete(documentsUrl(deal) + "/" + documentId))
                .andExpect(status().isNoContent());

        assertThat(documentRepository.findByDealId(deal.getId())).isEmpty();
        assertThat(storedFileCount()).isZero();
    }

    @Test
    void aFileTypeOutsideTheWhitelistIsRefused() throws Exception {
        mockMvc.perform(multipart(documentsUrl(deal))
                        .file(new MockMultipartFile("file", "payload.exe", "application/octet-stream",
                                "MZ".getBytes(StandardCharsets.UTF_8))))
                .andExpect(status().isBadRequest());

        assertThat(documentRepository.findByDealId(deal.getId())).isEmpty();
        assertThat(storedFileCount()).isZero();
    }

    @Test
    void anotherAgentsDealHasNoDocuments() throws Exception {
        mockMvc.perform(get(documentsUrl(someoneElsesDeal)))
                .andExpect(status().isNotFound());

        mockMvc.perform(multipart(documentsUrl(someoneElsesDeal))
                        .file(new MockMultipartFile("file", "plan.pdf", "application/pdf",
                                "x".getBytes(StandardCharsets.UTF_8))))
                .andExpect(status().isNotFound());

        assertThat(storedFileCount()).isZero();
    }

    private String documentsUrl(Deal target) {
        return "/deals/" + target.getId() + "/documents";
    }

    private User user(String email, String fullName) {
        return User.builder()
                .fullName(fullName)
                .email(email)
                .password("x")
                .role(Role.AGENT)
                .dataScope(DataScope.OWN)
                .team(team)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .build();
    }

    private Deal deal(String title, User owner) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Client of " + owner.getFullName())
                .type(ClientType.BUYER)
                .agent(owner)
                .team(owner.getTeam())
                .build());
        return Deal.builder()
                .title(title)
                .status(DealStatus.LEAD)
                .client(client)
                .agent(owner)
                .team(owner.getTeam())
                .build();
    }

    private long storedFileCount() throws Exception {
        if (!Files.exists(STORAGE)) return 0;
        try (var files = Files.walk(STORAGE)) {
            return files.filter(Files::isRegularFile).count();
        }
    }

    private void clearStorage() throws Exception {
        if (!Files.exists(STORAGE)) return;
        try (var paths = Files.walk(STORAGE)) {
            paths.sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
        }
    }
}
