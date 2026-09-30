package com.crm.realestate.service;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * What a typed tag becomes, and when two typed tags are the same one.
 *
 * <p>A tag is trimmed, a leading {@code #} is dropped (people type hashtags), and runs of spaces
 * inside it become one: {@code "  #new   build "} is {@code "new build"}. A comma or a semicolon
 * separates tags rather than belonging to one, so {@code "investor, urgent"} typed into one field
 * is two tags — which also keeps a comma out of every tag, and the export can list them with one.
 *
 * <p>Two tags are the same when they are equal without case ({@link #key}). Which casing is kept
 * is not decided here: inside a request the first spelling wins, and against the agency the
 * vocabulary's own spelling wins (see {@code ClientTagService}).
 */
public final class ClientTags {

    /** Characters in one tag. A label, not a note. */
    public static final int MAX_LENGTH = 32;

    /** Tags on one client. Past a handful, a tag stops telling one client from another. */
    public static final int MAX_PER_CLIENT = 10;

    public static final String TOO_LONG = "TAG_TOO_LONG";
    public static final String TOO_MANY = "TOO_MANY_TAGS";

    private static final Pattern SEPARATORS = Pattern.compile("[,;]");
    private static final Pattern SPACES = Pattern.compile("[\\s\\u00A0\\u2007\\u202F]+");

    private ClientTags() {
    }

    /** The shown form of one typed tag, or null when nothing is left of it. */
    public static String display(String raw) {
        if (raw == null) {
            return null;
        }
        String collapsed = SPACES.matcher(raw).replaceAll(" ").strip();
        int hashes = 0;
        while (hashes < collapsed.length() && collapsed.charAt(hashes) == '#') {
            hashes++;
        }
        String name = collapsed.substring(hashes).strip();
        return name.isEmpty() ? null : name;
    }

    /** What makes two spellings one tag. */
    public static String key(String display) {
        return display.toLowerCase(Locale.ROOT);
    }

    /**
     * Every tag in {@code raw}, split on commas and semicolons, normalised, and without repeats —
     * the first spelling of each kept, in the order typed. Limits are not applied; see
     * {@link #violation}.
     */
    public static List<String> normalise(Collection<String> raw) {
        Map<String, String> byKey = new LinkedHashMap<>();
        if (raw == null) {
            return List.of();
        }
        for (String typed : raw) {
            if (typed == null) {
                continue;
            }
            for (String part : SEPARATORS.split(typed)) {
                String name = display(part);
                if (name != null) {
                    byKey.putIfAbsent(key(name), name);
                }
            }
        }
        return new ArrayList<>(byKey.values());
    }

    /** {@link #TOO_LONG}, {@link #TOO_MANY}, or null when normalised tags are within the limits. */
    public static String violation(List<String> normalised) {
        for (String name : normalised) {
            if (name.codePointCount(0, name.length()) > MAX_LENGTH) {
                return TOO_LONG;
            }
        }
        return normalised.size() > MAX_PER_CLIENT ? TOO_MANY : null;
    }
}
