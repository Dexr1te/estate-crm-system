package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.dto.response.RecordChangeResponse;
import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPriceChangeRepository;
import com.crm.realestate.repository.RecordChangeRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.ChangeHistoryService;
import com.crm.realestate.service.ClientDuplicateService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.DealService;
import com.crm.realestate.service.PropertyService;
import com.crm.realestate.service.RecordHandoverService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.tuple;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The change log: who created, edited or deleted a listing, a deal or a client, and what each
 * edited field was before and after. One record's history is read by whoever can see the record;
 * the agency's whole feed by its manager. Nothing crosses between agencies, and a line outlives
 * both the record and the person who wrote it.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class ChangeLogTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PropertyService propertyService;
    @Autowired private DealService dealService;
    @Autowired private ClientService clientService;
    @Autowired private ChangeHistoryService historyService;
    @Autowired private RecordHandoverService handoverService;
    @Autowired private ClientDuplicateService duplicateService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private RecordChangeRepository changeRepository;
    @Autowired private PropertyPriceChangeRepository priceChangeRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User colleague;
    private User manager;
    private User stranger;
    private User admin;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estate.crm");
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("cl-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("cl-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        manager = user("cl-manager@almaty.kz", "Marat Manager", Role.MANAGER, DataScope.TEAM, almaty);
        stranger = user("cl-stranger@astana.kz", "Erlan Other", Role.MANAGER, DataScope.TEAM, astana);
        admin = user("cl-admin@estate.crm", "Platform Admin", Role.ADMIN, DataScope.ALL, null);
        signIn(agent);
    }

    // Writing ---------------------------------------------------------------------------

    @Test
    @DisplayName("a listing's creation, each field an edit moves, its status and its deletion are written down")
    void listingLifecycle() {
        PropertyResponse flat = propertyService.create(property("Dostyk 5, apt 12", "45000000.00"));

        PropertyRequest edit = property("Dostyk 5, apt 12", "42000000");
        edit.setRooms(3);
        propertyService.update(flat.getId(), edit);
        propertyService.updateStatus(flat.getId(), PropertyStatus.RESERVED);

        List<RecordChange> lines = lines(ChangeEntityType.PROPERTY, flat.getId());
        assertThat(lines).extracting(RecordChange::getAction, RecordChange::getField,
                        RecordChange::getOldValue, RecordChange::getNewValue)
                .containsExactly(
                        tuple(ChangeAction.CREATED, null, null, null),
                        tuple(ChangeAction.PRICE_CHANGED, "price", "45000000", "42000000"),
                        tuple(ChangeAction.UPDATED, "rooms", "2", "3"),
                        tuple(ChangeAction.STATUS_CHANGED, "status", "AVAILABLE", "RESERVED"));
        assertThat(lines).allSatisfy(line -> {
            assertThat(line.getActor().getId()).isEqualTo(agent.getId());
            assertThat(line.getActorName()).isEqualTo("Aigul Bekova");
            assertThat(line.getTeam().getId()).isEqualTo(almaty.getId());
            assertThat(line.getEntityLabel()).isEqualTo("Dostyk 5, apt 12");
        });
        // One save, one moment: the app shows the price and the rooms as one entry.
        assertThat(lines.get(1).getChangedAt()).isEqualTo(lines.get(2).getChangedAt());
        // The listing's own price history is untouched by the change log, and not doubled.
        assertThat(priceChangeRepository.findHistory(flat.getId())).hasSize(1);

        propertyService.delete(flat.getId());
        assertThat(lines(ChangeEntityType.PROPERTY, flat.getId())).last()
                .extracting(RecordChange::getAction).isEqualTo(ChangeAction.DELETED);
    }

    @Test
    @DisplayName("saving a record without changing anything writes nothing")
    void noChangeNoLine() {
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));
        propertyService.update(flat.getId(), property("Abay 10", "30000000.00"));

        assertThat(lines(ChangeEntityType.PROPERTY, flat.getId())).extracting(RecordChange::getAction)
                .containsExactly(ChangeAction.CREATED);
    }

    @Test
    @DisplayName("a deal's status and amount are written down, and the listing it reserves says so too")
    void dealAndItsListing() {
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));
        ClientResponse buyer = clientService.create(client("Saule Nurlanova"));
        DealResponse deal = dealService.create(deal(buyer.getId(), flat.getId(), DealStatus.LEAD, "29000000"));

        DealRequest edit = deal(buyer.getId(), flat.getId(), DealStatus.NEGOTIATION, "28500000");
        dealService.update(deal.getId(), edit);
        dealService.updateStatus(deal.getId(), DealStatus.CLOSED_LOST, DealLostReason.PRICE, null);

        assertThat(lines(ChangeEntityType.DEAL, deal.getId()))
                .extracting(RecordChange::getAction, RecordChange::getField,
                        RecordChange::getOldValue, RecordChange::getNewValue)
                .containsExactly(
                        tuple(ChangeAction.CREATED, null, null, null),
                        tuple(ChangeAction.STATUS_CHANGED, "status", "LEAD", "NEGOTIATION"),
                        tuple(ChangeAction.PRICE_CHANGED, "dealPrice", "29000000", "28500000"),
                        tuple(ChangeAction.STATUS_CHANGED, "status", "NEGOTIATION", "CLOSED_LOST"),
                        tuple(ChangeAction.UPDATED, "lostReason", null, "PRICE"));
        assertThat(lines(ChangeEntityType.PROPERTY, flat.getId()))
                .extracting(RecordChange::getField, RecordChange::getOldValue, RecordChange::getNewValue)
                .containsExactly(
                        tuple(null, null, null),
                        tuple("status", "AVAILABLE", "RESERVED"),
                        tuple("status", "RESERVED", "AVAILABLE"));
    }

    @Test
    @DisplayName("a client's edited fields, and a cleared one, are written with what they were")
    void clientFields() {
        ClientResponse saule = clientService.create(client("Saule Nurlanova"));
        ClientRequest edit = client("Saule Nurlanova-Ermekova");
        edit.setPhone(null);
        edit.setBudgetMax(new BigDecimal("50000000"));
        clientService.update(saule.getId(), edit);

        assertThat(lines(ChangeEntityType.CLIENT, saule.getId()))
                .extracting(RecordChange::getField, RecordChange::getOldValue, RecordChange::getNewValue)
                .containsExactly(
                        tuple(null, null, null),
                        tuple("fullName", "Saule Nurlanova", "Saule Nurlanova-Ermekova"),
                        tuple("phone", "+7 701 555 12 34", null),
                        tuple("budgetMax", null, "50000000"));
    }

    @Test
    @DisplayName("records handed to a colleague each say who took them over, and who handed them")
    void handover() {
        ClientResponse saule = clientService.create(client("Saule Nurlanova"));
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));

        handoverService.reassignTeamRecords(agent, colleague, almaty, manager);

        assertThat(changeRepository.findAll()).filteredOn(c -> c.getAction() == ChangeAction.AGENT_CHANGED)
                .extracting(RecordChange::getEntityType, RecordChange::getEntityId,
                        RecordChange::getOldValue, RecordChange::getNewValue, RecordChange::getActorName)
                .containsExactlyInAnyOrder(
                        tuple(ChangeEntityType.CLIENT, saule.getId(), "Aigul Bekova", "Timur Aliev", "Marat Manager"),
                        tuple(ChangeEntityType.PROPERTY, flat.getId(), "Aigul Bekova", "Timur Aliev", "Marat Manager"));
    }

    @Test
    @DisplayName("when someone leaves, their lines stay with their name, and their records say where they went")
    void leaverKeepsTheirName() {
        ClientResponse saule = clientService.create(client("Saule Nurlanova"));

        accountRemovalService.remove(admin, agent, colleague.getId(), "DELETE_USER");
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        List<RecordChangeResponse> history = historyService.forClient(saule.getId(), 0, 30).getContent();
        assertThat(history).extracting(RecordChangeResponse::getAction, RecordChangeResponse::getActorId,
                        RecordChangeResponse::getActorName)
                .containsExactly(
                        tuple(ChangeAction.AGENT_CHANGED, admin.getId(), "Platform Admin"),
                        tuple(ChangeAction.CREATED, null, "Aigul Bekova"));
        assertThat(history.get(0).getOldValue()).isEqualTo("Aigul Bekova");
        assertThat(history.get(0).getNewValue()).isEqualTo("Timur Aliev");
    }

    @Test
    @DisplayName("merging two cards: the one that goes is deleted in its log, the one that stays shows what it gained")
    void merge() {
        ClientResponse kept = clientService.create(client("Saule Nurlanova"));
        ClientRequest other = client("Saule N.");
        other.setEmail("saule@mail.kz");
        ClientResponse gone = clientService.create(other);
        signIn(manager);

        duplicateService.merge(kept.getId(), gone.getId());

        assertThat(lines(ChangeEntityType.CLIENT, gone.getId())).last()
                .extracting(RecordChange::getAction, RecordChange::getActorName)
                .containsExactly(ChangeAction.DELETED, "Marat Manager");
        assertThat(lines(ChangeEntityType.CLIENT, kept.getId()))
                .extracting(RecordChange::getField, RecordChange::getNewValue)
                .contains(tuple("email", "saule@mail.kz"));
    }

    // Reading one record ----------------------------------------------------------------

    @Test
    @DisplayName("a record's history is newest first, a page at a time, behind the record's own wall")
    void recordHistoryIsScoped() throws Exception {
        ClientResponse saule = clientService.create(client("Saule Nurlanova"));
        for (int i = 1; i <= 3; i++) {
            clientService.update(saule.getId(), client("Saule " + i));
        }

        assertThat(historyService.forClient(saule.getId(), 0, 2).getContent())
                .extracting(RecordChangeResponse::getNewValue).containsExactly("Saule 3", "Saule 2");

        mockMvc.perform(get("/clients/{id}/changes", saule.getId()).param("size", "2")
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.content[0].field").value("fullName"))
                .andExpect(jsonPath("$.content[0].oldValue").value("Saule 2"))
                .andExpect(jsonPath("$.content[0].newValue").value("Saule 3"))
                .andExpect(jsonPath("$.content[0].actorName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.totalElements").value(4));

        // A colleague on their own clients cannot see this one, so not its history either.
        mockMvc.perform(get("/clients/{id}/changes", saule.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(colleague)))
                .andExpect(status().isNotFound());
        // Another agency is told it does not exist.
        mockMvc.perform(get("/clients/{id}/changes", saule.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/clients/{id}/changes", saule.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("a listing's history is the whole agency's, like the listing; a deal's follows the deal")
    void listingAndDealHistory() throws Exception {
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));
        ClientResponse buyer = clientService.create(client("Saule Nurlanova"));
        DealResponse deal = dealService.create(deal(buyer.getId(), null, DealStatus.LEAD, null));

        mockMvc.perform(get("/properties/{id}/changes", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(colleague)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].action").value("CREATED"));
        mockMvc.perform(get("/properties/{id}/changes", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/deals/{id}/changes", deal.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(colleague)))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/deals/{id}/changes", deal.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].entityType").value("DEAL"));
    }

    // The agency's feed -----------------------------------------------------------------

    @Test
    @DisplayName("the agency's feed is the manager's, holds only the agency's changes, and filters")
    void teamFeed() throws Exception {
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));
        propertyService.update(flat.getId(), property("Abay 10", "28000000"));
        signIn(colleague);
        clientService.create(client("Saule Nurlanova"));
        signIn(stranger);
        propertyService.create(property("Kenesary 1", "20000000"));

        Page all = feed(manager, null, null, null, null, null);
        assertThat(all.lines).extracting(RecordChangeResponse::getEntityLabel)
                .containsExactly("Saule Nurlanova", "Abay 10", "Abay 10");

        assertThat(feed(manager, ChangeEntityType.PROPERTY, null, null, null, null).lines).hasSize(2);
        assertThat(feed(manager, null, colleague.getId(), null, null, null).lines)
                .extracting(RecordChangeResponse::getEntityType).containsExactly(ChangeEntityType.CLIENT);
        assertThat(feed(manager, null, null, ChangeAction.PRICE_CHANGED, null, null).lines)
                .extracting(RecordChangeResponse::getOldValue, RecordChangeResponse::getNewValue)
                .containsExactly(tuple("30000000", "28000000"));
        LocalDate today = LocalDate.now();
        assertThat(feed(manager, null, null, null, today, today).lines).hasSize(3);
        assertThat(feed(manager, null, null, null, today.plusDays(1), null).lines).isEmpty();
        assertThat(feed(manager, null, null, null, null, today.minusDays(1)).lines).isEmpty();

        // An admin reads every agency, or names one.
        assertThat(feed(admin, null, null, null, null, null).lines).extracting(RecordChangeResponse::getEntityLabel)
                .contains("Kenesary 1", "Saule Nurlanova", "Abay 10");
        signIn(admin);
        assertThat(historyService.feed(admin, almaty.getId(), null, null, null, null, null, 0, 30)
                .getContent()).hasSize(3);

        assertThatThrownBy(() -> feed(manager, null, null, null, today, today.minusDays(1)))
                .isInstanceOf(BusinessException.class).hasMessageContaining("ends before");
        assertThatThrownBy(() -> historyService.feed(admin, 999_999L, null, null, null, null, null, 0, 30))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("over HTTP: an agent is refused the feed, a manager pages it newest first")
    void feedOverHttp() throws Exception {
        PropertyResponse flat = propertyService.create(property("Abay 10", "30000000"));
        propertyService.updateStatus(flat.getId(), PropertyStatus.SOLD);

        mockMvc.perform(get("/audit").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/audit").param("entityType", "PROPERTY").param("size", "1")
                        .param("from", LocalDate.now().toString())
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content.length()").value(1))
                .andExpect(jsonPath("$.content[0].action").value("STATUS_CHANGED"))
                .andExpect(jsonPath("$.content[0].newValue").value("SOLD"))
                .andExpect(jsonPath("$.totalElements").value(2));
        mockMvc.perform(get("/audit").header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(0));
    }

    // Helpers ---------------------------------------------------------------------------

    private record Page(List<RecordChangeResponse> lines) {}

    private Page feed(User who, ChangeEntityType type, Long actorId, ChangeAction action,
                      LocalDate from, LocalDate to) {
        signIn(who);
        return new Page(historyService.feed(who, null, type, actorId, action, from, to, 0, 30).getContent());
    }

    private List<RecordChange> lines(ChangeEntityType type, Long id) {
        return changeRepository.findByEntityTypeAndEntityIdOrderByIdAsc(type, id);
    }

    private PropertyRequest property(String title, String price) {
        PropertyRequest request = new PropertyRequest();
        request.setTitle(title);
        request.setAddress(title);
        request.setCity("Almaty");
        request.setType(PropertyType.APARTMENT);
        request.setStatus(PropertyStatus.AVAILABLE);
        request.setPrice(new BigDecimal(price));
        request.setRooms(2);
        return request;
    }

    private ClientRequest client(String name) {
        ClientRequest request = new ClientRequest();
        request.setFullName(name);
        request.setPhone("+7 701 555 12 34");
        request.setType(ClientType.BUYER);
        return request;
    }

    private DealRequest deal(Long clientId, Long propertyId, DealStatus status, String price) {
        DealRequest request = new DealRequest();
        request.setTitle("Abay 10 for Saule");
        request.setClientId(clientId);
        request.setPropertyId(propertyId);
        request.setStatus(status);
        request.setDealPrice(price == null ? null : new BigDecimal(price));
        return request;
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /** Over HTTP the token alone says who is asking, so the test's own sign-in is put away. */
    private String bearer(User who) {
        SecurityContextHolder.clearContext();
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
