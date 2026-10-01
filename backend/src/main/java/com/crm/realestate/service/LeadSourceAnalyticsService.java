package com.crm.realestate.service;

import com.crm.realestate.dto.response.LeadSourceBreakdown;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.LeadSource;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Tuple;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Which channels bring clients in, and which of them end in a sale.
 *
 * <p>Scoped like the funnel, through the dashboard's {@code narrowed()}: an agent counts their own
 * clients, a manager the agency's, an admin everyone's, and {@code agentId} only narrows that.
 * One grouped statement, however many clients there are.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LeadSourceAnalyticsService {

    private final DashboardService dashboardService;
    private final SecurityUtils    securityUtils;
    private final EntityManager    entityManager;

    public LeadSourceBreakdown breakdown(LocalDate from, LocalDate to, Long agentId) {
        LocalDate start = from != null ? from : LocalDate.now().withDayOfMonth(1);
        LocalDate end = to != null ? to : start.plusMonths(1);
        if (!start.isBefore(end)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PERIOD",
                    "The period has to end after it starts");
        }
        User currentUser = securityUtils.getCurrentUser();
        LocalDateTime startAt = start.atStartOfDay();
        LocalDateTime endAt = end.atStartOfDay();
        Specification<Client> clients = dashboardService.<Client>narrowed(currentUser, agentId, null)
                .and((root, query, cb) -> cb.and(
                        cb.greaterThanOrEqualTo(root.get("createdAt"), startAt),
                        cb.lessThan(root.get("createdAt"), endAt)));

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Client> root = query.from(Client.class);

        Subquery<Long> wonDeal = query.subquery(Long.class);
        Root<Deal> deal = wonDeal.from(Deal.class);
        wonDeal.select(deal.get("id")).where(
                cb.equal(deal.get("client"), root),
                cb.equal(deal.get("status"), DealStatus.CLOSED_WON));

        Expression<LeadSource> source = root.get("leadSource");
        query.multiselect(
                source.alias("source"),
                cb.count(root).alias("clients"),
                cb.sum(cb.<Long>selectCase().when(cb.exists(wonDeal), 1L).otherwise(0L)).alias("won"));
        query.where(clients.toPredicate(root, query, cb));
        query.groupBy(source);

        List<LeadSourceBreakdown.Row> rows = new ArrayList<>();
        long total = 0;
        long won = 0;
        for (Tuple row : entityManager.createQuery(query).getResultList()) {
            LeadSource s = row.get("source", LeadSource.class);
            long n = asLong(row.get("clients"));
            long w = asLong(row.get("won"));
            total += n;
            won += w;
            rows.add(LeadSourceBreakdown.Row.builder()
                    .source(s == null ? LeadSourceBreakdown.UNKNOWN : s.name())
                    .clients(n)
                    .won(w)
                    .conversionRate(n == 0 ? 0 : (double) w / n)
                    .build());
        }
        // Most clients first; ties in the enum's order, with unknown last.
        rows.sort((a, b) -> a.getClients() != b.getClients()
                ? Long.compare(b.getClients(), a.getClients())
                : Integer.compare(order(a.getSource()), order(b.getSource())));

        return LeadSourceBreakdown.builder()
                .from(start)
                .to(end)
                .clients(total)
                .won(won)
                .sources(rows)
                .build();
    }

    private static int order(String source) {
        return LeadSourceBreakdown.UNKNOWN.equals(source) ? Integer.MAX_VALUE : LeadSource.valueOf(source).ordinal();
    }

    private static long asLong(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }
}
