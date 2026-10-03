package com.crm.realestate.service;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.repository.DealRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.List;

/**
 * Tells the agent, once, that a lease they let is running out: on the first run on or after the
 * day that is the deal's reminder lead time (30 days unless the deal says otherwise) before its
 * last day.
 *
 * <p>It runs on the clock the birthday reminder runs on — the same {@code app.client-dates.cron}
 * and zone, through the scheduling {@link com.crm.realestate.config.SchedulingConfig} turns on — so
 * an agency hears about its clients' dates and its leases at the same hours. A deal remembers the
 * last day it was reminded about ({@code lease_reminded_for}); the reminder sets it with a
 * conditional update and speaks only when that update changed the row, so the next hour, or a
 * second server at the same moment, says nothing. Renewing a lease moves its last day, and the
 * new one is news again in its turn.
 *
 * <p>A lease written down when its end is already inside the lead time is mentioned on the next
 * run. One whose last day has passed is not: it has ended, and the list no longer shows it either.
 */
@Component
@Slf4j
public class LeaseEndNotifier {

    private final DealRepository deals;
    private final NotificationEvents events;
    private final ZoneId zone;

    public LeaseEndNotifier(DealRepository deals, NotificationEvents events,
                            @Value("${app.client-dates.zone:}") String zone) {
        this.deals = deals;
        this.events = events;
        this.zone = zone == null || zone.isBlank() ? ZoneId.systemDefault() : ZoneId.of(zone);
    }

    /** Through the proxy, so the run below is one transaction; a self-call would not be. */
    @Scheduled(cron = "${app.client-dates.cron:0 0 8-21 * * *}", zone = "${app.client-dates.zone:}")
    @Transactional
    public void onSchedule() {
        int told = notifyFor(LocalDate.now(zone));
        if (told > 0) {
            log.info("Told agents about {} leases running out", told);
        }
    }

    /** Raises the lease reminders due by {@code today} and not raised yet; how many it raised. */
    @Transactional
    public int notifyFor(LocalDate today) {
        List<Deal> candidates = deals.findAll(LeaseService.endingBetween(today,
                today.plusDays(LeaseService.MAX_REMINDER_DAYS)));
        int told = 0;
        for (Deal deal : candidates.stream().sorted(Comparator.comparing(Deal::getLeaseEnd)
                .thenComparing(Deal::getId)).toList()) {
            LocalDate end = deal.getLeaseEnd();
            if (end.equals(deal.getLeaseRemindedFor())
                    || today.isBefore(end.minusDays(LeaseService.reminderDays(deal)))) {
                continue;
            }
            if (deals.markLeaseReminded(deal.getId(), end) == 0) {
                continue;
            }
            events.leaseEnding(deal, (int) java.time.temporal.ChronoUnit.DAYS.between(today, end));
            told++;
        }
        return told;
    }
}
