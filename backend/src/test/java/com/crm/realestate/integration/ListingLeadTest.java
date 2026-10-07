package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientActivityPropertyRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.LeadRateLimiter;
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
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * "I'm interested" on a listing's public page: a stranger's name and number become a client of
 * the listing's agent, a line in that client's history and a notification — and nothing a
 * stranger sends can overwrite a client, inject markup, or flood the agency. Filters are on.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class ListingLeadTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private ListingShareService shareService;
    @Autowired private LeadRateLimiter rateLimiter;
    @Autowired private PropertyShareLinkRepository linkRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private ClientActivityPropertyRepository activityPropertyRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private Team almaty;
    private User agent;
    private User colleague;
    private Property flat;
    private String token;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        rateLimiter.reset();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("lead-agent@almaty.kz", "Aigul Bekova", Role.AGENT);
        colleague = user("lead-colleague@almaty.kz", "Timur Aliev", Role.AGENT);
        flat = propertyRepository.save(Property.builder()
                .title("Severny Residence, apt 84").address("Dostyk 5").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3)
                .agent(agent).team(almaty).build());
        token = createAs(agent);
    }

    @Test
    @DisplayName("the page carries the form, and its policy lets it post back to this host only")
    void formOnThePage() throws Exception {
        MvcResult result = mockMvc.perform(get("/l/{token}", token)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isOk()).andReturn();
        String html = html(result);
        assertThat(html)
                .contains("<form class=\"lead\" method=\"post\" action=\"" + token + "/interest\"")
                .contains("name=\"name\"").contains("name=\"phone\"").contains("name=\"message\"")
                .contains("type=\"checkbox\" name=\"consent\"")
                .contains("I agree to be contacted about this listing")
                .contains("name=\"website\" type=\"text\" tabindex=\"-1\"")
                .doesNotContain("<script");
        assertThat(result.getResponse().getHeader("Content-Security-Policy"))
                .contains("form-action 'self'").doesNotContain("form-action 'none'")
                .contains("default-src 'none'").contains("frame-ancestors 'none'");
        assertThat(page("ru")).contains("Я согласен(на), чтобы со мной связались");
        assertThat(page("kk")).contains("Осы нысан бойынша менімен байланысуға келісемін");
        sample("lead-form-sample.html", html);
    }

    @Test
    @DisplayName("a valid enquiry makes a buyer for the listing's agent, a history line and a notification")
    void validEnquiry() throws Exception {
        String html = html(mockMvc.perform(lead("Dana Serikova", "+7 701 222-33-44",
                        "Is the price negotiable?", true).header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isOk()).andReturn());
        assertThat(html).contains("Thank you!").contains("Severny Residence, apt 84")
                .contains("href=\"../" + token + "\"");
        sample("lead-thanks-sample.html", html);

        Client client = onlyClient();
        assertThat(client.getFullName()).isEqualTo("Dana Serikova");
        assertThat(client.getType()).isEqualTo(ClientType.BUYER);
        assertThat(client.getSource()).isEqualTo(ClientSource.PUBLIC_LINK);
        assertThat(client.getLeadSource()).isEqualTo(com.crm.realestate.enums.LeadSource.WEBSITE);
        assertThat(client.getLeadSourceDetail()).isEqualTo("Severny Residence, apt 84");
        assertThat(client.getAgent().getId()).isEqualTo(agent.getId());
        assertThat(client.getTeam().getId()).isEqualTo(almaty.getId());
        assertThat(client.getPhoneNormalized()).isEqualTo("77012223344");
        assertThat(client.getNotes()).startsWith("From the public page of Severny Residence, apt 84")
                .contains("Is the price negotiable?");

        ClientActivity activity = onlyActivityOf(client);
        assertThat(activity.getType()).isEqualTo(ActivityType.MESSAGE);
        assertThat(activity.getNote()).isEqualTo("Is the price negotiable?");
        assertThat(activity.getAuthor()).isNull();
        assertThat(activity.getAuthorName()).isEqualTo("Dana Serikova");
        assertThat(activityPropertyRepository.findForActivities(List.of(activity.getId())))
                .extracting(link -> link.getProperty().getId()).containsExactly(flat.getId());

        List<Notification> told = notificationRepository.findByRecipientId(agent.getId());
        assertThat(told).hasSize(1);
        assertThat(told.get(0).getType()).isEqualTo(NotificationType.LISTING_LEAD);
        assertThat(told.get(0).getTargetId()).isEqualTo(client.getId());
        assertThat(told.get(0).getPayload()).contains("\"clientName\":\"Dana Serikova\"")
                .contains("\"propertyTitle\":\"Severny Residence, apt 84\"")
                .contains("\"phone\":\"+7 701 222-33-44\"");

        mockMvc.perform(get("/properties/{id}/share-link", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.leadCount").value(1));
        mockMvc.perform(get("/clients/{id}", client.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.source").value("PUBLIC_LINK"));
        mockMvc.perform(get("/clients").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].source").value("PUBLIC_LINK"))
                .andExpect(jsonPath("$[0].createdAt").exists());
    }

    @Test
    @DisplayName("a number the agency knows reuses that client and changes nothing on the card")
    void knownPhoneReusesClient() throws Exception {
        Client known = clientRepository.save(Client.builder().fullName("Dana (seller)")
                .phone("8 (701) 222 33 44").type(ClientType.SELLER).notes("Keeps a cat")
                .agent(colleague).team(almaty).build());

        mockMvc.perform(lead("Somebody Else", "+7 701 222-33-44", "Call me", true))
                .andExpect(status().isOk());

        assertThat(clientRepository.findAll()).hasSize(1);
        Client after = clientRepository.findById(known.getId()).orElseThrow();
        assertThat(after.getFullName()).isEqualTo("Dana (seller)");
        assertThat(after.getType()).isEqualTo(ClientType.SELLER);
        assertThat(after.getNotes()).isEqualTo("Keeps a cat");
        assertThat(after.getSource()).isEqualTo(ClientSource.MANUAL);
        assertThat(after.getAgent().getId()).isEqualTo(colleague.getId());
        assertThat(onlyActivityOf(after).getNote()).isEqualTo("Call me");
        assertThat(notificationRepository.findByRecipientId(agent.getId()))
                .extracting(Notification::getTargetId).containsExactly(known.getId());
    }

    @Test
    @DisplayName("a filled honeypot gets the thank-you page and writes nothing")
    void honeypot() throws Exception {
        String html = html(mockMvc.perform(post("/l/{token}/interest", token)
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("name", "Bot").param("phone", "+7 701 222-33-44")
                        .param("consent", "yes").param("website", "http://spam.example")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isOk()).andReturn());
        assertThat(html).contains("Thank you!");
        assertNothingWritten();
    }

    @Test
    @DisplayName("a bad form comes back with what was typed, escaped, and what was wrong")
    void validationErrors() throws Exception {
        String html = html(mockMvc.perform(lead("  ", "abc<script>", "<script>alert(1)</script>", false)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isBadRequest()).andReturn());
        assertThat(html).doesNotContain("<script")
                .contains("value=\"abc&lt;script&gt;\"")
                .contains("&lt;script&gt;alert(1)&lt;/script&gt;</textarea>")
                .contains("Please enter your name.").contains("Please enter a phone number")
                .contains("Please agree to be contacted").contains("action=\"interest\"")
                .contains("href=\"../" + token + "\"");
        assertThat(html).doesNotContain("The message is too long.");

        String tooLong = html(mockMvc.perform(lead("Dana", "+7 701 222-33-44", "x".repeat(1001), true)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "en"))
                .andExpect(status().isBadRequest()).andReturn());
        assertThat(tooLong).contains("The message is too long.").contains("value=\"Dana\"")
                .contains(" checked");
        assertNothingWritten();
    }

    @Test
    @DisplayName("markup typed into any field is stored as text and never reaches a page as markup")
    void markupEverywhereIsEscaped() throws Exception {
        flat.setTitle("<script>alert('t')</script> flat");
        propertyRepository.save(flat);
        String html = html(mockMvc.perform(lead("<script>alert(1)</script>", "+7 701 222-33-44",
                "<img src=x onerror=alert(1)>", true)).andExpect(status().isOk()).andReturn());
        assertThat(html).doesNotContain("<script").doesNotContain("<img")
                .contains("&lt;script&gt;alert(&#39;t&#39;)&lt;/script&gt; flat");
        assertThat(onlyClient().getFullName()).isEqualTo("<script>alert(1)</script>");
    }

    @Test
    @DisplayName("five enquiries per address per link in ten minutes, then a polite refusal")
    void perAddressLimit() throws Exception {
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(from("10.0.0.1", lead("Dana", "+7 701 222-33-44", null, true)))
                    .andExpect(status().isOk());
        }
        String html = html(mockMvc.perform(from("10.0.0.1", lead("Dana", "+7 701 222-33-44", null, true)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "en")))
                .andExpect(status().isTooManyRequests()).andReturn());
        assertThat(html).contains("Too many requests").contains("value=\"Dana\"");
        mockMvc.perform(from("10.0.0.2", lead("Dana", "+7 701 222-33-44", null, true)))
                .andExpect(status().isOk());
        assertThat(clientRepository.findAll()).hasSize(1);
        assertThat(linkRepository.findByTokenAndRevokedAtIsNull(token).orElseThrow().getLeadCount())
                .isEqualTo(6);
    }

    @Test
    @DisplayName("fifty enquiries per link a day, whatever the addresses")
    void perLinkLimit() throws Exception {
        for (int i = 0; i < 50; i++) {
            mockMvc.perform(from("10.1.0." + i, lead("Dana", "+7 701 222-33-44", null, true)))
                    .andExpect(status().isOk());
        }
        mockMvc.perform(from("10.2.0.1", lead("Dana", "+7 701 222-33-44", null, true)))
                .andExpect(status().isTooManyRequests());
    }

    @Test
    @DisplayName("a revoked or unknown link answers 404 and writes nothing")
    void revokedLink() throws Exception {
        signIn(agent);
        shareService.revoke(flat.getId());
        SecurityContextHolder.clearContext();

        mockMvc.perform(lead("Dana", "+7 701 222-33-44", null, true)).andExpect(status().isNotFound());
        mockMvc.perform(post("/l/{token}/interest", "nope").contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .param("name", "Dana").param("phone", "+77012223344").param("consent", "yes"))
                .andExpect(status().isNotFound());
        assertNothingWritten();
    }

    @Test
    @DisplayName("an oversized body is refused before any field is read")
    void bodyLimit() throws Exception {
        mockMvc.perform(post("/l/{token}/interest", token)
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .content("name=Dana&phone=%2B77012223344&consent=yes&message=" + "x".repeat(20_000)))
                .andExpect(status().isPayloadTooLarge());
        assertNothingWritten();
    }

    @Test
    @DisplayName("an oversized body says the message is too long, in the reader's language")
    void bodyLimitPage() throws Exception {
        Map<String, String> titles = Map.of("en", "Your message is too long",
                "ru", "Сообщение слишком длинное", "kk", "Хабарлама тым ұзын");
        for (Map.Entry<String, String> title : titles.entrySet()) {
            String page = html(mockMvc.perform(post("/l/{token}/interest", token)
                            .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                            .header(HttpHeaders.ACCEPT_LANGUAGE, title.getKey())
                            .content("name=Dana&message=" + "x".repeat(20_000)))
                    .andExpect(status().isPayloadTooLarge())
                    .andExpect(content().contentTypeCompatibleWith(MediaType.TEXT_HTML))
                    .andReturn());
            assertThat(page).contains(title.getValue()).contains("href=\"../" + token + "\"")
                    .doesNotContain("This link is no longer active");
        }
        assertNothingWritten();
    }

    @Test
    @DisplayName("with the listing's agent gone, the lead goes to whoever made the link")
    void agentGone() throws Exception {
        flat.setAgent(null);
        propertyRepository.save(flat);
        linkRepository.findByTokenAndRevokedAtIsNull(token).orElseThrow();

        mockMvc.perform(lead("Dana", "+7 701 222-33-44", null, true)).andExpect(status().isOk());
        assertThat(onlyClient().getAgent().getId()).isEqualTo(agent.getId());

        agent.setStatus(UserStatus.DEACTIVATED);
        userRepository.save(agent);
        mockMvc.perform(lead("Erlan", "+7 702 000-00-01", null, true)).andExpect(status().isOk());
        Client second = clientRepository.findAll().stream()
                .filter(c -> c.getFullName().equals("Erlan")).findFirst().orElseThrow();
        assertThat(second.getAgent()).isNull();
    }

    @Test
    @DisplayName("the form opens nothing else: the API still wants a token")
    void nothingElseIsPublic() throws Exception {
        assertThat(mockMvc.perform(get("/properties")).andReturn().getResponse().getStatus())
                .isIn(401, 403);
        assertThat(mockMvc.perform(get("/clients")).andReturn().getResponse().getStatus())
                .isIn(401, 403);
        assertThat(mockMvc.perform(post("/clients").contentType(MediaType.APPLICATION_JSON)
                .content("{}")).andReturn().getResponse().getStatus()).isIn(401, 403);
        String reopened = html(mockMvc.perform(get("/l/{token}/interest", token))
                .andExpect(status().isOk()).andReturn());
        assertThat(reopened).contains("action=\"interest\"");
        mockMvc.perform(get("/l/{token}/interest", "nope")).andExpect(status().isNotFound());    }

    private MockHttpServletRequestBuilder lead(String name, String phone, String message,
            boolean consent) {
        MockHttpServletRequestBuilder request = post("/l/{token}/interest", token)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .param("name", name).param("phone", phone).param("website", "");
        if (message != null) {
            request.param("message", message);
        }
        if (consent) {
            request.param("consent", "yes");
        }
        return request;
    }

    private static MockHttpServletRequestBuilder from(String address,
            MockHttpServletRequestBuilder request) {
        return request.with(r -> {
            r.setRemoteAddr(address);
            return r;
        });
    }

    private void assertNothingWritten() {
        assertThat(clientRepository.findAll()).isEmpty();
        assertThat(activityRepository.findAll()).isEmpty();
        assertThat(notificationRepository.findByRecipientId(agent.getId())).isEmpty();
        assertThat(linkRepository.findAll()).allMatch(link -> link.getLeadCount() == 0);
    }

    private Client onlyClient() {
        List<Client> all = clientRepository.findAll();
        assertThat(all).hasSize(1);
        return all.get(0);
    }

    private ClientActivity onlyActivityOf(Client client) {
        List<ClientActivity> mine = activityRepository.findAll().stream()
                .filter(a -> a.getClient().getId().equals(client.getId())).toList();
        assertThat(mine).hasSize(1);
        return mine.get(0);
    }

    private String page(String language) throws Exception {
        return html(mockMvc.perform(get("/l/{token}", token)
                .header(HttpHeaders.ACCEPT_LANGUAGE, language)).andReturn());
    }

    private String createAs(User who) {
        signIn(who);
        String url = shareService.create(flat.getId()).getUrl();
        SecurityContextHolder.clearContext();
        return url.substring(url.lastIndexOf('/') + 1);
    }

    private User user(String email, String name, Role role) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name).phone("+7 701 555-12-34")
                .role(role).dataScope(DataScope.TEAM).team(almaty)
                .status(UserStatus.ACTIVE).isActive(true).build());
    }

    private String bearer(User who) {
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private static String html(MvcResult result) throws Exception {
        return result.getResponse().getContentAsString(StandardCharsets.UTF_8);
    }

    /** Set LEAD_PAGE_SAMPLE_DIR to a directory to keep the rendered pages for looking at. */
    private static void sample(String name, String html) throws Exception {
        String dir = System.getenv("LEAD_PAGE_SAMPLE_DIR");
        if (dir != null && !dir.isBlank()) {
            Files.writeString(Path.of(dir, name), html, StandardCharsets.UTF_8);
        }
    }
}
