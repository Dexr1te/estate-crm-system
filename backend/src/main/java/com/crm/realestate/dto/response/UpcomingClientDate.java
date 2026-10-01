package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientDateKind;
import com.crm.realestate.enums.ClientType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/** A birthday or a purchase anniversary coming up, and who to greet. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpcomingClientDate {
    private ClientDateKind kind;
    /** The day it falls on this time; the 29th of February is the 28th in a common year. */
    private LocalDate date;
    /** 0 today, 1 tomorrow. */
    private int daysAway;
    /**
     * The age the client turns, or how many years since the deal was won. Null for a birthday
     * whose year is not known.
     */
    private Integer years;

    private Long clientId;
    private String clientName;
    private String phone;
    private ClientType clientType;
    private Long agentId;
    private String agentName;

    /** PURCHASE_ANNIVERSARY only: the deal that was won, and its listing if it had one. */
    private Long dealId;
    private String dealTitle;
    private String propertyTitle;
}
