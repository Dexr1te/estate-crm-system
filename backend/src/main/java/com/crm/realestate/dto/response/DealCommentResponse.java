package com.crm.realestate.dto.response;

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
public class DealCommentResponse {
    private Long id;
    private Long dealId;
    private String body;
    /** Null once the author's account is closed; {@link #authorName} still says who it was. */
    private Long authorId;
    private String authorName;
    private LocalDateTime createdAt;
    /** Null until the author corrects the text. */
    private LocalDateTime editedAt;
    /** Who the comment @mentions and still has an account. Empty, never null. */
    @Builder.Default
    private List<MentionRef> mentions = List.of();

    /** Just enough of a person to highlight their name in the text. */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MentionRef {
        private Long id;
        private String fullName;
    }
}
