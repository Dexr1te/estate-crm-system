package com.crm.realestate.service;

import com.crm.realestate.dto.response.LeaderboardResponse;
import com.crm.realestate.dto.response.LeaderboardResponse.Row;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Tuple;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The agent leaderboard: per person in one agency, what they won, earned, showed and brought in
 * over a period.
 *
 * <p>Only a manager (their own agency) or an admin (naming one with {@code teamId}) asks; the
 * controller turns everyone else away. Every statement is pinned to that one agency's
 * {@code team_id}, so another agency's records never count, whatever the caller's data scope.
 * Four grouped statements, however many people and records there are.
 *
 * <p>Who is on the board: the agency's agents and its manager, once they have an account (an
 * invitation nobody has accepted holds no records). Members deactivated by an admin are listed
 * apart as {@code inactive}. Someone taken off the team appears nowhere — their records were
 * handed to a colleague when they left, and count for that colleague now.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LeaderboardService {

    private static final BigDecimal HUNDRED = BigDecimal.valueOf(100);

    private final SecurityUtils  securityUtils;
    private final TeamRepository teamRepository;
    private final EntityManager  entityManager;

    public LeaderboardResponse leaderboard(LocalDate from, LocalDate to, Long teamId) {
        LocalDate start = from != null ? from : LocalDate.now().withDayOfMonth(1);
        LocalDate end = to != null ? to : start.plusMonths(1);
        if (!start.isBefore(end)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PERIOD",
                    "The period has to end after it starts");
        }
        Team team = teamOf(securityUtils.getCurrentUser(), teamId);
        LocalDateTime startAt = start.atStartOfDay();
        LocalDateTime endAt = end.atStartOfDay();

        Map<Long, Row> rows = new HashMap<>();
        List<Row> active = new ArrayList<>();
        List<Row> inactive = new ArrayList<>();
        for (User member : members(team.getId())) {
            Row row = Row.builder()
                    .agentId(member.getId())
                    .fullName(member.getFullName())
                    .role(member.getRole().name())
                    .wonValue(BigDecimal.ZERO.setScale(2))
                    .commission(BigDecimal.ZERO.setScale(2))
                    .build();
            rows.put(member.getId(), row);
            (isActive(member) ? active : inactive).add(row);
        }

        closedDeals(team.getId(), startAt, endAt, rows);
        viewingsHeld(team.getId(), startAt, endAt, rows);
        newClients(team.getId(), startAt, endAt, rows);

        Row totals = Row.builder()
                .wonValue(BigDecimal.ZERO.setScale(2))
                .commission(BigDecimal.ZERO.setScale(2))
                .build();
        for (Row row : rows.values()) {
            row.setWinRate(winRate(row));
            totals.setDealsWon(totals.getDealsWon() + row.getDealsWon());
            totals.setDealsLost(totals.getDealsLost() + row.getDealsLost());
            totals.setWonValue(totals.getWonValue().add(row.getWonValue()));
            totals.setCommission(totals.getCommission().add(row.getCommission()));
            totals.setViewingsHeld(totals.getViewingsHeld() + row.getViewingsHeld());
            totals.setNewClients(totals.getNewClients() + row.getNewClients());
        }
        totals.setWinRate(winRate(totals));

        return LeaderboardResponse.builder()
                .from(start)
                .to(end)
                .currency(team.getCurrency() == null ? null : team.getCurrency().name())
                .agents(ranked(active))
                .inactive(ranked(inactive))
                .totals(totals)
                .build();
    }

    /** A manager's own agency; an admin, who runs none, names one. */
    private Team teamOf(User user, Long teamId) {
        if (user.getRole() == Role.ADMIN) {
            if (teamId == null) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                        "Say which agency's leaderboard this is");
            }
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "Create or join an agency first");
        }
        return user.getTeam();
    }

    private List<User> members(Long teamId) {
        return entityManager.createQuery("""
                        SELECT u FROM User u
                        WHERE u.team.id = :team
                          AND u.role IN (:roles)
                          AND u.status NOT IN (:pending)
                        """, User.class)
                .setParameter("team", teamId)
                .setParameter("roles", List.of(Role.AGENT, Role.MANAGER))
                .setParameter("pending", List.of(UserStatus.PENDING_INVITE, UserStatus.PENDING_VERIFICATION))
                .getResultList();
    }

    private static boolean isActive(User user) {
        return user.isActive() && user.getStatus() != UserStatus.DEACTIVATED;
    }

    /**
     * Won and lost deals by their closing date, per holder: counts, won value and commission. The
     * commission sums price × percent and divides once, exactly as the dashboard's month does.
     */
    private void closedDeals(Long teamId, LocalDateTime startAt, LocalDateTime endAt, Map<Long, Row> rows) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Deal> deal = query.from(Deal.class);
        Expression<Long> agentId = deal.get("agent").get("id");
        Expression<DealStatus> status = deal.get("status");
        query.multiselect(
                agentId.alias("agent"),
                status.alias("status"),
                cb.count(deal).alias("n"),
                cb.sum(DealMoney.saleValue(cb, deal)).alias("value"),
                cb.sum(cb.prod(DealMoney.commissionBase(cb, deal),
                        deal.<BigDecimal>get("commissionPercent"))).alias("commission"));
        query.where(
                cb.equal(deal.get("team").get("id"), teamId),
                status.in(DealStatus.CLOSED_WON, DealStatus.CLOSED_LOST),
                cb.greaterThanOrEqualTo(deal.get("closedAt"), startAt),
                cb.lessThan(deal.get("closedAt"), endAt));
        query.groupBy(agentId, status);

        for (Tuple t : entityManager.createQuery(query).getResultList()) {
            Row row = rows.get(t.get("agent", Long.class));
            if (row == null) continue;
            long n = asLong(t.get("n"));
            if (t.get("status", DealStatus.class) == DealStatus.CLOSED_WON) {
                row.setDealsWon(n);
                row.setWonValue(money((BigDecimal) t.get("value"), BigDecimal.ONE));
                row.setCommission(money((BigDecimal) t.get("commission"), HUNDRED));
            } else {
                row.setDealsLost(n);
            }
        }
    }

    /**
     * Viewings that took place: a meeting with a listing, in the period and already in the past or
     * marked done (an agent who forgets to tick it off has still shown the flat, as in the seller's
     * report), unless the buyer did not come.
     */
    private void viewingsHeld(Long teamId, LocalDateTime startAt, LocalDateTime endAt, Map<Long, Row> rows) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Meeting> meeting = query.from(Meeting.class);
        Expression<Long> agentId = meeting.get("agent").get("id");
        Expression<ViewingOutcome> outcome = meeting.get("outcome");
        LocalDateTime now = LocalDateTime.now();
        query.multiselect(agentId.alias("agent"), cb.count(meeting).alias("n"));
        query.where(
                cb.equal(meeting.get("team").get("id"), teamId),
                cb.isNotNull(meeting.get("property")),
                cb.greaterThanOrEqualTo(meeting.get("scheduledAt"), startAt),
                cb.lessThan(meeting.get("scheduledAt"), endAt),
                cb.or(cb.isTrue(meeting.get("completed")), cb.lessThanOrEqualTo(meeting.get("scheduledAt"), now)),
                cb.or(cb.isNull(outcome), cb.notEqual(outcome, ViewingOutcome.NO_SHOW)));
        query.groupBy(agentId);
        for (Tuple t : entityManager.createQuery(query).getResultList()) {
            Row row = rows.get(t.get("agent", Long.class));
            if (row != null) row.setViewingsHeld(asLong(t.get("n")));
        }
    }

    /** Clients created in the period, by whoever holds them now. */
    private void newClients(Long teamId, LocalDateTime startAt, LocalDateTime endAt, Map<Long, Row> rows) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<Client> client = query.from(Client.class);
        Expression<Long> agentId = client.get("agent").get("id");
        query.multiselect(agentId.alias("agent"), cb.count(client).alias("n"));
        query.where(
                cb.equal(client.get("team").get("id"), teamId),
                cb.greaterThanOrEqualTo(client.get("createdAt"), startAt),
                cb.lessThan(client.get("createdAt"), endAt));
        query.groupBy(agentId);
        for (Tuple t : entityManager.createQuery(query).getResultList()) {
            Row row = rows.get(t.get("agent", Long.class));
            if (row != null) row.setNewClients(asLong(t.get("n")));
        }
    }

    /** Commission first, then deals won, then won value; a tie keeps alphabetical order. */
    private static List<Row> ranked(List<Row> rows) {
        rows.sort(Comparator.comparing(Row::getCommission).reversed()
                .thenComparing(Comparator.comparingLong(Row::getDealsWon).reversed())
                .thenComparing(Comparator.comparing(Row::getWonValue).reversed())
                .thenComparing(Row::getFullName, String.CASE_INSENSITIVE_ORDER));
        for (int i = 0; i < rows.size(); i++) {
            rows.get(i).setRank(i + 1);
        }
        return rows;
    }

    private static Double winRate(Row row) {
        long closed = row.getDealsWon() + row.getDealsLost();
        return closed == 0 ? null : (double) row.getDealsWon() / closed;
    }

    private static BigDecimal money(BigDecimal sum, BigDecimal divisor) {
        return sum == null ? BigDecimal.ZERO.setScale(2) : sum.divide(divisor, 2, RoundingMode.HALF_UP);
    }

    private static long asLong(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }
}
