package com.crm.realestate.service;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Partner;
import com.crm.realestate.enums.ReferralFeeType;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * What the agency owes a partner on one won deal of a client the partner sent.
 *
 * <ul>
 *   <li>{@code PERCENT}: that share of the agency's commission, which is commissionPercent of
 *       {@link DealMoney#commissionBase(Deal)} — the price of a sale, one month's rent of a rent.
 *       A deal without a commission percent or a base has no commission on record, so its fee is
 *       unknown rather than zero.</li>
 *   <li>{@code FIXED}: the amount, once per won deal, whatever the deal came to.</li>
 *   <li>No rule: nothing.</li>
 * </ul>
 *
 * <p>The partner's current rule is applied to every won deal: the agency changes the rule when it
 * agrees a new one, and the total says what that rule comes to. Amounts are in the agency's
 * currency, like the deals themselves.
 */
public final class ReferralFee {

    private static final BigDecimal HUNDRED = BigDecimal.valueOf(100);

    private ReferralFee() {
    }

    /** The fee on {@code deal}, or null when the rule is a percentage and the deal has no commission. */
    public static BigDecimal on(Partner partner, Deal deal) {
        if (partner.getFeeType() == null || partner.getFeeValue() == null) {
            return BigDecimal.ZERO;
        }
        if (partner.getFeeType() == ReferralFeeType.FIXED) {
            return partner.getFeeValue().setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal base = DealMoney.commissionBase(deal);
        BigDecimal percent = deal.getCommissionPercent();
        if (base == null || percent == null) {
            return null;
        }
        return base.multiply(percent).multiply(partner.getFeeValue())
                .divide(HUNDRED.multiply(HUNDRED), 2, RoundingMode.HALF_UP);
    }
}
