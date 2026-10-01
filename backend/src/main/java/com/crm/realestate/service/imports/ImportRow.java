package com.crm.realestate.service.imports;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.service.ClientTags;
import com.crm.realestate.service.ContactNormalizer;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * One spreadsheet row read through the confirmed column mapping: the values it yields, keyed by
 * field, and what is wrong with it, keyed by the same fields.
 *
 * <p>A row with any error is not imported at all — a client without the phone the agent typed is
 * worse than no client, because nobody notices it is incomplete.
 *
 * <p>Error codes are stable strings the app translates: {@code REQUIRED}, {@code INVALID_NUMBER},
 * {@code INVALID_EMAIL}, {@code INVALID_PHONE}, {@code UNKNOWN_VALUE}, {@code TOO_LONG},
 * {@code NEGATIVE}, {@code OUT_OF_RANGE}.
 */
public final class ImportRow {

    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    private final int number;
    private final Map<String, Object> values = new LinkedHashMap<>();
    private final Map<String, String> errors = new LinkedHashMap<>();

    private ImportRow(int number) {
        this.number = number;
    }

    public int number() {
        return number;
    }

    public Map<String, Object> values() {
        return values;
    }

    public Map<String, String> errors() {
        return errors;
    }

    public boolean valid() {
        return errors.isEmpty();
    }

    @SuppressWarnings("unchecked")
    public <T> T get(ImportField field) {
        return (T) values.get(field.key());
    }

    /** Reads {@code row} with {@code mapping.get(i)} naming the field column {@code i} fills. */
    public static ImportRow read(ImportKind kind, CsvTable.Row row, List<ImportField> mapping) {
        ImportRow result = new ImportRow(row.number());
        Map<ImportField, String> cells = new LinkedHashMap<>();
        for (int i = 0; i < mapping.size(); i++) {
            ImportField field = mapping.get(i);
            if (field != null) {
                cells.put(field, row.cell(i).strip());
            }
        }
        for (ImportField field : ImportField.of(kind)) {
            String cell = cells.getOrDefault(field, "");
            if (cell.isEmpty()) {
                if (field.required()) {
                    result.errors.put(field.key(), "REQUIRED");
                }
                continue;
            }
            result.readCell(field, cell);
        }
        result.crossCheck(kind);
        return result;
    }

    private void readCell(ImportField field, String cell) {
        switch (field) {
            case CLIENT_FULL_NAME, PROPERTY_TITLE, PROPERTY_CITY, CLIENT_WANTED_CITY ->
                    text(field, cell, field == ImportField.CLIENT_WANTED_CITY ? 120
                            : field == ImportField.PROPERTY_CITY ? 100 : 255);
            case PROPERTY_ADDRESS -> text(field, cell, 500);
            case CLIENT_NOTES, PROPERTY_DESCRIPTION -> text(field, cell, 2000);
            case CLIENT_PHONE -> {
                if (cell.length() > 50) {
                    errors.put(field.key(), "TOO_LONG");
                } else if (ContactNormalizer.phone(cell) == null) {
                    errors.put(field.key(), "INVALID_PHONE");
                } else {
                    values.put(field.key(), cell);
                }
            }
            case CLIENT_EMAIL -> {
                String email = cell.toLowerCase(java.util.Locale.ROOT);
                if (!EMAIL.matcher(email).matches() || email.length() > 255) {
                    errors.put(field.key(), "INVALID_EMAIL");
                } else {
                    values.put(field.key(), email);
                }
            }
            case CLIENT_TYPE -> known(field, ImportValues.clientType(cell));
            case CLIENT_LEAD_SOURCE -> known(field, ImportValues.leadSource(cell));
            case CLIENT_LEAD_SOURCE_DETAIL -> text(field, cell, 255);
            case CLIENT_TAGS -> {
                // "investor, urgent" — the export writes them so, and people type them so.
                List<String> tags = ClientTags.normalise(List.of(cell));
                String violation = ClientTags.violation(tags);
                if (ClientTags.TOO_LONG.equals(violation)) errors.put(field.key(), "TOO_LONG");
                else if (violation != null) errors.put(field.key(), "OUT_OF_RANGE");
                else if (!tags.isEmpty()) values.put(field.key(), tags);
            }
            case CLIENT_WANTED_TYPE, PROPERTY_TYPE -> known(field, ImportValues.propertyType(cell));
            case PROPERTY_STATUS -> known(field, ImportValues.propertyStatus(cell));
            case CLIENT_BUDGET_MIN, CLIENT_BUDGET_MAX, PROPERTY_PRICE ->
                    amount(field, ImportValues.price(cell), field == ImportField.PROPERTY_PRICE);
            case CLIENT_MIN_AREA, PROPERTY_AREA -> {
                BigDecimal area = ImportValues.decimal(cell);
                if (amount(field, area, field == ImportField.PROPERTY_AREA)) {
                    values.put(field.key(), area.doubleValue());
                }
            }
            case CLIENT_MIN_ROOMS, PROPERTY_ROOMS, PROPERTY_TOTAL_FLOORS -> {
                Integer n = ImportValues.integer(cell);
                if (n == null) errors.put(field.key(), "INVALID_NUMBER");
                else if (n < 0) errors.put(field.key(), "NEGATIVE");
                else if (n > 500) errors.put(field.key(), "OUT_OF_RANGE");
                else values.put(field.key(), n);
            }
            case PROPERTY_FLOOR -> {
                int[] floorOf = ImportValues.floorOf(cell);
                Integer floor = floorOf != null ? Integer.valueOf(floorOf[0]) : ImportValues.integer(cell);
                if (floor == null) {
                    errors.put(field.key(), "INVALID_NUMBER");
                } else {
                    values.put(field.key(), floor);
                    if (floorOf != null) {
                        // "5/9": the height too, unless a column of its own says otherwise.
                        values.putIfAbsent("totalFloors.fromFloor", floorOf[1]);
                    }
                }
            }
        }
    }

    private void text(ImportField field, String cell, int max) {
        if (cell.length() > max) {
            errors.put(field.key(), "TOO_LONG");
        } else {
            values.put(field.key(), cell);
        }
    }

    private void known(ImportField field, Enum<?> value) {
        if (value == null) {
            errors.put(field.key(), "UNKNOWN_VALUE");
        } else {
            values.put(field.key(), value);
        }
    }

    /** False, with the error recorded, unless the amount is a readable, sane number. */
    private boolean amount(ImportField field, BigDecimal value, boolean positive) {
        if (value == null) {
            errors.put(field.key(), "INVALID_NUMBER");
            return false;
        }
        if (value.signum() < 0 || (positive && value.signum() == 0)) {
            errors.put(field.key(), "NEGATIVE");
            return false;
        }
        if (value.precision() - value.scale() > 13) {
            errors.put(field.key(), "OUT_OF_RANGE");
            return false;
        }
        values.put(field.key(), value.setScale(Math.max(0, Math.min(2, value.scale())),
                java.math.RoundingMode.HALF_UP));
        return true;
    }

    private void crossCheck(ImportKind kind) {
        Object fromFloor = values.remove("totalFloors.fromFloor");
        if (kind == ImportKind.CLIENTS) {
            values.putIfAbsent(ImportField.CLIENT_TYPE.key(), ClientType.BUYER);
            if (values.get(ImportField.CLIENT_TYPE.key()) == ClientType.SELLER) {
                // A seller keeps no wish list (see ClientService).
                for (ImportField f : List.of(ImportField.CLIENT_WANTED_CITY, ImportField.CLIENT_WANTED_TYPE,
                        ImportField.CLIENT_BUDGET_MIN, ImportField.CLIENT_BUDGET_MAX,
                        ImportField.CLIENT_MIN_ROOMS, ImportField.CLIENT_MIN_AREA)) {
                    values.remove(f.key());
                    errors.remove(f.key());
                }
            }
            BigDecimal min = get(ImportField.CLIENT_BUDGET_MIN);
            BigDecimal max = get(ImportField.CLIENT_BUDGET_MAX);
            if (min != null && max != null && min.compareTo(max) > 0) {
                errors.put(ImportField.CLIENT_BUDGET_MIN.key(), "OUT_OF_RANGE");
            }
            return;
        }
        if (fromFloor != null && !values.containsKey(ImportField.PROPERTY_TOTAL_FLOORS.key())
                && !errors.containsKey(ImportField.PROPERTY_TOTAL_FLOORS.key())) {
            values.put(ImportField.PROPERTY_TOTAL_FLOORS.key(), fromFloor);
        }
        Integer floor = get(ImportField.PROPERTY_FLOOR);
        Integer total = get(ImportField.PROPERTY_TOTAL_FLOORS);
        if (floor != null && total != null && floor > total) {
            errors.put(ImportField.PROPERTY_FLOOR.key(), "OUT_OF_RANGE");
        }
    }
}
