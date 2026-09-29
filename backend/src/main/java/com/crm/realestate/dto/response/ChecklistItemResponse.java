package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ChecklistStage;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * One checklist line — of the agency template or of a deal. The template leaves the deal-only
 * fields ({@code custom}, {@code done*}, {@code document*}) empty.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChecklistItemResponse {
    private Long id;
    private ChecklistStage stage;
    private String title;
    private int position;
    private boolean required;

    private boolean custom;
    private boolean done;
    private LocalDateTime doneAt;
    /** Null when nobody ticked it, or the person who did has since closed their account. */
    private Long doneById;
    private String doneByName;

    private Long documentId;
    private String documentName;
}
