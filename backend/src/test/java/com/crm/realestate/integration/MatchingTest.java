package com.crm.realestate.integration;

import com.crm.realestate.dto.response.ClientMatch;
import com.crm.realestate.dto.response.PropertyMatch;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.MatchingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * What to show this buyer.
 *
 * <p>A requirement nobody stated must not narrow anything, a stated one must not
 * be ignored, and a listing a little over the ceiling has to come back marked
 * rather than hidden — an agent shows those and lets the buyer decide. The rest
 * is the wall every read here stands behind: another agency's listings are not
 * matched against these buyers, and an agent on own-data scope is not handed a
 * colleague's client.
 */
@SpringBootTest
@Transactional
class MatchingTest {

    @Autowired private MatchingService    matchingService;
    @Autowired private ClientRepository   clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository     userRepository;
    @Autowired private TeamRepository     teamRepository;

    private User agent;
    private Team team;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("agent@estate.crm", DataScope.TEAM, team);
        signIn(agent);
    }

    @Test
    @DisplayName("a listing has to answer every requirement the buyer stated")
    void everyStatedRequirementCounts() {
        Client buyer = buyer(b -> {
            b.setWantedCity("Almaty");
            b.setWantedType(PropertyType.APARTMENT);
            b.setBudgetMax(new BigDecimal("30000000"));
            b.setMinRooms(2);
            b.setMinAreaSqm(55.0);
        });

        Property fits = listing("Severny Residence, apt 84", "Almaty",
                PropertyType.APARTMENT, "28000000", 3, 62.0);
        listing("Talgar house", "Talgar", PropertyType.HOUSE, "25000000", 4, 120.0);
        listing("Studio downtown", "Almaty", PropertyType.APARTMENT, "19000000", 1, 34.0);
        listing("Penthouse", "Almaty", PropertyType.APARTMENT, "90000000", 5, 210.0);

        List<PropertyMatch> matches = matchingService.propertiesFor(buyer.getId());

        assertThat(matches).hasSize(1);
        assertThat(matches.get(0).getProperty().getId()).isEqualTo(fits.getId());
        assertThat(matches.get(0).isOverBudget()).isFalse();
    }

    @Test
    @DisplayName("a requirement left empty narrows nothing")
    void anUnstatedRequirementIsNotARequirement() {
        Client buyer = buyer(b -> b.setBudgetMax(new BigDecimal("30000000")));

        listing("Apartment", "Almaty", PropertyType.APARTMENT, "28000000", 1, 30.0);
        listing("House", "Talgar", PropertyType.HOUSE, "12000000", 6, 180.0);
        listing("Office", "Astana", PropertyType.COMMERCIAL, "29000000", null, null);

        assertThat(matchingService.propertiesFor(buyer.getId()))
                .as("only the ceiling was stated, so city, type, rooms and area must not filter")
                .hasSize(3);
    }

    @Test
    @DisplayName("a listing just over the ceiling comes back marked, and last")
    void slightlyOverBudgetIsShownNotHidden() {
        Client buyer = buyer(b -> b.setBudgetMax(new BigDecimal("30000000")));

        listing("Inside budget", "Almaty", PropertyType.APARTMENT, "29000000", 2, 60.0);
        listing("A little over", "Almaty", PropertyType.APARTMENT, "31000000", 2, 60.0);
        listing("Far over", "Almaty", PropertyType.APARTMENT, "40000000", 2, 60.0);

        List<PropertyMatch> matches = matchingService.propertiesFor(buyer.getId());

        assertThat(matches).hasSize(2);
        assertThat(matches.get(0).getProperty().getTitle()).isEqualTo("Inside budget");
        assertThat(matches.get(0).isOverBudget()).isFalse();
        assertThat(matches.get(1).getProperty().getTitle()).isEqualTo("A little over");
        assertThat(matches.get(1).isOverBudget())
                .as("the agent needs to see that it is over before quoting it")
                .isTrue();
    }

    @Test
    @DisplayName("only listings that are actually for sale are matched")
    void soldAndReservedListingsAreNotOffered() {
        Client buyer = buyer(b -> b.setBudgetMax(new BigDecimal("30000000")));

        Property sold = listing("Sold already", "Almaty",
                PropertyType.APARTMENT, "20000000", 2, 60.0);
        sold.setStatus(PropertyStatus.SOLD);
        propertyRepository.save(sold);

        assertThat(matchingService.propertiesFor(buyer.getId())).isEmpty();
    }

    @Test
    @DisplayName("a buyer with no requirements gets nothing, not everything")
    void silenceIsNotAWildcard() {
        Client buyer = buyer(b -> {});
        listing("Apartment", "Almaty", PropertyType.APARTMENT, "28000000", 2, 60.0);

        assertThat(matchingService.propertiesFor(buyer.getId()))
                .as("handing over the whole catalogue as matches would be noise")
                .isEmpty();
    }

    @Test
    @DisplayName("a seller is not matched against listings")
    void sellersHaveNoWishList() {
        Client seller = clientRepository.save(Client.builder()
                .fullName("Seller").type(ClientType.SELLER)
                .budgetMax(new BigDecimal("30000000"))
                .agent(agent).team(team).build());
        listing("Apartment", "Almaty", PropertyType.APARTMENT, "28000000", 2, 60.0);

        assertThat(matchingService.propertiesFor(seller.getId())).isEmpty();
    }

    @Test
    @DisplayName("the mirror: a listing names the buyers who asked for it")
    void aListingFindsItsBuyers() {
        Client wants = buyer(b -> {
            b.setWantedCity("Almaty");
            b.setBudgetMax(new BigDecimal("30000000"));
            b.setMinRooms(2);
        });
        buyer(b -> {
            b.setFullName("Wrong city");
            b.setWantedCity("Astana");
            b.setBudgetMax(new BigDecimal("30000000"));
        });
        buyer(b -> b.setFullName("No requirements"));

        Property listing = listing("Severny Residence, apt 84", "Almaty",
                PropertyType.APARTMENT, "28000000", 3, 62.0);

        List<ClientMatch> interested = matchingService.buyersFor(listing.getId());

        assertThat(interested).hasSize(1);
        assertThat(interested.get(0).getClient().getId()).isEqualTo(wants.getId());
    }

    @Test
    @DisplayName("a requirement the listing cannot answer rules the buyer out")
    void anUnknownFigureIsNotAMatch() {
        buyer(b -> b.setMinRooms(2));

        Property noRooms = listing("Land plot", "Almaty",
                PropertyType.COMMERCIAL, "9000000", null, null);

        assertThat(matchingService.buyersFor(noRooms.getId()))
                .as("a listing that does not say how many rooms it has cannot be said to have two")
                .isEmpty();
    }

    @Test
    @DisplayName("another agency's listings are not matched against these buyers")
    void agenciesDoNotMatchAcrossTheWall() {
        Client buyer = buyer(b -> b.setBudgetMax(new BigDecimal("30000000")));

        Team other = teamRepository.save(Team.builder().name("Astana Estate").build());
        User stranger = user("stranger@other.crm", DataScope.TEAM, other);
        propertyRepository.save(Property.builder()
                .title("Their listing").city("Almaty").address("x")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("20000000")).rooms(2).areaSqm(60.0)
                .agent(stranger).team(other).build());

        assertThat(matchingService.propertiesFor(buyer.getId())).isEmpty();
    }

    @Test
    @DisplayName("an own-scope agent cannot match a colleague's client")
    void ownScopeStopsAtTheColleaguesClient() {
        Client colleaguesBuyer = buyer(b -> b.setBudgetMax(new BigDecimal("30000000")));

        User loner = user("loner@estate.crm", DataScope.OWN, team);
        signIn(loner);

        assertThatThrownBy(() -> matchingService.propertiesFor(colleaguesBuyer.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    private Client buyer(java.util.function.Consumer<Client> requirements) {
        Client buyer = Client.builder()
                .fullName("Irina Sokolova").type(ClientType.BUYER)
                .agent(agent).team(team).build();
        requirements.accept(buyer);
        return clientRepository.save(buyer);
    }

    private Property listing(String title, String city, PropertyType type,
                             String price, Integer rooms, Double area) {
        return propertyRepository.save(Property.builder()
                .title(title).city(city).address(title)
                .type(type).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal(price)).rooms(rooms).areaSqm(area)
                .agent(agent).team(team).build());
    }

    private User user(String email, DataScope scope, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(scope).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
