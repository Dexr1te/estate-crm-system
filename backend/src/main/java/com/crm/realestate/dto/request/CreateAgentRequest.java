package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateAgentRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    private String email;

    private String phone;

    private Role role = Role.AGENT;
    private DataScope dataScope = DataScope.OWN;
    private Long teamId;
}