package com.crm.realestate.integration;

import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPriceChangeRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.PropertyService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * What a listing used to cost.
 *
 * <p>A listing holds one price, so a reduction used to overwrite the old figure without a trace. An
 * edit that moves the price now leaves a row; one that does not, and the listing's creation, leave
 * nothing. The history is seen by whoever can see the listing, outlives the colleague who made the
 * change, and the list reads the latest change without a round trip per row.
 */
@SpringBootTest
@Transactional
class PropertyPriceHistoryTest {

    @Autowired private PropertyService propertyService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private PropertyPriceChangeRepository priceChangeRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private User agent;
    private User colleague;
    private User stranger;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        priceChangeRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estate.crm");

        Team almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("agent@almaty.kz", almaty);
        colleague = user("colleague@almaty.kz", almaty);
        stranger = user("manager@astana.kz", astana);
        signIn(agent);
    }

    @Test
    @DisplayName("an edit that moves the price is recorded with who made it")
    void aReductionIsRecorded() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));

        PropertyResponse updated = propertyService.update(listing.getId(), request("Dostyk 210", "46500000"));

        List<PropertyPriceChangeResponse> history = propertyService.priceHistory(listing.getId());
        assertThat(history).hasSize(1);
        assertThat(history.get(0).getOldPrice()).isEqualByComparingTo("50000000");
        assertThat(history.get(0).getNewPrice()).isEqualByComparingTo("46500000");
        assertThat(history.get(0).getChangedById()).isEqualTo(agent.getId());
        assertThat(history.get(0).getChangedByName()).isEqualTo(agent.getFullName());
        assertThat(history.get(0).getChangedAt()).isNotNull();

        assertThat(updated.getPrice()).isEqualByComparingTo("46500000");
        assertThat(updated.getPreviousPrice()).isEqualByComparingTo("50000000");
        assertThat(updated.getPriceChangedAt()).isEqualTo(history.get(0).getChangedAt());
    }

    @Test
    @DisplayName("re-saving the same figure, however it is written, is not a change")
    void anEqualPriceIsNotRecorded() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));

        propertyService.update(listing.getId(), request("Dostyk 210, renamed", "50000000.00"));

        assertThat(propertyService.priceHistory(listing.getId())).isEmpty();
        assertThat(propertyService.getById(listing.getId()).getPreviousPrice()).isNull();
    }

    @Test
    @DisplayName("creating a listing is not a change of price")
    void creationIsNotRecorded() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));

        assertThat(listing.getPreviousPrice()).isNull();
        assertThat(listing.getPriceChangedAt()).isNull();
        assertThat(propertyService.priceHistory(listing.getId())).isEmpty();
    }

    @Test
    @DisplayName("the history reads newest first, and the listing carries the latest")
    void historyIsNewestFirst() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));
        propertyService.update(listing.getId(), request("Dostyk 210", "48000000"));
        propertyService.update(listing.getId(), request("Dostyk 210", "49000000"));
        propertyService.update(listing.getId(), request("Dostyk 210", "45000000"));

        assertThat(propertyService.priceHistory(listing.getId()))
                .extracting(c -> c.getNewPrice().intValue())
                .containsExactly(45000000, 49000000, 48000000);
        assertThat(propertyService.getById(listing.getId()).getPreviousPrice())
                .isEqualByComparingTo("49000000");
        assertThat(propertyService.getAll()).singleElement()
                .satisfies(p -> assertThat(p.getPreviousPrice()).isEqualByComparingTo("49000000"));
    }

    @Test
    @DisplayName("the history is the agency's, and another agency is told the listing does not exist")
    void historyStaysInTheAgency() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));
        propertyService.update(listing.getId(), request("Dostyk 210", "46000000"));

        signIn(colleague);
        assertThat(propertyService.priceHistory(listing.getId())).hasSize(1);

        signIn(stranger);
        assertThatThrownBy(() -> propertyService.priceHistory(listing.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("the change outlives the colleague who made it")
    void deletingTheAuthorKeepsTheHistory() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));
        signIn(colleague);
        propertyService.update(listing.getId(), request("Dostyk 210", "46000000"));

        accountRemovalService.remove(agent, colleague, null, "DELETE_USER");
        entityManager.flush();
        entityManager.clear();

        signIn(agent);
        List<PropertyPriceChangeResponse> history = propertyService.priceHistory(listing.getId());
        assertThat(history).hasSize(1);
        assertThat(history.get(0).getChangedById()).isNull();
        assertThat(history.get(0).getChangedByName()).isNull();
        assertThat(history.get(0).getNewPrice()).isEqualByComparingTo("46000000");
    }

    @Test
    @DisplayName("deleting the listing takes its history with it")
    void deletingTheListingDropsTheHistory() {
        PropertyResponse listing = propertyService.create(request("Dostyk 210", "50000000"));
        propertyService.update(listing.getId(), request("Dostyk 210", "46000000"));
        entityManager.flush();
        entityManager.clear();

        propertyService.delete(listing.getId());
        entityManager.flush();

        assertThat(priceChangeRepository.count()).isZero();
    }

    @Test
    @DisplayName("the list reads each listing's latest change at a fixed cost")
    void listingDoesNotScaleWithRowCount() {
        seedReducedListings(3);
        long fewAll = countStatements(() -> propertyService.getAll());
        long fewPage = countStatements(this::pageOfListings);

        seedReducedListings(12);
        long manyAll = countStatements(() -> propertyService.getAll());
        long manyPage = countStatements(this::pageOfListings);

        assertThat(manyAll).as("3 listings took %d statements, 15 took %d", fewAll, manyAll)
                .isEqualTo(fewAll);
        assertThat(manyPage).as("a page of 3 took %d statements, of 15 took %d", fewPage, manyPage)
                .isEqualTo(fewPage);
        assertThat(manyAll).isLessThanOrEqualTo(3);

        assertThat(propertyService.getAll())
                .hasSize(15)
                .allSatisfy(p -> assertThat(p.getPreviousPrice()).isEqualByComparingTo("50000000"));
    }

    // Helpers -------------------------------------------------------------------------

    private void pageOfListings() {
        propertyService.search(null, null, null, null, null, null, null, null, PageRequest.of(0, 50));
    }

    private void seedReducedListings(int count) {
        IntStream.range(0, count).forEach(i -> {
            PropertyResponse listing = propertyService.create(request("Listing " + i, "50000000"));
            propertyService.update(listing.getId(), request("Listing " + i, "47000000"));
        });
        entityManager.flush();
        entityManager.clear();
    }

    private long countStatements(Runnable read) {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        read.run();
        return stats.getPrepareStatementCount();
    }

    private PropertyRequest request(String title, String price) {
        PropertyRequest request = new PropertyRequest();
        request.setTitle(title);
        request.setAddress(title);
        request.setType(PropertyType.APARTMENT);
        request.setStatus(PropertyStatus.AVAILABLE);
        request.setPrice(new BigDecimal(price));
        return request;
    }

    private User user(String email, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName("Agent " + email)
                .role(Role.AGENT).dataScope(DataScope.OWN).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
