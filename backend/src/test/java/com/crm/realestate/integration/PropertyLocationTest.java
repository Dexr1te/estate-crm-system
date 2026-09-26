package com.crm.realestate.integration;

import com.crm.realestate.dto.response.ShareLinkResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ListingShareService;
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
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Listings on a map: a pin on a listing, and the listings inside the rectangle a map shows.
 *
 * <p>A pin is both halves or neither and inside the globe. The rectangle narrows the ordinary
 * list, so it combines with every other filter and never shows another agency's listing. The
 * public page links to the point only when there is one.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PropertyLocationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private ListingShareService shareService;
    @Autowired private PropertyShareLinkRepository linkRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private User agent;
    private User stranger;
    private Property dostyk;
    private Property unpinned;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        linkRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", Role.AGENT, almaty);
        stranger = user("manager@astana.kz", Role.MANAGER, astana);

        dostyk = listing("Dostyk 5", 3, PropertyStatus.AVAILABLE, 43.2380, 76.9570, agent, almaty);
        listing("Esentai Park", 2, PropertyStatus.AVAILABLE, 43.2180, 76.9280, agent, almaty);
        listing("Kok-Tobe", 3, PropertyStatus.SOLD, 43.2330, 76.9750, agent, almaty);
        unpinned = listing("No pin yet", 3, PropertyStatus.AVAILABLE, null, null, agent, almaty);
        // Another agency's flat in the very same rectangle.
        listing("Their flat", 3, PropertyStatus.AVAILABLE, 43.2300, 76.9500, stranger, astana);
    }

    // Saving a pin ----------------------------------------------------------------------------

    @Test
    @DisplayName("a pin sent on create comes back, and an edit can move it or clear it")
    void coordinatesAreSavedAndReturned() throws Exception {
        String created = mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body(43.25654, 76.92848)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.latitude").value(43.25654))
                .andExpect(jsonPath("$.longitude").value(76.92848))
                .andReturn().getResponse().getContentAsString();
        long id = Long.parseLong(created.replaceAll(".*\"id\":(\\d+).*", "$1"));

        mockMvc.perform(put("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body(51.128207, 71.430411)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.latitude").value(51.128207));
        mockMvc.perform(get("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(jsonPath("$.longitude").value(71.430411));

        mockMvc.perform(put("/properties/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body(null, null)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.latitude").value(nullValue()))
                .andExpect(jsonPath("$.longitude").value(nullValue()));
        assertThat(propertyRepository.findById(id).orElseThrow().getLatitude()).isNull();
    }

    @Test
    @DisplayName("a pin off the globe, or half a pin, is refused and nothing is saved")
    void invalidCoordinatesAreRefused() throws Exception {
        long before = propertyRepository.count();
        for (String bad : List.of(body(90.5, 10.0), body(-91.0, 10.0), body(10.0, 180.01),
                body(10.0, -181.0), body(43.2, null), body(null, 76.9))) {
            mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                            .contentType(MediaType.APPLICATION_JSON).content(bad))
                    .andExpect(status().isBadRequest());
        }
        assertThat(propertyRepository.count()).isEqualTo(before);

        mockMvc.perform(post("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body(-90.0, 180.0)))
                .andExpect(status().isCreated());
    }

    // The map's rectangle ---------------------------------------------------------------------

    @Test
    @DisplayName("the rectangle returns only this agency's pinned listings inside it")
    void boundingBoxFilter() throws Exception {
        mockMvc.perform(inAlmaty(agent))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(3))
                .andExpect(jsonPath("$.content[*].title")
                        .value(containsInAnyOrder("Dostyk 5", "Esentai Park", "Kok-Tobe")));

        // A rectangle that holds only Esentai Park.
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("minLat", "43.21").param("maxLat", "43.22")
                        .param("minLng", "76.92").param("maxLng", "76.93"))
                .andExpect(jsonPath("$.totalElements").value(1))
                .andExpect(jsonPath("$.content[0].title").value("Esentai Park"));

        // The other agency sees only its own flat in the same rectangle.
        mockMvc.perform(inAlmaty(stranger))
                .andExpect(jsonPath("$.totalElements").value(1))
                .andExpect(jsonPath("$.content[0].title").value("Their flat"));
    }

    @Test
    @DisplayName("the rectangle combines with the other filters and with pagination")
    void boundingBoxWithOtherFilters() throws Exception {
        mockMvc.perform(inAlmaty(agent).param("status", "AVAILABLE"))
                .andExpect(jsonPath("$.totalElements").value(2))
                .andExpect(jsonPath("$.content[*].title")
                        .value(containsInAnyOrder("Dostyk 5", "Esentai Park")));
        mockMvc.perform(inAlmaty(agent).param("rooms", "3"))
                .andExpect(jsonPath("$.content[*].title")
                        .value(containsInAnyOrder("Dostyk 5", "Kok-Tobe")));
        mockMvc.perform(inAlmaty(agent).param("search", "esentai"))
                .andExpect(jsonPath("$.totalElements").value(1));
        mockMvc.perform(inAlmaty(agent).param("size", "2").param("page", "0"))
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.totalElements").value(3));
    }

    @Test
    @DisplayName("a rectangle across the antimeridian wraps instead of coming back empty")
    void antimeridian() throws Exception {
        listing("Kamchatka", 1, PropertyStatus.AVAILABLE, 53.0, 179.5, agent, dostyk.getTeam());
        listing("Chukotka", 1, PropertyStatus.AVAILABLE, 65.0, -179.5, agent, dostyk.getTeam());
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("minLat", "50").param("maxLat", "70")
                        .param("minLng", "179").param("maxLng", "-179"))
                .andExpect(jsonPath("$.content[*].title")
                        .value(containsInAnyOrder("Kamchatka", "Chukotka")));
    }

    @Test
    @DisplayName("half a rectangle, or one off the globe, is a 400")
    void invalidBounds() throws Exception {
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("minLat", "43").param("maxLat", "44"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_BOUNDS"));
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("minLat", "-95").param("maxLat", "44")
                        .param("minLng", "76").param("maxLng", "77"))
                .andExpect(status().isBadRequest());
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("minLat", "44").param("maxLat", "43")
                        .param("minLng", "76").param("maxLng", "77"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("hasLocation=false lists the listings the map cannot show, within the agency")
    void listingsWithoutAPin() throws Exception {
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("hasLocation", "false"))
                .andExpect(jsonPath("$.totalElements").value(1))
                .andExpect(jsonPath("$.content[0].title").value("No pin yet"));
        mockMvc.perform(get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .param("hasLocation", "true"))
                .andExpect(jsonPath("$.totalElements").value(3));
    }

    // The public page -------------------------------------------------------------------------

    @Test
    @DisplayName("the public page links to the pin on OpenStreetMap, and only when there is one")
    void publicPageMapLink() throws Exception {
        String pinned = publicPage(dostyk);
        assertThat(pinned).contains(
                "href=\"https://www.openstreetmap.org/?mlat=43.238000&amp;mlon=76.957000#map=17/43.238000/76.957000\"");
        assertThat(pinned).contains("Open in maps").doesNotContain("<script").doesNotContain("<iframe");

        String bare = publicPage(unpinned);
        assertThat(bare).doesNotContain("openstreetmap").doesNotContain("Open in maps");
    }

    // Helpers ---------------------------------------------------------------------------------

    private MockHttpServletRequestBuilder inAlmaty(User who) {
        return get("/properties").header(HttpHeaders.AUTHORIZATION, bearer(who))
                .param("minLat", "43.20").param("maxLat", "43.30")
                .param("minLng", "76.90").param("maxLng", "77.00");
    }

    private String publicPage(Property which) throws Exception {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
        ShareLinkResponse link = shareService.create(which.getId());
        SecurityContextHolder.clearContext();
        String token = link.getUrl().substring(link.getUrl().lastIndexOf('/') + 1);
        return mockMvc.perform(get("/l/{token}", token).header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
    }

    private static String body(Double lat, Double lng) {
        return """
                {"title":"Pinned flat","address":"Abaya 10","city":"Almaty","type":"APARTMENT",
                 "price":30000000,"latitude":%s,"longitude":%s}
                """.formatted(lat, lng);
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private Property listing(String title, int rooms, PropertyStatus status, Double lat, Double lng,
                             User owner, Team where) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Almaty street").city("Almaty")
                .type(PropertyType.APARTMENT).status(status)
                .price(new BigDecimal("28000000")).rooms(rooms)
                .latitude(lat).longitude(lng)
                .agent(owner).team(where).build());
    }

    private User user(String email, Role role, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email).phone(null)
                .role(role).dataScope(DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }
}
