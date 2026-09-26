package com.crm.realestate.dto.response;

import com.crm.realestate.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * One entry of the caller's feed. There is no text: the app words it from {@code type} and
 * {@code params}, in the reader's language.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private Long id;
    private NotificationType type;
    /** The task, deal, listing, request or agent it is about, according to the type. */
    private Long targetId;
    /** Names, counts and prices the sentence needs; never null. */
    private Map<String, Object> params;
    /** Null while unread. */
    private LocalDateTime readAt;
    private LocalDateTime createdAt;
}
