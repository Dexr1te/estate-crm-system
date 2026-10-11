package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VerifyEmailRequest {
    /** A Firebase ID token for the user the link was sent to. */
    @NotBlank(message = "ID token is required")
    private String idToken;
}
