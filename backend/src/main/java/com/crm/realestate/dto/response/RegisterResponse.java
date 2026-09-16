package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Where a new account stands until its address is confirmed. Carries no tokens on purpose. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterResponse {
    private String email;
    /** How long before another code may be requested, so the app can count it down. */
    private long resendAvailableInSeconds;
    private long codeExpiresInSeconds;
}
