package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/** What an import did: rows created, duplicates left out, rows that could not be read. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportResultResponse {
    private String kind;
    private int totalRows;
    private int created;
    private int skippedDuplicates;
    private int invalid;
    private Long assignedToId;
    private String assignedToName;
}
