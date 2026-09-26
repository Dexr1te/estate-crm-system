package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ActivityType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

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
    /** The listings this entry was about — what went out in a message. Empty, never null. */
    @Builder.Default
    private List<PropertyRef> properties = List.of();

    /** Just enough of a listing to name it and open it. */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PropertyRef {
        private Long id;
        private String title;
    }
}
