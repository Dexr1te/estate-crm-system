package com.crm.realestate.dto.request;

import com.crm.realestate.enums.PartnerHandoffStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

/**
 * A client sent to a partner. The day defaults to today and cannot be in the future; the status
 * defaults to SENT. On an update the partner may not change: a different partner is another
 * hand-off.
 */
@Data
public class PartnerHandoffRequest {

    @NotNull(message = "Partner is required")
    private Long partnerId;

    private LocalDate sentOn;

    private PartnerHandoffStatus status;

    @Size(max = 500, message = "Note must be at most 500 characters")
    private String note;
}
