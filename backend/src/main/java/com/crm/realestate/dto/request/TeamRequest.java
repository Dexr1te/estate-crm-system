package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeamRequest {

    @NotBlank(message = "Team name is required")
    private String name;

    private Long managerId;
}
