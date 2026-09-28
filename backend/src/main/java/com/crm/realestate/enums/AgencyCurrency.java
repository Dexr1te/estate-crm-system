package com.crm.realestate.enums;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

/**
 * The currencies an agency can price its listings in (ISO 4217).
 *
 * <p>Amounts carry no currency of their own: this only decides the symbol and where it sits. The
 * rules match the app's {@code formatMoney}: in English "$" and "€" lead ("$12,500,000"), every
 * other sign follows the number after a space ("12,500,000 ₸"); in Russian and Kazakh every sign
 * follows and digits are grouped by spaces ("12 500 000 ₸", "12 500 000 $").
 */
public enum AgencyCurrency {
    KZT("₸", "₸"),
    RUB("₽", "₽"),
    USD("$", "$"),
    EUR("€", "€"),
    UZS("UZS", "сум"),
    KGS("KGS", "сом");

    /** A space that keeps "₸" on the same line as its number. */
    private static final char NBSP = ' ';

    private final String englishSign;
    private final String localSign;

    AgencyCurrency(String englishSign, String localSign) {
        this.englishSign = englishSign;
        this.localSign = localSign;
    }

    /** "$" in any language; "сум" in Russian and Kazakh but "UZS" in English. */
    public String sign(Locale locale) {
        return isEnglish(locale) ? englishSign : localSign;
    }

    /** Whole units, grouped the way the reader's language groups digits, with the sign. */
    public String format(BigDecimal amount, Locale locale) {
        if (amount == null) {
            return "";
        }
        boolean english = isEnglish(locale);
        DecimalFormatSymbols symbols = DecimalFormatSymbols.getInstance(Locale.ROOT);
        symbols.setGroupingSeparator(english ? ',' : NBSP);
        symbols.setDecimalSeparator(english ? '.' : ',');
        DecimalFormat format = new DecimalFormat("#,##0", symbols);
        format.setRoundingMode(RoundingMode.HALF_UP);
        BigDecimal abs = amount.abs();
        String digits = format.format(abs);
        String minus = amount.signum() < 0 ? "-" : "";
        boolean leads = english && (this == USD || this == EUR);
        return leads ? minus + englishSign + digits : minus + digits + NBSP + sign(locale);
    }

    private static boolean isEnglish(Locale locale) {
        return locale == null || "en".equals(locale.getLanguage());
    }
}
