package com.crm.realestate.integration;

import com.crm.realestate.dto.response.PropertyPhotoResponse;
import com.crm.realestate.dto.response.ShareLinkResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPhotoRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ListingShareService;
import com.crm.realestate.service.PropertyPhotoService;
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
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A listing's public link: one address a client opens in any browser, with no account.
 *
 * <p>The link is made and read behind the listing's own walls, and switched off by the listing's
 * agent or a manager. The page it opens answers by token alone, shows only what a client should
 * see, escapes everything an agent typed, and reads the same for a revoked link as for one that
 * never existed. Filters are on here: the point is that {@code /l/**} and nothing else is public.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class ListingShareLinkTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private ListingShareService shareService;
    @Autowired private PropertyPhotoService photoService;
    @Autowired private PropertyShareLinkRepository linkRepository;
    @Autowired private PropertyPhotoRepository photoRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private Team almaty;
    private User agent;
    private User colleague;
    private User manager;
    private User stranger;
    private Property flat;
    private Property otherFlat;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        linkRepository.deleteAll();
        photoRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", "Aigul Bekova", "+7 701 555-12-34", Role.AGENT, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", null, Role.AGENT, almaty);
        manager = user("manager@almaty.kz", "Asel Nurlanovna", null, Role.MANAGER, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", null, Role.MANAGER, astana);

        flat = listing("Severny Residence, apt 84", agent, almaty);
        otherFlat = listing("Esentai Park, apt 12", agent, almaty);
    }

    // Making, reading and switching off ---------------------------------------------------

    @Test
    @DisplayName("asking for a link twice gives the same unguessable link")
    void createIsIdempotent() {
        signIn(agent);
        ShareLinkResponse first = shareService.create(flat.getId());
        ShareLinkResponse again = shareService.create(flat.getId());

        assertThat(again.getUrl()).isEqualTo(first.getUrl());
        assertThat(first.getUrl()).startsWith("http://localhost:8080/api/l/");
        String token = tokenOf(first);
        assertThat(token).hasSizeGreaterThanOrEqualTo(22).matches("[A-Za-z0-9_-]+");
        assertThat(token).doesNotContain(String.valueOf(flat.getId()).repeat(3));
        assertThat(linkRepository.findAll()).hasSize(1);
        assertThat(shareService.get(flat.getId()).getUrl()).isEqualTo(first.getUrl());
    }

    @Test
    @DisplayName("a listing with no link says so with a null url")
    void noLinkYet() throws Exception {
        mockMvc.perform(get("/properties/{id}/share-link", flat.getId()).header(
                        HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.url").doesNotExist())
                .andExpect(jsonPath("$.viewCount").value(0));
    }

    @Test
    @DisplayName("another agency's listing reads as missing, for making a link and for reading one")
    void anotherAgencyGetsNotFound() throws Exception {
        signIn(stranger);
        assertThatThrownBy(() -> shareService.create(flat.getId()))
                .isInstanceOf(ResourceNotFoundException.class);

        mockMvc.perform(post("/properties/{id}/share-link", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete("/properties/{id}/share-link", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        assertThat(linkRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("a revoked link is dead for good; a new one is a different address")
    void revokeKillsTheLink() throws Exception {
        String token = createAs(agent);

        mockMvc.perform(delete("/properties/{id}/share-link", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNoContent());

        signIn(agent);
        assertThat(shareService.get(flat.getId()).getUrl()).isNull();
        mockMvc.perform(get("/l/{token}", token)).andExpect(status().isNotFound());

        signIn(agent);
        String fresh = tokenOf(shareService.create(flat.getId()));
        assertThat(fresh).isNotEqualTo(token);
        mockMvc.perform(get("/l/{token}", token)).andExpect(status().isNotFound());
        mockMvc.perform(get("/l/{token}", fresh)).andExpect(status().isOk());
    }

    @Test
    @DisplayName("only the listing's agent, a manager or an admin switches a link off")
    void revokeIsNarrowerThanCreate() {
        createAs(agent);

        signIn(colleague);
        assertThat(shareService.get(flat.getId()).getUrl()).as("a colleague sees it").isNotNull();
        assertThatThrownBy(() -> shareService.revoke(flat.getId()))
                .isInstanceOf(BusinessException.class);
        assertThat(shareService.get(flat.getId()).getUrl()).isNotNull();

        signIn(manager);
        shareService.revoke(flat.getId());
        assertThat(shareService.get(flat.getId()).getUrl()).isNull();
    }

    // The public page ----------------------------------------------------------------------

    @Test
    @DisplayName("the page opens without an account and escapes everything an agent typed")
    void publicPageEscapes() throws Exception {
        flat.setTitle("Flat \"with\" <b>view</b>");
        flat.setDescription("Sunny.\n<script>alert('x')</script>\n<img src=x onerror=alert(1)>");
        propertyRepository.save(flat);
        String token = createAs(agent);

        MvcResult result = mockMvc.perform(get("/l/{token}", token))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Robots-Tag", "noindex, nofollow"))
                .andExpect(header().string("Referrer-Policy", "no-referrer"))
                .andExpect(header().string(HttpHeaders.CACHE_CONTROL, "no-store"))
                .andReturn();
        String html = html(result);

        assertThat(html).doesNotContain("<script").doesNotContain("<img src=x")
                .doesNotContain("<b>view</b>");
        assertThat(html).contains("&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;")
                .contains("Flat &quot;with&quot; &lt;b&gt;view&lt;/b&gt;");
        assertThat(html).contains("Aigul Bekova").contains("Almaty Realty");
        assertThat(html).as("no emails, no internal ids in the page")
                .doesNotContain("@almaty.kz").doesNotContain("/properties/");
        assertThat(result.getResponse().getHeader("Content-Security-Policy"))
                .contains("default-src 'none'");
    }

    @Test
    @DisplayName("the page carries preview tags with the cover, the price and the address")
    void openGraphTags() throws Exception {
        signIn(agent);
        PropertyPhotoResponse cover = photoService.upload(flat.getId(), PropertyPhotoTest.image("a.jpg"));
        photoService.upload(flat.getId(), PropertyPhotoTest.image("b.jpg"));
        String token = createAs(agent);

        String html = html(mockMvc.perform(get("/l/{token}", token)).andReturn());

        String url = "http://localhost:8080/api/l/" + token;
        assertThat(html)
                .contains("<meta property=\"og:title\" content=\"Severny Residence, apt 84\">")
                .contains("<meta property=\"og:url\" content=\"" + url + "\">")
                .contains("<meta property=\"og:image\" content=\"" + url + "/photos/"
                        + cover.getId() + "\">")
                .contains("property=\"og:description\" content=\"$28")
                .contains("src=\"" + token + "/photos/" + cover.getId() + "\"");
        sample(html);
    }

    @Test
    @DisplayName("a sold listing says so, and the call buttons appear only for an agent with a phone")
    void soldBadgeAndContact() throws Exception {
        flat.setStatus(PropertyStatus.SOLD);
        propertyRepository.save(flat);
        String token = createAs(agent);
        String html = html(mockMvc.perform(get("/l/{token}", token)
                .header(HttpHeaders.ACCEPT_LANGUAGE, "en")).andReturn());
        assertThat(html).contains("class=\"badge badge-sold\">Sold<")
                .contains("href=\"tel:+77015551234\"").contains("href=\"https://wa.me/77015551234\"");

        otherFlat.setAgent(colleague);
        propertyRepository.save(otherFlat);
        String other = createAs(colleague, otherFlat);
        String plain = html(mockMvc.perform(get("/l/{token}", other)).andReturn());
        assertThat(plain).doesNotContain("tel:").doesNotContain("wa.me").doesNotContain("class=\"badge ");
    }

    @Test
    @DisplayName("the page speaks the browser's language among en, ru and kk, Russian otherwise")
    void languagePick() throws Exception {
        String token = createAs(agent);
        assertThat(page(token, "en-US,en;q=0.9")).contains("<html lang=\"en\">").contains(">Rooms<");
        assertThat(page(token, "kk-KZ,ru;q=0.8")).contains("<html lang=\"kk\">").contains(">Бөлме<");
        assertThat(page(token, "de-DE,ru;q=0.5")).contains("<html lang=\"ru\">").contains(">Комнат<");
        assertThat(page(token, "fr")).contains("<html lang=\"ru\">");
        assertThat(page(token, null)).contains("<html lang=\"ru\">");
        assertThat(page(token, ";;;garbage")).contains("<html lang=\"ru\">");
    }

    @Test
    @DisplayName("each open is counted, with when")
    void viewCounter() throws Exception {
        String token = createAs(agent);
        mockMvc.perform(get("/l/{token}", token)).andExpect(status().isOk());
        mockMvc.perform(get("/l/{token}", token)).andExpect(status().isOk());

        signIn(agent);
        ShareLinkResponse link = shareService.get(flat.getId());
        assertThat(link.getViewCount()).isEqualTo(2);
        assertThat(link.getLastViewedAt()).isNotNull();
    }

    @Test
    @DisplayName("an unknown or malformed token gets the same friendly page, never a hint")
    void unknownToken() throws Exception {
        String html = html(mockMvc.perform(get("/l/{token}", "nope-not-a-token"))
                .andExpect(status().isNotFound()).andReturn());
        assertThat(html).contains("<html lang=\"ru\">").contains("Ссылка больше не действует");
        mockMvc.perform(get("/l/{token}", "x".repeat(300))).andExpect(status().isNotFound());
    }

    // Photographs --------------------------------------------------------------------------

    @Test
    @DisplayName("the page's photo endpoint serves that listing's photos and nobody else's")
    void photosOfThatListingOnly() throws Exception {
        signIn(agent);
        PropertyPhotoResponse mine = photoService.upload(flat.getId(), PropertyPhotoTest.image("a.jpg"));
        PropertyPhotoResponse theirs =
                photoService.upload(otherFlat.getId(), PropertyPhotoTest.image("b.jpg"));
        String token = createAs(agent);

        MvcResult ok = mockMvc.perform(get("/l/{t}/photos/{p}", token, mine.getId()))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, "image/jpeg"))
                .andExpect(header().string("X-Robots-Tag", "noindex, nofollow"))
                .andReturn();
        assertThat(ok.getResponse().getContentAsByteArray()).hasSize(mine.getFileSize().intValue());
        assertThat(ok.getResponse().getHeader(HttpHeaders.CACHE_CONTROL)).contains("max-age=3600");

        mockMvc.perform(get("/l/{t}/photos/{p}", token, theirs.getId())).andExpect(status().isNotFound());
        mockMvc.perform(get("/l/{t}/photos/{p}", token, "abc")).andExpect(status().isNotFound());
        mockMvc.perform(get("/l/{t}/photos/{p}", "wrong", mine.getId())).andExpect(status().isNotFound());

        signIn(agent);
        shareService.revoke(flat.getId());
        mockMvc.perform(get("/l/{t}/photos/{p}", token, mine.getId())).andExpect(status().isNotFound());
    }

    // What is public ------------------------------------------------------------------------

    @Test
    @DisplayName("/l/** is public; the listing API next to it still needs a token")
    void onlyTheLinkIsPublic() throws Exception {
        String token = createAs(agent);
        mockMvc.perform(get("/l/{token}", token)).andExpect(status().isOk());

        int bare = mockMvc.perform(get("/properties/{id}", flat.getId())).andReturn()
                .getResponse().getStatus();
        assertThat(bare).isIn(401, 403);
        int link = mockMvc.perform(get("/properties/{id}/share-link", flat.getId())).andReturn()
                .getResponse().getStatus();
        assertThat(link).isIn(401, 403);
        int create = mockMvc.perform(post("/properties/{id}/share-link", flat.getId())).andReturn()
                .getResponse().getStatus();
        assertThat(create).isIn(401, 403);
        int photos = mockMvc.perform(get("/properties/{id}/photos", flat.getId())).andReturn()
                .getResponse().getStatus();
        assertThat(photos).isIn(401, 403);
    }

    // Helpers --------------------------------------------------------------------------------

    private String createAs(User who) {
        return createAs(who, flat);
    }

    private String createAs(User who, Property which) {
        signIn(who);
        String token = tokenOf(shareService.create(which.getId()));
        SecurityContextHolder.clearContext();
        return token;
    }

    private String page(String token, String language) throws Exception {
        var request = get("/l/{token}", token);
        if (language != null) {
            request.header(HttpHeaders.ACCEPT_LANGUAGE, language);
        }
        return html(mockMvc.perform(request).andExpect(status().isOk()).andReturn());
    }

    private static String html(MvcResult result) throws Exception {
        return result.getResponse().getContentAsString(StandardCharsets.UTF_8);
    }

    private static String tokenOf(ShareLinkResponse link) {
        return link.getUrl().substring(link.getUrl().lastIndexOf('/') + 1);
    }

    /** Set LISTING_PAGE_SAMPLE to a path to keep a rendered page for looking at by hand. */
    private static void sample(String html) throws Exception {
        String out = System.getenv("LISTING_PAGE_SAMPLE");
        if (out != null && !out.isBlank()) {
            Files.writeString(Path.of(out), html, StandardCharsets.UTF_8);
        }
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private Property listing(String title, User owner, Team where) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Dostyk 5").city("Almaty")
                .description("Bright corner flat with a view of the mountains.")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3).areaSqm(62.5).floor(7).totalFloors(12)
                .agent(owner).team(where).build());
    }

    private User user(String email, String name, String phone, Role role, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name).phone(phone)
                .role(role).dataScope(DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
