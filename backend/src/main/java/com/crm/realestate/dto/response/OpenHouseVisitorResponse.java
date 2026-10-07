package com.crm.realestate.dto.response;

import com.crm.realestate.enums.OpenHouseInterest;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * One line of the sign-in sheet.
 *
 * <p>The client a visitor matched may be a colleague's that the caller is not allowed to open:
 * then {@link #clientVisible} is false and only the colleague's name is given, so the agent knows
 * whom to talk to without reading a card that is not theirs.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OpenHouseVisitorResponse {
    private Long id;
    private Long openHouseId;
    private String fullName;
    private String phone;
    private OpenHouseInterest interest;
    private String note;
    /** Null once the client card is deleted. */
    private Long clientId;
    private boolean clientVisible;
    /** The card's name, when the caller may open it. */
    private String clientName;
    private String clientAgentName;
    /** Whether this sign-in made the client, rather than finding one. */
    private boolean newClient;
    private Long signedInById;
    private String signedInByName;
    private LocalDateTime signedInAt;
    /** Whether the caller may take this line back off the sheet. */
    private boolean canRemove;
}
