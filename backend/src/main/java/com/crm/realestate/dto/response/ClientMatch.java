package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

/** A buyer whose requirements this listing answers. The mirror of {@link PropertyMatch}. */
@Data
@AllArgsConstructor
public class ClientMatch {
    private ClientResponse client;
    private boolean overBudget;
}
