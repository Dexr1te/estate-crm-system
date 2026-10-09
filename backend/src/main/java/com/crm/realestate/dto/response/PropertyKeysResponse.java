package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * A listing's keys: who has them now, if anybody does, and the handovers that are over.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyKeysResponse {
    /** The keys that are out now; null while they are in the office. */
    private KeyHandoverResponse current;
    /** The handovers that are over, the newest first, at most 50. */
    private List<KeyHandoverResponse> history;
}
