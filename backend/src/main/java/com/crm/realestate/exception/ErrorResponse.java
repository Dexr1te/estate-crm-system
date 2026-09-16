package com.crm.realestate.exception;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {
    private int status;
    private String error;
    private String message;
    private String path;
    /**
     * A stable, machine-readable reason, for the cases a client has to react to rather than just
     * show — EMAIL_NOT_VERIFIED, TEAM_REQUIRED and the like. Null for everything else.
     */
    private String code;
    private LocalDateTime timestamp;
    private Map<String, String> validationErrors; // для @Valid ошибок
}