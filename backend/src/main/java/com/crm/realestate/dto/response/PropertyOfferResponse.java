package com.crm.realestate.dto.response;

import com.crm.realestate.enums.OfferAction;
import com.crm.realestate.enums.OfferParty;
import com.crm.realestate.enums.OfferStatus;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * A buyer's offer on a listing. The negotiation, {@link #history}, comes only with a single offer;
 * lists leave it out.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyOfferResponse {
    private Long id;
    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;
    /** The listing's asking price, to set the offer against. */
    private BigDecimal propertyPrice;
    private Long clientId;
    /** Whether the caller may open the buyer's card; when not, {@link #clientName} is null. */
    private boolean clientVisible;
    private String clientName;
    /** Who holds the buyer's card, so a colleague's buyer can be named without opening it. */
    private String clientAgentName;
    /** Who recorded the offer and follows it up. */
    private Long agentId;
    private String agentName;
    /** The figure on the table now, in the agency's currency. */
    private BigDecimal amount;
    private OfferParty lastParty;
    private String note;
    private LocalDate expiresOn;
    /** Where it stands today: EXPIRED for an open offer past its last day. */
    private OfferStatus status;
    /** Whether another offer on the same listing has been accepted while this one is still open. */
    private boolean otherAccepted;
    /** Whether the caller may counter, accept, reject or withdraw it. */
    private boolean canEdit;
    private LocalDateTime decidedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<Step> history;

    /** One step in the negotiation, the first first. */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Step {
        private Long id;
        private OfferAction action;
        private BigDecimal amount;
        private OfferParty party;
        private String note;
        private Long actorId;
        private String actorName;
        private LocalDateTime createdAt;
    }
}
