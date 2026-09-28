package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamResponse {
    private Long id;
    private String name;
    private Long managerId;
    private String managerName;
    /** ISO 4217: KZT, RUB, USD, EUR, UZS or KGS. */
    private String currency;
    private Long memberCount;
    private LocalDateTime createdAt;
}
