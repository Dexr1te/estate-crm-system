package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ExpenseCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/** What went on one category, in the agency's currency. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExpenseCategoryTotal {
    private ExpenseCategory category;
    private BigDecimal total;
}
