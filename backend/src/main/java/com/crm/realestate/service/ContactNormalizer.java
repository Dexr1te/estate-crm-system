package com.crm.realestate.service;

import java.util.Locale;

/**
 * The comparable form of a phone number or an email address, so the same person typed two ways
 * is still recognised as one.
 *
 * <p>A phone keeps its digits only. An 11-digit number starting with 8 is the domestic spelling of
 * a +7 number in Kazakhstan and Russia, so "8 916 220-84-11" and "+7 (916) 220 84 11" both become
 * {@code 79162208411}. Fewer than {@value #MIN_PHONE_DIGITS} digits is not a phone anyone can be
 * found by, and normalises to null rather than matching every other half-typed number.
 *
 * <p>An email is trimmed and lower-cased; a blank one is null.
 *
 * <p>The database backfill in {@code V29__client_phone_normalized.sql} spells out the same phone
 * rule in SQL — change both together.
 */
public final class ContactNormalizer {

    static final int MIN_PHONE_DIGITS = 7;

    private ContactNormalizer() {
    }

    public static String phone(String raw) {
        if (raw == null) {
            return null;
        }
        String digits = raw.replaceAll("\\D", "");
        if (digits.length() == 11 && digits.charAt(0) == '8') {
            digits = "7" + digits.substring(1);
        }
        return digits.length() < MIN_PHONE_DIGITS ? null : digits;
    }

    public static String email(String raw) {
        if (raw == null) {
            return null;
        }
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed.toLowerCase(Locale.ROOT);
    }
}
