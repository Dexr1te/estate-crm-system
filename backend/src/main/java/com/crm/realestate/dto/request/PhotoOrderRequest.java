package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

/**
 * The gallery in the order it should be shown, first one first.
 *
 * <p>The whole order rather than a move: the client already knows the list it is showing, and
 * sending it back whole means the server never has to guess what "up one" meant against a list that
 * may have changed under it.
 */
@Data
public class PhotoOrderRequest {

    @NotEmpty(message = "The order cannot be empty")
    private List<Long> photoIds;
}
