package com.crm.realestate.dto.response;

import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamMemberResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private Role role;
    /** PENDING_INVITE for someone invited by email who has not set a password yet. */
    private UserStatus status;
    // Named without "is": Lombok and Jackson would otherwise publish it as "active" anyway.
    private boolean active;
    /** The one who runs the team. */
    private boolean teamManager;
    private LocalDateTime createdAt;
}
