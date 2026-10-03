package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * One line of a change log. {@code field}, {@code oldValue} and {@code newValue} are null on a
 * creation or deletion. Values are plain text — enum names, plain decimals, ISO dates, names — for
 * the app to put into words. {@code actorId} is null once the person has left; {@code actorName}
 * still says who it was.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecordChangeResponse {
    private Long id;
    private ChangeEntityType entityType;
    private Long entityId;
    private String entityLabel;
    private ChangeAction action;
    private String field;
    private String oldValue;
    private String newValue;
    private Long actorId;
    private String actorName;
    private LocalDateTime changedAt;
}
