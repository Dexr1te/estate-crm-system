package com.crm.realestate.dto.response;

import com.crm.realestate.enums.CommissionPartyKind;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Who gets what of a deal's commission. Always lists the deal's agent first, with what the others
 * leave them (100% when nothing is shared), then the shares in the order they were entered.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommissionSplitResponse {

    private Long dealId;

    /** The whole commission in the agency's currency; null until the base and the rate are known. */
    private BigDecimal commission;

    /** Whether anybody but the deal's agent has a share. */
    private boolean split;

    /** Whether the caller may change it: the deal's agent, a manager or an admin. */
    private boolean editable;

    private List<Share> shares;

    /**
     * Who may be given a share, when the caller may edit: the active agents and managers of the
     * deal's agency, the deal's agent left out. Empty otherwise.
     */
    private List<Colleague> colleagues;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Share {
        private CommissionPartyKind kind;
        /** The deal's agent or a colleague; null for a co-broker. */
        private Long userId;
        /** The person's name, or the co-broker's. */
        private String name;
        /** A co-broker's agency, if given. */
        private String agency;
        private BigDecimal percent;
        /**
         * What the share comes to; null while the commission is unknown. The agent's is what the
         * others' rounded amounts leave, so the amounts always add up to the commission.
         */
        private BigDecimal amount;
        /** False for a colleague who has since been deactivated; their share stands. */
        private boolean active;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Colleague {
        private Long id;
        private String fullName;
    }
}
