package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyShareLink;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.service.exports.ExportFilters;
import com.crm.realestate.service.exports.ExportKind;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.util.UUID;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Guards the cost of an export the way {@code DealQueryCountTest} guards the deal list: an agent
 * name, a client name or a listing title read lazily off every row would turn fifty thousand rows
 * into fifty thousand round trips. Statements are counted, not milliseconds.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ExportQueryCountTest extends CsvExportFixture {

    @Autowired private EntityManagerFactory entityManagerFactory;
    @Autowired private EntityManager entityManager;
    @Autowired private PropertyShareLinkRepository shareLinkRepository;

    @ParameterizedTest
    @EnumSource(ExportKind.class)
    @DisplayName("exporting costs the same number of statements however many rows there are")
    void flat(ExportKind kind) throws Exception {
        signIn(manager);
        seed(3);
        long few = statements(kind);
        seed(30);
        long many = statements(kind);
        assertThat(many)
                .as("%s: %d statements with few rows, %d with many", kind, few, many)
                .isEqualTo(few)
                .isPositive()
                .isLessThanOrEqualTo(6);
    }

    private long statements(ExportKind kind) throws Exception {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.flush();
        entityManager.clear();
        stats.clear();
        var plan = exportService.prepare(kind, ExportFilters.none(), "ru", null);
        exportService.write(plan, new ByteArrayOutputStream());
        return stats.getPrepareStatementCount();
    }

    /** Rows held by two different agents, each deal with its own client and listing. */
    private void seed(int count) {
        IntStream.range(0, count).forEach(i -> {
            var holder = i % 2 == 0 ? agent : manager;
            Client client = clientRepository.save(Client.builder().fullName("Client " + i)
                    .type(ClientType.BUYER).agent(holder).team(almaty).build());
            Property property = propertyRepository.save(Property.builder().title("Listing " + i)
                    .address("Street " + i).type(PropertyType.APARTMENT)
                    .status(PropertyStatus.AVAILABLE).price(BigDecimal.TEN)
                    .agent(holder).team(almaty).build());
            shareLinkRepository.save(PropertyShareLink.builder().property(property)
                    .token(UUID.randomUUID().toString()).createdAt(java.time.LocalDateTime.now())
                    .viewCount(i).build());
            dealRepository.save(Deal.builder().title("Deal " + i).status(DealStatus.LEAD)
                    .client(client).property(property).agent(holder).team(almaty).build());
        });
    }
}
