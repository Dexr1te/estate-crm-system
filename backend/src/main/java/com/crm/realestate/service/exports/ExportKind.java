package com.crm.realestate.service.exports;

import com.crm.realestate.exception.ResourceNotFoundException;

import java.util.Locale;

/** What a spreadsheet is being exported from. The path segment is its lower-case name. */
public enum ExportKind {
    CLIENTS,
    PROPERTIES,
    DEALS;

    public static ExportKind fromPath(String value) {
        try {
            return valueOf(value.toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new ResourceNotFoundException("Nothing to export as " + value);
        }
    }

    public String path() {
        return name().toLowerCase(Locale.ROOT);
    }
}
