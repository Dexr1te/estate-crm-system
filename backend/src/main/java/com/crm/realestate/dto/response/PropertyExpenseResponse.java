package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ExpenseCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** One payment for a listing. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyExpenseResponse {
    private Long id;
    private Long propertyId;
    private ExpenseCategory category;
    /** In the agency's currency. */
    private BigDecimal amount;
    private LocalDate spentOn;
    private String note;
    /** Who recorded it; null once their account is gone. */
    private Long createdById;
    private String createdByName;
    private LocalDateTime createdAt;
    /** Whether the caller may delete it: who recorded it, a manager or an admin. */
    private boolean canDelete;
}
