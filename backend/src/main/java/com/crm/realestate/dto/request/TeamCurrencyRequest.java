package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

/** A manager choosing the currency their agency's prices are shown in. */
@Data
public class TeamCurrencyRequest {

    public static final String CODES = "KZT|RUB|USD|EUR|UZS|KGS";

    @NotBlank(message = "Currency is required")
    @Pattern(regexp = CODES, message = "Currency must be one of KZT, RUB, USD, EUR, UZS, KGS")
    private String currency;
}
