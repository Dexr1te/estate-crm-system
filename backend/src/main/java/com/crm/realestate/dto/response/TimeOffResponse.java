package com.crm.realestate.dto.response;

import com.crm.realestate.enums.TimeOffKind;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * An absence as the app shows it: who, why, the days, the cover, and the meetings the absent
 * person still has on those days — a warning, nothing is moved or refused because of them.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimeOffResponse {
    private Long id;
    private Long userId;
    private String userName;
    private TimeOffKind kind;
    private LocalDate startDate;
    private LocalDate endDate;
    /** How many days it takes in, the first and the last included. */
    private long days;
    private String note;
    /** Who covers; null when nobody does, or their account is gone. */
    private Long coverId;
    private String coverName;
    private Long createdById;
    private String createdByName;
    /** Whether the person is away on the agency's today. */
    private boolean current;
    /** Whether the caller may change or cancel it. */
    private boolean canEdit;
    /** How many meetings still to happen the absent person holds on one of these days. */
    private int conflictCount;
    /**
     * Those meetings, soonest first — only when the caller's data scope reaches the absent
     * person's records; otherwise empty, and {@link #conflictCount} alone says there are some.
     */
    private List<Conflict> conflicts;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Conflict {
        private Long meetingId;
        private String title;
        private LocalDateTime scheduledAt;
        private String clientName;
        private String propertyTitle;
    }
}
