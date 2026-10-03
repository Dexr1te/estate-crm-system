package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * How much a handover moves, or moved. The preview and the handover itself answer the same shape,
 * so what the manager confirmed is what happened.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HandoverResponse {
    /** False for a preview, true once the records have changed hands. */
    private boolean done;
    /** Null when the clients named came from more than one colleague. */
    private Long fromAgentId;
    private String fromAgentName;
    private Long toAgentId;
    private String toAgentName;
    private int clients;
    private int listings;
    private int deals;
    private int meetings;
    private int tasks;
    private int openHouses;
    /** Everything above added up; zero means there is nothing to hand over. */
    private int total;
}
