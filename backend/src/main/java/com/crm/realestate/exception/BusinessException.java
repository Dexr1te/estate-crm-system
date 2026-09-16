package com.crm.realestate.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * A rule the client is expected to react to, not merely display.
 *
 * <p>Carries an HTTP status and a stable {@link #getCode() code}, so the app can tell "confirm your
 * email first" from "you are not in a team yet" without parsing English out of the message.
 */
@Getter
public class BusinessException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    public BusinessException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }
}
