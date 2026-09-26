package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

/**
 * A comment to add to a deal's discussion, or the corrected text of one.
 *
 * <p>The body keeps a readable {@code @Name}; who was actually meant travels separately in
 * {@link #mentionedUserIds}, so a name typed by hand never notifies anybody and two colleagues with
 * the same name are never confused. Each id must be an active member of the deal's agency who can
 * see the deal.
 */
@Data
public class DealCommentRequest {

    private String body;

    @Size(max = 20, message = "At most 20 people can be mentioned in one comment")
    private List<Long> mentionedUserIds;
}
