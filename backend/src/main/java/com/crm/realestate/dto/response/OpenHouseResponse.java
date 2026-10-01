package com.crm.realestate.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * An open house with its summary. The sign-in sheet itself, {@link #visitors}, comes only with a
 * single open house; lists leave it out.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OpenHouseResponse {
    private Long id;
    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;
    /** Who holds it; null once that account is closed with nobody to take it over. */
    private Long agentId;
    private String agentName;
    private LocalDateTime startsAt;
    private LocalDateTime endsAt;
    private String note;
    private long visitorCount;
    private long newClientCount;
    private long interestedCount;
    /** Whether the caller may move or cancel it: its host, a manager or an admin. */
    private boolean canEdit;
    private LocalDateTime createdAt;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<OpenHouseVisitorResponse> visitors;
}
