package com.crm.realestate.service;

import com.crm.realestate.dto.response.FunnelResponse;
import com.crm.realestate.dto.response.FunnelResponse.LostReasonShare;
import com.crm.realestate.dto.response.FunnelResponse.MonthPoint;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealStatusChange;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Tuple;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The deal funnel, computed in the database over exactly the deals the dashboard would count.
 *
 * <p>Scoping is the dashboard's own {@code narrowed()}: an agent sees their own figures, a manager
 * their agency's, an admin everyone's, and {@code agentId} only ever narrows that — asking about
 * someone in another agency yields zeros. Five statements, however many deals there are.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AnalyticsService {

    static final int MONTHS = 6;
    static final String UNSPECIFIED = "UNSPECIFIED";

    private final DashboardService dashboardService;
    private final SecurityUtils    securityUtils;
    private final EntityManager    entityManager;

    public FunnelResponse funnel(LocalDate from, LocalDate to, Long agentId) {
        LocalDate today = LocalDate.now();
        LocalDate start = from != null ? from : today.withDayOfMonth(1);
        LocalDate end = to != null ? to : start.plusMonths(1);
        if (!start.isBefore(end)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PERIOD",
                    "The period has to end after it starts");
        }

        User currentUser = securityUtils.getCurrentUser();
        Specification<Deal> visible = dashboardService.narrowed(currentUser, agentId, null);
        LocalDateTime startAt = start.atStartOfDay();
        LocalDateTime endAt = end.atStartOfDay();
        Specification<Deal> inPeriod = visible.and((root, query, cb) -> cb.and(
                cb.greaterThanOrEqualTo(root.get("createdAt"), startAt),
                cb.lessThan(root.get("createdAt"), endAt)));

        FunnelResponse res = totals(inPeriod);
        res.setFrom(start);
        res.setTo(end);
        res.setAvgDaysToWin(avgDaysToWin(inPeriod));
        res.setLostReasons(lostReasons(inPeriod, res.getLost()));
        res.setMonthly(monthly(visible, today.withDayOfMonth(1).minusMonths(MONTHS - 1)));
        return res;
    }

    /**
     * Counts and the won value in one statement. A deal reached negotiation if it is there now, was
     * won (nobody wins without negotiating), or its history shows it passed through. A deal lost
     * before history was kept, with no row saying otherwise, counts as lost straight from lead.
     */
    private FunnelResponse totals(Specification<Deal> deals) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Deal> root = query.from(Deal.class);

        Subquery<Long> passedNegotiation = query.subquery(Long.class);
        Root<DealStatusChange> change = passedNegotiation.from(DealStatusChange.class);
        passedNegotiation.select(change.get("id")).where(
                cb.equal(change.get("deal"), root),
                cb.equal(change.get("toStatus"), DealStatus.NEGOTIATION));

        Expression<DealStatus> status = root.get("status");
        Predicate isWon = cb.equal(status, DealStatus.CLOSED_WON);
        Predicate isLost = cb.equal(status, DealStatus.CLOSED_LOST);
        Predicate reached = cb.or(
                status.in(DealStatus.NEGOTIATION, DealStatus.CLOSED_WON),
                cb.exists(passedNegotiation));

        query.multiselect(
                cb.count(root).alias("created"),
                cb.sum(cb.<Long>selectCase().when(reached, 1L).otherwise(0L)).alias("reached"),
                cb.sum(cb.<Long>selectCase().when(isWon, 1L).otherwise(0L)).alias("won"),
                cb.sum(cb.<Long>selectCase().when(isLost, 1L).otherwise(0L)).alias("lost"),
                cb.sum(cb.<BigDecimal>selectCase()
                        .when(isWon, root.<BigDecimal>get("dealPrice"))
                        .otherwise(cb.nullLiteral(BigDecimal.class))).alias("value"));
        query.where(deals.toPredicate(root, query, cb));

        Tuple row = entityManager.createQuery(query).getSingleResult();
        long created = asLong(row.get("created"));
        long reachedNegotiation = asLong(row.get("reached"));
        long won = asLong(row.get("won"));
        BigDecimal value = (BigDecimal) row.get("value");

        return FunnelResponse.builder()
                .created(created)
                .reachedNegotiation(reachedNegotiation)
                .won(won)
                .lost(asLong(row.get("lost")))
                .leadToNegotiationRate(rate(reachedNegotiation, created))
                .negotiationToWonRate(rate(won, reachedNegotiation))
                .leadToWonRate(rate(won, created))
                .wonValue(value == null ? BigDecimal.ZERO.setScale(2) : value.setScale(2))
                .build();
    }

    /**
     * Mean days from lead to won. Both ends come from the status history — the creation row and
     * the latest move to won — and a deal from before history was kept falls back to its own
     * created and closed dates. One row per won deal, two timestamps each: the averaging is done
     * here only because date arithmetic is not portable between H2 and PostgreSQL.
     */
    private Double avgDaysToWin(Specification<Deal> deals) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Deal> root = query.from(Deal.class);

        Subquery<LocalDateTime> createdAt = query.subquery(LocalDateTime.class);
        Root<DealStatusChange> first = createdAt.from(DealStatusChange.class);
        createdAt.select(cb.least(first.<LocalDateTime>get("changedAt")))
                .where(cb.equal(first.get("deal"), root), cb.isNull(first.get("fromStatus")));

        Subquery<LocalDateTime> wonAt = query.subquery(LocalDateTime.class);
        Root<DealStatusChange> last = wonAt.from(DealStatusChange.class);
        wonAt.select(cb.greatest(last.<LocalDateTime>get("changedAt")))
                .where(cb.equal(last.get("deal"), root),
                        cb.equal(last.get("toStatus"), DealStatus.CLOSED_WON));

        query.multiselect(
                cb.coalesce(createdAt.getSelection(), root.<LocalDateTime>get("createdAt")).alias("start"),
                cb.coalesce(wonAt.getSelection(), root.<LocalDateTime>get("closedAt")).alias("end"));
        query.where(cb.and(deals.toPredicate(root, query, cb),
                cb.equal(root.get("status"), DealStatus.CLOSED_WON)));

        long totalSeconds = 0;
        int counted = 0;
        for (Tuple row : entityManager.createQuery(query).getResultList()) {
            LocalDateTime start = row.get("start", LocalDateTime.class);
            LocalDateTime end = row.get("end", LocalDateTime.class);
            if (start == null || end == null || end.isBefore(start)) continue;
            totalSeconds += Duration.between(start, end).getSeconds();
            counted++;
        }
        if (counted == 0) return null;
        double days = totalSeconds / 86400.0 / counted;
        return Math.round(days * 10) / 10.0;
    }

    /** Lost deals grouped by reason, most common first; no reason reads as unspecified. */
    private List<LostReasonShare> lostReasons(Specification<Deal> deals, long lost) {
        if (lost == 0) return List.of();
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Deal> root = query.from(Deal.class);
        Expression<DealLostReason> reason = root.get("lostReason");
        query.multiselect(reason.alias("reason"), cb.count(root).alias("n"));
        query.where(cb.and(deals.toPredicate(root, query, cb),
                cb.equal(root.get("status"), DealStatus.CLOSED_LOST)));
        query.groupBy(reason);

        List<LostReasonShare> shares = new ArrayList<>();
        for (Tuple row : entityManager.createQuery(query).getResultList()) {
            DealLostReason r = row.get("reason", DealLostReason.class);
            long n = asLong(row.get("n"));
            shares.add(LostReasonShare.builder()
                    .reason(r == null ? UNSPECIFIED : r.name())
                    .count(n)
                    .share((double) n / lost)
                    .build());
        }
        // Most common first; ties in the enum's order, with unspecified last.
        shares.sort((a, b) -> a.getCount() != b.getCount()
                ? Long.compare(b.getCount(), a.getCount())
                : Integer.compare(order(a.getReason()), order(b.getReason())));
        return shares;
    }

    private static int order(String reason) {
        return UNSPECIFIED.equals(reason) ? Integer.MAX_VALUE : DealLostReason.valueOf(reason).ordinal();
    }

    /**
     * Created, won and lost per month for the last {@link #MONTHS} months, in two grouped
     * statements: creations by the month they were created, outcomes by the month they closed.
     */
    private List<MonthPoint> monthly(Specification<Deal> deals, LocalDate firstMonth) {
        LocalDateTime since = firstMonth.atStartOfDay();
        Map<LocalDate, MonthPoint> points = new java.util.LinkedHashMap<>();
        for (int i = 0; i < MONTHS; i++) {
            LocalDate month = firstMonth.plusMonths(i);
            points.put(month, MonthPoint.builder().month(month).build());
        }

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> created = cb.createTupleQuery();
        Root<Deal> c = created.from(Deal.class);
        Expression<Integer> cy = cb.function("year", Integer.class, c.get("createdAt"));
        Expression<Integer> cm = cb.function("month", Integer.class, c.get("createdAt"));
        created.multiselect(cy.alias("y"), cm.alias("m"), cb.count(c).alias("n"));
        created.where(cb.and(deals.toPredicate(c, created, cb),
                cb.greaterThanOrEqualTo(c.get("createdAt"), since)));
        created.groupBy(cy, cm);
        for (Tuple row : entityManager.createQuery(created).getResultList()) {
            MonthPoint p = points.get(monthOf(row));
            if (p != null) p.setCreated(asLong(row.get("n")));
        }

        CriteriaQuery<Tuple> closed = cb.createTupleQuery();
        Root<Deal> d = closed.from(Deal.class);
        Expression<Integer> dy = cb.function("year", Integer.class, d.get("closedAt"));
        Expression<Integer> dm = cb.function("month", Integer.class, d.get("closedAt"));
        Expression<DealStatus> status = d.get("status");
        closed.multiselect(dy.alias("y"), dm.alias("m"), status.alias("s"), cb.count(d).alias("n"));
        closed.where(cb.and(deals.toPredicate(d, closed, cb),
                status.in(DealStatus.CLOSED_WON, DealStatus.CLOSED_LOST),
                cb.greaterThanOrEqualTo(d.get("closedAt"), since)));
        closed.groupBy(dy, dm, status);
        for (Tuple row : entityManager.createQuery(closed).getResultList()) {
            MonthPoint p = points.get(monthOf(row));
            if (p == null) continue;
            if (row.get("s", DealStatus.class) == DealStatus.CLOSED_WON) {
                p.setWon(asLong(row.get("n")));
            } else {
                p.setLost(asLong(row.get("n")));
            }
        }
        return new ArrayList<>(points.values());
    }

    private static LocalDate monthOf(Tuple row) {
        return LocalDate.of(((Number) row.get("y")).intValue(), ((Number) row.get("m")).intValue(), 1);
    }

    private static long asLong(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }

    private static Double rate(long part, long whole) {
        return whole == 0 ? null : (double) part / whole;
    }
}
