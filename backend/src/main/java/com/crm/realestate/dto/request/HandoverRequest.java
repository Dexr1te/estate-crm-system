package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * What a manager hands from one member of the agency to another.
 *
 * <p>Either the source's whole book, a part at a time ({@code clients}, {@code listings},
 * {@code deals}, {@code upcoming}), or the clients named in {@code clientIds}. A client brings its
 * open deals, meetings to come and open tasks along. Without {@code fromAgentId} the clients named
 * may be anybody's in the agency, each leaving whoever holds it.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HandoverRequest {

    /** Whose work moves. Needed unless {@code clientIds} names the clients. */
    private Long fromAgentId;

    @NotNull(message = "Say who takes the work over")
    private Long toAgentId;

    /** Every client the source holds, each with its open deals, meetings to come and open tasks. */
    private boolean clients;

    /** Every listing the source holds, and the open houses on the calendar they are to host. */
    private boolean listings;

    /** Every deal the source holds that is still open, with its meetings to come and open tasks. */
    private boolean deals;

    /** Every meeting to come and every open task the source has. */
    private boolean upcoming;

    /** Only these clients, in place of {@code clients}. At most {@value #MAX_CLIENTS}. */
    private List<Long> clientIds;

    public static final int MAX_CLIENTS = 500;
}
