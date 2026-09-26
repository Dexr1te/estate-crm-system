package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Another card in the agency for what looks like the same person.
 *
 * <p>Deliberately minimal: an agent working only their own clients still learns that a colleague
 * already has this buyer, and who to talk to — but not the requirements, notes or history behind it.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientDuplicate {

    /** Which contact detail the two cards share. */
    public enum MatchedOn { PHONE, EMAIL, PHONE_AND_EMAIL }

    private Long id;
    private String fullName;
    private ClientType type;
    private Long agentId;
    private String agentName;
    private String phone;
    private String email;
    private MatchedOn matchedOn;
    /**
     * Whether the caller may open this card. False for a colleague's card when the caller works
     * only their own clients — they learn who has the buyer, not the file.
     */
    private boolean visible;
}
