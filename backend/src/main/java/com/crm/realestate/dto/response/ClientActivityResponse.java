package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ActivityType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientActivityResponse {
    private Long id;
    private Long clientId;
    private ActivityType type;
    private String note;
    private LocalDateTime occurredAt;
    /** Null once the author's account is closed; {@link #authorName} still says who it was. */
    private Long authorId;
    private String authorName;
    private LocalDateTime createdAt;
}
