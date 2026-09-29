package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
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
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.PriceInsightService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Is this price right? From the agency's own book.
 *
 * <p>The seeded Almaty book, all 2-room flats of 50 m², per m²: active 400k, 500k, 600k, 700k,
 * 800k; sold 450k (no deal) and 550k (listed at 600k, the won deal at 27.5M). Around it: a 3-room
 * flat, a house, a flat with no area, and another agency's ten flats at 2M per m² — none of which
 * may move a figure below.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PriceInsightTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PriceInsightService priceInsightService;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private Team almaty;
    private User agent;
    private User stranger;
    private Property cheapest;
    private Property dearest;
    private Property theirs;
    private Client buyer;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", almaty);
        stranger = user("manager@astana.kz", astana);
        buyer = clientRepository.save(Client.builder().fullName("Buyer").type(ClientType.BUYER)
                .agent(agent).team(almaty).build());

        cheapest = flat("Abay 1", "Almaty", 2, "20000000", PropertyStatus.AVAILABLE);
        flat("Abay 2", " ALMATY ", 2, "25000000", PropertyStatus.RESERVED);
        flat("Abay 3", "almaty", 2, "30000000", PropertyStatus.AVAILABLE);
        flat("Abay 4", "Almaty", 2, "35000000", PropertyStatus.AVAILABLE);
        dearest = flat("Abay 5", "Almaty", 2, "40000000", PropertyStatus.AVAILABLE);
        flat("Sold, no deal", "Almaty", 2, "22500000", PropertyStatus.SOLD);
        Property wonDeal = flat("Sold by a deal", "Almaty", 2, "30000000", PropertyStatus.SOLD);
        won(wonDeal, "27500000", 30);

        flat("Three rooms", "Almaty", 3, "90000000", PropertyStatus.AVAILABLE);
        save(listing("A house", "Almaty", 2, "90000000", PropertyStatus.AVAILABLE, 50.0)
                .type(PropertyType.HOUSE));
        save(listing("No area", "Almaty", 2, "90000000", PropertyStatus.AVAILABLE, null));
        for (int i = 0; i < 10; i++) {
            Property p = save(listing("Their flat " + i, "Almaty", 2, "100000000",
                    PropertyStatus.AVAILABLE, 50.0).agent(stranger).team(astana));
            if (i == 0) theirs = p;
        }
        entityManager.flush();
        entityManager.clear();
    }

    @Test
    @DisplayName("percentiles per m² for active and sold, interpolated, and the range for an area")
    void exactPercentiles() throws Exception {
        insight("Almaty", "APARTMENT", "2", "60")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(7))
                .andExpect(jsonPath("$.lowConfidence").value(false))
                .andExpect(jsonPath("$.criteria.roomsRule").value("EXACT"))
                .andExpect(jsonPath("$.criteria.minRooms").value(2))
                .andExpect(jsonPath("$.criteria.maxRooms").value(2))
                .andExpect(jsonPath("$.active.count").value(5))
                .andExpect(jsonPath("$.active.p25PerSqm").value(500000))
                .andExpect(jsonPath("$.active.medianPerSqm").value(600000))
                .andExpect(jsonPath("$.active.p75PerSqm").value(700000))
                .andExpect(jsonPath("$.sold.count").value(2))
                .andExpect(jsonPath("$.sold.p25PerSqm").value(475000))
                .andExpect(jsonPath("$.sold.medianPerSqm").value(500000))
                .andExpect(jsonPath("$.sold.p75PerSqm").value(525000))
                .andExpect(jsonPath("$.sold.medianDaysOnMarket").value(30))
                // All seven: 400 450 500 550 600 700 800k → p25 475k, median 550k, p75 650k; × 60 m².
                .andExpect(jsonPath("$.suggested.low").value(28500000))
                .andExpect(jsonPath("$.suggested.median").value(33000000))
                .andExpect(jsonPath("$.suggested.high").value(39000000))
                .andExpect(jsonPath("$.position").value(nullValue()));
    }

    @Test
    @DisplayName("a sold listing counts at its won deal's price, not its asking price")
    void dealPriceIsPreferred() throws Exception {
        insight("Almaty", "APARTMENT", "2", null)
                .andExpect(jsonPath("$.comparables[?(@.title == 'Sold by a deal')].price").value(27500000.0))
                .andExpect(jsonPath("$.comparables[?(@.title == 'Sold by a deal')].pricePerSqm").value(550000))
                .andExpect(jsonPath("$.comparables[?(@.title == 'Sold by a deal')].sold").value(true))
                .andExpect(jsonPath("$.suggested").value(nullValue()))
                .andExpect(jsonPath("$.comparables[0].agentId").doesNotExist())
                .andExpect(jsonPath("$.comparables[0].agentName").doesNotExist());
    }

    @Test
    @DisplayName("exact rooms, then ±1, then any; fewer than five even then is low confidence")
    void widening() throws Exception {
        flat("Astana 2a", "Astana", 2, "30000000", PropertyStatus.AVAILABLE);
        flat("Astana 2b", "Astana", 2, "30000000", PropertyStatus.AVAILABLE);
        flat("Astana 2c", "Astana", 2, "30000000", PropertyStatus.AVAILABLE);
        flat("Astana 3a", "Astana", 3, "30000000", PropertyStatus.AVAILABLE);
        flat("Astana 1a", "Astana", 1, "30000000", PropertyStatus.AVAILABLE);
        flat("Astana 6a", "Astana", 6, "30000000", PropertyStatus.AVAILABLE);

        insight("Astana", "APARTMENT", "2", "50")
                .andExpect(jsonPath("$.criteria.roomsRule").value("NEAR"))
                .andExpect(jsonPath("$.criteria.minRooms").value(1))
                .andExpect(jsonPath("$.criteria.maxRooms").value(3))
                .andExpect(jsonPath("$.count").value(5))
                .andExpect(jsonPath("$.lowConfidence").value(false));
        insight("Astana", "APARTMENT", "9", "50")
                .andExpect(jsonPath("$.criteria.roomsRule").value("ANY"))
                .andExpect(jsonPath("$.criteria.minRooms").value(nullValue()))
                .andExpect(jsonPath("$.count").value(6))
                .andExpect(jsonPath("$.lowConfidence").value(false));

        flat("Shymkent 2a", "Shymkent", 2, "30000000", PropertyStatus.AVAILABLE);
        flat("Shymkent 2b", "Shymkent", 2, "20000000", PropertyStatus.AVAILABLE);
        insight("Shymkent", "APARTMENT", "2", "50")
                .andExpect(jsonPath("$.criteria.roomsRule").value("ANY"))
                .andExpect(jsonPath("$.count").value(2))
                .andExpect(jsonPath("$.lowConfidence").value(true))
                .andExpect(jsonPath("$.active.medianPerSqm").value(500000));
        insight("Nowhere", "APARTMENT", "2", "50")
                .andExpect(jsonPath("$.count").value(0))
                .andExpect(jsonPath("$.lowConfidence").value(true))
                .andExpect(jsonPath("$.suggested").value(nullValue()));
    }

    @Test
    @DisplayName("the listing being priced is left out of its own comparables")
    void excludeId() throws Exception {
        mockMvc.perform(get("/properties/price-insight").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("city", "Almaty").param("type", "APARTMENT").param("rooms", "2")
                        .param("excludeId", String.valueOf(cheapest.getId())))
                .andExpect(jsonPath("$.count").value(6))
                .andExpect(jsonPath("$.active.count").value(4))
                .andExpect(jsonPath("$.comparables[*].id", not(hasItem(cheapest.getId().intValue()))));
    }

    @Test
    @DisplayName("another agency's listings never count, and theirs is only theirs")
    void otherAgencyNeverCounts() throws Exception {
        insight("Almaty", "APARTMENT", "2", "50")
                .andExpect(jsonPath("$.comparables[*].id", not(hasItem(theirs.getId().intValue()))));
        mockMvc.perform(get("/properties/price-insight").header(HttpHeaders.AUTHORIZATION, bearer(stranger))
                        .param("city", "Almaty").param("type", "APARTMENT").param("rooms", "2"))
                .andExpect(jsonPath("$.count").value(10))
                .andExpect(jsonPath("$.active.medianPerSqm").value(2000000));
        mockMvc.perform(get("/properties/{id}/price-insight", theirs.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("missing or nonsensical parameters are a 400")
    void badParameters() throws Exception {
        insight(null, "APARTMENT", "2", "50").andExpect(status().isBadRequest());
        insight("  ", "APARTMENT", "2", "50").andExpect(status().isBadRequest());
        insight("Almaty", null, "2", "50").andExpect(status().isBadRequest());
        insight("Almaty", "CASTLE", "2", "50").andExpect(status().isBadRequest());
        insight("Almaty", "APARTMENT", "-1", "50").andExpect(status().isBadRequest());
        insight("Almaty", "APARTMENT", "2", "0").andExpect(status().isBadRequest());
        insight("Almaty", "APARTMENT", "two", "50").andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("a saved listing is told where its price per m² sits among the active ones")
    void position() throws Exception {
        // Without itself the active are 500 600 700 800k: median 650k; 400k is below all of them.
        positionOf(cheapest)
                .andExpect(jsonPath("$.count").value(6))
                .andExpect(jsonPath("$.criteria.excludeId").value(cheapest.getId()))
                .andExpect(jsonPath("$.position.pricePerSqm").value(400000))
                .andExpect(jsonPath("$.position.percentile").value(0))
                .andExpect(jsonPath("$.position.vsMedianPercent").value(-38.5));
        // Active 400 500 600 700k: median 550k; 800k is above every one, 45.5% over.
        positionOf(dearest)
                .andExpect(jsonPath("$.position.percentile").value(100))
                .andExpect(jsonPath("$.position.vsMedianPercent").value(45.5))
                .andExpect(jsonPath("$.suggested.median").value(26250000));
        // 30M, the middle one: active 400 500 700 800k, median 600k — dead on, half below.
        Property middle = propertyRepository.findByTitleStartingWith("Abay 3").get(0);
        positionOf(middle)
                .andExpect(jsonPath("$.position.percentile").value(50))
                .andExpect(jsonPath("$.position.vsMedianPercent").value(0.0));
    }

    @Test
    @DisplayName("an insight costs the same statements whatever the size of the book")
    void statementCountIsFlat() {
        signIn(agent);
        long few = statements();
        IntStream.range(0, 30).forEach(i -> {
            Property p = flat("More " + i, "Almaty", 2, "30000000",
                    i % 2 == 0 ? PropertyStatus.AVAILABLE : PropertyStatus.SOLD);
            if (i % 3 == 0) won(p, "29000000", 10);
        });
        entityManager.flush();
        long many = statements();
        assertThat(many).as("7 comparables took %d statements, 37 took %d", few, many).isEqualTo(few);
        assertThat(many).isLessThanOrEqualTo(3);
    }

    private long statements() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        assertThat(priceInsightService.insight("Almaty", PropertyType.APARTMENT, 2, 50.0, null).getCount())
                .isPositive();
        return stats.getPrepareStatementCount();
    }

    private ResultActions insight(String city, String type, String rooms, String area) throws Exception {
        var request = get("/properties/price-insight").header(HttpHeaders.AUTHORIZATION, bearer(agent));
        if (city != null) request.param("city", city);
        if (type != null) request.param("type", type);
        if (rooms != null) request.param("rooms", rooms);
        if (area != null) request.param("areaSqm", area);
        return mockMvc.perform(request);
    }

    private ResultActions positionOf(Property listing) throws Exception {
        return mockMvc.perform(get("/properties/{id}/price-insight", listing.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk());
    }

    private Property flat(String title, String city, int rooms, String price, PropertyStatus status) {
        return save(listing(title, city, rooms, price, status, 50.0));
    }

    private Property.PropertyBuilder listing(String title, String city, int rooms, String price,
                                             PropertyStatus status, Double area) {
        return Property.builder().title(title).address("Street").city(city)
                .type(PropertyType.APARTMENT).status(status).price(new BigDecimal(price))
                .areaSqm(area).rooms(rooms).agent(agent).team(almaty);
    }

    private Property save(Property.PropertyBuilder builder) {
        return propertyRepository.save(builder.build());
    }

    /** A won deal closed {@code days} after the listing went up. */
    private void won(Property listing, String price, int days) {
        LocalDateTime listed = LocalDateTime.of(2026, 3, 1, 10, 0);
        entityManager.flush();
        entityManager.createNativeQuery("UPDATE properties SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, listed).setParameter(2, listing.getId()).executeUpdate();
        dealRepository.save(Deal.builder().title("Won").status(DealStatus.CLOSED_WON)
                .dealPrice(new BigDecimal(price)).closedAt(listed.plusDays(days))
                .client(buyer).property(listing).agent(agent).team(almaty).build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private User user(String email, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
