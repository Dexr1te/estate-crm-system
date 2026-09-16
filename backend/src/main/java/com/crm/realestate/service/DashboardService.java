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
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    /**
     * Five numbers, counted in the database over exactly the records the caller may see.
     *
     * <p>{@code agentId} and {@code teamId} only ever narrow that set — a manager asking about
     * another agency's team gets zeros, not that agency's figures.
     */
    public DashboardSummary getSummary(Long agentId, Long teamId) {
        User currentUser = securityUtils.getCurrentUser();

        // Five numbers, four counting queries. This used to load every closed deal and every
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
                .build();
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
