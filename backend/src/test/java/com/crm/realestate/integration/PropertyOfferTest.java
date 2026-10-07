package com.crm.realestate.integration;

import com.crm.realestate.dto.request.OfferCounterRequest;
import com.crm.realestate.dto.request.OfferDecisionRequest;
import com.crm.realestate.dto.request.PropertyOfferRequest;
import com.crm.realestate.dto.response.PropertyOfferResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyOffer;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.OfferAction;
import com.crm.realestate.enums.OfferParty;
import com.crm.realestate.enums.OfferStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyOfferEventRepository;
import com.crm.realestate.repository.PropertyOfferRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ClientDuplicateService;
import com.crm.realestate.service.PropertyOfferService;
import com.crm.realestate.service.RecordHandoverService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.groups.Tuple.tuple;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Offers on a listing: recorded for a buyer, countered back and forth with every figure kept,
 * accepted one at a time per listing while the rest wait as backups, and everything inside the
 * agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PropertyOfferTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PropertyOfferService offerService;
    @Autowired private ClientDuplicateService duplicateService;
    @Autowired private RecordHandoverService handoverService;
    @Autowired private PropertyOfferRepository offerRepository;
    @Autowired private PropertyOfferEventRepository eventRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User colleague;
    private User manager;
    private User stranger;
    private Property flat;
    private Client buyer;
    private Client otherBuyer;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("of-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("of-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        manager = user("of-manager@almaty.kz", "Marat Manager", Role.MANAGER, DataScope.TEAM, almaty);
        stranger = user("of-stranger@astana.kz", "Erlan Other", Role.MANAGER, DataScope.TEAM, astana);
        flat = propertyRepository.save(Property.builder()
                .title("Severny Residence, apt 84").address("Dostyk 5").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3)
                .agent(agent).team(almaty).build());
        buyer = client("Saule Nurlanova", "+7 701 555 12 34", ClientType.BUYER, agent);
        otherBuyer = client("Arman Bekov", "+7 702 111 22 33", ClientType.BUYER, agent);
        signIn(agent);
    }

    // Recording -------------------------------------------------------------------------

    @Test
    @DisplayName("an offer is recorded for a buyer on a listing, NEW, with its first step in the history")
    void record() {
        PropertyOfferResponse offer = offerService.create(flat.getId(),
                request(buyer, "26500000", " Cash, can sign this week ", LocalDate.now().plusDays(5)));

        assertThat(offer.getPropertyId()).isEqualTo(flat.getId());
        assertThat(offer.getPropertyTitle()).isEqualTo("Severny Residence, apt 84");
        assertThat(offer.getPropertyPrice()).isEqualByComparingTo("28000000");
        assertThat(offer.getClientId()).isEqualTo(buyer.getId());
        assertThat(offer.getClientName()).isEqualTo("Saule Nurlanova");
        assertThat(offer.isClientVisible()).isTrue();
        assertThat(offer.getAgentId()).isEqualTo(agent.getId());
        assertThat(offer.getAmount()).isEqualByComparingTo("26500000");
        assertThat(offer.getLastParty()).isEqualTo(OfferParty.BUYER);
        assertThat(offer.getNote()).isEqualTo("Cash, can sign this week");
        assertThat(offer.getStatus()).isEqualTo(OfferStatus.NEW);
        assertThat(offer.isCanEdit()).isTrue();
        assertThat(offer.isOtherAccepted()).isFalse();
        assertThat(offer.getDecidedAt()).isNull();
        assertThat(offer.getHistory()).singleElement().satisfies(step -> {
            assertThat(step.getAction()).isEqualTo(OfferAction.OFFERED);
            assertThat(step.getParty()).isEqualTo(OfferParty.BUYER);
            assertThat(step.getAmount()).isEqualByComparingTo("26500000");
            assertThat(step.getActorName()).isEqualTo("Aigul Bekova");
        });

        assertThat(offerService.forClient(buyer.getId())).extracting(PropertyOfferResponse::getId)
                .containsExactly(offer.getId());
        assertThat(offerService.forProperty(flat.getId())).singleElement()
                .satisfies(o -> assertThat(o.getHistory()).as("lists leave the history out").isNull());
    }

    @Test
    @DisplayName("the API refuses a non-buyer, a second open offer, a past deadline, a sold flat and nothing at all")
    void recordingRules() throws Exception {
        Client seller = client("Seller", "+7 700 000 00 01", ClientType.SELLER, agent);
        offer(flat.getId(), seller, "100", null)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("CLIENT_NOT_BUYER"));
        offer(flat.getId(), buyer, "0", null)
                .andExpect(status().isBadRequest());
        offer(flat.getId(), buyer, "100", LocalDate.now().minusDays(1))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OFFER_EXPIRY_PAST"));
        offer(flat.getId(), buyer, "25000000", LocalDate.now())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("NEW"))
                .andExpect(jsonPath("$.history.length()").value(1));
        offer(flat.getId(), buyer, "25500000", null)
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_ALREADY_OPEN"));

        flat.setStatus(PropertyStatus.SOLD);
        propertyRepository.save(flat);
        offer(flat.getId(), otherBuyer, "100", null)
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("PROPERTY_SOLD"));
        assertThat(offerRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("a listing's offers come highest first")
    void highestFirst() {
        Client third = client("Dana", "+7 705 000 00 03", ClientType.BUYER, agent);
        Long low = offerService.create(flat.getId(), request(buyer, "24000000", null, null)).getId();
        Long high = offerService.create(flat.getId(), request(otherBuyer, "27000000", null, null)).getId();
        Long mid = offerService.create(flat.getId(), request(third, "25000000", null, null)).getId();

        assertThat(offerService.forProperty(flat.getId())).extracting(PropertyOfferResponse::getId)
                .containsExactly(high, mid, low);
    }

    // Negotiating -----------------------------------------------------------------------

    @Test
    @DisplayName("counters from either side move the figure on the table, and every step is kept")
    void negotiation() {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();

        PropertyOfferResponse countered = offerService.counter(id,
                counter("27500000", OfferParty.SELLER, "Seller wants more", LocalDate.now().plusDays(3)));
        assertThat(countered.getStatus()).isEqualTo(OfferStatus.COUNTERED);
        assertThat(countered.getAmount()).isEqualByComparingTo("27500000");
        assertThat(countered.getLastParty()).isEqualTo(OfferParty.SELLER);
        assertThat(countered.getExpiresOn()).isEqualTo(LocalDate.now().plusDays(3));

        signIn(manager);
        offerService.counter(id, counter("26200000", OfferParty.BUYER, null, null));
        PropertyOfferResponse accepted = offerService.accept(id, new OfferDecisionRequest("Agreed by phone"));

        assertThat(accepted.getStatus()).isEqualTo(OfferStatus.ACCEPTED);
        assertThat(accepted.getAmount()).as("the figure on the table is the agreed price")
                .isEqualByComparingTo("26200000");
        assertThat(accepted.getDecidedAt()).isNotNull();
        assertThat(accepted.getExpiresOn()).as("a counter without a date keeps the old one")
                .isEqualTo(LocalDate.now().plusDays(3));
        assertThat(accepted.getHistory())
                .extracting(PropertyOfferResponse.Step::getAction, PropertyOfferResponse.Step::getParty,
                        s -> s.getAmount().toBigInteger().longValue(), PropertyOfferResponse.Step::getActorName)
                .containsExactly(
                        tuple(OfferAction.OFFERED, OfferParty.BUYER, 25000000L, "Aigul Bekova"),
                        tuple(OfferAction.COUNTERED, OfferParty.SELLER, 27500000L, "Aigul Bekova"),
                        tuple(OfferAction.COUNTERED, OfferParty.BUYER, 26200000L, "Marat Manager"),
                        tuple(OfferAction.ACCEPTED, null, 26200000L, "Marat Manager"));
        assertThat(accepted.getHistory().get(3).getNote()).isEqualTo("Agreed by phone");
    }

    @Test
    @DisplayName("a decided offer takes no more counters or decisions")
    void decidedIsDecided() throws Exception {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();
        offerService.reject(id, null);

        mockMvc.perform(post("/offers/{id}/counter", id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"amount\":26000000,\"party\":\"BUYER\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_CLOSED"));
        mockMvc.perform(post("/offers/{id}/accept", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_CLOSED"));
        mockMvc.perform(post("/offers/{id}/withdraw", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_CLOSED"));
        assertThat(eventRepository.findHistory(id)).hasSize(2);
    }

    @Test
    @DisplayName("an open offer past its last day reads as expired and can no longer be accepted")
    void expiry() {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, LocalDate.now())).getId();
        PropertyOffer stored = offerRepository.findById(id).orElseThrow();
        stored.setExpiresOn(LocalDate.now().minusDays(1));
        offerRepository.saveAndFlush(stored);

        assertThat(offerService.get(id).getStatus()).isEqualTo(OfferStatus.EXPIRED);
        assertThat(offerRepository.findById(id).orElseThrow().getStatus())
                .as("worked out when read, never written").isEqualTo(OfferStatus.NEW);
        assertThatThrownBy(() -> offerService.accept(id, null))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("code", "OFFER_CLOSED");

        PropertyOfferResponse fresh = offerService.create(flat.getId(), request(buyer, "25500000", null, null));
        assertThat(fresh.getStatus()).as("the buyer may make a new one").isEqualTo(OfferStatus.NEW);
    }

    // Accepting -------------------------------------------------------------------------

    @Test
    @DisplayName("one accepted offer per listing; the others stay open, flagged, until it is withdrawn")
    void oneAcceptedAtATime() throws Exception {
        Long first = offerService.create(flat.getId(), request(buyer, "27000000", null, null)).getId();
        Long backup = offerService.create(flat.getId(), request(otherBuyer, "26000000", null, null)).getId();

        offerService.accept(first, null);

        assertThat(offerService.forProperty(flat.getId()))
                .extracting(PropertyOfferResponse::getId, PropertyOfferResponse::getStatus,
                        PropertyOfferResponse::isOtherAccepted)
                .containsExactly(
                        tuple(first, OfferStatus.ACCEPTED, false),
                        tuple(backup, OfferStatus.NEW, true));
        assertThat(offerService.forClient(otherBuyer.getId())).singleElement()
                .satisfies(o -> assertThat(o.isOtherAccepted()).isTrue());

        mockMvc.perform(post("/offers/{id}/accept", backup).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_ALREADY_ACCEPTED"));

        signIn(agent);
        PropertyOfferResponse withdrawn = offerService.withdraw(first, new OfferDecisionRequest("Mortgage refused"));
        assertThat(withdrawn.getStatus()).isEqualTo(OfferStatus.WITHDRAWN);

        PropertyOfferResponse next = offerService.accept(backup, null);
        assertThat(next.getStatus()).isEqualTo(OfferStatus.ACCEPTED);
        assertThat(propertyRepository.findById(flat.getId()).orElseThrow().getStatus())
                .as("accepting does not change the listing's status").isEqualTo(PropertyStatus.AVAILABLE);
    }

    // Who may ---------------------------------------------------------------------------

    @Test
    @DisplayName("a colleague sees the figures but not a buyer they may not open, and cannot decide")
    void aColleague() {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();

        signIn(colleague);
        PropertyOfferResponse read = offerService.get(id);
        assertThat(read.getAmount()).isEqualByComparingTo("25000000");
        assertThat(read.isClientVisible()).isFalse();
        assertThat(read.getClientName()).isNull();
        assertThat(read.getClientAgentName()).isEqualTo("Aigul Bekova");
        assertThat(read.isCanEdit()).isFalse();
        assertThatThrownBy(() -> offerService.accept(id, null)).isInstanceOf(AccessDeniedException.class);
        assertThatThrownBy(() -> offerService.counter(id, counter("1", OfferParty.SELLER, null, null)))
                .isInstanceOf(AccessDeniedException.class);
        assertThatThrownBy(() -> offerService.forClient(buyer.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> offerService.create(flat.getId(), request(buyer, "1", null, null)))
                .as("nor record one for a buyer they cannot see")
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("the listing's agent may decide an offer a colleague recorded")
    void theListingAgentDecides() {
        Client theirs = client("Theirs", "+7 707 000 00 07", ClientType.BUYER, colleague);
        signIn(colleague);
        Long id = offerService.create(flat.getId(), request(theirs, "25000000", null, null)).getId();

        signIn(agent);
        PropertyOfferResponse read = offerService.get(id);
        assertThat(read.isCanEdit()).isTrue();
        assertThat(offerService.reject(id, null).getStatus()).isEqualTo(OfferStatus.REJECTED);
    }

    @Test
    @DisplayName("another agency is told the offers, the listing and the buyer do not exist")
    void anotherAgencySeesNothing() throws Exception {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();

        signIn(stranger);
        assertThatThrownBy(() -> offerService.get(id)).isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> offerService.forProperty(flat.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> offerService.forClient(buyer.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> offerService.accept(id, null)).isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> offerService.withdraw(id, null)).isInstanceOf(ResourceNotFoundException.class);

        Client theirBuyer = clientRepository.save(Client.builder().fullName("Their buyer").phone("+7 777 000 00 00")
                .type(ClientType.BUYER).agent(stranger).team(stranger.getTeam()).build());
        assertThatThrownBy(() -> offerService.create(flat.getId(), request(theirBuyer, "1", null, null)))
                .isInstanceOf(ResourceNotFoundException.class);
        signIn(manager);
        assertThatThrownBy(() -> offerService.create(flat.getId(), request(theirBuyer, "1", null, null)))
                .as("another agency's buyer on our listing")
                .isInstanceOf(ResourceNotFoundException.class);

        mockMvc.perform(get("/offers/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        assertThat(offerRepository.findById(id).orElseThrow().getStatus()).isEqualTo(OfferStatus.NEW);
    }

    @Test
    @DisplayName("without a team the offers are shut, like the rest of the CRM")
    void teamRequired() throws Exception {
        User loner = user("of-loner@nowhere.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        mockMvc.perform(get("/offers/{id}", 1).header(HttpHeaders.AUTHORIZATION, bearer(loner)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // What happens to it later ----------------------------------------------------------

    @Test
    @DisplayName("deleting the listing or the buyer takes their offers and the history with them")
    void cascades() {
        Long onFlat = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();
        Property other = propertyRepository.save(Property.builder()
                .title("Other").address("Abay 1").city("Almaty").type(PropertyType.APARTMENT)
                .status(PropertyStatus.AVAILABLE).price(new BigDecimal("1000")).agent(agent).team(almaty).build());
        Long byOther = offerService.create(other.getId(), request(otherBuyer, "900", null, null)).getId();
        entityManager.flush();
        entityManager.clear();

        propertyRepository.deleteById(flat.getId());
        clientRepository.deleteById(otherBuyer.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(offerRepository.findById(onFlat)).isEmpty();
        assertThat(offerRepository.findById(byOther)).isEmpty();
        assertThat(eventRepository.count()).isZero();
    }

    @Test
    @DisplayName("merging two cards moves the offers to the card that stays")
    void mergeMovesOffers() {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();

        signIn(manager);
        duplicateService.merge(otherBuyer.getId(), buyer.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(offerService.get(id).getClientId()).isEqualTo(otherBuyer.getId());
    }

    @Test
    @DisplayName("when the agent leaves, the offers they follow go to whoever takes over their records")
    void handover() {
        Long id = offerService.create(flat.getId(), request(buyer, "25000000", null, null)).getId();

        handoverService.reassignTeamRecords(agent, colleague, almaty);
        entityManager.flush();
        entityManager.clear();

        signIn(colleague);
        PropertyOfferResponse read = offerService.get(id);
        assertThat(read.getAgentId()).isEqualTo(colleague.getId());
        assertThat(read.isCanEdit()).isTrue();
    }

    private org.springframework.test.web.servlet.ResultActions offer(Long propertyId, Client client, String amount,
                                                                     LocalDate expiresOn) throws Exception {
        String body = "{\"clientId\":" + client.getId() + ",\"amount\":" + amount
                + (expiresOn == null ? "" : ",\"expiresOn\":\"" + expiresOn + "\"") + "}";
        return mockMvc.perform(
                org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                        .post("/properties/{id}/offers", propertyId)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body));
    }

    private static PropertyOfferRequest request(Client client, String amount, String note, LocalDate expiresOn) {
        return new PropertyOfferRequest(client.getId(), new BigDecimal(amount), note, expiresOn);
    }

    private static OfferCounterRequest counter(String amount, OfferParty party, String note, LocalDate expiresOn) {
        return new OfferCounterRequest(new BigDecimal(amount), party, note, expiresOn);
    }

    private Client client(String name, String phone, ClientType type, User holder) {
        return clientRepository.save(Client.builder().fullName(name).phone(phone).type(type)
                .agent(holder).team(holder.getTeam()).build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /**
     * The token for a request as {@code who}. The JWT filter keeps an authentication that is
     * already there, so the test's own is switched to the same person.
     */
    private String bearer(User who) {
        signIn(who);
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
