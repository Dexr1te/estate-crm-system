package com.crm.realestate.controller;

import com.crm.realestate.dto.request.PropertyExpenseRequest;
import com.crm.realestate.dto.response.ExpenseSummaryResponse;
import com.crm.realestate.dto.response.PropertyExpenseResponse;
import com.crm.realestate.dto.response.PropertyExpensesResponse;
import com.crm.realestate.service.PropertyExpenseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

/**
 * What the agency spends marketing its listings. See {@link PropertyExpenseService} for who sees
 * and who deletes what.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Expenses", description = "Money spent on listings: photos, ads, staging and the like")
@SecurityRequirement(name = "bearerAuth")
public class PropertyExpenseController {

    private final PropertyExpenseService expenseService;

    @GetMapping("/properties/{propertyId}/expenses")
    @Operation(summary = "A listing's expenses, the latest paid first, with the total and the sum per category")
    public ResponseEntity<PropertyExpensesResponse> forProperty(@PathVariable Long propertyId) {
        return ResponseEntity.ok(expenseService.forProperty(propertyId));
    }

    @PostMapping("/properties/{propertyId}/expenses")
    @Operation(summary = "Record money spent on a listing (EXPENSE_DATE_IN_FUTURE for a day after today)")
    public ResponseEntity<PropertyExpenseResponse> create(@PathVariable Long propertyId,
                                                          @Valid @RequestBody PropertyExpenseRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(expenseService.create(propertyId, request));
    }

    @DeleteMapping("/properties/{propertyId}/expenses/{expenseId}")
    @Operation(summary = "Delete an expense: who recorded it, a manager or an admin")
    public ResponseEntity<Void> delete(@PathVariable Long propertyId, @PathVariable Long expenseId) {
        expenseService.delete(propertyId, expenseId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Counted like the analytics screen: a manager the agency's listings, an agent the listings in
     * their data scope, an admin everyone's.
     */
    @GetMapping("/expenses/summary")
    @Operation(summary = "Spent on listings over [from, to], both days included (this month by default): "
            + "the total, per category and the five listings that cost the most")
    public ResponseEntity<ExpenseSummaryResponse> summary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(expenseService.summary(from, to));
    }
}
