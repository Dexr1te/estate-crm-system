package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageTemplateResponse {
    private Long id;
    private String title;
    /** The text with its placeholders unfilled; the app fills them for the client in hand. */
    private String body;
    private LocalDateTime updatedAt;
}
