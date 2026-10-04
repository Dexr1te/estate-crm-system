package com.crm.realestate.dto.response;

import com.crm.realestate.enums.PartnerHandoffStatus;
import com.crm.realestate.enums.PartnerKind;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** A client sent to a partner, named from both ends so either card can list it. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartnerHandoffResponse {
    private Long id;
    private Long clientId;
    private String clientName;
    private Long partnerId;
    private String partnerName;
    private String partnerCompany;
    private PartnerKind partnerKind;
    private LocalDate sentOn;
    private PartnerHandoffStatus status;
    private String note;
    /** Who sent them; null once that account is closed. */
    private Long sentById;
    private String sentByName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
