package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * A stretch of a deal's discussion, oldest first so it reads top to bottom, and whether anything
 * older is left to show above it.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DealCommentPage {
    private List<DealCommentResponse> comments;
    private boolean hasEarlier;
}
