package com.crm.realestate.dto.response;

import com.crm.realestate.enums.StarType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * A starred record as the list shows it: what it is, which one, and two lines to recognise it by —
 * a client's name and phone, a listing's title and address, a deal's title and client.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StarResponse {
    private StarType type;
    /** The record's id, the one its own endpoints take. */
    private Long id;
    private String title;
    /** Null when the record has nothing to show there. */
    private String subtitle;
    private LocalDateTime starredAt;
}
