package com.crm.realestate.service;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final DealRepository    dealRepository;
    private final ClientRepository  clientRepository;
    private final MeetingRepository meetingRepository;
    private final SecurityUtils     securityUtils;
    private final ScopeService      scopeService;
    private final EntityManager     entityManager;

    /**
     * Five counts and a sum, computed in the database over exactly the records the caller may see.
     *
     * <p>{@code agentId} and {@code teamId} only ever narrow that set — a manager asking about
     * another agency's team gets zeros, not that agency's figures.
     */
    public DashboardSummary getSummary(Long agentId, Long teamId) {
        User currentUser = securityUtils.getCurrentUser();

        // Five counts in four queries, and one sum. This used to load every closed deal and every
        // upcoming meeting into memory to call .size() on them, and the meeting filter read
        // m.getAgent().getId() per row — an N+1 on top of a full table scan, to produce integers.
        final List<DealStatus> closedStatuses =
                List.of(DealStatus.CLOSED_WON, DealStatus.CLOSED_LOST);
        final LocalDateTime now = LocalDateTime.now();

        Specification<Deal> deals = this.<Deal>narrowed(currentUser, agentId, teamId);
        long totalDeals = dealRepository.count(deals);
        long closedDeals = dealRepository.count(
                deals.and((root, query, cb) -> root.get("status").in(closedStatuses)));
        long totalClients = clientRepository.count(this.<Client>narrowed(currentUser, agentId, teamId));
        long upcomingMeetings = meetingRepository.count(this.<Meeting>narrowed(currentUser, agentId, teamId)
                .and((root, query, cb) -> cb.greaterThan(root.get("scheduledAt"), now)));

        long activeDeals = totalDeals - closedDeals;

        return DashboardSummary.builder()
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .closedDeals(closedDeals)
                .totalClients(totalClients)
                .upcomingMeetings(upcomingMeetings)
                .commissionThisMonth(commissionWonInMonth(deals, now.toLocalDate().withDayOfMonth(1)))
                .build();
    }

    /**
     * Commission on deals won in the month starting {@code monthStart}, summed in the database.
     *
     * <p>SUM skips deals missing a price or a rate, since their product is null. Summing
     * price × percent and dividing once keeps the total exact rather than adding rounded parts.
     */
    private BigDecimal commissionWonInMonth(Specification<Deal> deals, LocalDate monthStart) {
        Specification<Deal> won = deals
                .and((root, query, cb) -> cb.equal(root.get("status"), DealStatus.CLOSED_WON))
                .and((root, query, cb) -> cb.and(
                        cb.greaterThanOrEqualTo(root.get("closedAt"), monthStart.atStartOfDay()),
                        cb.lessThan(root.get("closedAt"), monthStart.plusMonths(1).atStartOfDay())));

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<BigDecimal> query = cb.createQuery(BigDecimal.class);
        Root<Deal> root = query.from(Deal.class);
        query.select(cb.sum(cb.prod(
                root.<BigDecimal>get("dealPrice"), root.<BigDecimal>get("commissionPercent"))));
        query.where(won.toPredicate(root, query, cb));

        BigDecimal total = entityManager.createQuery(query).getSingleResult();
        return total == null
                ? BigDecimal.ZERO.setScale(2)
                : total.divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    private <T> Specification<T> narrowed(User currentUser, Long agentId, Long teamId) {
        Specification<T> filter = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (agentId != null) {
                predicates.add(cb.equal(root.get("agent").get("id"), agentId));
            }
            if (teamId != null) {
                predicates.add(cb.equal(root.get("team").get("id"), teamId));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        return filter.and(scopeService.visibleTo(currentUser));
    }
}
