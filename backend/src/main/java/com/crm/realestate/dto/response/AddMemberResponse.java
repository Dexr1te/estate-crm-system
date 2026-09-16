package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * What "add an agent" turned into, which depends on whether the address already had an account.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddMemberResponse {

    public enum Result {
        /** The account exists; the agent has to accept before joining. */
        REQUEST_SENT,
        /** Nobody had this address; an invite went out and the account joins on acceptance. */
        INVITE_SENT
    }

    private Result result;
    /** Set for REQUEST_SENT. */
    private JoinRequestResponse request;
    /** Set for INVITE_SENT. */
    private TeamMemberResponse member;
}
