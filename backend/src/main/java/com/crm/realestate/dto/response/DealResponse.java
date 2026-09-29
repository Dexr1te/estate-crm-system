package com.crm.realestate.dto.response;

import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.ChecklistStage;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Data
public class DealResponse {
    private Long id;
    private String title;
    private DealStatus status;
    private BigDecimal dealPrice;
    private BigDecimal budget;
    private BigDecimal commissionPercent;
    /** dealPrice × commissionPercent / 100, or null while either is unknown. */
    private BigDecimal commission;
    private String notes;
    /** Why the deal was lost; null unless CLOSED_LOST, and null on deals lost before it was asked. */
    private DealLostReason lostReason;
    private String lostNote;

    private Long clientId;
    private String clientName;

    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;

    private Long agentId;
    private String agentName;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime closedAt;

    /** How many comments the deal's discussion has; zero for a new deal. */
    private long commentCount;

    /** Checklist lines ticked, and all of them, for the deal's current stage and the ones before. */
    private long checklistDone;
    private long checklistTotal;

    /**
     * Required lines of the stages before the current one that are still open — what a move to
     * NEGOTIATION or CLOSED_WON left behind. The move is never refused over it (the gate is soft);
     * the app warns before it and can show it after. Zero for LEAD and CLOSED_LOST.
     */
    private long openRequired;

    /** Open required lines per checklist stage, so the app can warn before any move. */
    private Map<ChecklistStage, Long> openRequiredByStage = Map.of();
}