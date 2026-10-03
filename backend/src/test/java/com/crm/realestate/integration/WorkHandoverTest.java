package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientActivityRequest;
import com.crm.realestate.dto.request.HandoverRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.dto.response.ClientListItem;
import com.crm.realestate.dto.response.HandoverResponse;
import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.OpenHouse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.OpenHouseRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ClientActivityService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.WorkHandoverService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A manager hands an agent's work to a colleague while both stay: the parts chosen, or a few
 * clients picked by hand, each client bringing its open deals and the work still to do on it. The
 * preview counts what the handover moves, the history says who had the client, and it never
 * reaches outside the agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class WorkHandoverTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private WorkHandoverService handoverService;
    @Autowired private ClientActivityService activityService;
    @Autowired private ClientService clientService;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private OpenHouseRepository openHouseRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private Team astana;
    private User agent;
    private User colleague;
    private User third;
    private User manager;
    private User stranger;
    private LocalDateTime now;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("ho-agent@almaty.kz", "Aigul Bekova", Role.AGENT, almaty);
        colleague = user("ho-colleague@almaty.kz", "Timur Aliev", Role.AGENT, almaty);
        third = user("ho-third@almaty.kz", "Dana Seitova", Role.AGENT, almaty);
        manager = user("ho-manager@almaty.kz", "Marat Manager", Role.MANAGER, almaty);
        stranger = user("ho-stranger@astana.kz", "Erlan Other", Role.AGENT, astana);
        now = LocalDateTime.now();
        signIn(manager);
    }

    // The whole book, a part at a time --------------------------------------------------

    @Test
    @DisplayName("a client brings its open deals and the work still to do on it; what is finished stays")
    void clientBringsItsWork() {
        Client buyer = client("Aliya Buyer", agent, almaty);
        Deal open = deal(buyer, agent, DealStatus.NEGOTIATION);
        Deal won = deal(buyer, agent, DealStatus.CLOSED_WON);
        Meeting tomorrow = meeting(buyer, agent, now.plusDays(1), false);
        Meeting lastWeek = meeting(buyer, agent, now.minusDays(7), true);
        Task call = task("Call back", agent, buyer, null, null);
        Task done = task("Sent the brochure", agent, buyer, null, now.minusDays(1));
        Task onDeal = task("Chase the bank", agent, null, open, null);
        // Somebody else's work on the same client is theirs to keep.
        Meeting thirds = meeting(buyer, third, now.plusDays(2), false);

        HandoverResponse preview = handoverService.preview(manager, null, clients(agent, colleague));
        assertThat(preview.isDone()).isFalse();
        assertThat(preview.getClients()).isEqualTo(1);
        assertThat(preview.getDeals()).isEqualTo(1);
        assertThat(preview.getMeetings()).isEqualTo(1);
        assertThat(preview.getTasks()).isEqualTo(2);
        assertThat(preview.getListings()).isZero();
        assertThat(preview.getTotal()).isEqualTo(5);
        assertThat(clientRepository.findById(buyer.getId()).orElseThrow().getAgent().getId())
                .as("a preview moves nothing").isEqualTo(agent.getId());

        HandoverResponse done1 = handoverService.handOver(manager, null, clients(agent, colleague));
        assertThat(done1.isDone()).isTrue();
        assertThat(done1).usingRecursiveComparison().ignoringFields("done").isEqualTo(preview);

        flush();
        assertThat(clientRepository.findById(buyer.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(dealRepository.findById(open.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(dealRepository.findById(won.getId()).orElseThrow().getAgent().getId()).isEqualTo(agent.getId());
        assertThat(meetingRepository.findById(tomorrow.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(meetingRepository.findById(lastWeek.getId()).orElseThrow().getAgent().getId()).isEqualTo(agent.getId());
        assertThat(meetingRepository.findById(thirds.getId()).orElseThrow().getAgent().getId()).isEqualTo(third.getId());
        assertThat(taskRepository.findById(call.getId()).orElseThrow().getAssignee().getId()).isEqualTo(colleague.getId());
        assertThat(taskRepository.findById(onDeal.getId()).orElseThrow().getAssignee().getId()).isEqualTo(colleague.getId());
        assertThat(taskRepository.findById(done.getId()).orElseThrow().getAssignee().getId()).isEqualTo(agent.getId());
        assertThat(userRepository.findById(agent.getId()).orElseThrow().getTeam().getId())
                .as("nobody leaves").isEqualTo(almaty.getId());
    }

    @Test
    @DisplayName("each part can go on its own: listings with the open houses still to come, open deals, what is coming up")
    void partsOnTheirOwn() {
        Client buyer = client("Aliya Buyer", agent, almaty);
        Property flat = listing("Dostyk 5", agent, almaty);
        OpenHouse saturday = openHouse(flat, agent, now.plusDays(3));
        OpenHouse past = openHouse(flat, agent, now.minusDays(3));
        Deal open = deal(buyer, agent, DealStatus.LEAD);
        Meeting tomorrow = meeting(buyer, agent, now.plusDays(1), false);
        Task todo = task("Call", agent, null, null, null);

        HandoverRequest listingsOnly = request(agent, colleague);
        listingsOnly.setListings(true);
        HandoverResponse moved = handoverService.handOver(manager, null, listingsOnly);
        assertThat(moved.getListings()).isEqualTo(1);
        assertThat(moved.getOpenHouses()).isEqualTo(1);
        assertThat(moved.getClients() + moved.getDeals() + moved.getMeetings() + moved.getTasks()).isZero();
        flush();
        assertThat(propertyRepository.findById(flat.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(openHouseRepository.findById(saturday.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(openHouseRepository.findById(past.getId()).orElseThrow().getAgent().getId())
                .as("who hosted one that is over does not change").isEqualTo(agent.getId());
        assertThat(clientRepository.findById(buyer.getId()).orElseThrow().getAgent().getId()).isEqualTo(agent.getId());

        HandoverRequest dealsOnly = request(agent, colleague);
        dealsOnly.setDeals(true);
        HandoverResponse deals = handoverService.handOver(manager, null, dealsOnly);
        assertThat(deals.getDeals()).isEqualTo(1);
        assertThat(deals.getClients()).isZero();
        assertThat(deals.getMeetings()).as("the meeting is not on the deal").isZero();

        HandoverRequest upcoming = request(agent, third);
        upcoming.setUpcoming(true);
        HandoverResponse work = handoverService.handOver(manager, null, upcoming);
        assertThat(work.getMeetings()).isEqualTo(1);
        assertThat(work.getTasks()).isEqualTo(1);
        flush();
        assertThat(meetingRepository.findById(tomorrow.getId()).orElseThrow().getAgent().getId()).isEqualTo(third.getId());
        assertThat(taskRepository.findById(todo.getId()).orElseThrow().getAssignee().getId()).isEqualTo(third.getId());
        assertThat(dealRepository.findById(open.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
    }

    @Test
    @DisplayName("nothing to move answers zeros and changes nothing")
    void nothingToMove() {
        HandoverResponse done = handoverService.handOver(manager, null, clients(agent, colleague));
        assertThat(done.getTotal()).isZero();
        flush();
        assertThat(notificationRepository.findByRecipientId(colleague.getId())).isEmpty();
        assertThat(auditLogRepository.findAll()).extracting(AuditLog::getAction).doesNotContain("HAND_OVER_WORK");
    }

    // Clients picked by hand ------------------------------------------------------------

    @Test
    @DisplayName("only the clients picked move, with their own work")
    void handPicked() {
        Client one = client("Aliya Buyer", agent, almaty);
        Client two = client("Bolat Seller", agent, almaty);
        Meeting onOne = meeting(one, agent, now.plusDays(1), false);
        Meeting onTwo = meeting(two, agent, now.plusDays(1), false);

        HandoverRequest request = request(agent, colleague);
        request.setClientIds(List.of(one.getId(), one.getId()));
        HandoverResponse done = handoverService.handOver(manager, null, request);

        assertThat(done.getClients()).isEqualTo(1);
        assertThat(done.getMeetings()).isEqualTo(1);
        flush();
        assertThat(clientRepository.findById(two.getId()).orElseThrow().getAgent().getId()).isEqualTo(agent.getId());
        assertThat(meetingRepository.findById(onOne.getId()).orElseThrow().getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(meetingRepository.findById(onTwo.getId()).orElseThrow().getAgent().getId()).isEqualTo(agent.getId());
    }

    @Test
    @DisplayName("from the client list, clients of several agents go at once, and the colleague hears from each")
    void fromSeveralAgents() {
        Client aigul = client("Aliya Buyer", agent, almaty);
        Client dana = client("Bolat Seller", third, almaty);
        Client already = client("Already Theirs", colleague, almaty);

        HandoverRequest request = new HandoverRequest();
        request.setToAgentId(colleague.getId());
        request.setClientIds(List.of(aigul.getId(), dana.getId(), already.getId()));
        HandoverResponse done = handoverService.handOver(manager, null, request);

        assertThat(done.getClients()).as("the colleague's own client has nowhere to go").isEqualTo(2);
        assertThat(done.getFromAgentId()).isNull();
        assertThat(done.getFromAgentName()).isNull();
        flush();
        List<Notification> heard = notificationRepository.findByRecipientId(colleague.getId());
        assertThat(heard).hasSize(2).allSatisfy(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.RECORDS_HANDED_OVER);
            assertThat(params(n)).containsEntry("clients", 1);
        });
        assertThat(heard).extracting(n -> params(n).get("fromName"))
                .containsExactlyInAnyOrder("Aigul Bekova", "Dana Seitova");

        HandoverRequest severalWithParts = new HandoverRequest();
        severalWithParts.setToAgentId(colleague.getId());
        severalWithParts.setClientIds(List.of(aigul.getId()));
        severalWithParts.setListings(true);
        assertCode(() -> handoverService.preview(manager, null, severalWithParts), "FROM_AGENT_REQUIRED");
    }

    @Test
    @DisplayName("a client picked has to be the named agent's and the agency's")
    void pickedClientsAreChecked() {
        Client thirds = client("Bolat Seller", third, almaty);
        Client foreign = client("Astana Buyer", stranger, astana);

        HandoverRequest notTheirs = request(agent, colleague);
        notTheirs.setClientIds(List.of(thirds.getId()));
        assertCode(() -> handoverService.preview(manager, null, notTheirs), "CLIENT_NOT_FROM_AGENT");

        HandoverRequest elsewhere = new HandoverRequest();
        elsewhere.setToAgentId(colleague.getId());
        elsewhere.setClientIds(List.of(foreign.getId()));
        assertThatThrownBy(() -> handoverService.preview(manager, null, elsewhere))
                .isInstanceOf(ResourceNotFoundException.class);

        HandoverRequest none = request(agent, colleague);
        none.setClientIds(List.of());
        assertCode(() -> handoverService.preview(manager, null, none), "NOTHING_SELECTED");
    }

    // The history and the feed ----------------------------------------------------------

    @Test
    @DisplayName("each client moved says in its history who had it and who has it now, and that is not contact")
    void historyLine() throws Exception {
        Client buyer = client("Aliya Buyer", agent, almaty);
        handoverService.handOver(manager, null, clients(agent, colleague));
        flush();

        List<ClientActivityResponse> history = activityService.list(buyer.getId());
        assertThat(history).singleElement().satisfies(line -> {
            assertThat(line.getType()).isEqualTo(ActivityType.NOTE);
            assertThat(line.getNote()).isNull();
            assertThat(line.getHandoverFromName()).isEqualTo("Aigul Bekova");
            assertThat(line.getHandoverToName()).isEqualTo("Timur Aliev");
            assertThat(line.getAuthorName()).isEqualTo("Marat Manager");
        });

        List<ClientListItem> list = clientService.getClientsWithDetails();
        assertThat(list).filteredOn(c -> c.getId().equals(buyer.getId())).singleElement()
                .satisfies(c -> assertThat(c.getLastContactAt()).as("a handover is not a call").isNull());

        ClientActivityRequest reword = new ClientActivityRequest();
        reword.setType(ActivityType.NOTE);
        reword.setNote("Something else");
        Long lineId = history.get(0).getId();
        assertCode(() -> activityService.update(buyer.getId(), lineId, reword), "HANDOVER_ENTRY_READ_ONLY");
        activityService.delete(buyer.getId(), lineId);
        assertThat(activityService.list(buyer.getId())).isEmpty();
    }

    @Test
    @DisplayName("the colleague hears once with the counts, and the journal says who did it")
    void notifiedAndAudited() {
        Client buyer = client("Aliya Buyer", agent, almaty);
        deal(buyer, agent, DealStatus.LEAD);
        listing("Dostyk 5", agent, almaty);
        HandoverRequest all = clients(agent, colleague);
        all.setListings(true);
        all.setDeals(true);
        all.setUpcoming(true);
        handoverService.handOver(manager, null, all);
        flush();

        assertThat(notificationRepository.findByRecipientId(colleague.getId())).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.RECORDS_HANDED_OVER);
            assertThat(params(n)).containsEntry("fromName", "Aigul Bekova")
                    .containsEntry("clients", 1).containsEntry("properties", 1).containsEntry("deals", 1);
        });
        assertThat(notificationRepository.findByRecipientId(agent.getId())).isEmpty();
        assertThat(auditLogRepository.findAll()).filteredOn(a -> "HAND_OVER_WORK".equals(a.getAction()))
                .singleElement().satisfies(a -> {
                    assertThat(a.getEntityId()).isEqualTo(agent.getId());
                    assertThat(a.getMetadata()).contains("to=ho-colleague@almaty.kz", "clients=1", "listings=1");
                });
    }

    // Who may, and within what ----------------------------------------------------------

    @Test
    @DisplayName("an agent may not; a manager may only within their agency; both people active members")
    void whoMay() throws Exception {
        String body = objectMapper.writeValueAsString(clients(agent, colleague));
        mockMvc.perform(post("/handovers/preview").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isForbidden());

        client("Aliya Buyer", agent, almaty);
        mockMvc.perform(post("/handovers/preview").header(HttpHeaders.AUTHORIZATION, bearer(manager))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.clients").value(1))
                .andExpect(jsonPath("$.fromAgentName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.toAgentName").value("Timur Aliev"))
                .andExpect(jsonPath("$.done").value(false));

        signIn(manager);
        assertThatThrownBy(() -> handoverService.preview(manager, null, clients(agent, stranger)))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> handoverService.preview(manager, null, clients(stranger, colleague)))
                .isInstanceOf(ResourceNotFoundException.class);

        User away = user("ho-away@almaty.kz", "Away Agent", Role.AGENT, almaty);
        away.setActive(false);
        userRepository.save(away);
        assertThatThrownBy(() -> handoverService.preview(manager, null, clients(agent, away)))
                .isInstanceOf(ResourceNotFoundException.class);

        assertCode(() -> handoverService.preview(manager, null, clients(agent, agent)), "SAME_AGENT");
        assertCode(() -> handoverService.preview(manager, null, request(agent, colleague)), "NOTHING_SELECTED");

        mockMvc.perform(post("/handovers").header(HttpHeaders.AUTHORIZATION, bearer(manager))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"fromAgentId\":" + agent.getId() + "}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("an admin names the agency")
    void adminNamesTheAgency() {
        User admin = user("ho-admin@estatecrm.app", "Admin", Role.ADMIN, null);
        client("Aliya Buyer", agent, almaty);
        assertCode(() -> handoverService.preview(admin, null, clients(agent, colleague)), "TEAM_REQUIRED");
        assertThat(handoverService.preview(admin, almaty.getId(), clients(agent, colleague)).getClients()).isEqualTo(1);
        assertThatThrownBy(() -> handoverService.preview(admin, astana.getId(), clients(agent, colleague)))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // Helpers ---------------------------------------------------------------------------

    private static HandoverRequest request(User from, User to) {
        HandoverRequest request = new HandoverRequest();
        request.setFromAgentId(from.getId());
        request.setToAgentId(to.getId());
        return request;
    }

    private static HandoverRequest clients(User from, User to) {
        HandoverRequest request = request(from, to);
        request.setClients(true);
        return request;
    }

    private static void assertCode(org.assertj.core.api.ThrowableAssert.ThrowingCallable call, String code) {
        assertThatThrownBy(call).isInstanceOf(BusinessException.class)
                .satisfies(e -> assertThat(((BusinessException) e).getCode()).isEqualTo(code));
    }

    private void flush() {
        entityManager.flush();
        entityManager.clear();
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> params(Notification n) {
        try {
            return objectMapper.readValue(n.getPayload(), Map.class);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private Client client(String name, User holder, Team team) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER).agent(holder).team(team).build());
    }

    private Deal deal(Client client, User holder, DealStatus status) {
        return dealRepository.save(Deal.builder()
                .title("Deal for " + client.getFullName()).status(status)
                .client(client).agent(holder).team(client.getTeam()).build());
    }

    private Meeting meeting(Client client, User holder, LocalDateTime at, boolean completed) {
        return meetingRepository.save(Meeting.builder()
                .title("Viewing").scheduledAt(at).completed(completed)
                .client(client).agent(holder).team(client.getTeam()).build());
    }

    private Task task(String title, User holder, Client client, Deal deal, LocalDateTime completedAt) {
        return taskRepository.save(Task.builder()
                .title(title).dueAt(now.plusDays(1))
                .assignee(holder).createdBy(holder).team(holder.getTeam())
                .client(client).deal(deal).completedAt(completedAt).build());
    }

    private Property listing(String title, User holder, Team team) {
        return propertyRepository.save(Property.builder()
                .title(title).address(title).city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new java.math.BigDecimal("28000000"))
                .agent(holder).team(team).build());
    }

    private OpenHouse openHouse(Property flat, User host, LocalDateTime start) {
        return openHouseRepository.save(OpenHouse.builder()
                .property(flat).team(flat.getTeam()).agent(host)
                .startsAt(start).endsAt(start.plusHours(2)).build());
    }

    private User user(String email, String name, Role role, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(role == Role.AGENT ? DataScope.OWN : DataScope.TEAM).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /** The token alone decides who is asking: the filter keeps an authentication already there. */
    private String bearer(User who) {
        SecurityContextHolder.clearContext();
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    /** With the person's role, since the endpoints are for managers and the filter keeps this one. */
    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, who.getAuthorities()));
    }
}
