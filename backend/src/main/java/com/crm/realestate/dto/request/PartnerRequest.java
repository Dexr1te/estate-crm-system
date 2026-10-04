package com.crm.realestate.dto.request;

import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.enums.ReferralFeeType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

/**
 * A partner as typed. The referral fee is both halves or neither: a type and its value, a percent
 * of the commission (above 0, at most 100) or a fixed amount above 0.
 */
@Data
public class PartnerRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 120, message = "Name must be at most 120 characters")
    private String name;

    @Size(max = 120, message = "Company must be at most 120 characters")
    private String company;

    @NotNull(message = "Kind is required")
    private PartnerKind kind;

    @Size(max = 40, message = "Phone must be at most 40 characters")
    private String phone;

    @Email(message = "Invalid email format")
    @Size(max = 255, message = "Email must be at most 255 characters")
    private String email;

    @Size(max = 1000, message = "Note must be at most 1000 characters")
    private String note;

    private ReferralFeeType feeType;

    private BigDecimal feeValue;
}
