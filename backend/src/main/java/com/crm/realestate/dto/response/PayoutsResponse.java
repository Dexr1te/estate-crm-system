package com.crm.realestate.dto.response;

import com.crm.realestate.enums.CommissionPartyKind;
import com.crm.realestate.enums.PayoutStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * The shares of won deals' commissions and whether each has been paid out: a manager's whole
 * agency, an agent's own. Amounts are in the agency's currency. The totals and {@link #byAgent}
 * cover every share in the reader's view whichever {@link #status} the items are filtered to.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayoutsResponse {

    /** Which shares {@link #items} lists. */
    private PayoutStatus status;

    /** Whether the reader sees the whole agency (a manager or an admin) or only their own shares. */
    private boolean wholeTeam;

    /** Still owed, over every share in view. */
    private BigDecimal unpaidTotal;

    /** Already paid out, over every share in view. */
    private BigDecimal paidTotal;

    /** What each person (or co-broker) is still owed, largest first; nobody who is owed nothing. */
    private List<PartyTotal> byAgent;

    /** Unpaid: the longest-waiting first. Paid: the latest payout first. */
    private List<Item> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Item {
        private Long shareId;
        private Long dealId;
        private String dealTitle;
        /** When the deal was won. */
        private LocalDateTime closedAt;
        /** A colleague or a co-broker: the deal's agent holds no share of their own here. */
        private CommissionPartyKind kind;
        /** The colleague; null for a co-broker. */
        private Long agentId;
        /** The colleague's name, or the co-broker's. */
        private String agentName;
        /** A co-broker's agency, if given. */
        private String agency;
        private BigDecimal percent;
        /** What the share comes to; null while the deal's price or rate is unknown. */
        private BigDecimal amount;
        private boolean paid;
        private LocalDateTime paidAt;
        private Long paidById;
        private String paidByName;
        private String note;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PartyTotal {
        private CommissionPartyKind kind;
        /** The colleague; null for a co-broker. */
        private Long agentId;
        private String name;
        private String agency;
        private BigDecimal unpaid;
        /** How many shares make up {@link #unpaid}. */
        private int shares;
    }
}
