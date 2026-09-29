package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ChecklistTemplateItemRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealChecklistItemRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.nio.charset.StandardCharsets;

/**
 * Two agencies for the checklist tests: Almaty with a manager, the deal's agent, a colleague who
 * sees the whole team and one who sees only their own; Astana with a manager of its own.
 */
abstract class ChecklistFixture {

    @Autowired protected MockMvc mockMvc;
    @Autowired protected ObjectMapper objectMapper;
    @Autowired protected JwtService jwtService;
    @Autowired protected EntityManager entityManager;

    @Autowired protected ChecklistTemplateItemRepository templateRepository;
    @Autowired protected DealChecklistItemRepository itemRepository;
    @Autowired protected DocumentRepository documentRepository;
    @Autowired protected DealRepository dealRepository;
    @Autowired protected ClientRepository clientRepository;
    @Autowired protected UserRepository userRepository;
    @Autowired protected TeamRepository teamRepository;
    @Autowired protected AuditLogRepository auditLogRepository;

    protected Team almaty;
    protected Team astana;
    protected User manager;
    protected User agent;
    protected User colleague;
    protected User ownOnly;
    protected User stranger;

    @BeforeEach
    void seedAgencies() {
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("cl-manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("cl-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("cl-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        ownOnly = user("cl-own@almaty.kz", "Dana Seitova", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("cl-manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);
    }

    protected User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /** A deal saved straight to the database, the way deals from before the checklist exist. */
    protected Deal oldDeal(String title, User holder, Team team) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer of " + title).type(ClientType.BUYER).agent(holder).team(team).build());
        return dealRepository.save(Deal.builder()
                .title(title).status(DealStatus.LEAD).client(client).agent(holder).team(team).build());
    }

    protected Document document(Deal deal, String name) {
        return documentRepository.save(Document.builder()
                .fileName(name).fileType("pdf").fileSize(10L).filePath("mem/" + name)
                .deal(deal).uploadedBy(deal.getAgent()).build());
    }

    protected ResultActions as(User who, MockHttpServletRequestBuilder request) throws Exception {
        return mockMvc.perform(request.header(HttpHeaders.AUTHORIZATION, "Bearer " + jwtService.generateAccessToken(who)));
    }

    protected JsonNode json(ResultActions result) throws Exception {
        return objectMapper.readTree(result.andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8));
    }

    protected void flushAndClear() {
        entityManager.flush();
        entityManager.clear();
    }
}
