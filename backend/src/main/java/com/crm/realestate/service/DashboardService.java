package com.crm.realestate.service;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
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
    private final TaskRepository    taskRepository;
    private final SecurityUtils     securityUtils;
    private final ScopeService      scopeService;
    private final EntityManager     entityManager;
    private final ColdClientService coldClientService;
    private final CommissionSplitStore splitStore;

    /**
     * Seven counts and a sum, computed in the database over exactly the records the caller may see.
     *
     * <p>{@code agentId} and {@code teamId} only ever narrow that set — a manager asking about
     * another agency's team gets zeros, not that agency's figures. For tasks, the agent is the
     * assignee.
     */
    public DashboardSummary getSummary(Long agentId, Long teamId) {
        User currentUser = securityUtils.getCurrentUser();

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

        // Overdue is anything open whose time has passed; due today is the rest of today, so
        // the two never count the same task.
        Specification<Task> openTasks = this.<Task>narrowed(currentUser, agentId, teamId, TaskService.HOLDER)
                .and((root, query, cb) -> cb.isNull(root.get("completedAt")));
        long tasksOverdue = taskRepository.count(
                openTasks.and((root, query, cb) -> cb.lessThan(root.get("dueAt"), now)));
        LocalDateTime tomorrow = now.toLocalDate().plusDays(1).atStartOfDay();
        long tasksDueToday = taskRepository.count(
                openTasks.and((root, query, cb) -> cb.and(
                        cb.greaterThanOrEqualTo(root.get("dueAt"), now),
                        cb.lessThan(root.get("dueAt"), tomorrow))));

        return DashboardSummary.builder()
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .closedDeals(closedDeals)
                .totalClients(totalClients)
                .upcomingMeetings(upcomingMeetings)
                .tasksDueToday(tasksDueToday)
                .tasksOverdue(tasksOverdue)
                .coldCount(coldClientService.count(currentUser, agentId, teamId))
                .commissionThisMonth(commissionWonInMonth(currentUser, agentId, teamId, deals,
                        now.toLocalDate().withDayOfMonth(1)))
                .build();
    }

    /**
     * Commission on deals won in the month starting {@code monthStart}, summed in the database.
     *
     * <p>SUM skips deals missing a price or a rate, since their product is null. Summing
     * price × percent and dividing once keeps the total exact rather than adding rounded parts.
     *
     * <p>Split commissions count by share (see {@link CommissionSplitStore}). About one person —
     * {@code agentId}, or the caller when they see only their own records — it is that person's
     * shares: what is left them of their own deals and their part of colleagues'. About an agency
     * it is the whole commission less what went to co-brokers outside it. Someone on their own
     * records asking about somebody else still learns nothing.
     */
    private BigDecimal commissionWonInMonth(User currentUser, Long agentId, Long teamId,
                                            Specification<Deal> deals, LocalDate monthStart) {
        Specification<Deal> wonInMonth = (root, query, cb) -> cb.and(
                cb.equal(root.get("status"), DealStatus.CLOSED_WON),
                cb.greaterThanOrEqualTo(root.get("closedAt"), monthStart.atStartOfDay()),
                cb.lessThan(root.get("closedAt"), monthStart.plusMonths(1).atStartOfDay()));

        boolean ownOnly = !scopeService.isAdmin(currentUser) && !scopeService.seesWholeTeam(currentUser);
        Long person = agentId != null ? agentId : ownOnly ? currentUser.getId() : null;
        BigDecimal raw;
        if (person == null) {
            Specification<Deal> won = deals.and(wonInMonth);
            raw = sumOfCommission(won).add(CommissionSplitStore.net(splitStore.shifts(won)));
        } else if (ownOnly && !person.equals(currentUser.getId())) {
            raw = BigDecimal.ZERO;
        } else {
            Specification<Deal> pool = wonInMonth
                    .and(this.<Deal>narrowed(currentUser, null, teamId, "agent", false));
            raw = sumOfCommission(pool.and((root, query, cb) -> cb.equal(root.get("agent").get("id"), person)))
                    .add(splitStore.shifts(pool).getOrDefault(person, BigDecimal.ZERO));
        }
        return raw.divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    /** SUM(base × percent) over these deals; zero when there are none. */
    private BigDecimal sumOfCommission(Specification<Deal> deals) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<BigDecimal> query = cb.createQuery(BigDecimal.class);
        Root<Deal> root = query.from(Deal.class);
        query.select(cb.sum(cb.prod(
                DealMoney.commissionBase(cb, root), root.<BigDecimal>get("commissionPercent"))));
        query.where(deals.toPredicate(root, query, cb));

        BigDecimal total = entityManager.createQuery(query).getSingleResult();
        return total == null ? BigDecimal.ZERO : total;
    }

    <T> Specification<T> narrowed(User currentUser, Long agentId, Long teamId) {
        return narrowed(currentUser, agentId, teamId, "agent");
    }

    private <T> Specification<T> narrowed(User currentUser, Long agentId, Long teamId, String holder) {
        return narrowed(currentUser, agentId, teamId, holder, true);
    }

    /**
     * With {@code byScope} false only the agency's wall applies, not the data scope inside it: for
     * a person's commission, whose shares lie in colleagues' deals too.
     */
    private <T> Specification<T> narrowed(User currentUser, Long agentId, Long teamId, String holder,
                                          boolean byScope) {
        Specification<T> filter = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (agentId != null) {
                predicates.add(cb.equal(root.get(holder).get("id"), agentId));
            }
            if (teamId != null) {
                predicates.add(cb.equal(root.get("team").get("id"), teamId));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        return filter.and(byScope ? scopeService.visibleTo(currentUser, holder) : scopeService.visibleToTeam(currentUser));
    }
}
