package com.crm.realestate.integration;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.stream.IntStream;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
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
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DealService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

/**
 * Guards the cost of listing deals.
 *
 * <p>Every response field that reads through a lazy association — client name, property title,
 * agent name — is one more round trip. On a database in the same container that is invisible;
 * against Neon in another region every one of them pays cross-cloud latency, so a list of thirty
 * deals turns into seconds. This measures statements rather than milliseconds, so it fails on the
 * cause instead of flaking on a slow machine.
 */
@SpringBootTest
@Transactional
class DealQueryCountTest {

    @Autowired private DealService dealService;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private EntityManagerFactory entityManagerFactory;
    @Autowired private EntityManager entityManager;

    private User agent;

    @BeforeEach
    void setUp() {
        dealRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();

        agent = userRepository.save(User.builder()
                .fullName("Aigerim Serikbaykyzy")
                .email("agent@estate.crm")
                .password("x")
                .role(Role.ADMIN)
                .dataScope(DataScope.ALL)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .build());

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
    }

    private void seedDeals(int count) {
        IntStream.range(0, count).forEach(i -> {
            Client client = clientRepository.save(Client.builder()
                    .fullName("Client " + i)
                    .type(ClientType.BUYER)
                    .agent(agent)
                    .build());
            Property property = propertyRepository.save(Property.builder()
                    .title("Property " + i)
                    .address("Somewhere " + i)
                    .type(PropertyType.APARTMENT)
                    .status(PropertyStatus.AVAILABLE)
                    .price(new java.math.BigDecimal("1000000"))
                    .agent(agent)
                    .build());
            dealRepository.save(Deal.builder()
                    .title("Deal " + i)
                    .status(DealStatus.LEAD)
                    .client(client)
                    .property(property)
                    .agent(agent)
                    .build());
        });
        entityManager.flush();
        entityManager.clear();
    }

    private long countStatementsListingDeals() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        dealService.getAll();
        return stats.getPrepareStatementCount();
    }

    @Test
    @DisplayName("listing deals costs the same number of queries however many there are")
    void listingDoesNotScaleWithRowCount() {
        seedDeals(3);
        long few = countStatementsListingDeals();

        seedDeals(12);
        long many = countStatementsListingDeals();

        assertThat(many)
                .as("3 deals took %d statements, 15 took %d — the response reads client, "
                        + "property and agent off every row, so the cost grows with the list",
                        few, many)
                .isEqualTo(few);
    }

    @Test
    @DisplayName("a page of deals is a small, fixed number of statements")
    void listingIsCheap() {
        seedDeals(20);
        assertThat(countStatementsListingDeals())
                .as("20 deals should not need dozens of round trips")
                .isLessThanOrEqualTo(4);
    }
}
