package com.crm.realestate.dto.response;

import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType = "Bearer";
    private Long userId;
    private String fullName;
    private String email;
    private Role role;
    private DataScope dataScope;
    private UserStatus status;
    private Long teamId;
    private String teamName;
    /** The team's currency (ISO 4217), or null with no team. */
    private String teamCurrency;
    private boolean mustChangePassword;
}