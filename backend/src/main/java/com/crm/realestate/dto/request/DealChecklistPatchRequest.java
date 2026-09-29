package com.crm.realestate.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * A change to one checklist line. Every field is optional and a missing one leaves that part
 * alone: {@code done} ticks or un-ticks, {@code documentId} links one of the deal's documents,
 * {@code detachDocument} removes the link.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DealChecklistPatchRequest {
    private Boolean done;
    private Long documentId;
    private Boolean detachDocument;
}
