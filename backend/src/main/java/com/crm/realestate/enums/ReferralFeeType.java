package com.crm.realestate.enums;

/** How a partner's referral fee is worked out on a won deal. See {@code ReferralFee}. */
public enum ReferralFeeType {
    /** A percentage of the agency's commission on the deal. */
    PERCENT,
    /** A fixed amount per won deal, in the agency's currency. */
    FIXED
}
