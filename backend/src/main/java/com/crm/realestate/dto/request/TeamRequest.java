package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class TeamRequest {

    @NotBlank(message = "Team name is required")
    private String name;

    private Long managerId;

    /** Optional: the ISO 4217 code the team's prices are shown in. Nothing is converted. */
    @Pattern(regexp = TeamCurrencyRequest.CODES,
            message = "Currency must be one of KZT, RUB, USD, EUR, UZS, KGS")
    private String currency;
}
