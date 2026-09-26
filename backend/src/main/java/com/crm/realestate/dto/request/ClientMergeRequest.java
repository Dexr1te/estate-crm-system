package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/** The card folded into the one named in the path, and then deleted. */
@Data
public class ClientMergeRequest {

    @NotNull
    private Long sourceId;
}
