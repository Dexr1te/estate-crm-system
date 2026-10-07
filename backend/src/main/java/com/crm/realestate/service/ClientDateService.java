package com.crm.realestate.service;

import com.crm.realestate.dto.response.UpcomingClientDate;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientDateKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Fetch;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Path;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.hibernate.query.criteria.HibernateCriteriaBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Year;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Function;

/**
 * Birthdays and purchase anniversaries coming up: reasons to get back in touch.
 *
 * <p>A birthday is the client's day and month. A purchase anniversary is the day a deal of theirs
 * was won, in every year after the one it was won in. Either may fall on the 29th of February, and
 * in a common year it is marked on the 28th, so it is never skipped.
 *
 * <p>An agent sees the dates of the clients they hold, and nobody else's, whatever their data
 * scope: it is their relationship to keep. A manager sees the agency's, an admin everyone's. Another
 * agency's clients are never looked at — see {@link ScopeService}.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientDateService {

    public static final int DEFAULT_DAYS = 14;
    public static final int MAX_DAYS = 60;

    private final EntityManager entityManager;
    private final SecurityUtils securityUtils;
    private final ScopeService scopeService;

    /** The caller's dates from {@code from} (today if null) for {@code days} days, soonest first. */
    public List<UpcomingClientDate> upcoming(Integer days, LocalDate from) {
        int window = days == null ? DEFAULT_DAYS : days;
        if (window < 1 || window > MAX_DAYS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_DAYS",
                    "days must be between 1 and " + MAX_DAYS);
        }
        User me = securityUtils.getCurrentUser();
        return between(from == null ? LocalDate.now() : from, window, client -> heldBy(me, client));
    }

    /** Everyone's dates that fall on {@code day}, for the reminder. */
    public List<UpcomingClientDate> fallingOn(LocalDate day) {
        return between(day, 1, client -> null);
    }

    /**
     * Every date in {@code [from, from + days)} of the clients {@code scope} lets through. The scope
     * is given the path to the client — the root for birthdays, the deal's client for
     * anniversaries — and returns null for no restriction.
     */
    private List<UpcomingClientDate> between(LocalDate from, int days,
                                             Function<Path<Client>, Predicate> scope) {
        LocalDate until = from.plusDays(days);
        Set<Integer> keys = new LinkedHashSet<>();
        Set<Integer> months = new LinkedHashSet<>();
        for (LocalDate d = from; d.isBefore(until); d = d.plusDays(1)) {
            keys.add(key(d.getMonthValue(), d.getDayOfMonth()));
            months.add(d.getMonthValue());
            if (d.getMonthValue() == 2 && d.getDayOfMonth() == 28 && !d.isLeapYear()) {
                keys.add(key(2, 29));
            }
        }
        List<UpcomingClientDate> result = new ArrayList<>();
        for (Client client : birthdays(keys, months, scope)) {
            ClientBirthday birthday = ClientBirthday.of(client);
            LocalDate date = nextOn(birthday.month(), birthday.day(), from, until);
            if (date == null) {
                continue;
            }
            result.add(base(client, ClientDateKind.BIRTHDAY, date, from)
                    .years(birthday.year() == null ? null : date.getYear() - birthday.year())
                    .build());
        }
        for (Deal deal : wonDeals(keys, from, scope)) {
            LocalDate closed = deal.getClosedAt().toLocalDate();
            LocalDate date = nextOn(closed.getMonthValue(), closed.getDayOfMonth(), from, until);
            if (date == null || date.getYear() <= closed.getYear()) {
                continue;
            }
            result.add(base(deal.getClient(), ClientDateKind.PURCHASE_ANNIVERSARY, date, from)
                    .years(date.getYear() - closed.getYear())
                    .dealId(deal.getId())
                    .dealTitle(deal.getTitle())
                    .propertyTitle(deal.getProperty() == null ? null : deal.getProperty().getTitle())
                    .build());
        }
        result.sort(Comparator.comparing(UpcomingClientDate::getDate)
                .thenComparing(UpcomingClientDate::getKind)
                .thenComparing(UpcomingClientDate::getClientName, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                .thenComparing(UpcomingClientDate::getClientId)
                .thenComparing(UpcomingClientDate::getDealId, Comparator.nullsFirst(Comparator.naturalOrder())));
        return result;
    }

    private List<Client> birthdays(Set<Integer> keys, Set<Integer> months,
                                   Function<Path<Client>, Predicate> scope) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Client> query = cb.createQuery(Client.class);
        Root<Client> root = query.from(Client.class);
        root.fetch("agent", JoinType.LEFT);
        Expression<Integer> key = cb.sum(cb.prod(root.<Integer>get("birthMonth"), 100), root.<Integer>get("birthDay"));
        List<Predicate> where = new ArrayList<>();
        // The month narrows by the index; the key then picks the days.
        where.add(root.get("birthMonth").in(months));
        where.add(key.in(keys));
        Predicate visible = scope.apply(root);
        if (visible != null) {
            where.add(visible);
        }
        query.select(root).where(where.toArray(new Predicate[0]));
        return entityManager.createQuery(query).getResultList();
    }

    private List<Deal> wonDeals(Set<Integer> keys, LocalDate from, Function<Path<Client>, Predicate> scope) {
        HibernateCriteriaBuilder cb = (HibernateCriteriaBuilder) entityManager.getCriteriaBuilder();
        CriteriaQuery<Deal> query = cb.createQuery(Deal.class);
        Root<Deal> root = query.from(Deal.class);
        @SuppressWarnings("unchecked")
        Fetch<Deal, Client> client = root.fetch("client", JoinType.INNER);
        client.fetch("agent", JoinType.LEFT);
        root.fetch("property", JoinType.LEFT);
        @SuppressWarnings("unchecked")
        Path<Client> clientPath = (Path<Client>) client;
        Expression<java.time.LocalDateTime> closedAt = root.get("closedAt");
        Expression<Integer> key = cb.sum(
                cb.prod(cb.month(closedAt), 100),
                cb.day(closedAt));
        List<Predicate> where = new ArrayList<>();
        where.add(cb.equal(root.get("status"), DealStatus.CLOSED_WON));
        where.add(cb.isNotNull(closedAt));
        // A window may run into next year; that a deal was won in an earlier year than the day it
        // comes round is checked once the day is known.
        where.add(cb.lessThan(closedAt, Year.of(from.getYear()).atDay(1).atStartOfDay().plusYears(1)));
        where.add(key.in(keys));
        Predicate visible = scope.apply(clientPath);
        if (visible != null) {
            where.add(visible);
        }
        query.select(root).where(where.toArray(new Predicate[0]));
        return entityManager.createQuery(query).getResultList();
    }

    /**
     * The clients whose dates {@code me} sees: their own clients for an agent, whatever the data
     * scope; the rest as {@link ScopeService#visibleTo} has it.
     */
    private Predicate heldBy(User me, Path<Client> client) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        if (scopeService.isAdmin(me)) {
            return cb.conjunction();
        }
        Predicate mine = cb.equal(client.get("agent").get("id"), me.getId());
        Long teamId = scopeService.teamIdOf(me);
        if (teamId == null) {
            return cb.and(cb.isNull(client.get("team")), mine);
        }
        Predicate inTeam = cb.equal(client.get("team").get("id"), teamId);
        boolean wholeTeam = !scopeService.isAgent(me) && scopeService.seesWholeTeam(me);
        return wholeTeam ? inTeam : cb.and(inTeam, mine);
    }

    /** The first day in {@code [from, until)} that the yearly date falls on, or null. */
    static LocalDate nextOn(int month, int day, LocalDate from, LocalDate until) {
        for (int year = from.getYear(); year <= until.getYear(); year++) {
            LocalDate date = ClientBirthday.inYear(month, day, year);
            if (!date.isBefore(from) && date.isBefore(until)) {
                return date;
            }
        }
        return null;
    }

    private static int key(int month, int day) {
        return month * 100 + day;
    }

    private static UpcomingClientDate.UpcomingClientDateBuilder base(Client client, ClientDateKind kind,
                                                                     LocalDate date, LocalDate from) {
        return UpcomingClientDate.builder()
                .kind(kind)
                .date(date)
                .daysAway((int) ChronoUnit.DAYS.between(from, date))
                .clientId(client.getId())
                .clientName(client.getFullName())
                .phone(client.getPhone())
                .clientType(client.getType())
                .agentId(client.getAgent() == null ? null : client.getAgent().getId())
                .agentName(client.getAgent() == null ? null : client.getAgent().getFullName());
    }
}
