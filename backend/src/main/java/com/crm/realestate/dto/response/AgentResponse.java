package com.crm.realestate.dto.response;

import com.crm.realestate.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private Role role;
    private boolean isActive;
    private LocalDateTime createdAt;

    /**
     * One-time invite token, populated ONLY in the response to a create/invite
     * call so the admin/manager can hand it to the new user. Always null in list
     * responses so tokens are never leaked when enumerating users.
     */
    private String inviteToken;
}