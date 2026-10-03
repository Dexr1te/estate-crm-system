package com.crm.realestate.service;

import com.crm.realestate.dto.request.RenewLeaseRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.dto.response.LeaseEnding;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.AgencyCurrency;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * Leases: the rent deals whose last day is coming, and carrying one on past it.
 *
 * <p>A lease is "ending" while it is a won rent and its last day is still ahead. The list shows
 * what the caller may see of their agency's deals — the same walls as the deal list, team and data
 * scope ({@link ScopeService#visibleTo}) — soonest first.
 *
 * <p>Renewing keeps the deal and moves its last day on. The tenancy is the same one, between the
 * same people, on the same flat: a second deal would count a second win in the funnel and the
 * leaderboard for what is one let, and leave the first deal looking like a lease that ran out. The
 * deal's discussion gets a line saying what changed, so the old end date is not lost. An agency
 * that charges again for a renewal records that as a deal of its own.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LeaseService {

    public static final int DEFAULT_DAYS = 30;
    public static final int MAX_DAYS = 365;
    public static final int DEFAULT_REMINDER_DAYS = 30;
    public static final int MAX_REMINDER_DAYS = 365;

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd.MM.yyyy");

    private final DealRepository dealRepository;
    private final DealCommentRepository commentRepository;
    private final DealService dealService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    /** The caller's won rents ending in {@code [from, from + days]} (from: today if null), soonest first. */
    public List<LeaseEnding> ending(Integer days, LocalDate from) {
        int window = days == null ? DEFAULT_DAYS : days;
        if (window < 1 || window > MAX_DAYS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_DAYS",
                    "days must be between 1 and " + MAX_DAYS);
        }
        LocalDate today = from == null ? LocalDate.now() : from;
        User me = securityUtils.getCurrentUser();
        Specification<Deal> filter = endingBetween(today, today.plusDays(window))
                .and(scopeService.visibleTo(me));
        return dealRepository.findAll(filter).stream()
                .sorted(Comparator.comparing(Deal::getLeaseEnd)
                        .thenComparing(Deal::getTitle, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(Deal::getId))
                .map(deal -> toEnding(deal, today))
                .toList();
    }

    /**
     * Carries the lease on to a later last day, and to a new rent when one is given. Only a won
     * rent has a lease to carry on. Whoever may see the deal may renew it, as they may edit it.
     */
    @Transactional
    public DealResponse renew(Long dealId, RenewLeaseRequest request) {
        User me = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, me);
        if (deal.getKind() != DealKind.RENT || deal.getStatus() != DealStatus.CLOSED_WON) {
            throw new BusinessException(HttpStatus.CONFLICT, "LEASE_NOT_RENEWABLE",
                    "Only a won rent deal has a lease to renew");
        }
        if (!request.getLeaseEnd().isAfter(deal.getLeaseEnd())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LEASE_END_NOT_LATER",
                    "A renewed lease ends after the day it ended before");
        }
        BigDecimal rent = request.getMonthlyRent();
        if (rent != null && rent.signum() <= 0) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RENT_REQUIRED",
                    "A rent deal needs a monthly rent above zero");
        }
        LocalDate previousEnd = deal.getLeaseEnd();
        BigDecimal previousRent = deal.getMonthlyRent();
        deal.setLeaseEnd(request.getLeaseEnd());
        if (rent != null) {
            deal.setMonthlyRent(rent);
        }
        Deal saved = dealRepository.save(deal);
        commentRepository.save(DealComment.builder()
                .deal(saved)
                .team(saved.getTeam())
                .author(me)
                .authorName(me == null ? null : me.getFullName())
                .body(renewedText(language(), saved, previousEnd, previousRent))
                .build());
        return dealService.responseFor(saved);
    }

    /** A lease's first and last day, both there and the last after the first. */
    static void requireLeasePeriod(LocalDate start, LocalDate end) {
        if (start == null || end == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LEASE_DATES_REQUIRED",
                    "A rent deal needs the first and the last day of the lease");
        }
        if (!end.isAfter(start)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LEASE_ENDS_BEFORE_START",
                    "The lease has to end after it starts");
        }
    }

    /** How many days before its end a lease is brought up, the default filled in. */
    public static int reminderDays(Deal deal) {
        return deal.getLeaseReminderDays() == null ? DEFAULT_REMINDER_DAYS : deal.getLeaseReminderDays();
    }

    /** Won rents, in any agency, whose last day falls in {@code [from, until]}. */
    static Specification<Deal> endingBetween(LocalDate from, LocalDate until) {
        return (root, query, cb) -> cb.and(
                cb.equal(root.get("kind"), DealKind.RENT),
                cb.equal(root.get("status"), DealStatus.CLOSED_WON),
                cb.greaterThanOrEqualTo(root.get("leaseEnd"), from),
                cb.lessThanOrEqualTo(root.get("leaseEnd"), until));
    }

    static LeaseEnding toEnding(Deal deal, LocalDate today) {
        Client tenant = deal.getClient();
        Client landlord = deal.getLandlord();
        return LeaseEnding.builder()
                .dealId(deal.getId())
                .dealTitle(deal.getTitle())
                .monthlyRent(deal.getMonthlyRent())
                .leaseStart(deal.getLeaseStart())
                .leaseEnd(deal.getLeaseEnd())
                .daysLeft((int) ChronoUnit.DAYS.between(today, deal.getLeaseEnd()))
                .reminderDays(reminderDays(deal))
                .tenantId(tenant.getId())
                .tenantName(tenant.getFullName())
                .tenantPhone(tenant.getPhone())
                .landlordId(landlord == null ? null : landlord.getId())
                .landlordName(landlord == null ? null : landlord.getFullName())
                .landlordPhone(landlord == null ? null : landlord.getPhone())
                .propertyId(deal.getProperty() == null ? null : deal.getProperty().getId())
                .propertyTitle(deal.getProperty() == null ? null : deal.getProperty().getTitle())
                .propertyAddress(deal.getProperty() == null ? null : deal.getProperty().getAddress())
                .agentId(deal.getAgent() == null ? null : deal.getAgent().getId())
                .agentName(deal.getAgent() == null ? null : deal.getAgent().getFullName())
                .build();
    }

    // Wording ---------------------------------------------------------------------------

    /**
     * The discussion line for a renewal, in the language the caller's app asks in — the rule
     * {@link DealDepositStore} follows. It is history: the next reader sees it as it was written.
     */
    static String renewedText(String language, Deal deal, LocalDate previousEnd, BigDecimal previousRent) {
        String from = DATE.format(previousEnd);
        String to = DATE.format(deal.getLeaseEnd());
        String rent = null;
        if (previousRent != null && deal.getMonthlyRent().compareTo(previousRent) != 0) {
            AgencyCurrency currency = deal.getTeam() == null ? AgencyCurrency.USD : deal.getTeam().getCurrency();
            rent = currency.format(deal.getMonthlyRent(), Locale.forLanguageTag(language));
        }
        return switch (language) {
            case "en" -> "Lease renewed: it now ends on " + to + " instead of " + from + "."
                    + (rent == null ? "" : " New rent: " + rent + " a month.");
            case "kk" -> "Жалдау ұзартылды: енді " + from + " емес, " + to + " аяқталады."
                    + (rent == null ? "" : " Жаңа жалдау ақысы: айына " + rent + ".");
            default -> "Аренда продлена: теперь заканчивается " + to + " вместо " + from + "."
                    + (rent == null ? "" : " Новая ставка: " + rent + " в месяц.");
        };
    }

    private static String language() {
        String header = null;
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attributes) {
            header = attributes.getRequest().getHeader("Accept-Language");
        }
        String language = DefaultChecklist.supported(header);
        return language != null ? language : DefaultChecklist.FALLBACK_LANGUAGE;
    }
}
