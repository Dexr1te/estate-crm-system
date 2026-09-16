package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/** A manager naming — or renaming — their own agency. */
@Data
public class TeamNameRequest {

    @NotBlank(message = "Team name is required")
    @Size(max = 100, message = "Team name is too long")
    private String name;
}
