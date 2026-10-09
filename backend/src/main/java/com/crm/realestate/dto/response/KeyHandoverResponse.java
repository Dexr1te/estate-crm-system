package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * One time a listing's keys went out, as the app shows it: the listing, who has (or had) them,
 * until when, and who recorded them going out and coming back.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KeyHandoverResponse {
    private Long id;
    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;
    private String propertyCity;
    /** The colleague holding them; null for somebody outside the agency. */
    private Long holderUserId;
    /** Who holds them, by name: the colleague's, or the one typed in. */
    private String holderName;
    private String note;
    private LocalDateTime handedOutAt;
    /** The last day they are to be back, if one was set. */
    private LocalDate dueBackAt;
    /** When they came back; null while they are out. */
    private LocalDateTime returnedAt;
    /** Who recorded the handover; null once their account is gone. */
    private Long handedOutById;
    private String handedOutByName;
    private Long returnedById;
    private String returnedByName;
    /** Out past the last day they were to be back, on the agency's today. */
    private boolean overdue;
}
