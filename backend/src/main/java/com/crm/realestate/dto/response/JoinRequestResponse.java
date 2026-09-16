package com.crm.realestate.dto.response;

import com.crm.realestate.enums.JoinRequestStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JoinRequestResponse {
    private Long id;
    private Long teamId;
    private String teamName;
    /** Who sent it — what the agent needs to recognise the request. */
    private String invitedByName;
    private Long userId;
    private String userFullName;
    private String userEmail;
    private JoinRequestStatus status;
    private LocalDateTime createdAt;
}
