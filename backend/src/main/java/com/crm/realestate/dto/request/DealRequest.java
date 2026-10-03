package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class DealRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private DealStatus status = DealStatus.LEAD;

    private BigDecimal dealPrice;

    private BigDecimal budget;

    @DecimalMin(value = "0", inclusive = false, message = "Commission must be above 0%")
    @DecimalMax(value = "100", message = "Commission cannot exceed 100%")
    @Digits(integer = 3, fraction = 2, message = "Commission takes at most two decimal places")
    private BigDecimal commissionPercent;

    private String notes;

    /**
     * SALE or RENT. Left out, a new deal is a sale and an existing one keeps its kind — and its
     * lease: an app that knows nothing of rents cannot turn one into a sale by saving it.
     */
    private DealKind kind;

    /** RENT only, required there: the rent per month, above zero. A rent has no dealPrice. */
    private BigDecimal monthlyRent;

    /** RENT only, required there: the first and the last day of the lease; the end after the start. */
    private LocalDate leaseStart;
    private LocalDate leaseEnd;

    /** RENT only, optional: days before the end to be reminded, 1-365; null for the default 30. */
    private Integer leaseReminderDays;

    /** RENT only, optional: the client who lets the place; the deal's client is the tenant. */
    private Long landlordId;

    /** Required when status is CLOSED_LOST, ignored otherwise. */
    private DealLostReason lostReason;

    @Size(max = 500, message = "The note on why the deal was lost takes at most 500 characters")
    private String lostNote;

    @NotNull(message = "Client ID is required")
    private Long clientId;


    private Long propertyId;

    @NotNull(message = "Agent ID is required")
    private Long agentId;
}