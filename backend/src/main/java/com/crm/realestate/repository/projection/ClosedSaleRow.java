package com.crm.realestate.repository.projection;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** A won deal on a listing: what it actually went for, and when. */
public record ClosedSaleRow(Long propertyId, BigDecimal dealPrice, LocalDateTime closedAt) {
}
