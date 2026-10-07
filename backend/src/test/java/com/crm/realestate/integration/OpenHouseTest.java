package com.crm.realestate.integration;

import com.crm.realestate.dto.request.OpenHouseRequest;
import com.crm.realestate.dto.request.OpenHouseVisitorRequest;
import com.crm.realestate.dto.response.ClientActivityResponse;
import com.crm.realestate.dto.response.OpenHouseResponse;
import com.crm.realestate.dto.response.OpenHouseVisitorResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.OpenHouseInterest;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.OpenHouseRepository;
import com.crm.realestate.repository.OpenHouseVisitorRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.ClientActivityService;
import com.crm.realestate.service.ClientDuplicateService;
import com.crm.realestate.service.OpenHouseService;
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
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Open houses: scheduled on a listing, a sign-in sheet that turns each number into the agency's
 * client — a new buyer or the one it already knows — and a line in that client's history, and a
 * summary afterwards. Everything stays inside the agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class OpenHouseTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private OpenHouseService openHouseService;
    @Autowired private ClientActivityService activityService;
    @Autowired private ClientDuplicateService duplicateService;
    @Autowired private RecordHandoverService handoverService;
    @Autowired private OpenHouseRepository openHouseRepository;
    @Autowired private OpenHouseVisitorRepository visitorRepository;
    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User colleague;
    private User teamAgent;
    private User manager;
    private User stranger;
    private Property flat;
    private LocalDateTime saturday;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("oh-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("oh-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        teamAgent = user("oh-team@almaty.kz", "Dana Seitova", Role.AGENT, DataScope.TEAM, almaty);
        manager = user("oh-manager@almaty.kz", "Marat Manager", Role.MANAGER, DataScope.TEAM, almaty);
        stranger = user("oh-stranger@astana.kz", "Erlan Other", Role.MANAGER, DataScope.TEAM, astana);
        flat = propertyRepository.save(Property.builder()
                .title("Severny Residence, apt 84").address("Dostyk 5").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3)
                .agent(agent).team(almaty).build());
        saturday = LocalDateTime.now().plusDays(3).withHour(12).withMinute(0).withSecond(0).withNano(0);
        signIn(agent);
    }

    // Scheduling ------------------------------------------------------------------------

    @Test
    @DisplayName("an open house is scheduled on a listing, held by whoever scheduled it")
    void schedule() {
        OpenHouseResponse created = openHouseService.create(flat.getId(), request(saturday, 3, "Bring the keys"));

        assertThat(created.getPropertyId()).isEqualTo(flat.getId());
        assertThat(created.getPropertyTitle()).isEqualTo("Severny Residence, apt 84");
        assertThat(created.getPropertyAddress()).isEqualTo("Dostyk 5");
        assertThat(created.getAgentId()).isEqualTo(agent.getId());
        assertThat(created.getAgentName()).isEqualTo("Aigul Bekova");
        assertThat(created.getStartsAt()).isEqualTo(saturday);
        assertThat(created.getEndsAt()).isEqualTo(saturday.plusHours(3));
        assertThat(created.getNote()).isEqualTo("Bring the keys");
        assertThat(created.isCanEdit()).isTrue();
        assertThat(created.getVisitorCount()).isZero();
        assertThat(created.getVisitors()).isNull();

        OpenHouseResponse read = openHouseService.get(created.getId());
        assertThat(read.getVisitors()).isEmpty();
        assertThat(openHouseService.forProperty(flat.getId())).extracting(OpenHouseResponse::getId)
                .containsExactly(created.getId());
    }

    @Test
    @DisplayName("an open house ends after it starts, and within twelve hours")
    void timesAreChecked() throws Exception {
        mockMvc.perform(post("/properties/{id}/open-houses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(timesJson(saturday, saturday)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("ENDS_BEFORE_START"));
        mockMvc.perform(post("/properties/{id}/open-houses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(timesJson(saturday, saturday.plusHours(13))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OPEN_HOUSE_TOO_LONG"));
        mockMvc.perform(post("/properties/{id}/open-houses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(timesJson(saturday, saturday.plusHours(2))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.agentId").value(agent.getId()))
                .andExpect(jsonPath("$.visitors").doesNotExist());
        assertThat(openHouseRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("the host or a manager moves it; a colleague may not")
    void onlyTheHostOrAManagerMovesIt() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        signIn(colleague);
        assertThat(openHouseService.get(id).isCanEdit()).isFalse();
        assertThatThrownBy(() -> openHouseService.update(id, request(saturday.plusDays(1), 2, null)))
                .isInstanceOf(AccessDeniedException.class);
        assertThatThrownBy(() -> openHouseService.delete(id)).isInstanceOf(AccessDeniedException.class);

        signIn(manager);
        OpenHouseResponse moved = openHouseService.update(id, request(saturday.plusDays(1), 4, "Moved"));
        assertThat(moved.getStartsAt()).isEqualTo(saturday.plusDays(1));
        assertThat(moved.getEndsAt()).isEqualTo(saturday.plusDays(1).plusHours(4));
        assertThat(moved.getNote()).isEqualTo("Moved");
        assertThat(moved.getAgentId()).as("moving it does not change who holds it").isEqualTo(agent.getId());
    }

    // The sign-in sheet -----------------------------------------------------------------

    @Test
    @DisplayName("a number nobody knows becomes a new buyer of the host, with the visit in its history")
    void aNewNumberIsANewBuyer() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        OpenHouseVisitorResponse visitor = openHouseService.signIn(id,
                visitor("  Saule Nurlanova ", "+7 701 555 12 34", OpenHouseInterest.INTERESTED, "Wants a quiet floor"));

        assertThat(visitor.isNewClient()).isTrue();
        assertThat(visitor.isClientVisible()).isTrue();
        assertThat(visitor.getFullName()).isEqualTo("Saule Nurlanova");
        assertThat(visitor.getInterest()).isEqualTo(OpenHouseInterest.INTERESTED);
        assertThat(visitor.getSignedInById()).isEqualTo(agent.getId());
        assertThat(visitor.isCanRemove()).isTrue();

        Client client = clientRepository.findById(visitor.getClientId()).orElseThrow();
        assertThat(client.getFullName()).isEqualTo("Saule Nurlanova");
        assertThat(client.getType()).isEqualTo(ClientType.BUYER);
        assertThat(client.getSource()).isEqualTo(ClientSource.OPEN_HOUSE);
        assertThat(client.getAgent().getId()).isEqualTo(agent.getId());
        assertThat(client.getTeam().getId()).isEqualTo(almaty.getId());

        List<ClientActivityResponse> history = activityService.list(client.getId());
        assertThat(history).singleElement().satisfies(entry -> {
            assertThat(entry.getOpenHouseId()).isEqualTo(id);
            assertThat(entry.getNote()).isEqualTo("Wants a quiet floor");
            assertThat(entry.getAuthorId()).isEqualTo(agent.getId());
            assertThat(entry.getProperties()).extracting(ClientActivityResponse.PropertyRef::getId)
                    .containsExactly(flat.getId());
        });
    }

    @Test
    @DisplayName("a number the agency knows is that client, left as it is, with the visit in its history")
    void aKnownNumberIsTheSameClient() {
        Client known = clientRepository.save(Client.builder()
                .fullName("Saule N.").phone("8 (701) 555-12-34").type(ClientType.SELLER)
                .agent(colleague).team(almaty).build());
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        OpenHouseVisitorResponse visitor = openHouseService.signIn(id,
                visitor("Saule Nurlanova", "+77015551234", null, null));

        assertThat(visitor.isNewClient()).isFalse();
        assertThat(visitor.getClientId()).isEqualTo(known.getId());
        assertThat(visitor.isClientVisible())
                .as("a colleague's client, and this agent sees only their own").isFalse();
        assertThat(visitor.getClientName()).isNull();
        assertThat(visitor.getClientAgentName()).isEqualTo("Timur Aliev");
        assertThat(clientRepository.count()).isEqualTo(1);

        Client after = clientRepository.findById(known.getId()).orElseThrow();
        assertThat(after.getFullName()).isEqualTo("Saule N.");
        assertThat(after.getType()).isEqualTo(ClientType.SELLER);
        assertThat(after.getAgent().getId()).isEqualTo(colleague.getId());

        signIn(colleague);
        assertThat(activityService.list(known.getId())).singleElement()
                .satisfies(entry -> assertThat(entry.getOpenHouseId()).isEqualTo(id));
    }

    @Test
    @DisplayName("the same number twice at one open house is refused, however it is written")
    void oneSignInPerNumber() throws Exception {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        openHouseService.signIn(id, visitor("Saule", "+7 701 555 12 34", null, null));

        mockMvc.perform(post("/open-houses/{id}/visitors", id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"fullName\":\"Saule again\",\"phone\":\"87015551234\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_SIGNED_IN"));
        mockMvc.perform(post("/open-houses/{id}/visitors", id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"fullName\":\"Nobody\",\"phone\":\"12-34\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_PHONE"));
        mockMvc.perform(post("/open-houses/{id}/visitors", id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"fullName\":\"Arman\",\"phone\":\"+7 702 111 22 33\",\"interest\":\"JUST_LOOKING\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.interest").value("JUST_LOOKING"))
                .andExpect(jsonPath("$.newClient").value(true));
        assertThat(visitorRepository.count()).isEqualTo(2);
    }

    @Test
    @DisplayName("the summary counts visitors, new clients and the interested, on the event and in lists")
    void summary() {
        clientRepository.save(Client.builder().fullName("Known").phone("+7 701 000 00 01")
                .type(ClientType.BUYER).agent(agent).team(almaty).build());
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        Long other = openHouseService.create(flat.getId(), request(saturday.plusDays(7), 2, null)).getId();
        openHouseService.signIn(id, visitor("Known", "+7 701 000 00 01", OpenHouseInterest.INTERESTED, null));
        openHouseService.signIn(id, visitor("New one", "+7 701 000 00 02", OpenHouseInterest.INTERESTED, null));
        openHouseService.signIn(id, visitor("New two", "+7 701 000 00 03", OpenHouseInterest.JUST_LOOKING, null));
        openHouseService.signIn(id, visitor("New three", "+7 701 000 00 04", null, null));

        OpenHouseResponse read = openHouseService.get(id);
        assertThat(read.getVisitorCount()).isEqualTo(4);
        assertThat(read.getNewClientCount()).isEqualTo(3);
        assertThat(read.getInterestedCount()).isEqualTo(2);
        assertThat(read.getVisitors()).extracting(OpenHouseVisitorResponse::getFullName)
                .containsExactly("New three", "New two", "New one", "Known");

        assertThat(openHouseService.forProperty(flat.getId()))
                .extracting(OpenHouseResponse::getId, OpenHouseResponse::getVisitorCount,
                        OpenHouseResponse::getNewClientCount, OpenHouseResponse::getInterestedCount)
                .containsExactly(
                        org.assertj.core.groups.Tuple.tuple(other, 0L, 0L, 0L),
                        org.assertj.core.groups.Tuple.tuple(id, 4L, 3L, 2L));
    }

    @Test
    @DisplayName("a colleague at the door can sign people in, and take off only the ones they signed in")
    void aColleagueAtTheDoor() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        OpenHouseVisitorResponse byHost = openHouseService.signIn(id, visitor("A", "+7 701 000 00 11", null, null));

        signIn(colleague);
        OpenHouseVisitorResponse byColleague = openHouseService.signIn(id, visitor("B", "+7 701 000 00 12", null, null));
        Client madeByColleague = clientRepository.findById(byColleague.getClientId()).orElseThrow();
        assertThat(madeByColleague.getAgent().getId()).as("the new buyer is the host's").isEqualTo(agent.getId());
        assertThat(openHouseService.get(id).getVisitors())
                .extracting(OpenHouseVisitorResponse::getFullName, OpenHouseVisitorResponse::isCanRemove)
                .containsExactly(org.assertj.core.groups.Tuple.tuple("B", true),
                        org.assertj.core.groups.Tuple.tuple("A", false));
        assertThatThrownBy(() -> openHouseService.removeVisitor(id, byHost.getId()))
                .isInstanceOf(AccessDeniedException.class);

        openHouseService.removeVisitor(id, byColleague.getId());
        entityManager.flush();
        entityManager.clear();
        assertThat(visitorRepository.findById(byColleague.getId())).isEmpty();
        assertThat(clientRepository.findById(madeByColleague.getId()))
                .as("the client the sign-in made stays in the book").isPresent();
        signIn(agent);
        assertThat(activityService.list(madeByColleague.getId()))
                .as("but the visit leaves its history").isEmpty();
    }

    @Test
    @DisplayName("an open house with visitors is not deleted; an empty one is")
    void deletingNeedsAnEmptySheet() throws Exception {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        Long empty = openHouseService.create(flat.getId(), request(saturday.plusDays(1), 2, null)).getId();
        openHouseService.signIn(id, visitor("A", "+7 701 000 00 21", null, null));

        mockMvc.perform(delete("/open-houses/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OPEN_HOUSE_HAS_VISITORS"));
        mockMvc.perform(delete("/open-houses/{id}", empty).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNoContent());
        assertThat(openHouseRepository.findById(empty)).isEmpty();
        assertThat(openHouseRepository.findById(id)).isPresent();
    }

    // The calendar ----------------------------------------------------------------------

    @Test
    @DisplayName("the calendar shows the open houses overlapping its window that the caller's scope reaches")
    void calendarWindow() throws Exception {
        Long mine = openHouseService.create(flat.getId(), request(saturday, 3, null)).getId();
        signIn(colleague);
        Long theirs = openHouseService.create(flat.getId(), request(saturday.plusHours(1), 2, null)).getId();
        openHouseService.create(flat.getId(), request(saturday.plusDays(40), 2, null));

        signIn(agent);
        assertThat(openHouseService.inRange(saturday.minusDays(1), saturday.plusDays(1)))
                .extracting(OpenHouseResponse::getId).containsExactly(mine);
        assertThat(openHouseService.inRange(saturday.plusHours(2), saturday.plusDays(1)))
                .as("one that started before the window but is still on")
                .extracting(OpenHouseResponse::getId).containsExactly(mine);

        signIn(teamAgent);
        assertThat(openHouseService.inRange(saturday.minusDays(1), saturday.plusDays(1)))
                .extracting(OpenHouseResponse::getId).containsExactly(mine, theirs);

        mockMvc.perform(get("/open-houses").param("from", saturday.toString())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isBadRequest());
        mockMvc.perform(get("/open-houses")
                        .param("from", saturday.minusDays(1).toString())
                        .param("to", saturday.plusDays(1).toString())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].propertyTitle").value("Severny Residence, apt 84"))
                .andExpect(jsonPath("$[0].visitors").doesNotExist());
    }

    // The agency's walls ----------------------------------------------------------------

    @Test
    @DisplayName("another agency is told the open house and the listing do not exist")
    void anotherAgencySeesNothing() throws Exception {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        signIn(stranger);
        assertThatThrownBy(() -> openHouseService.get(id)).isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> openHouseService.forProperty(flat.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> openHouseService.create(flat.getId(), request(saturday, 2, null)))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> openHouseService.signIn(id, visitor("X", "+7 701 999 99 99", null, null)))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> openHouseService.update(id, request(saturday, 2, null)))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> openHouseService.delete(id)).isInstanceOf(ResourceNotFoundException.class);
        assertThat(openHouseService.inRange(saturday.minusDays(1), saturday.plusDays(1))).isEmpty();

        mockMvc.perform(get("/open-houses/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        assertThat(visitorRepository.count()).isZero();
    }

    @Test
    @DisplayName("a number another agency knows is a new buyer here, and their client is untouched")
    void matchingStaysInTheAgency() {
        Client theirs = clientRepository.save(Client.builder().fullName("Theirs").phone("+7 701 444 44 44")
                .type(ClientType.BUYER).agent(stranger).team(stranger.getTeam()).build());
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        OpenHouseVisitorResponse visitor = openHouseService.signIn(id, visitor("Visitor", "87014444444", null, null));

        assertThat(visitor.isNewClient()).isTrue();
        assertThat(visitor.getClientId()).isNotEqualTo(theirs.getId());
        assertThat(activityRepository.findByClientNewestFirst(theirs.getId())).isEmpty();
    }

    @Test
    @DisplayName("without a team the open houses are shut, like the rest of the CRM")
    void teamRequired() throws Exception {
        User loner = user("oh-loner@nowhere.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        mockMvc.perform(get("/open-houses").param("from", saturday.toString())
                        .param("to", saturday.plusDays(1).toString())
                        .header(HttpHeaders.AUTHORIZATION, bearer(loner)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // What happens to it later ----------------------------------------------------------

    @Test
    @DisplayName("deleting the listing takes its open houses, and the visits stay in clients' histories")
    void deletingTheListing() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        Long clientId = openHouseService.signIn(id, visitor("A", "+7 701 000 00 31", null, "Liked it")).getClientId();
        entityManager.flush();
        entityManager.clear();

        propertyRepository.deleteById(flat.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(openHouseRepository.count()).isZero();
        assertThat(visitorRepository.count()).isZero();
        assertThat(activityService.list(clientId)).singleElement().satisfies(entry -> {
            assertThat(entry.getNote()).isEqualTo("Liked it");
            assertThat(entry.getOpenHouseId()).isNull();
        });
    }

    @Test
    @DisplayName("merging two cards moves the sheet's lines to the card that stays")
    void mergeMovesTheSheet() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();
        Long source = openHouseService.signIn(id, visitor("A", "+7 701 000 00 41", null, null)).getClientId();
        Client target = clientRepository.save(Client.builder().fullName("A, properly").phone("+7 701 000 00 42")
                .type(ClientType.BUYER).agent(agent).team(almaty).build());

        signIn(manager);
        duplicateService.merge(target.getId(), source);
        entityManager.flush();
        entityManager.clear();

        assertThat(openHouseService.get(id).getVisitors()).singleElement()
                .satisfies(v -> assertThat(v.getClientId()).isEqualTo(target.getId()));
    }

    @Test
    @DisplayName("when the host leaves, the open houses go to whoever takes over their records")
    void handover() {
        Long id = openHouseService.create(flat.getId(), request(saturday, 2, null)).getId();

        handoverService.reassignTeamRecords(agent, colleague, almaty);
        entityManager.flush();
        entityManager.clear();

        signIn(colleague);
        OpenHouseResponse read = openHouseService.get(id);
        assertThat(read.getAgentId()).isEqualTo(colleague.getId());
        assertThat(read.isCanEdit()).isTrue();
    }

    private static OpenHouseRequest request(LocalDateTime start, int hours, String note) {
        OpenHouseRequest request = new OpenHouseRequest();
        request.setStartsAt(start);
        request.setEndsAt(start.plusHours(hours));
        request.setNote(note);
        return request;
    }

    private static OpenHouseVisitorRequest visitor(String name, String phone, OpenHouseInterest interest, String note) {
        OpenHouseVisitorRequest request = new OpenHouseVisitorRequest();
        request.setFullName(name);
        request.setPhone(phone);
        request.setInterest(interest);
        request.setNote(note);
        return request;
    }

    private static String timesJson(LocalDateTime start, LocalDateTime end) {
        return "{\"startsAt\":\"" + start + "\",\"endsAt\":\"" + end + "\"}";
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
