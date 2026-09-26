package com.crm.realestate.integration;

import com.crm.realestate.dto.request.AddMemberRequest;
import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamJoinRequestRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.DealService;
import com.crm.realestate.service.EmailService;
import com.crm.realestate.service.PropertyService;
import com.crm.realestate.service.RecordHandoverService;
import com.crm.realestate.service.TaskService;
import com.crm.realestate.service.TeamMembershipService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Who hears about what.
 *
 * <p>Every event reaches the person it concerns and nobody else: never the one who did it, never
 * anybody in another agency, and a new listing only the agents whose buyers it fits.
 */
@SpringBootTest
@Transactional
class NotificationEventsTest {

    @Autowired private TaskService taskService;
    @Autowired private DealService dealService;
    @Autowired private PropertyService propertyService;
    @Autowired private TeamMembershipService membership;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private RecordHandoverService recordHandoverService;

    @Autowired private NotificationRepository notificationRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private TeamJoinRequestRepository requestRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private ObjectMapper objectMapper;

    @MockBean private EmailService emailService;

    private Team almaty;
    private Team astana;
    private User manager;
    private User agent;
    private User colleague;
    private User stranger;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        notificationRepository.deleteAll();
        taskRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        requestRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estatecrm.app");

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        almaty.setManager(manager);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("agent@astana.kz", "Yerlan Sadykov", Role.AGENT, DataScope.TEAM, astana);
    }

    // Tasks ----------------------------------------------------------------------------

    @Test
    @DisplayName("a task a manager gives an agent reaches the agent, and not the manager")
    void taskGivenToSomebodyElse() {
        signIn(manager);
        Long taskId = taskService.create(task("Call Irina back", agent.getId())).getId();

        List<Notification> feed = feed(agent);
        assertThat(feed).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.TASK_ASSIGNED);
            assertThat(n.getTargetId()).isEqualTo(taskId);
            assertThat(params(n)).containsEntry("taskTitle", "Call Irina back")
                    .containsEntry("actorName", "Asel Nurlanovna");
        });
        assertThat(feed(manager)).as("nobody is told what they did themselves").isEmpty();
    }

    @Test
    @DisplayName("writing a task for yourself tells nobody")
    void ownTask() {
        signIn(agent);
        taskService.create(task("Send the contract", null));

        assertThat(notificationRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("handing a task on tells the new assignee; editing it in place tells nobody")
    void taskHandedOn() {
        signIn(manager);
        Long taskId = taskService.create(task("Call Irina back", agent.getId())).getId();
        taskService.update(taskId, task("Call Irina back today", agent.getId()));
        assertThat(feed(agent)).hasSize(1);

        taskService.update(taskId, task("Call Irina back today", colleague.getId()));

        assertThat(feed(colleague)).singleElement()
                .extracting(Notification::getType).isEqualTo(NotificationType.TASK_ASSIGNED);
        assertThat(feed(agent)).hasSize(1);
    }

    // Handovers ------------------------------------------------------------------------

    @Test
    @DisplayName("a closed account's work reaches its successor as one line with the counts")
    void handoverOnAccountRemoval() {
        buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        buyer("Daniyar", agent, almaty, "Almaty", "40000000");
        signIn(agent);
        taskService.create(task("Call Irina back", null));

        accountRemovalService.remove(manager, agent, colleague.getId(), "DELETE_USER");

        assertThat(feed(colleague)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.RECORDS_HANDED_OVER);
            assertThat(params(n)).containsEntry("fromName", "Aigul Bekova")
                    .containsEntry("clients", 2).containsEntry("tasks", 1).containsEntry("deals", 0);
        });
        assertThat(feed(manager)).isEmpty();
    }

    @Test
    @DisplayName("taking over records yourself tells nobody; being handed them by a manager does")
    void handoverWithinTeam() {
        buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        recordHandoverService.reassignTeamRecords(agent, colleague, almaty, colleague);
        assertThat(notificationRepository.findAll()).isEmpty();

        recordHandoverService.reassignTeamRecords(colleague, agent, almaty, manager);
        assertThat(feed(agent)).singleElement()
                .satisfies(n -> assertThat(params(n)).containsEntry("clients", 1));
    }

    // Joining an agency ---------------------------------------------------------------

    @Test
    @DisplayName("a request to join reaches the agent outside any team; their yes reaches the manager")
    void joinRequestAndAcceptance() {
        User newcomer = user("newcomer@mail.kz", "Madina Omarova", Role.AGENT, DataScope.OWN, null);
        AddMemberRequest add = new AddMemberRequest();
        add.setEmail(newcomer.getEmail());
        add.setFullName("Madina Omarova");

        Long requestId = membership.addMember(manager, add).getRequest().getId();

        assertThat(feed(newcomer)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.JOIN_REQUEST);
            assertThat(n.getTargetId()).isEqualTo(requestId);
            assertThat(n.getTeam()).as("the agent is in no team yet").isNull();
            assertThat(params(n)).containsEntry("teamName", "Almaty Realty")
                    .containsEntry("actorName", "Asel Nurlanovna");
        });
        assertThat(feed(manager)).isEmpty();

        membership.acceptRequest(newcomer, requestId);

        assertThat(feed(manager)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.JOIN_ACCEPTED);
            assertThat(n.getTargetId()).isEqualTo(newcomer.getId());
            assertThat(params(n)).containsEntry("agentName", "Madina Omarova");
        });
        assertThat(feed(newcomer)).hasSize(1);
    }

    // Matches -----------------------------------------------------------------------------

    @Test
    @DisplayName("a new listing reaches only the agents whose buyers it fits, in its own agency")
    void newListingMatchesBuyers() {
        Client aigerim = buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        buyer("Daniyar", colleague, almaty, "Almaty", "40000000");
        buyer("Bolat", colleague, almaty, "Almaty", "35000000");
        buyer("Too poor", colleague, almaty, "Almaty", "1000000");
        buyer("Wrong city", manager, almaty, "Astana", "40000000");
        buyer("Madina", stranger, astana, "Almaty", "40000000");
        signIn(manager);

        Long listingId = propertyService.create(listing("Dostyk 5", "30000000")).getId();

        assertThat(feed(agent)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.NEW_MATCH);
            assertThat(n.getTargetId()).isEqualTo(listingId);
            assertThat(params(n)).containsEntry("propertyTitle", "Dostyk 5")
                    .containsEntry("buyerCount", 1)
                    .containsEntry("buyerNames", List.of("Aigerim"))
                    .containsEntry("clientId", aigerim.getId().intValue());
        });
        assertThat(feed(colleague)).as("one line per agent, however many buyers").singleElement()
                .satisfies(n -> assertThat(params(n)).containsEntry("buyerCount", 2)
                        .containsEntry("buyerNames", List.of("Bolat", "Daniyar"))
                        .doesNotContainKey("clientId"));
        assertThat(feed(manager)).as("the manager added it, and their buyer does not fit").isEmpty();
        assertThat(feed(stranger)).as("another agency's buyers are never looked at").isEmpty();
    }

    @Test
    @DisplayName("an agent who lists a flat for their own buyer is not told about it")
    void ownListingForOwnBuyer() {
        buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        signIn(agent);

        propertyService.create(listing("Dostyk 5", "30000000"));

        assertThat(notificationRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("a buyer who turned the flat down is left out, and coming back on the market says nothing twice")
    void rejectedBuyersAndRelisting() {
        Client aigerim = buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        signIn(manager);
        Long listingId = propertyService.create(listing("Dostyk 5", "30000000")).getId();
        assertThat(feed(agent)).hasSize(1);

        propertyService.updateStatus(listingId, PropertyStatus.RESERVED);
        propertyService.updateStatus(listingId, PropertyStatus.AVAILABLE);
        assertThat(feed(agent)).as("already told about this listing").hasSize(1);

        buyer("Daniyar", colleague, almaty, "Almaty", "40000000");
        meetingRepository.save(Meeting.builder().title("Viewing")
                .scheduledAt(LocalDateTime.now().minusDays(1)).agent(agent).client(aigerim)
                .property(propertyRepository.findById(listingId).orElseThrow())
                .team(almaty).outcome(ViewingOutcome.REJECTED).completed(true).build());
        propertyService.update(listingId, listing("Dostyk 5", "28000000"));

        assertThat(feed(agent)).as("Aigerim said no to it").hasSize(1);
        assertThat(feed(colleague)).singleElement()
                .extracting(Notification::getType).isEqualTo(NotificationType.PRICE_DROP_MATCH);
    }

    @Test
    @DisplayName("a price cut that brings a listing within reach tells the buyers' agents, a rise does not")
    void priceDrop() {
        buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        signIn(manager);
        Long listingId = propertyService.create(listing("Dostyk 5", "50000000")).getId();
        assertThat(feed(agent)).as("out of Aigerim's reach").isEmpty();

        propertyService.update(listingId, listing("Dostyk 5", "42000000"));

        assertThat(feed(agent)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.PRICE_DROP_MATCH);
            assertThat(params(n)).containsEntry("oldPrice", "50000000")
                    .containsEntry("newPrice", "42000000")
                    .containsEntry("buyerNames", List.of("Aigerim"));
        });

        propertyService.update(listingId, listing("Dostyk 5", "43000000"));
        assertThat(feed(agent)).hasSize(1);
    }

    // Deals -------------------------------------------------------------------------------

    @Test
    @DisplayName("a manager moving an agent's deal tells the agent; the agent moving it tells nobody")
    void dealStatusChanged() {
        Client aigerim = buyer("Aigerim", agent, almaty, "Almaty", "40000000");
        Deal deal = dealRepository.save(Deal.builder().title("Dostyk flat").status(DealStatus.LEAD)
                .client(aigerim).agent(agent).team(almaty).build());

        signIn(agent);
        dealService.updateStatus(deal.getId(), DealStatus.NEGOTIATION, null, null);
        assertThat(notificationRepository.findAll()).isEmpty();

        signIn(manager);
        dealService.updateStatus(deal.getId(), DealStatus.CLOSED_WON, null, null);

        assertThat(feed(agent)).singleElement().satisfies(n -> {
            assertThat(n.getType()).isEqualTo(NotificationType.DEAL_STATUS_CHANGED);
            assertThat(n.getTargetId()).isEqualTo(deal.getId());
            assertThat(params(n)).containsEntry("dealTitle", "Dostyk flat")
                    .containsEntry("fromStatus", "NEGOTIATION")
                    .containsEntry("toStatus", "CLOSED_WON")
                    .containsEntry("actorName", "Asel Nurlanovna");
        });
    }

    // Helpers --------------------------------------------------------------------------

    private PropertyRequest listing(String title, String price) {
        PropertyRequest request = new PropertyRequest();
        request.setTitle(title);
        request.setAddress(title);
        request.setCity("Almaty");
        request.setType(PropertyType.APARTMENT);
        request.setStatus(PropertyStatus.AVAILABLE);
        request.setPrice(new BigDecimal(price));
        return request;
    }

    private List<Notification> feed(User who) {
        entityManager.flush();
        return notificationRepository.findByRecipientId(who.getId());
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> params(Notification n) {
        try {
            return objectMapper.readValue(n.getPayload(), Map.class);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private TaskRequest task(String title, Long assigneeId) {
        TaskRequest request = new TaskRequest();
        request.setTitle(title);
        request.setDueAt(LocalDateTime.now().plusDays(1));
        request.setAssigneeId(assigneeId);
        return request;
    }

    private Client buyer(String name, User holder, Team team, String city, String budgetMax) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .wantedCity(city).budgetMax(new BigDecimal(budgetMax))
                .agent(holder).team(team).build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
