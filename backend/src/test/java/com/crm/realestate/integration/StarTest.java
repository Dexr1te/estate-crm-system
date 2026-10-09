package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Star;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.StarType;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.CommissionSplitRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.StarRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.StarService;
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
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Starred records: each person's own, only on what they may read, the same star however often it
 * is asked for, a list that keeps to what is still in view, and nothing left behind by a record
 * that is deleted.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class StarTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private StarService starService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private StarRepository starRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private CommissionSplitRepository splitRepository;
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
    private Client agentsClient;
    private Client colleaguesClient;
    private Property colleaguesListing;
    private Deal colleaguesDeal;
    private Client strangersClient;
    private Property strangersListing;
    private Deal strangersDeal;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("st-manager@almaty.kz", "Marat Manager", Role.MANAGER, almaty);
        agent = user("st-agent@almaty.kz", "Aigul Bekova", Role.AGENT, almaty);
        colleague = user("st-colleague@almaty.kz", "Timur Aliev", Role.AGENT, almaty);
        stranger = user("st-stranger@astana.kz", "Erlan Other", Role.AGENT, astana);
        admin = user("st-admin@estate.crm", "Platform Admin", Role.ADMIN, null);

        agentsClient = client("Aliya Nurlanovna", "+7 701 000 00 01", agent);
        colleaguesClient = client("Dana Seitova", null, colleague);
        colleaguesClient.setEmail("dana@mail.kz");
        clientRepository.save(colleaguesClient);
        colleaguesListing = listing("Abay 10, flat 4", "Abay avenue 10", colleague);
        colleaguesDeal = deal("Dana buys Abay 10", colleaguesClient, colleaguesListing, colleague);
        strangersClient = client("Someone Else", "+7 702 000 00 02", stranger);
        strangersListing = listing("Kenesary 5", "Kenesary street 5", stranger);
        strangersDeal = deal("Astana deal", strangersClient, strangersListing, stranger);
        flush();
    }

    // Starring and unstarring ------------------------------------------------------------

    @Test
    @DisplayName("starring twice is one star with one moment, and the list names the record")
    void starIsIdempotent() throws Exception {
        String first = as(agent, put("/stars/CLIENT/" + agentsClient.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("CLIENT"))
                .andExpect(jsonPath("$.id").value(agentsClient.getId()))
                .andExpect(jsonPath("$.title").value("Aliya Nurlanovna"))
                .andExpect(jsonPath("$.subtitle").value("+7 701 000 00 01"))
                .andReturn().getResponse().getContentAsString();
        flush();
        String again = as(agent, put("/stars/client/" + agentsClient.getId()))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(again).isEqualTo(first);
        assertThat(starRepository.findAll()).hasSize(1);
        as(agent, get("/stars"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].type").value("CLIENT"))
                .andExpect(jsonPath("$[0].title").value("Aliya Nurlanovna"))
                .andExpect(jsonPath("$[0].subtitle").value("+7 701 000 00 01"));
    }

    @Test
    @DisplayName("unstarring twice, or what was never starred, is fine, and touches only the caller's star")
    void unstarIsIdempotent() throws Exception {
        as(agent, put("/stars/PROPERTY/" + colleaguesListing.getId())).andExpect(status().isOk());
        as(manager, put("/stars/PROPERTY/" + colleaguesListing.getId())).andExpect(status().isOk());

        as(agent, delete("/stars/PROPERTY/" + colleaguesListing.getId())).andExpect(status().isNoContent());
        as(agent, delete("/stars/PROPERTY/" + colleaguesListing.getId())).andExpect(status().isNoContent());
        as(agent, delete("/stars/DEAL/" + strangersDeal.getId())).andExpect(status().isNoContent());
        flush();

        assertThat(starRepository.findAll()).extracting(s -> s.getUser().getId())
                .containsExactly(manager.getId());
        as(agent, get("/stars")).andExpect(jsonPath("$", hasSize(0)));
        as(manager, get("/stars")).andExpect(jsonPath("$", hasSize(1)));
    }

    @Test
    @DisplayName("another agency's client, listing or deal answers 404 and nothing is starred")
    void otherAgency() throws Exception {
        as(agent, put("/stars/CLIENT/" + strangersClient.getId())).andExpect(status().isNotFound());
        as(manager, put("/stars/PROPERTY/" + strangersListing.getId())).andExpect(status().isNotFound());
        as(manager, put("/stars/DEAL/" + strangersDeal.getId())).andExpect(status().isNotFound());
        as(manager, put("/stars/DEAL/987654")).andExpect(status().isNotFound());
        assertThat(starRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("an agent on their own records stars what they read: not a colleague's client or deal, "
            + "but any listing of the agency and a deal they share in")
    void dataScope() throws Exception {
        as(agent, put("/stars/CLIENT/" + colleaguesClient.getId())).andExpect(status().isNotFound());
        as(agent, put("/stars/DEAL/" + colleaguesDeal.getId())).andExpect(status().isNotFound());
        as(agent, put("/stars/PROPERTY/" + colleaguesListing.getId())).andExpect(status().isOk());
        as(manager, put("/stars/CLIENT/" + colleaguesClient.getId())).andExpect(status().isOk());

        splitRepository.save(CommissionSplit.builder()
                .deal(colleaguesDeal).user(agent).sharePercent(new BigDecimal("30")).position(0).build());
        flush();
        as(agent, put("/stars/DEAL/" + colleaguesDeal.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Dana buys Abay 10"))
                .andExpect(jsonPath("$.subtitle").value("Dana Seitova"));
    }

    @Test
    @DisplayName("a type that is not a client, a property or a deal is refused with a code; "
            + "somebody with no agency is sent to get one")
    void refusals() throws Exception {
        as(agent, put("/stars/MEETING/" + agentsClient.getId()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("STAR_TYPE_UNKNOWN"));
        User loner = user("st-loner@nowhere.kz", "Loner", Role.AGENT, null);
        as(loner, get("/stars"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // The list ---------------------------------------------------------------------------

    @Test
    @DisplayName("the list is newest first with each record's two lines, and skips what was deleted "
            + "or left the caller's sight")
    void listKeepsToWhatIsInView() throws Exception {
        LocalDateTime now = LocalDateTime.of(2026, 10, 9, 12, 30, 15);
        Client leaving = client("Moving Away", "+7 703 000 00 03", colleague);
        Client gone = client("Long Gone", "+7 704 000 00 04", colleague);
        star(manager, StarType.CLIENT, colleaguesClient.getId(), now.minusMinutes(5));
        star(manager, StarType.PROPERTY, colleaguesListing.getId(), now.minusMinutes(4));
        star(manager, StarType.DEAL, colleaguesDeal.getId(), now.minusMinutes(3));
        star(manager, StarType.CLIENT, leaving.getId(), now.minusMinutes(2));
        star(manager, StarType.CLIENT, gone.getId(), now.minusMinutes(1));
        // Another person's stars are theirs alone.
        star(agent, StarType.CLIENT, agentsClient.getId(), now);

        leaving.setTeam(astana);
        leaving.setAgent(stranger);
        clientRepository.save(leaving);
        // Straight through the repository: the read alone has to keep it out.
        clientRepository.delete(gone);
        flush();

        as(manager, get("/stars"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(3)))
                .andExpect(jsonPath("$[0].type").value("DEAL"))
                .andExpect(jsonPath("$[0].id").value(colleaguesDeal.getId()))
                .andExpect(jsonPath("$[0].subtitle").value("Dana Seitova"))
                .andExpect(jsonPath("$[0].starredAt").value(now.minusMinutes(3).toString()))
                .andExpect(jsonPath("$[1].type").value("PROPERTY"))
                .andExpect(jsonPath("$[1].title").value("Abay 10, flat 4"))
                .andExpect(jsonPath("$[1].subtitle").value("Abay avenue 10"))
                .andExpect(jsonPath("$[2].type").value("CLIENT"))
                .andExpect(jsonPath("$[2].title").value("Dana Seitova"))
                .andExpect(jsonPath("$[2].subtitle").value("dana@mail.kz"));
    }

    @Test
    @DisplayName("a client handed to a colleague drops out of an agent's list, and comes back with it")
    void scopeChangesAreFollowed() throws Exception {
        as(agent, put("/stars/CLIENT/" + agentsClient.getId())).andExpect(status().isOk());

        agentsClient.setAgent(colleague);
        clientRepository.save(agentsClient);
        flush();
        as(agent, get("/stars")).andExpect(jsonPath("$", hasSize(0)));
        assertThat(starRepository.findAll()).hasSize(1);

        Client back = clientRepository.findById(agentsClient.getId()).orElseThrow();
        back.setAgent(agent);
        clientRepository.save(back);
        flush();
        as(agent, get("/stars")).andExpect(jsonPath("$", hasSize(1)));
    }

    // Deleting records -------------------------------------------------------------------

    @Test
    @DisplayName("deleting a client, a listing or a deal takes everybody's stars on it, and only those")
    void deleteTakesTheStars() throws Exception {
        Client spare = client("Spare Client", "+7 705 000 00 05", colleague);
        Property spareListing = listing("Spare flat", "Spare street 1", colleague);
        flush();
        for (User who : List.of(manager, colleague)) {
            as(who, put("/stars/CLIENT/" + spare.getId())).andExpect(status().isOk());
            as(who, put("/stars/PROPERTY/" + spareListing.getId())).andExpect(status().isOk());
            as(who, put("/stars/DEAL/" + colleaguesDeal.getId())).andExpect(status().isOk());
        }
        as(manager, put("/stars/CLIENT/" + colleaguesClient.getId())).andExpect(status().isOk());
        flush();

        as(admin, delete("/clients/" + spare.getId())).andExpect(status().isNoContent());
        as(manager, delete("/properties/" + spareListing.getId())).andExpect(status().isNoContent());
        as(admin, delete("/deals/" + colleaguesDeal.getId())).andExpect(status().isNoContent());
        flush();

        List<Star> left = starRepository.findAll();
        assertThat(left).hasSize(1);
        assertThat(left.get(0).getEntityType()).isEqualTo(StarType.CLIENT);
        assertThat(left.get(0).getEntityId()).isEqualTo(colleaguesClient.getId());
    }

    @Test
    @DisplayName("merging two cards moves the stars to the card that stays, once per person")
    void mergeMovesTheStars() throws Exception {
        Client duplicate = client("Aliya N.", "+7 701 000 00 01", agent);
        flush();
        as(manager, put("/stars/CLIENT/" + duplicate.getId())).andExpect(status().isOk());
        as(manager, put("/stars/CLIENT/" + agentsClient.getId())).andExpect(status().isOk());
        as(agent, put("/stars/CLIENT/" + duplicate.getId())).andExpect(status().isOk());
        flush();

        as(manager, post("/clients/" + agentsClient.getId() + "/merge")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"sourceId\":" + duplicate.getId() + "}"))
                .andExpect(status().isOk());
        flush();

        List<Star> stars = starRepository.findAll();
        assertThat(stars).hasSize(2);
        assertThat(stars).allSatisfy(s -> {
            assertThat(s.getEntityType()).isEqualTo(StarType.CLIENT);
            assertThat(s.getEntityId()).isEqualTo(agentsClient.getId());
        });
        assertThat(stars).extracting(s -> s.getUser().getId())
                .containsExactlyInAnyOrder(manager.getId(), agent.getId());
    }

    @Test
    @DisplayName("a closed account's stars go with it")
    void accountClosed() throws Exception {
        as(colleague, put("/stars/CLIENT/" + colleaguesClient.getId())).andExpect(status().isOk());
        as(manager, put("/stars/CLIENT/" + colleaguesClient.getId())).andExpect(status().isOk());
        flush();

        accountRemovalService.remove(admin, userRepository.findById(colleague.getId()).orElseThrow(),
                agent.getId(), "DELETE_USER");
        flush();

        assertThat(starRepository.findAll()).extracting(s -> s.getUser().getId())
                .containsExactly(manager.getId());
    }

    // Cost -------------------------------------------------------------------------------

    @Test
    @DisplayName("listing stars costs the same few statements however many there are")
    void listingDoesNotScaleWithStars() {
        seedStarred(2);
        long few = statementsListing();
        assertThat(starService.list(manager)).hasSize(6);

        seedStarred(10);
        long many = statementsListing();
        assertThat(starService.list(manager)).hasSize(36);

        assertThat(many)
                .as("6 stars took %d statements, 36 took %d: a record is being read per star", few, many)
                .isEqualTo(few);
        assertThat(many)
                .as("the stars, then one query per type")
                .isLessThanOrEqualTo(4);
    }

    private void seedStarred(int perType) {
        for (int i = 0; i < perType; i++) {
            Client c = client("Buyer " + i, "+7 700 " + i, colleague);
            Property p = listing("Flat " + i, "Street " + i, colleague);
            Deal d = deal("Deal " + i, c, p, colleague);
            star(manager, StarType.CLIENT, c.getId(), null);
            star(manager, StarType.PROPERTY, p.getId(), null);
            star(manager, StarType.DEAL, d.getId(), null);
        }
        flush();
    }

    private long statementsListing() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        starService.list(manager);
        return stats.getPrepareStatementCount();
    }

    private void star(User who, StarType type, Long id, LocalDateTime at) {
        starRepository.save(Star.builder().user(who).entityType(type).entityId(id).createdAt(at).build());
    }

    private Client client(String name, String phone, User holder) {
        return clientRepository.save(Client.builder()
                .fullName(name).phone(phone).type(ClientType.BUYER)
                .agent(holder).team(holder.getTeam()).build());
    }

    private Property listing(String title, String address, User holder) {
        return propertyRepository.save(Property.builder()
                .title(title).address(address).city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("45000000"))
                .agent(holder).team(holder.getTeam()).build());
    }

    private Deal deal(String title, Client client, Property property, User holder) {
        return dealRepository.save(Deal.builder()
                .title(title).status(DealStatus.NEGOTIATION)
                .client(client).property(property)
                .agent(holder).team(holder.getTeam()).build());
    }

    private User user(String email, String name, Role role, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role)
                .dataScope(switch (role) {
                    case AGENT -> DataScope.OWN;
                    case MANAGER -> DataScope.TEAM;
                    case ADMIN -> DataScope.ALL;
                })
                .team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private ResultActions as(User who, MockHttpServletRequestBuilder request) throws Exception {
        return mockMvc.perform(request.header(HttpHeaders.AUTHORIZATION, bearer(who)));
    }

    /** The token alone decides who is asking: the filter keeps an authentication already there. */
    private String bearer(User who) {
        SecurityContextHolder.clearContext();
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void flush() {
        entityManager.flush();
        entityManager.clear();
    }
}
