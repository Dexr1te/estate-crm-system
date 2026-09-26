package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientActivityRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.dto.response.PropertyMatch;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityPropertyRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.ClientActivityService;
import com.crm.realestate.service.MatchingService;
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
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * What was sent, remembered: an entry in a client's history can name the listings it was about, and
 * the buyer's match list says when each one last went out.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ActivityPropertiesTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ClientActivityService activityService;
    @Autowired private MatchingService matchingService;

    @Autowired private ClientActivityPropertyRepository linkRepository;
    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private Team almaty;
    private Team astana;
    private User manager;
    private User agent;
    private User colleague;
    private User stranger;
    private User admin;
    private Client aigerim;
    private Client daniyar;
    private Property dostyk;
    private Property abay;
    private Property theirs;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        linkRepository.deleteAll();
        activityRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);
        admin = user("owner@estatecrm.app", "Owner", Role.ADMIN, DataScope.TEAM, null);

        aigerim = buyer("Aigerim", agent, almaty);
        daniyar = buyer("Daniyar", colleague, almaty);

        dostyk = listing("Dostyk 5, apt 12", colleague, almaty);
        abay = listing("Abay 44, apt 3", agent, almaty);
        theirs = listing("Kabanbay 10", stranger, astana);
    }

    // Linking ---------------------------------------------------------------------------

    @Test
    @DisplayName("a message names the listings it sent, and reads back with their titles")
    void storesAndReturnsListings() throws Exception {
        signIn(agent);

        mockMvc.perform(post("/clients/" + aigerim.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"propertyIds\":[" + abay.getId() + ","
                                + dostyk.getId() + "," + abay.getId() + "]}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.properties.length()").value(2))
                .andExpect(jsonPath("$.properties[0].title").value("Dostyk 5, apt 12"))
                .andExpect(jsonPath("$.properties[1].id").value(abay.getId()));

        flushAndClear();
        mockMvc.perform(get("/clients/" + aigerim.getId() + "/activities"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].properties.length()").value(2))
                .andExpect(jsonPath("$[0].properties[1].title").value("Abay 44, apt 3"));
    }

    @Test
    @DisplayName("an entry with no listings reads back with an empty list, not null")
    void noListingsIsEmpty() throws Exception {
        signIn(agent);
        mockMvc.perform(post("/clients/" + aigerim.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"CALL\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.properties.length()").value(0));
    }

    @Test
    @DisplayName("another agency's listing, or one that does not exist, answers not found and logs nothing")
    void foreignListingIsRefused() throws Exception {
        signIn(agent);

        mockMvc.perform(post("/clients/" + aigerim.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"propertyIds\":[" + abay.getId() + ","
                                + theirs.getId() + "]}"))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/clients/" + aigerim.getId() + "/activities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"propertyIds\":[999999]}"))
                .andExpect(status().isNotFound());

        assertThat(activityRepository.count()).isZero();
        assertThat(linkRepository.count()).isZero();
    }

    @Test
    @DisplayName("an admin, who sees every listing, still cannot tie one agency's listing to another's client")
    void crossAgencyIsRefusedEvenForAdmin() {
        signIn(admin);
        assertThatThrownBy(() -> activityService.create(aigerim.getId(),
                request(ActivityType.MESSAGE, null, List.of(theirs.getId()))))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // Last sent on the match list ---------------------------------------------------

    @Test
    @DisplayName("a match says when it last went to this buyer — the latest time, and only this buyer's")
    void lastSentAtIsLatestAndPerClient() {
        LocalDateTime now = LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS);
        signIn(agent);
        activityService.create(aigerim.getId(),
                request(ActivityType.MESSAGE, now.minusDays(5), List.of(dostyk.getId(), abay.getId())));
        activityService.create(aigerim.getId(),
                request(ActivityType.MESSAGE, now.minusDays(1), List.of(dostyk.getId())));
        signIn(colleague);
        activityService.create(daniyar.getId(),
                request(ActivityType.MESSAGE, now.minusHours(1), List.of(abay.getId())));
        flushAndClear();

        signIn(agent);
        List<PropertyMatch> forAigerim = matchingService.propertiesFor(aigerim.getId());
        assertThat(sentAt(forAigerim, dostyk)).isEqualTo(now.minusDays(1));
        assertThat(sentAt(forAigerim, abay))
                .as("Daniyar being sent it an hour ago says nothing about Aigerim")
                .isEqualTo(now.minusDays(5));

        signIn(colleague);
        List<PropertyMatch> forDaniyar = matchingService.propertiesFor(daniyar.getId());
        assertThat(sentAt(forDaniyar, dostyk)).isNull();
        assertThat(sentAt(forDaniyar, abay)).isEqualTo(now.minusHours(1));
    }

    @Test
    @DisplayName("over HTTP the match carries lastSentAt")
    void lastSentAtOverHttp() throws Exception {
        signIn(agent);
        activityService.create(aigerim.getId(), request(ActivityType.MESSAGE, null, List.of(abay.getId())));
        flushAndClear();

        mockMvc.perform(get("/clients/" + aigerim.getId() + "/matches"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.property.id == " + abay.getId() + ")].lastSentAt").isNotEmpty())
                .andExpect(jsonPath("$[?(@.property.id == " + dostyk.getId() + ")].lastSentAt").value(
                        org.hamcrest.Matchers.contains((Object) null)));
    }

    @Test
    @DisplayName("matches and history cost the same number of statements for one sent listing or thirty")
    void queryCountStaysFlat() {
        signIn(agent);
        List<Long> many = IntStream.range(0, 30)
                .mapToObj(i -> listing("Seeded " + i, agent, almaty).getId())
                .toList();
        activityService.create(aigerim.getId(), request(ActivityType.MESSAGE, null, List.of(abay.getId())));
        long matchesWithOne = countStatements(() -> matchingService.propertiesFor(aigerim.getId()));
        long historyWithOne = countStatements(() -> activityService.list(aigerim.getId()));

        IntStream.range(0, 5).forEach(i ->
                activityService.create(aigerim.getId(), request(ActivityType.MESSAGE, null, many)));
        long matchesWithMany = countStatements(() -> matchingService.propertiesFor(aigerim.getId()));
        long historyWithMany = countStatements(() -> activityService.list(aigerim.getId()));

        assertThat(matchingService.propertiesFor(aigerim.getId())).hasSizeGreaterThan(30);
        assertThat(matchesWithMany).isEqualTo(matchesWithOne);
        assertThat(historyWithMany).isEqualTo(historyWithOne);
    }

    // Correcting an entry -------------------------------------------------------------

    @Test
    @DisplayName("the author can correct the kind, the note and when it happened; listings stay unless replaced")
    void authorCanEdit() throws Exception {
        signIn(agent);
        Long id = activityService.create(aigerim.getId(),
                request(ActivityType.CALL, null, List.of(abay.getId()))).getId();
        LocalDateTime yesterday = LocalDateTime.now().minusDays(1).truncatedTo(ChronoUnit.SECONDS);

        mockMvc.perform(put("/clients/" + aigerim.getId() + "/activities/" + id)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"note\":\"Sent it on WhatsApp\",\"occurredAt\":\""
                                + yesterday + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("MESSAGE"))
                .andExpect(jsonPath("$.note").value("Sent it on WhatsApp"))
                .andExpect(jsonPath("$.properties.length()").value(1));

        mockMvc.perform(put("/clients/" + aigerim.getId() + "/activities/" + id)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"type\":\"MESSAGE\",\"propertyIds\":[" + dostyk.getId() + "]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.properties.length()").value(1))
                .andExpect(jsonPath("$.properties[0].id").value(dostyk.getId()));

        flushAndClear();
        ClientActivityResponse stored = activityService.list(aigerim.getId()).get(0);
        assertThat(stored.getOccurredAt()).as("omitted occurredAt keeps the corrected time").isEqualTo(yesterday);
        assertThat(stored.getNote()).isNull();
        assertThat(stored.getProperties()).extracting(ClientActivityResponse.PropertyRef::getId)
                .containsExactly(dostyk.getId());
    }

    @Test
    @DisplayName("a colleague cannot rewrite someone else's entry; a manager can")
    void editRights() {
        signIn(colleague);
        Long id = activityService.create(daniyar.getId(), request(ActivityType.CALL, null, null)).getId();

        User other = user("other@almaty.kz", "Other Agent", Role.AGENT, DataScope.TEAM, almaty);
        signIn(other);
        assertThatThrownBy(() -> activityService.update(daniyar.getId(), id,
                request(ActivityType.EMAIL, null, null)))
                .isInstanceOf(AccessDeniedException.class);

        signIn(manager);
        assertThat(activityService.update(daniyar.getId(), id, request(ActivityType.EMAIL, null, null))
                .getType()).isEqualTo(ActivityType.EMAIL);

        signIn(stranger);
        assertThatThrownBy(() -> activityService.update(daniyar.getId(), id,
                request(ActivityType.NOTE, null, null)))
                .as("another agency does not even see the client")
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("an edit cannot move the time into the future")
    void editRejectsFuture() {
        signIn(agent);
        Long id = activityService.create(aigerim.getId(), request(ActivityType.CALL, null, null)).getId();
        assertThatThrownBy(() -> activityService.update(aigerim.getId(), id,
                request(ActivityType.CALL, LocalDateTime.now().plusHours(2), null)))
                .hasMessageContaining("before it has happened");
    }

    // Cascades ------------------------------------------------------------------------

    @Test
    @DisplayName("deleting a listing drops it from the entries that sent it; the entry stays")
    void deletingAListingCascades() {
        signIn(agent);
        Long id = activityService.create(aigerim.getId(),
                request(ActivityType.MESSAGE, null, List.of(abay.getId(), dostyk.getId()))).getId();
        flushAndClear();

        propertyRepository.deleteById(abay.getId());
        flushAndClear();

        assertThat(activityRepository.findById(id)).isPresent();
        assertThat(activityService.list(aigerim.getId()).get(0).getProperties())
                .extracting(ClientActivityResponse.PropertyRef::getId)
                .containsExactly(dostyk.getId());
    }

    @Test
    @DisplayName("deleting an entry takes its links with it")
    void deletingAnEntryCascades() {
        signIn(agent);
        Long id = activityService.create(aigerim.getId(),
                request(ActivityType.MESSAGE, null, List.of(abay.getId(), dostyk.getId()))).getId();
        flushAndClear();
        assertThat(linkRepository.count()).isEqualTo(2);

        activityService.delete(aigerim.getId(), id);
        flushAndClear();

        assertThat(linkRepository.count()).isZero();
        assertThat(propertyRepository.findById(abay.getId())).isPresent();
    }

    // Helpers -------------------------------------------------------------------------

    private static LocalDateTime sentAt(List<PropertyMatch> matches, Property listing) {
        return matches.stream()
                .filter(m -> m.getProperty().getId().equals(listing.getId()))
                .findFirst().orElseThrow()
                .getLastSentAt();
    }

    private long countStatements(Runnable read) {
        entityManager.flush();
        entityManager.clear();
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        stats.clear();
        read.run();
        return stats.getPrepareStatementCount();
    }

    private void flushAndClear() {
        entityManager.flush();
        entityManager.clear();
    }

    private static ClientActivityRequest request(ActivityType type, LocalDateTime when, List<Long> propertyIds) {
        ClientActivityRequest request = new ClientActivityRequest();
        request.setType(type);
        request.setOccurredAt(when);
        request.setPropertyIds(propertyIds);
        return request;
    }

    private Client buyer(String name, User holder, Team team) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .budgetMax(new BigDecimal("100000000"))
                .agent(holder).team(team).build());
    }

    private Property listing(String title, User holder, Team team) {
        return propertyRepository.save(Property.builder()
                .title(title).city("Almaty").address(title)
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("30000000")).rooms(2).areaSqm(60.0)
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
