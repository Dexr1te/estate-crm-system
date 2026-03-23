package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ClientType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ClientRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    @Email(message = "Invalid email format")
    private String email;

    private String phone;

    @NotNull(message = "Client type is required")
    private ClientType type;   // BUYER or SELLER

    private String notes;

    private Long agentId;      // если ADMIN назначает агента вручную
}