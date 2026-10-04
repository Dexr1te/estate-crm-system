package com.crm.realestate.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;

/**
 * What day it is for the agencies: the date in the zone the client-date and lease reminders run in
 * ({@code app.client-dates.zone}, the server's when blank). Time off is written in these dates, so
 * "away today" means the same day the reminders think it is.
 */
@Component
public class AgencyCalendar {

    private final ZoneId zone;

    public AgencyCalendar(@Value("${app.client-dates.zone:}") String zone) {
        this.zone = zone == null || zone.isBlank() ? ZoneId.systemDefault() : ZoneId.of(zone);
    }

    public LocalDate today() {
        return LocalDate.now(zone);
    }
}
