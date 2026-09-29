package com.crm.realestate.repository.projection;

import com.crm.realestate.enums.PropertyStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** The few columns a price insight reads off a listing — never its agent or its clients. */
public record PriceComparableRow(Long id, String title, BigDecimal price, Double areaSqm,
                                 Integer rooms, PropertyStatus status, LocalDateTime createdAt) {
}
