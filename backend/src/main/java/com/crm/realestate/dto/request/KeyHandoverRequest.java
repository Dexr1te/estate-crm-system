package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

/**
 * A listing's keys going out: to a colleague ({@link #holderUserId}) or to somebody outside the
 * agency by name ({@link #holderName}) — exactly one of the two — with the last day they are to be
 * back if there is one, and a note.
 */
@Data
public class KeyHandoverRequest {

    private Long holderUserId;

    @Size(max = 255, message = "The holder's name must be at most 255 characters")
    private String holderName;

    private LocalDate dueBackAt;

    @Size(max = 500, message = "Note must be at most 500 characters")
    private String note;
}
