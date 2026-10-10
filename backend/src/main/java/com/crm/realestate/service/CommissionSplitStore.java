package com.crm.realestate.service;

import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.CommissionSplitRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Tuple;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;

/**
 * What the rest of the CRM needs to know about commission splits (V55), kept apart from the
 * split's own API so the deal list, the totals and the handovers can lean on it without a cycle.
 *
 * <p><b>The rule.</b> A deal's agent holds the whole commission unless they share it. Each share
 * is a row: a colleague from the deal's agency or an outside co-broker, with a percentage. The
 * deal's agent has no row and holds what the rows leave. A colleague's share is credited to the
 * colleague and taken off the agent; a co-broker's is taken off the agent and credited to nobody,
 * so it leaves the agency's totals.
 *
 * <p><b>Seeing a deal.</b> A colleague with a share works the deal with its agent, so they see it
 * whatever their data scope — inside their own agency only, like everything else.
 */
@Component
@RequiredArgsConstructor
public class CommissionSplitStore {

    /** The change log's field for a deal's split. */
    public static final String FIELD = "commissionSplit";

    static final BigDecimal HUNDRED = BigDecimal.valueOf(100);

    private final CommissionSplitRepository repository;
    private final ScopeService scopeService;
    private final ChangeLogService changeLog;
    private final EntityManager entityManager;

    // Seeing a deal ----------------------------------------------------------------------------

    /** Deals {@code user} may see: what their data scope shows, and the deals they share in. */
    public Specification<Deal> visibleTo(User user) {
        Specification<Deal> scoped = scopeService.visibleTo(user);
        if (user == null || scopeService.isAdmin(user) || scopeService.seesWholeTeam(user)) {
            return scoped;
        }
        return scoped.or(sharedWith(user));
    }

    /** Deals of {@code user}'s agency in which they hold a share. */
    public Specification<Deal> sharedWith(User user) {
        return (root, query, cb) -> {
            Long teamId = scopeService.teamIdOf(user);
            if (teamId == null) {
                return cb.disjunction();
            }
            Subquery<Long> share = query.subquery(Long.class);
            Root<CommissionSplit> s = share.from(CommissionSplit.class);
            share.select(s.get("id")).where(
                    cb.equal(s.get("deal"), root),
                    cb.equal(s.get("user").get("id"), user.getId()));
            return cb.and(cb.equal(root.get("team").get("id"), teamId), cb.exists(share));
        };
    }

    /** The single-deal form of {@link #visibleTo}. */
    public boolean canSee(User user, Deal deal) {
        if (scopeService.canSee(user, deal.getTeam(), deal.getAgent())) {
            return true;
        }
        Long teamId = scopeService.teamIdOf(user);
        return teamId != null && deal.getTeam() != null && teamId.equals(deal.getTeam().getId())
                && repository.existsByDealIdAndUserId(deal.getId(), user.getId());
    }

    // Totals ----------------------------------------------------------------------------------

    /**
     * How much of the commission on the deals matching {@code deals} moves away from their agents,
     * per person, in one grouped statement: positive for a colleague credited with a share,
     * negative for the deal's agent who gave it. A co-broker's share is only taken off the agent.
     * The key is null for a deal nobody holds.
     *
     * <p>In the units the totals already sum in — base × percent, divided by 100 once at the end —
     * so adding these to {@code SUM(base × percent)} keeps the result exact.
     */
    public Map<Long, BigDecimal> shifts(Specification<Deal> deals) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<CommissionSplit> split = query.from(CommissionSplit.class);
        Root<Deal> deal = query.from(Deal.class);
        Expression<Long> holder = split.join("user", JoinType.LEFT).get("id");
        Expression<Long> agent = deal.join("agent", JoinType.LEFT).get("id");
        query.multiselect(
                holder.alias("holder"),
                agent.alias("agent"),
                cb.sum(cb.prod(cb.prod(DealMoney.commissionBase(cb, deal),
                                deal.<BigDecimal>get("commissionPercent")),
                        split.<BigDecimal>get("sharePercent"))).alias("moved"));
        query.where(cb.equal(split.get("deal"), deal), deals.toPredicate(deal, query, cb));
        query.groupBy(holder, agent);

        Map<Long, BigDecimal> shifts = new HashMap<>();
        for (Tuple t : entityManager.createQuery(query).getResultList()) {
            BigDecimal moved = (BigDecimal) t.get("moved");
            if (moved == null) {
                continue;
            }
            moved = moved.movePointLeft(2);
            Long to = t.get("holder", Long.class);
            if (to != null) {
                shifts.merge(to, moved, BigDecimal::add);
            }
            shifts.merge(t.get("agent", Long.class), moved.negate(), BigDecimal::add);
        }
        return shifts;
    }

    /** What all of {@link #shifts} come to: what co-brokers take out of these deals, negated. */
    public static BigDecimal net(Map<Long, BigDecimal> shifts) {
        return shifts.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // Reading one deal's --------------------------------------------------------------------

    public List<CommissionSplit> of(Deal deal) {
        return repository.findByDealIdOrderByPositionAscIdAsc(deal.getId());
    }

    /** The deal's whole commission in the agency's currency; null until its base and rate are known. */
    public static BigDecimal commissionOf(Deal deal) {
        return DealService.commissionOf(DealMoney.commissionBase(deal), deal.getCommissionPercent());
    }

    /** What a share of {@code percent} comes to, to the cent; null while the commission is unknown. */
    public static BigDecimal amountOf(BigDecimal commission, BigDecimal percent) {
        return commission == null ? null
                : commission.multiply(percent).divide(HUNDRED, 2, RoundingMode.HALF_UP);
    }

    /** What the deal's agent holds: 100 less every share. */
    public static BigDecimal agentShare(List<CommissionSplit> shares) {
        return HUNDRED.subtract(shares.stream().map(CommissionSplit::getSharePercent)
                .reduce(BigDecimal.ZERO, BigDecimal::add));
    }

    /**
     * The split in a line, as the change log and the export write it: "Aigul Bekova 60%, Timur
     * Aliev 30%, Ivan Petrov (Etazhi) 10%", the agent first. Null when nothing is shared — the
     * whole commission is the agent's.
     */
    public static String describe(User agent, List<CommissionSplit> shares) {
        if (shares.isEmpty()) {
            return null;
        }
        List<String> parts = new ArrayList<>();
        BigDecimal mine = agentShare(shares);
        if (mine.signum() > 0) {
            parts.add(nameOf(agent) + " " + percent(mine));
        }
        for (CommissionSplit s : shares) {
            parts.add(partyOf(s) + " " + percent(s.getSharePercent()));
        }
        return String.join(", ", parts);
    }

    /** {@link #describe} for each deal of an export's page that has a split: one query. */
    public Map<Long, String> describe(List<Deal> deals) {
        if (deals.isEmpty()) {
            return Map.of();
        }
        Map<Long, List<CommissionSplit>> byDeal = new LinkedHashMap<>();
        for (CommissionSplit s : repository.findByDealIdInOrderByDealIdAscPositionAscIdAsc(
                deals.stream().map(Deal::getId).toList())) {
            byDeal.computeIfAbsent(s.getDeal().getId(), id -> new ArrayList<>()).add(s);
        }
        Map<Long, String> lines = new HashMap<>();
        for (Deal deal : deals) {
            List<CommissionSplit> shares = byDeal.get(deal.getId());
            if (shares != null) {
                lines.put(deal.getId(), describe(deal.getAgent(), shares));
            }
        }
        return lines;
    }

    static String partyOf(CommissionSplit s) {
        if (s.getUser() != null) {
            return nameOf(s.getUser());
        }
        String agency = s.getCoBrokerAgency();
        return agency == null || agency.isBlank()
                ? s.getCoBrokerName()
                : s.getCoBrokerName() + " (" + agency + ")";
    }

    private static String nameOf(User user) {
        String name = ChangeSnapshot.person(user);
        return name == null ? "?" : name;
    }

    private static String percent(BigDecimal value) {
        return value.stripTrailingZeros().toPlainString() + "%";
    }

    // Writing --------------------------------------------------------------------------------

    /** Replaces the deal's shares with these, logging the change; an empty list clears the split. */
    public void replace(Deal deal, List<CommissionSplit> next, User actor) {
        List<CommissionSplit> current = of(deal);
        String before = describe(deal.getAgent(), current);
        repository.deleteAll(current);
        repository.flush();
        for (int i = 0; i < next.size(); i++) {
            next.get(i).setDeal(deal);
            next.get(i).setPosition(i);
        }
        repository.saveAll(next);
        changeLog.fieldChanged(ChangeSnapshot.target(deal), actor, FIELD, before,
                describe(deal.getAgent(), next));
    }

    // Handing over --------------------------------------------------------------------------

    /**
     * {@code from}'s shares on the deals of {@code team} go to {@code to}: someone leaving the
     * agency, or taken off it. A share on a deal {@code to} holds becomes part of what they hold;
     * a share next to one {@code to} already has is added to it. Call before the deals themselves
     * change hands.
     */
    public void passShares(User from, User to, Team team, User actor) {
        pass(repository.heldInTeam(from, team), to, actor);
    }

    /**
     * The same for an account being closed: every share it holds, wherever the deal is. With no
     * successor ({@code to} null) each share goes back to its deal's agent.
     */
    public void passAllShares(User from, User to, User actor) {
        pass(repository.heldBy(from), to, actor);
    }

    /**
     * {@code holder} has just been given deals they held a share in: the share is part of what
     * they hold now, so it goes. Asked of the database, so deals moved by a bulk update count.
     * {@code previousAgent} says who held each deal before, for the change log's "before".
     */
    public void foldOwnShares(User holder, Function<Long, User> previousAgent, User actor) {
        for (CommissionSplit own : repository.onOwnDeals(holder)) {
            Deal deal = own.getDeal();
            List<CommissionSplit> shares = of(deal);
            User heldBy = previousAgent.apply(deal.getId());
            String before = describe(heldBy == null ? holder : heldBy, shares);
            shares.removeIf(s -> s.getId().equals(own.getId()));
            repository.delete(own);
            changeLog.fieldChanged(ChangeSnapshot.target(deal), actor, FIELD, before, describe(holder, shares));
        }
        repository.flush();
    }

    private void pass(List<CommissionSplit> leaving, User to, User actor) {
        for (CommissionSplit share : leaving) {
            Deal deal = share.getDeal();
            List<CommissionSplit> shares = of(deal);
            String before = describe(deal.getAgent(), shares);
            CommissionSplit theirs = to == null ? null : shares.stream()
                    .filter(s -> s.getUser() != null && Objects.equals(s.getUser().getId(), to.getId()))
                    .findFirst().orElse(null);
            CommissionSplit gone = shares.stream()
                    .filter(s -> s.getId().equals(share.getId())).findFirst().orElse(share);
            if (to == null || (deal.getAgent() != null && Objects.equals(deal.getAgent().getId(), to.getId()))) {
                shares.remove(gone);
                repository.delete(gone);
            } else if (theirs != null) {
                theirs.setSharePercent(theirs.getSharePercent().add(gone.getSharePercent()));
                shares.remove(gone);
                repository.delete(gone);
            } else {
                gone.setUser(to);
            }
            changeLog.fieldChanged(ChangeSnapshot.target(deal), actor, FIELD, before,
                    describe(deal.getAgent(), shares));
        }
        repository.flush();
    }
}
