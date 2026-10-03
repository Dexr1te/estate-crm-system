package com.crm.realestate.service;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.enums.DealKind;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Path;

import java.math.BigDecimal;

/**
 * What a deal's money means, once there are rents as well as sales — in one place, so every total
 * agrees on it.
 *
 * <ul>
 *   <li>The <b>value</b> of a deal (funnel's won value, leaderboard's won value, price insight's sale
 *       price) is what a place sold for. A rent has none: its dealPrice is always null (V50), and the
 *       queries below say {@code kind = SALE} out loud rather than lean on that.</li>
 *   <li>The <b>commission base</b> is the price of a sale and one month's rent of a rent: the agent
 *       earns commissionPercent of it. Rents count towards commission, goals and the leaderboard's
 *       commission like any other won deal.</li>
 *   <li>Counts of deals — won, lost, in the funnel — take rents and sales alike: a rent is a deal
 *       the agent closed.</li>
 * </ul>
 */
public final class DealMoney {

    /** The commission base in JPQL, for a deal aliased {@code d}. */
    public static final String JPQL_COMMISSION_BASE =
            "(CASE WHEN d.kind = com.crm.realestate.enums.DealKind.RENT THEN d.monthlyRent ELSE d.dealPrice END)";

    private DealMoney() {
    }

    /** What the commission is a percentage of: the price of a sale, one month's rent of a rent. */
    public static BigDecimal commissionBase(Deal deal) {
        return deal.getKind() == DealKind.RENT ? deal.getMonthlyRent() : deal.getDealPrice();
    }

    /** {@link #commissionBase(Deal)} as a criteria expression. */
    public static Expression<BigDecimal> commissionBase(CriteriaBuilder cb, Path<Deal> deal) {
        return cb.<BigDecimal>selectCase()
                .when(cb.equal(deal.get("kind"), DealKind.RENT), deal.<BigDecimal>get("monthlyRent"))
                .otherwise(deal.<BigDecimal>get("dealPrice"));
    }

    /** A deal's sale value: its price for a sale, null for a rent. */
    public static Expression<BigDecimal> saleValue(CriteriaBuilder cb, Path<Deal> deal) {
        return cb.<BigDecimal>selectCase()
                .when(cb.equal(deal.get("kind"), DealKind.SALE), deal.<BigDecimal>get("dealPrice"))
                .otherwise(cb.nullLiteral(BigDecimal.class));
    }
}
