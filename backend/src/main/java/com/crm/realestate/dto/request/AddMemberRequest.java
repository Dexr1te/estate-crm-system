package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AddMemberRequest {

    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    private String email;

    /** Used only when nobody has this address yet and an invite is sent instead of a request. */
    @NotBlank(message = "Full name is required")
    private String fullName;

    private String phone;
}
