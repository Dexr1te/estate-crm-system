package com.crm.realestate.service.imports;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A cell as people type it into a spreadsheet, read as the value it stands for.
 *
 * <p>Every reader returns null for a value it cannot read; the caller tells an empty cell from an
 * unreadable one and reports the latter.
 */
public final class ImportValues {

    private ImportValues() {
    }

    // Numbers -----------------------------------------------------------------------------------

    private static final Pattern MULTIPLIER = Pattern.compile(
            "(млрд|миллиард\\w*|bn|billion|mlrd|b"
                    + "|млн|миллион\\w*|mln|million|mio|m"
                    + "|тыс|тысяч\\w*|мың|k|thousand)\\.?$");

    /** Currency marks and words that may sit around an amount and mean nothing to its value. */
    private static final Pattern CURRENCY = Pattern.compile(
            "[$€₸₽£]|kzt|usd|eur|rub|uzs|kgs|тенге|теңге|тг|руб\\w*|р\\.|сум\\w*|сом\\w*|so['ʻ’]?m\\b");

    /**
     * A price: "12 500 000", "12,5 млн", "12.5M", "$12,500,000", "12.500.000 тг".
     *
     * <p>A single comma or dot followed by exactly three digits, with no multiplier, is a thousands
     * separator — a flat at "12,500" is twelve and a half thousand, not twelve and a half.
     */
    public static BigDecimal price(String raw) {
        if (raw == null) {
            return null;
        }
        String s = raw.toLowerCase(Locale.ROOT).strip();
        s = CURRENCY.matcher(s).replaceAll("");
        s = squeeze(s);
        BigDecimal multiplier = BigDecimal.ONE;
        Matcher m = MULTIPLIER.matcher(s);
        if (m.find() && m.start() > 0) {
            multiplier = multiplierOf(m.group(1));
            s = s.substring(0, m.start());
        }
        BigDecimal number = number(s, multiplier.equals(BigDecimal.ONE));
        return number == null ? null : number.multiply(multiplier).stripTrailingZeros();
    }

    /** An area or a budget-free measure: a comma is a decimal point here ("45,5"). */
    public static BigDecimal decimal(String raw) {
        if (raw == null) {
            return null;
        }
        String s = raw.toLowerCase(Locale.ROOT).strip();
        s = s.replaceAll("(м²|м2|кв\\.?\\s*м\\.?|sq\\.?\\s*m|m²|m2|sqm)$", "");
        return number(squeeze(s), false);
    }

    /**
     * A whole number: "3", "3 комн.", "3-к". A floor written "5/9" reads as 5 here; see
     * {@link #floorOf}.
     */
    public static Integer integer(String raw) {
        if (raw == null) {
            return null;
        }
        Matcher m = Pattern.compile("^\\s*(-?\\d{1,9})(?:\\s*[-\\s]?\\p{L}*\\.?)?\\s*$").matcher(raw);
        return m.matches() ? Integer.valueOf(m.group(1)) : null;
    }

    private static final Pattern FLOOR_OF = Pattern.compile("^\\s*(-?\\d{1,4})\\s*(?:/|из|of|из-за)\\s*(\\d{1,4})\\s*$");

    /** "5/9" or "5 из 9": the floor and the building's height, or null if not in that form. */
    public static int[] floorOf(String raw) {
        if (raw == null) {
            return null;
        }
        Matcher m = FLOOR_OF.matcher(raw.toLowerCase(Locale.ROOT));
        return m.matches() ? new int[]{Integer.parseInt(m.group(1)), Integer.parseInt(m.group(2))} : null;
    }

    // Words -------------------------------------------------------------------------------------

    private static final Map<String, ClientType> CLIENT_TYPES = new HashMap<>();
    private static final Map<String, PropertyType> PROPERTY_TYPES = new HashMap<>();
    private static final Map<String, PropertyStatus> STATUSES = new HashMap<>();

    static {
        words(CLIENT_TYPES, ClientType.BUYER, "buyer", "buy", "purchase", "b", "покупатель",
                "покупательница", "покупка", "купить", "покупает", "п", "сатып алушы", "сатып алу",
                "алушы");
        words(CLIENT_TYPES, ClientType.SELLER, "seller", "sell", "sale", "s", "продавец",
                "продавщица", "продажа", "продать", "продает", "собственник", "сатушы", "сату",
                "иесі");
        words(PROPERTY_TYPES, PropertyType.APARTMENT, "apartment", "flat", "apt", "квартира", "кв",
                "квартиры", "студия", "пәтер", "апартаменты");
        words(PROPERTY_TYPES, PropertyType.HOUSE, "house", "home", "cottage", "villa", "дом",
                "коттедж", "таунхаус", "дача", "частный дом", "үй", "жеке үй", "саяжай");
        words(PROPERTY_TYPES, PropertyType.COMMERCIAL, "commercial", "retail", "shop", "коммерция",
                "коммерческая", "коммерческая недвижимость", "коммерческое", "магазин",
                "помещение", "коммерциялық", "дүкен");
        words(PROPERTY_TYPES, PropertyType.LAND, "land", "plot", "lot", "участок", "земля",
                "земельный участок", "жер", "жер учаскесі", "учаскесі");
        words(PROPERTY_TYPES, PropertyType.OFFICE, "office", "офис", "кабинет", "кеңсе", "офис орны");
        words(STATUSES, PropertyStatus.AVAILABLE, "available", "active", "for sale", "on sale",
                "open", "в продаже", "продается", "свободна", "свободно", "свободен", "активна",
                "активно", "актуально", "доступно", "доступна", "сатылымда", "бос", "қолжетімді");
        words(STATUSES, PropertyStatus.RESERVED, "reserved", "booked", "pending", "hold",
                "on hold", "бронь", "забронирована", "забронировано", "зарезервирована",
                "резерв", "задаток", "брондалған", "броньда");
        words(STATUSES, PropertyStatus.SOLD, "sold", "closed", "продана", "продано", "продан",
                "сделка закрыта", "сатылды", "сатылған");
    }

    @SafeVarargs
    private static <E> void words(Map<String, E> into, E value, String... synonyms) {
        into.put(word(value.toString()), value);
        for (String synonym : synonyms) {
            into.put(word(synonym), value);
        }
    }

    /** Lower case, ё as е, punctuation as spaces, runs of spaces as one. */
    public static String word(String raw) {
        if (raw == null) {
            return "";
        }
        return raw.toLowerCase(Locale.ROOT)
                .replace('ё', 'е')
                .replaceAll("[^\\p{L}\\p{N}]+", " ")
                .strip();
    }

    public static ClientType clientType(String raw) {
        return CLIENT_TYPES.get(word(raw));
    }

    public static PropertyType propertyType(String raw) {
        return PROPERTY_TYPES.get(word(raw));
    }

    public static PropertyStatus propertyStatus(String raw) {
        return STATUSES.get(word(raw));
    }

    /** Drops spaces of every width and apostrophes used as thousands separators. */
    private static String squeeze(String s) {
        return s.replaceAll("[\\s\\u00A0\\u202F\\u2009'’]", "");
    }

    private static BigDecimal multiplierOf(String word) {
        if (word.startsWith("млрд") || word.startsWith("миллиард") || word.equals("bn") || word.equals("b")
                || word.equals("billion") || word.equals("mlrd")) {
            return BigDecimal.valueOf(1_000_000_000L);
        }
        if (word.startsWith("тыс") || word.equals("мың") || word.equals("k") || word.equals("thousand")) {
            return BigDecimal.valueOf(1_000L);
        }
        return BigDecimal.valueOf(1_000_000L);
    }

    /**
     * Digits with at most one decimal separator, after deciding which of comma and dot is which.
     * With both present the later one is the decimal point.
     */
    private static BigDecimal number(String s, boolean threeDigitsIsThousands) {
        if (s.isEmpty() || !s.matches("-?[0-9.,]+")) {
            return null;
        }
        int comma = s.lastIndexOf(',');
        int dot = s.lastIndexOf('.');
        String normalized;
        if (comma >= 0 && dot >= 0) {
            char decimal = comma > dot ? ',' : '.';
            char grouping = decimal == ',' ? '.' : ',';
            normalized = s.replace(String.valueOf(grouping), "").replace(decimal, '.');
        } else if (comma >= 0 || dot >= 0) {
            char sep = comma >= 0 ? ',' : '.';
            int count = s.length() - s.replace(String.valueOf(sep), "").length();
            int lastIndex = s.lastIndexOf(sep);
            boolean grouping = count > 1
                    || (threeDigitsIsThousands && s.length() - lastIndex - 1 == 3 && lastIndex > 0);
            normalized = grouping ? s.replace(String.valueOf(sep), "") : s.replace(sep, '.');
        } else {
            normalized = s;
        }
        try {
            return new BigDecimal(normalized);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
