package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/** The lease goes on: its new last day, and the new rent when it changed. */
@Data
public class RenewLeaseRequest {

    @NotNull(message = "The new last day of the lease is required")
    private LocalDate leaseEnd;

    /** Left out, the rent stays what it was. */
    private BigDecimal monthlyRent;
}
