package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPriceChange;
import com.crm.realestate.entity.PropertyShareLink;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyPriceChangeRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The report for the seller.
 *
 * <p>The seeded flat went up thirty days ago at 50M, came down to 48M and then to 45M. It has had
 * five viewings: interested, turned down, a no-show and one nobody has written up, all past, and
 * one tomorrow. Two links, one revoked, between them opened 17 times with 4 enquiries. Of the
 * agency's buyers one fits it, one fits on paper but turned it down, and one cannot afford it;
 * another agency has a buyer who would fit and must not be counted.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class SellerReportTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private MeetingRepository meetingRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private PropertyShareLinkRepository linkRepository;
    @Autowired private PropertyPriceChangeRepository priceChangeRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User ownScopeColleague;
    private User stranger;
    private Property flat;
    private Client fits;
    private Client turnedItDown;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        linkRepository.deleteAll();
        priceChangeRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", almaty, DataScope.TEAM);
        ownScopeColleague = user("own@almaty.kz", almaty, DataScope.OWN);
        stranger = user("manager@astana.kz", astana, DataScope.TEAM);

        flat = propertyRepository.save(Property.builder().title("Abay 10, flat 5").address("Abay 10")
                .city("Almaty").type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("45000000")).areaSqm(60.0).rooms(2)
                .agent(agent).team(almaty).build());
        listedDaysAgo(flat, 30);
        priceChange(flat, "50000000", "48000000", 20);
        priceChange(flat, "48000000", "45000000", 5);

        fits = buyer("Fits", "50000000", agent, almaty);
        turnedItDown = buyer("Turned it down", "50000000", agent, almaty);
        buyer("Too poor", "20000000", agent, almaty);
        buyer("Another agency's", "50000000", stranger, astana);

        viewing(turnedItDown, -10, ViewingOutcome.REJECTED);
        viewing(fits, -8, ViewingOutcome.INTERESTED);
        viewing(fits, -6, ViewingOutcome.NO_SHOW);
        viewing(fits, -2, null);
        viewing(fits, 1, null);

        link(flat, 5, 1, LocalDateTime.now().minusDays(10));
        link(flat, 12, 3, null);

        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("days on the market, viewings by outcome, link enquiries, price and matching buyers")
    void fullReport() throws Exception {
        report(agent)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.propertyId").value(flat.getId()))
                .andExpect(jsonPath("$.title").value("Abay 10, flat 5"))
                .andExpect(jsonPath("$.status").value("AVAILABLE"))
                .andExpect(jsonPath("$.daysOnMarket").value(30))
                .andExpect(jsonPath("$.soldAt").value(nullValue()))
                .andExpect(jsonPath("$.generatedOn").value(LocalDate.now().toString()))
                .andExpect(jsonPath("$.viewings.total").value(5))
                .andExpect(jsonPath("$.viewings.held").value(4))
                .andExpect(jsonPath("$.viewings.upcoming").value(1))
                .andExpect(jsonPath("$.viewings.outcomes.INTERESTED").value(1))
                .andExpect(jsonPath("$.viewings.outcomes.REJECTED").value(1))
                .andExpect(jsonPath("$.viewings.outcomes.NO_SHOW").value(1))
                .andExpect(jsonPath("$.viewings.awaitingOutcome").value(1))
                .andExpect(jsonPath("$.viewings.nextAt").isNotEmpty())
                .andExpect(jsonPath("$.viewings.lastHeldAt").isNotEmpty())
                .andExpect(jsonPath("$.publicLink.active").value(true))
                .andExpect(jsonPath("$.publicLink.views").value(17))
                .andExpect(jsonPath("$.publicLink.leads").value(4))
                .andExpect(jsonPath("$.price.current").value(45000000))
                .andExpect(jsonPath("$.price.original").value(50000000))
                .andExpect(jsonPath("$.price.change").value(-5000000))
                .andExpect(jsonPath("$.price.changePercent").value(-10.0))
                .andExpect(jsonPath("$.price.changes", hasSize(2)))
                .andExpect(jsonPath("$.price.changes[0].newPrice").value(48000000))
                .andExpect(jsonPath("$.price.changes[1].newPrice").value(45000000))
                // Only "Fits": the one who turned it down is not offered it again, the other is
                // over budget, and the other agency's buyer is behind the wall.
                .andExpect(jsonPath("$.matchingBuyers").value(1));
    }

    @Test
    @DisplayName("another agency's listing answers as missing, as does one that does not exist")
    void tenantWall() throws Exception {
        report(stranger).andExpect(status().isNotFound());
        mockMvc.perform(get("/properties/{id}/report", flat.getId() + 1000)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("an agent on own-data scope sees the listing but counts only their own viewings and buyers")
    void ownScope() throws Exception {
        report(ownScopeColleague)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.daysOnMarket").value(30))
                .andExpect(jsonPath("$.viewings.total").value(0))
                .andExpect(jsonPath("$.viewings.outcomes.INTERESTED").value(0))
                .andExpect(jsonPath("$.matchingBuyers").value(0))
                .andExpect(jsonPath("$.publicLink.leads").value(4));
    }

    @Test
    @DisplayName("a sold listing stops counting days at the won deal's close")
    void soldStopsTheClock() throws Exception {
        Property sold = propertyRepository.findById(flat.getId()).orElseThrow();
        sold.setStatus(PropertyStatus.SOLD);
        propertyRepository.save(sold);
        dealRepository.save(Deal.builder().title("Won").status(DealStatus.CLOSED_WON)
                .dealPrice(new BigDecimal("44000000"))
                .closedAt(LocalDateTime.now().minusDays(12))
                .client(clientRepository.findById(fits.getId()).orElseThrow())
                .property(sold).agent(agent).team(almaty).build());
        entityManager.flush();
        entityManager.clear();

        report(agent)
                .andExpect(jsonPath("$.status").value("SOLD"))
                .andExpect(jsonPath("$.daysOnMarket").value(18))
                .andExpect(jsonPath("$.soldAt").isNotEmpty());
    }

    @Test
    @DisplayName("a listing with no history reads as zeros, its original price its current one")
    void bareListing() throws Exception {
        Property bare = propertyRepository.save(Property.builder().title("New").address("Street")
                .city("Nowhere").type(PropertyType.HOUSE).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("90000000")).rooms(5).agent(agent).team(almaty).build());
        entityManager.flush();
        entityManager.clear();

        mockMvc.perform(get("/properties/{id}/report", bare.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.daysOnMarket").value(0))
                .andExpect(jsonPath("$.viewings.total").value(0))
                .andExpect(jsonPath("$.viewings.outcomes.NO_SHOW").value(0))
                .andExpect(jsonPath("$.viewings.nextAt").value(nullValue()))
                .andExpect(jsonPath("$.publicLink.active").value(false))
                .andExpect(jsonPath("$.publicLink.views").value(0))
                .andExpect(jsonPath("$.price.original").value(90000000))
                .andExpect(jsonPath("$.price.change").value(0))
                .andExpect(jsonPath("$.price.changePercent").value(0.0))
                .andExpect(jsonPath("$.price.changes", hasSize(0)))
                .andExpect(jsonPath("$.matchingBuyers").value(0));
    }

    private ResultActions report(User who) throws Exception {
        return mockMvc.perform(get("/properties/{id}/report", flat.getId())
                .header(HttpHeaders.AUTHORIZATION, bearer(who)));
    }

    private void listedDaysAgo(Property listing, int days) {
        entityManager.flush();
        entityManager.createNativeQuery("UPDATE properties SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, LocalDateTime.now().minusDays(days))
                .setParameter(2, listing.getId())
                .executeUpdate();
    }

    private void priceChange(Property listing, String from, String to, int daysAgo) {
        priceChangeRepository.save(PropertyPriceChange.builder().property(listing).team(almaty)
                .oldPrice(new BigDecimal(from)).newPrice(new BigDecimal(to))
                .changedBy(agent).changedAt(LocalDateTime.now().minusDays(daysAgo)).build());
    }

    private Client buyer(String name, String budgetMax, User owner, Team team) {
        return clientRepository.save(Client.builder().fullName(name).type(ClientType.BUYER)
                .wantedCity("Almaty").minRooms(2).budgetMax(new BigDecimal(budgetMax))
                .agent(owner).team(team).build());
    }

    private void viewing(Client who, int daysFromNow, ViewingOutcome outcome) {
        LocalDateTime at = LocalDateTime.now().plusDays(daysFromNow);
        meetingRepository.save(Meeting.builder().title("Viewing").scheduledAt(at)
                .completed(outcome != null).outcome(outcome)
                .client(who).property(flat).agent(agent).team(almaty).build());
    }

    private void link(Property listing, long views, long leads, LocalDateTime revokedAt) {
        linkRepository.save(PropertyShareLink.builder()
                .token("t" + views + "-" + leads).property(listing).createdBy(agent)
                .viewCount(views).leadCount(leads).revokedAt(revokedAt).build());
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private User user(String email, Team where, DataScope scope) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(scope).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
