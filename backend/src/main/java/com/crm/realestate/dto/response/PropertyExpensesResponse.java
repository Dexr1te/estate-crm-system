package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/** What a listing has cost the agency: every payment, the latest first, and the sums. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyExpensesResponse {
    private List<PropertyExpenseResponse> items;
    /** Everything spent on the listing, in the agency's currency. */
    private BigDecimal total;
    /** Per category that has any, the largest first. */
    private List<ExpenseCategoryTotal> byCategory;
}
