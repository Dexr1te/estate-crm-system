package com.crm.realestate.dto.response;

import com.crm.realestate.enums.DealStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientListItem {
    private Long id;
    private String fullName;
    private String phone;
    private String email;

    private DealStatus status;
    private BigDecimal budget;

    private String propertyTitle;

    private LocalDateTime nextMeetingAt;

    private LocalDateTime lastContactAt;
}