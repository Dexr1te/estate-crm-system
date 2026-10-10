package com.crm.realestate.enums;

import java.util.Locale;

/** What a star is on — see {@link com.crm.realestate.entity.Star}. */
public enum StarType {
    CLIENT,
    PROPERTY,
    DEAL;

    /** The type an address names, in any case; null when it names none. */
    public static StarType parse(String raw) {
        if (raw == null) {
            return null;
        }
        try {
            return valueOf(raw.strip().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
