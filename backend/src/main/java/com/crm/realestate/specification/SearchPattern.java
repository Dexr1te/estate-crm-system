package com.crm.realestate.specification;

import java.util.Locale;

/**
 * What was typed in a search box as a lower-cased LIKE pattern that finds it anywhere in a value.
 * {@code %}, {@code _} and the escape itself match as typed, not as wildcards, so "anna_k" finds
 * anna_k@mail.ru and not annask@mail.ru. Pass {@link #ESCAPE} as the like's escape character.
 */
public final class SearchPattern {

    public static final char ESCAPE = '\\';

    private SearchPattern() {}

    public static String contains(String search) {
        String literal = search.trim().toLowerCase(Locale.ROOT)
                .replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
        return "%" + literal + "%";
    }
}
