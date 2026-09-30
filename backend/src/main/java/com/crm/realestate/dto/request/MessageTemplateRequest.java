package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * A message template as the manager wants it: a title for the picker and the text, which may use
 * the placeholders in {@link com.crm.realestate.service.MessageTemplateService#PLACEHOLDERS}.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageTemplateRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 80, message = "Title takes at most 80 characters")
    private String title;

    @NotBlank(message = "Text is required")
    @Size(max = 1000, message = "Text takes at most 1000 characters")
    private String body;
}
