package com.crm.realestate.service;

import com.crm.realestate.dto.response.UpcomingClientDate;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientDateNotice;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientDateKind;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.repository.ClientDateNoticeRepository;
import com.crm.realestate.repository.ClientRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.Set;

/**
 * Tells each agent, on the day, whose birthday or purchase anniversary it is.
 *
 * <p>This is the one thing in the backend that runs on a clock rather than because somebody did
 * something. It runs every hour through the day ({@code app.client-dates.cron}) in the agency's
 * time zone ({@code app.client-dates.zone}, the server's when blank), so a server that was down at
 * eight still tells everybody by nine. Each client is mentioned at most once a year for each kind
 * of date: a {@code client_date_notices} row is written in the same transaction as the
 * notification, the next hour finds it and says nothing, and its unique key stops another server
 * running at the same moment from saying it twice.
 *
 * <p>The notification goes to the client's agent, or to the agency's manager for a client nobody
 * holds. A client with two deals won on the same day hears about the first only.
 */
@Component
@Slf4j
public class ClientDateNotifier {

    private final ClientDateService dates;
    private final ClientDateNoticeRepository notices;
    private final ClientRepository clients;
    private final NotificationEvents events;
    private final ZoneId zone;

    public ClientDateNotifier(ClientDateService dates, ClientDateNoticeRepository notices,
                              ClientRepository clients, NotificationEvents events,
                              @Value("${app.client-dates.zone:}") String zone) {
        this.dates = dates;
        this.notices = notices;
        this.clients = clients;
        this.events = events;
        this.zone = zone == null || zone.isBlank() ? ZoneId.systemDefault() : ZoneId.of(zone);
    }

    /** Through the proxy, so the run below is one transaction; a self-call would not be. */
    @Scheduled(cron = "${app.client-dates.cron:0 0 8-21 * * *}", zone = "${app.client-dates.zone:}")
    @Transactional
    public void onSchedule() {
        int told = notifyFor(LocalDate.now(zone));
        if (told > 0) {
            log.info("Told agents about {} client birthdays and anniversaries", told);
        }
    }

    /**
     * Raises today's notifications not raised yet; how many it raised. One transaction for the
     * run: should another server write the same notice at the same moment, this whole run rolls
     * back, its notifications with it, and the other server's run is the one that told everybody.
     */
    @Transactional
    public int notifyFor(LocalDate today) {
        Set<String> seen = new HashSet<>();
        int told = 0;
        for (UpcomingClientDate date : dates.fallingOn(today)) {
            if (!seen.add(date.getClientId() + ":" + date.getKind())) {
                continue;
            }
            if (notifyOne(date, today.getYear())) {
                told++;
            }
        }
        return told;
    }

    private boolean notifyOne(UpcomingClientDate date, int year) {
        if (notices.existsByClientIdAndKindAndOccurrenceYear(date.getClientId(), date.getKind(), year)) {
            return false;
        }
        Client client = clients.findById(date.getClientId()).orElse(null);
        if (client == null) {
            return false;
        }
        notices.saveAndFlush(ClientDateNotice.builder()
                .client(client)
                .kind(date.getKind())
                .occurrenceYear(year)
                .build());
        User recipient = client.getAgent() != null ? client.getAgent()
                : client.getTeam() == null ? null : client.getTeam().getManager();
        NotificationType type = date.getKind() == ClientDateKind.BIRTHDAY
                ? NotificationType.CLIENT_BIRTHDAY
                : NotificationType.PURCHASE_ANNIVERSARY;
        events.clientDate(recipient, client, type, date.getYears(), date.getDealTitle());
        return true;
    }
}
