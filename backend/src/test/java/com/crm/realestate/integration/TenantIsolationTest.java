package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.request.MeetingRequest;
import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AdminService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.DashboardService;
import com.crm.realestate.service.DealService;
import com.crm.realestate.service.MeetingService;
import com.crm.realestate.service.PropertyService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * A team is an agency, and nothing crosses between agencies.
 *
 * <p>Anyone can open an agency, so the people on the other side of this wall are strangers. Every
 * test here signs in on one side and checks that the other side's clients, listings, deals and
 * meetings are neither listed, nor readable by id, nor changeable, nor linkable.
 */
@SpringBootTest
@Transactional
class TenantIsolationTest {

    @Autowired private ClientService clientService;
    @Autowired private PropertyService propertyService;
    @Autowired private DealService dealService;
    @Autowired private MeetingService meetingService;
    @Autowired private DashboardService dashboardService;
    @Autowired private AdminService adminService;

    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private Team astana;

    private User almatyManager;
    private User almatyAgent;
    private User almatyColleague;
    private User astanaManager;
    private User admin;

    private Client almatyClient;
    private Client colleagueClient;
    private Client astanaClient;
    private Property almatyListing;
    private Property astanaListing;
    private Deal almatyDeal;
    private Deal astanaDeal;
    private Meeting astanaMeeting;

    @BeforeEach
    void setUp() {
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        almatyManager = user("manager@almaty.kz", Role.MANAGER, DataScope.TEAM, almaty);
        almatyAgent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        almatyColleague = user("colleague@almaty.kz", Role.AGENT, DataScope.OWN, almaty);
        astanaManager = user("manager@astana.kz", Role.MANAGER, DataScope.TEAM, astana);
        admin = user("admin@estatecrm.app", Role.ADMIN, DataScope.ALL, null);

        almatyClient = client("Aigerim", "aigerim@mail.kz", almatyAgent);
        colleagueClient = client("Daniyar", "daniyar@mail.kz", almatyColleague);
        astanaClient = client("Madina", "madina@mail.kz", astanaManager);

        almatyListing = listing("Dostyk 210", almatyAgent, almaty);
        astanaListing = listing("Mangilik El 55", null, astana);

        almatyDeal = deal(almatyClient, almatyListing, almatyAgent);
        astanaDeal = deal(astanaClient, astanaListing, astanaManager);

        meeting(almatyClient, almatyAgent, LocalDateTime.now().plusDays(1));
        astanaMeeting = meeting(astanaClient, astanaManager, LocalDateTime.now().plusDays(2));

        entityManager.flush();
        entityManager.clear();
    }

    // Lists ---------------------------------------------------------------------------

    @Test
    @DisplayName("a manager lists their own agency's records and none of the other's")
    void managerListsOnlyTheirTeam() {
        signIn(almatyManager);

        assertThat(clientService.getAll()).extracting(ClientResponse::getFullName)
                .containsExactlyInAnyOrder("Aigerim", "Daniyar");
        assertThat(propertyService.getAll()).extracting(PropertyResponse::getTitle)
                .containsExactly("Dostyk 210");
        assertThat(dealService.getAll()).extracting(d -> d.getId())
                .containsExactly(almatyDeal.getId());
        assertThat(meetingService.getAll()).hasSize(1);
        assertThat(meetingService.getAllUpcoming()).hasSize(1);
        assertThat(clientService.getClientsWithDetails()).extracting(c -> c.getFullName())
                .containsOnly("Aigerim", "Daniyar");
    }

    @Test
    @DisplayName("filters and searches stay inside the agency too")
    void filteredReadsStayInside() {
        signIn(almatyManager);

        assertThat(clientService.search("Madina")).isEmpty();
        assertThat(clientService.getByType(ClientType.BUYER)).extracting(ClientResponse::getFullName)
                .doesNotContain("Madina");
        assertThat(clientService.getByAgent(astanaManager.getId())).isEmpty();
        assertThat(propertyService.search("Mangilik")).isEmpty();
        assertThat(propertyService.filter(PropertyStatus.AVAILABLE, null, null, null, null))
                .extracting(PropertyResponse::getTitle)
                .containsExactly("Dostyk 210");
        assertThat(dealService.getByStatus(DealStatus.LEAD)).extracting(d -> d.getId())
                .containsExactly(almatyDeal.getId());
        assertThat(meetingService.getByAgent(astanaManager.getId())).isEmpty();
    }

    @Test
    @DisplayName("an agent on their own data sees their clients, but all of the agency's listings")
    void ownScopeNarrowsClientsButNotListings() {
        signIn(almatyAgent);

        assertThat(clientService.getAll()).extracting(ClientResponse::getFullName)
                .containsExactly("Aigerim");
        assertThat(propertyService.getAll()).extracting(PropertyResponse::getTitle)
                .containsExactly("Dostyk 210");
        assertThatThrownBy(() -> clientService.getById(colleagueClient.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // Single records -------------------------------------------------------------------

    @Test
    @DisplayName("another agency's records cannot be read, changed or deleted by id")
    void otherAgencyByIdIsMissing() {
        signIn(almatyManager);

        assertThatThrownBy(() -> clientService.getById(astanaClient.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> clientService.update(astanaClient.getId(), clientRequest("Renamed", null)))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> clientService.delete(astanaClient.getId()))
                .isInstanceOf(ResourceNotFoundException.class);

        assertThatThrownBy(() -> propertyService.getById(astanaListing.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> propertyService.updateStatus(astanaListing.getId(), PropertyStatus.SOLD))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> propertyService.delete(astanaListing.getId()))
                .isInstanceOf(ResourceNotFoundException.class);

        assertThatThrownBy(() -> dealService.getById(astanaDeal.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> dealService.updateStatus(astanaDeal.getId(), DealStatus.CLOSED_WON, null, null))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> dealService.delete(astanaDeal.getId()))
                .isInstanceOf(ResourceNotFoundException.class);

        assertThatThrownBy(() -> meetingService.getById(astanaMeeting.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> meetingService.markCompleted(astanaMeeting.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("records from another agency cannot be linked into a deal or a meeting")
    void crossAgencyLinksAreRefused() {
        signIn(almatyManager);

        assertThatThrownBy(() -> dealService.create(dealRequest(astanaClient.getId(), null)))
                .as("a deal on another agency's client")
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> dealService.create(dealRequest(almatyClient.getId(), astanaListing.getId())))
                .as("another agency's listing on our deal")
                .isInstanceOf(ResourceNotFoundException.class);

        MeetingRequest meeting = new MeetingRequest();
        meeting.setTitle("Viewing");
        meeting.setScheduledAt(LocalDateTime.now().plusDays(3));
        meeting.setAgentId(almatyManager.getId());
        meeting.setClientId(almatyClient.getId());
        meeting.setDealId(astanaDeal.getId());
        assertThatThrownBy(() -> meetingService.create(meeting))
                .as("another agency's deal on our meeting")
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // Writes -----------------------------------------------------------------------------

    @Test
    @DisplayName("what someone creates lands in their agency, held by them")
    void createdRecordsJoinTheCreatorsTeam() {
        signIn(almatyAgent);

        ClientResponse client = clientService.create(clientRequest("Ruslan", "ruslan@mail.kz"));
        PropertyRequest listing = new PropertyRequest();
        listing.setTitle("Al-Farabi 77");
        listing.setAddress("Al-Farabi Ave 77");
        listing.setType(PropertyType.APARTMENT);
        listing.setPrice(new BigDecimal("215000"));
        PropertyResponse created = propertyService.create(listing);
        Long dealId = dealService.create(dealRequest(client.getId(), created.getId())).getId();
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(client.getId()).orElseThrow().getTeam().getId())
                .isEqualTo(almaty.getId());
        Property stored = propertyRepository.findById(created.getId()).orElseThrow();
        assertThat(stored.getTeam().getId()).isEqualTo(almaty.getId());
        assertThat(stored.getAgent().getId())
                .as("a listing used to be saved with no agent, belonging to nobody")
                .isEqualTo(almatyAgent.getId());
        assertThat(dealRepository.findById(dealId).orElseThrow().getTeam().getId()).isEqualTo(almaty.getId());

        signIn(astanaManager);
        assertThat(clientService.getAll()).extracting(ClientResponse::getFullName).doesNotContain("Ruslan");
    }

    @Test
    @DisplayName("two agencies may each have a client with the same address")
    void clientEmailIsUniquePerAgency() {
        signIn(almatyManager);

        clientService.create(clientRequest("Also Madina", "madina@mail.kz"));

        assertThatThrownBy(() -> clientService.create(clientRequest("Aigerim again", "aigerim@mail.kz")))
                .as("inside one agency the address is still unique")
                .hasMessageContaining("already exists");
    }

    @Test
    @DisplayName("a manager editing an agent's client does not take it over")
    void editingDoesNotChangeHands() {
        signIn(almatyManager);

        clientService.update(almatyClient.getId(), clientRequest("Aigerim N.", "aigerim@mail.kz"));
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(almatyClient.getId()).orElseThrow().getAgent().getId())
                .isEqualTo(almatyAgent.getId());
    }

    // Dashboard ----------------------------------------------------------------------

    @Test
    @DisplayName("the dashboard counts one agency, even when asked about another")
    void dashboardCountsOnlyTheTeam() {
        signIn(almatyManager);

        DashboardSummary mine = dashboardService.getSummary(null, null);
        assertThat(mine.getTotalClients()).isEqualTo(2);
        assertThat(mine.getTotalDeals()).isEqualTo(1);
        assertThat(mine.getUpcomingMeetings()).isEqualTo(1);

        DashboardSummary theirs = dashboardService.getSummary(null, astana.getId());
        assertThat(theirs.getTotalClients()).isZero();
        assertThat(theirs.getTotalDeals()).isZero();

        signIn(admin);
        assertThat(dashboardService.getSummary(null, null).getTotalClients()).isEqualTo(3);
        assertThat(dashboardService.getSummary(null, astana.getId()).getTotalClients()).isEqualTo(1);
    }

    // No team ----------------------------------------------------------------------------

    @Test
    @DisplayName("someone in no team sees only their own team-less records, and brings them along when placed")
    void teamlessRecordsFollowTheirOwner() {
        User newcomer = user("newcomer@mail.kz", Role.AGENT, DataScope.OWN, null);
        Client legacy = client("Timur", "timur@mail.kz", newcomer);
        entityManager.flush();
        entityManager.clear();

        signIn(newcomer);
        assertThat(clientService.getAll()).extracting(ClientResponse::getFullName).containsExactly("Timur");
        assertThat(propertyService.getAll()).isEmpty();

        signIn(admin);
        adminService.assignTeam(newcomer.getId(), almaty.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(legacy.getId()).orElseThrow().getTeam().getId())
                .isEqualTo(almaty.getId());
        signIn(almatyManager);
        assertThat(clientService.getAll()).extracting(ClientResponse::getFullName).contains("Timur");
    }

    @Test
    @DisplayName("an admin sees every agency")
    void adminSeesEverything() {
        signIn(admin);

        assertThat(clientService.getAll()).hasSize(3);
        assertThat(propertyService.getAll()).hasSize(2);
        assertThat(dealService.getAll()).hasSize(2);
        assertThat(clientService.getById(astanaClient.getId()).getFullName()).isEqualTo("Madina");
    }

    // Fixtures -------------------------------------------------------------------------

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private User user(String email, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private Client client(String name, String email, User agent) {
        return clientRepository.save(Client.builder()
                .fullName(name).email(email).type(ClientType.BUYER)
                .agent(agent).team(agent.getTeam())
                .build());
    }

    private Property listing(String title, User agent, Team team) {
        return propertyRepository.save(Property.builder()
                .title(title).address(title).type(PropertyType.APARTMENT)
                .status(PropertyStatus.AVAILABLE).price(new BigDecimal("100000"))
                .agent(agent).team(team)
                .build());
    }

    private Deal deal(Client client, Property property, User agent) {
        return dealRepository.save(Deal.builder()
                .title("Deal for " + client.getFullName()).status(DealStatus.LEAD)
                .client(client).property(property).agent(agent).team(client.getTeam())
                .build());
    }

    private Meeting meeting(Client client, User agent, LocalDateTime at) {
        return meetingRepository.save(Meeting.builder()
                .title("Viewing").scheduledAt(at)
                .client(client).agent(agent).team(client.getTeam())
                .build());
    }

    private ClientRequest clientRequest(String name, String email) {
        ClientRequest request = new ClientRequest();
        request.setFullName(name);
        request.setEmail(email);
        request.setType(ClientType.BUYER);
        return request;
    }

    private DealRequest dealRequest(Long clientId, Long propertyId) {
        DealRequest request = new DealRequest();
        request.setTitle("New deal");
        request.setClientId(clientId);
        request.setPropertyId(propertyId);
        request.setAgentId(almatyManager.getId());
        return request;
    }
}
