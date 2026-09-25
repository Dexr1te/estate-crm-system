package com.crm.realestate.dto.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** One change of a listing's price. The author is null once they have left. */
@Data
public class PropertyPriceChangeResponse {
    private Long id;
    private Long propertyId;
    private BigDecimal oldPrice;
    private BigDecimal newPrice;
    private Long changedById;
    private String changedByName;
    private LocalDateTime changedAt;
}
