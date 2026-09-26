package com.crm.realestate.service.imports;

import com.crm.realestate.exception.ResourceNotFoundException;

import java.util.Locale;

/** What a spreadsheet is being imported as. The path segment is its lower-case name. */
public enum ImportKind {
    CLIENTS,
    PROPERTIES;

    public static ImportKind fromPath(String value) {
        try {
            return valueOf(value.toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new ResourceNotFoundException("Nothing to import as " + value);
        }
    }

    public String path() {
        return name().toLowerCase(Locale.ROOT);
    }
}
