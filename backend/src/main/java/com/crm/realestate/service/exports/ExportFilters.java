package com.crm.realestate.service.exports;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * The list filters an export narrows by — the same ones the list screen for that kind takes.
 * Values a kind has no use for are ignored. Enum values arrive as their names ("BUYER") and are
 * read, and refused when unknown, by {@link ExportService}.
 */
public record ExportFilters(
        String type,
        String status,
        String source,
        String city,
        Long agentId,
        String search,
        BigDecimal minPrice,
        BigDecimal maxPrice,
        Integer rooms,
        LocalDate createdFrom,
        LocalDate createdTo,
        LocalDate closedFrom,
        LocalDate closedTo,
        List<String> tags,
        String leadSource) {

    public static ExportFilters none() {
        return new ExportFilters(null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null);
    }

    /** "type=BUYER agentId=7": the filters that were set, for the audit journal. */
    public String describe() {
        Map<String, Object> set = new LinkedHashMap<>();
        set.put("type", type);
        set.put("status", status);
        set.put("source", source);
        set.put("city", city);
        set.put("agentId", agentId);
        set.put("search", search);
        set.put("minPrice", minPrice);
        set.put("maxPrice", maxPrice);
        set.put("rooms", rooms);
        set.put("createdFrom", createdFrom);
        set.put("createdTo", createdTo);
        set.put("closedFrom", closedFrom);
        set.put("closedTo", closedTo);
        set.put("tags", tags == null || tags.isEmpty() ? null : String.join(",", tags));
        set.put("leadSource", leadSource);
        return set.entrySet().stream()
                .filter(e -> e.getValue() != null && !e.getValue().toString().isBlank())
                .map(e -> e.getKey() + "=" + e.getValue())
                .collect(Collectors.joining(" "));
    }
}
