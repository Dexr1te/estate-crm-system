package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * What a spreadsheet would bring in, read but not written.
 *
 * <p>{@code mapping} has one entry per column of {@code headers}: the field key that column fills,
 * or null for a column that is left out. {@code problems} lists the rows that would not be
 * imported as they are — invalid ones and duplicates — capped at {@value #MAX_PROBLEMS};
 * {@code sample} is the first few rows that would.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportPreviewResponse {

    public static final int MAX_PROBLEMS = 1000;
    public static final int SAMPLE_SIZE = 5;

    public enum RowStatus { VALID, INVALID, DUPLICATE }

    /** Where the same person was already found. */
    public enum DuplicateSource { AGENCY, FILE }

    private String kind;
    /** "," ";" or "\t". */
    private String delimiter;
    /** UTF_8, UTF_8_BOM, UTF_16 or WINDOWS_1251. */
    private String encoding;
    private List<String> headers;
    private List<String> mapping;
    private List<Target> targets;
    private int totalRows;
    private int validRows;
    private int invalidRows;
    private int duplicateRows;
    private List<Row> problems;
    private boolean problemsTruncated;
    private List<Row> sample;

    /** A field a column may be mapped to. */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Target {
        private String field;
        private boolean required;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Row {
        /** The spreadsheet row, header being row 1. */
        private int row;
        private RowStatus status;
        /** Field key to error code. */
        private Map<String, String> errors;
        /** Field key to the value as it would be saved. */
        private Map<String, String> values;
        private Duplicate duplicate;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Duplicate {
        private DuplicateSource source;
        private ClientDuplicate.MatchedOn matchedOn;
        /** The agency's client, when the source is AGENCY. */
        private Long clientId;
        private String clientName;
        /** The earlier row, when the source is FILE. */
        private Integer row;
    }
}
