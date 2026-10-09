package com.crm.realestate.service;

import com.crm.realestate.dto.request.PropertyExpenseRequest;
import com.crm.realestate.dto.response.ExpenseCategoryTotal;
import com.crm.realestate.dto.response.ExpenseSummaryResponse;
import com.crm.realestate.dto.response.PropertyExpenseResponse;
import com.crm.realestate.dto.response.PropertyExpensesResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyExpense;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ExpenseCategory;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyExpenseRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Tuple;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * What the agency spends marketing its listings: the photographer, ads, staging, cleaning, the
 * lawyer.
 *
 * <p><b>Who sees what.</b> An expense is on the listing, so it sits behind the listing's wall: the
 * whole agency sees what a listing has cost, whatever their data scope, and another agency is told
 * the listing does not exist. The period summary is analytics, and counts like the analytics
 * screen does: a manager the agency's listings, an agent the listings in their data scope (their
 * own, on their own records), an admin everyone's.
 *
 * <p><b>Who changes what.</b> Anyone who can see the listing records what was spent on it. Who
 * recorded an expense, a manager or an admin deletes it; anyone else is refused (403). Nothing is
 * edited in place: a wrong figure is deleted and recorded again.
 *
 * <p><b>The rules.</b> The amount is above zero, and the day it was paid is not after the agency's
 * today (EXPENSE_DATE_IN_FUTURE). A summary's period ends no earlier than it starts
 * (INVALID_PERIOD).
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyExpenseService {

    /** How many listings the summary names. */
    static final int TOP_LISTINGS = 5;

    private static final BigDecimal NOTHING = BigDecimal.ZERO.setScale(2);

    private final PropertyExpenseRepository expenseRepository;
    private final PropertyService propertyService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final AgencyCalendar calendar;
    private final EntityManager entityManager;

    // One listing -------------------------------------------------------------------------

    /** A listing's expenses, the latest paid first, with the total and the sum per category. */
    public PropertyExpensesResponse forProperty(Long propertyId) {
        User user = securityUtils.getCurrentUser();
        Property property = propertyService.requireVisible(propertyId, user);
        List<PropertyExpense> expenses = expenseRepository.findByPropertyNewestFirst(property.getId());

        Map<ExpenseCategory, BigDecimal> sums = new EnumMap<>(ExpenseCategory.class);
        for (PropertyExpense e : expenses) {
            sums.merge(e.getCategory(), e.getAmount(), BigDecimal::add);
        }
        List<ExpenseCategoryTotal> byCategory = largestFirst(sums);
        return PropertyExpensesResponse.builder()
                .items(expenses.stream().map(e -> toResponse(e, user)).toList())
                .total(totalOf(byCategory))
                .byCategory(byCategory)
                .build();
    }

    @Transactional
    public PropertyExpenseResponse create(Long propertyId, PropertyExpenseRequest request) {
        User user = securityUtils.getCurrentUser();
        Property property = propertyService.requireVisible(propertyId, user);
        if (request.getSpentOn().isAfter(calendar.today())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EXPENSE_DATE_IN_FUTURE",
                    "An expense is recorded once it is paid, not before");
        }
        PropertyExpense expense = expenseRepository.save(PropertyExpense.builder()
                .team(property.getTeam())
                .property(property)
                .category(request.getCategory())
                .amount(request.getAmount())
                .spentOn(request.getSpentOn())
                .note(strip(request.getNote()))
                .createdBy(user)
                .build());
        return toResponse(expense, user);
    }

    @Transactional
    public void delete(Long propertyId, Long expenseId) {
        User user = securityUtils.getCurrentUser();
        Property property = propertyService.requireVisible(propertyId, user);
        PropertyExpense expense = expenseRepository.findOnProperty(expenseId, property.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with id: " + expenseId));
        if (!canDelete(expense, user)) {
            throw new AccessDeniedException("Only who recorded this expense or a manager can delete it");
        }
        expenseRepository.delete(expense);
    }

    // A period ----------------------------------------------------------------------------

    /**
     * What was spent over {@code [from, to]}, both days included — this month unless told — on the
     * listings the caller counts: in total, per category, and the {@value #TOP_LISTINGS} listings
     * that cost the most. Two grouped statements, however many expenses there are.
     */
    public ExpenseSummaryResponse summary(LocalDate from, LocalDate to) {
        LocalDate start = from != null ? from : calendar.today().withDayOfMonth(1);
        LocalDate end = to != null ? to : start.withDayOfMonth(start.lengthOfMonth());
        if (end.isBefore(start)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PERIOD",
                    "The period has to end no earlier than it starts");
        }
        User user = securityUtils.getCurrentUser();
        Specification<Property> listings = scopeService.isAgent(user)
                ? scopeService.<Property>visibleTo(user)
                : scopeService.<Property>visibleToTeam(user);

        List<ExpenseCategoryTotal> byCategory = byCategory(listings, start, end);
        return ExpenseSummaryResponse.builder()
                .from(start)
                .to(end)
                .total(totalOf(byCategory))
                .byCategory(byCategory)
                .topListings(topListings(listings, start, end))
                .build();
    }

    private List<ExpenseCategoryTotal> byCategory(Specification<Property> listings, LocalDate start, LocalDate end) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<PropertyExpense> root = query.from(PropertyExpense.class);
        Expression<ExpenseCategory> category = root.get("category");
        query.multiselect(category.alias("category"), cb.sum(root.<BigDecimal>get("amount")).alias("total"));
        query.where(counted(root, query, cb, listings, start, end));
        query.groupBy(category);

        Map<ExpenseCategory, BigDecimal> sums = new EnumMap<>(ExpenseCategory.class);
        for (Tuple row : entityManager.createQuery(query).getResultList()) {
            sums.put(row.get("category", ExpenseCategory.class), row.get("total", BigDecimal.class));
        }
        return largestFirst(sums);
    }

    private List<ExpenseSummaryResponse.Listing> topListings(Specification<Property> listings,
                                                             LocalDate start, LocalDate end) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Tuple> query = cb.createTupleQuery();
        Root<PropertyExpense> root = query.from(PropertyExpense.class);
        Join<PropertyExpense, Property> property = root.join("property");
        Expression<BigDecimal> total = cb.sum(root.<BigDecimal>get("amount"));
        query.multiselect(property.get("id").alias("id"), property.get("title").alias("title"),
                total.alias("total"));
        query.where(counted(root, query, cb, listings, start, end));
        query.groupBy(property.get("id"), property.get("title"));
        query.orderBy(cb.desc(total), cb.asc(property.get("id")));

        return entityManager.createQuery(query).setMaxResults(TOP_LISTINGS).getResultList().stream()
                .map(row -> ExpenseSummaryResponse.Listing.builder()
                        .propertyId(row.get("id", Long.class))
                        .title(row.get("title", String.class))
                        .total(money(row.get("total", BigDecimal.class)))
                        .build())
                .toList();
    }

    /**
     * Paid within the period, on a listing the caller counts. The listings come from
     * {@link ScopeService} itself, as a subquery, so the wall is the one every other read uses.
     */
    private static Predicate counted(Root<PropertyExpense> root, CriteriaQuery<?> query, CriteriaBuilder cb,
                                     Specification<Property> listings, LocalDate start, LocalDate end) {
        Subquery<Long> visible = query.subquery(Long.class);
        Root<Property> property = visible.from(Property.class);
        visible.select(property.get("id")).where(listings.toPredicate(property, query, cb));
        return cb.and(
                cb.greaterThanOrEqualTo(root.<LocalDate>get("spentOn"), start),
                cb.lessThanOrEqualTo(root.<LocalDate>get("spentOn"), end),
                root.get("property").get("id").in(visible));
    }

    // Rules and mapping -------------------------------------------------------------------

    private boolean canDelete(PropertyExpense expense, User user) {
        return scopeService.isAdmin(user) || scopeService.isManager(user)
                || (expense.getCreatedBy() != null && Objects.equals(expense.getCreatedBy().getId(), user.getId()));
    }

    private PropertyExpenseResponse toResponse(PropertyExpense e, User user) {
        User author = e.getCreatedBy();
        return PropertyExpenseResponse.builder()
                .id(e.getId())
                .propertyId(e.getProperty().getId())
                .category(e.getCategory())
                .amount(money(e.getAmount()))
                .spentOn(e.getSpentOn())
                .note(e.getNote())
                .createdById(author == null ? null : author.getId())
                .createdByName(author == null ? null : author.getFullName())
                .createdAt(e.getCreatedAt())
                .canDelete(canDelete(e, user))
                .build();
    }

    /** The categories that have any, the largest first; ties in the enum's order. */
    private static List<ExpenseCategoryTotal> largestFirst(Map<ExpenseCategory, BigDecimal> sums) {
        List<ExpenseCategoryTotal> totals = new ArrayList<>();
        sums.forEach((category, sum) -> {
            if (sum != null && sum.signum() > 0) {
                totals.add(ExpenseCategoryTotal.builder().category(category).total(money(sum)).build());
            }
        });
        totals.sort(Comparator.comparing(ExpenseCategoryTotal::getTotal).reversed()
                .thenComparing(ExpenseCategoryTotal::getCategory));
        return totals;
    }

    private static BigDecimal totalOf(List<ExpenseCategoryTotal> byCategory) {
        return byCategory.stream().map(ExpenseCategoryTotal::getTotal).reduce(NOTHING, BigDecimal::add);
    }

    private static BigDecimal money(BigDecimal value) {
        return value == null ? NOTHING : value.setScale(2, RoundingMode.HALF_UP);
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
