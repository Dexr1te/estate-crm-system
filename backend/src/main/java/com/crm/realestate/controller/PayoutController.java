package com.crm.realestate.controller;

import com.crm.realestate.dto.response.PayoutsResponse;
import com.crm.realestate.enums.PayoutStatus;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.CommissionPayoutService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * What the agency owes from its won deals' commission splits and what it has paid out. A share is
 * marked paid on its deal: {@code POST /deals/{dealId}/commission-split/shares/{shareId}/payout}.
 * See {@link CommissionPayoutService} for who sees what. An admin names the agency with
 * {@code teamId}.
 */
@RestController
@RequestMapping("/payouts")
@RequiredArgsConstructor
@Tag(name = "Payouts", description = "Which shares of won deals' commissions have been paid out")
@SecurityRequirement(name = "bearerAuth")
public class PayoutController {

    private final CommissionPayoutService payoutService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @Operation(summary = "The shares of won deals, unpaid or paid, with what is owed and paid in all and "
            + "what each person is still owed",
            description = "A manager sees the whole agency (one colleague with agentId, another agency's: "
                    + "404); an agent only their own shares (someone else's agentId: 403 OWN_PAYOUTS_ONLY)")
    public ResponseEntity<PayoutsResponse> list(
            @RequestParam(defaultValue = "UNPAID") PayoutStatus status,
            @RequestParam(required = false) Long agentId,
            @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(payoutService.list(securityUtils.getCurrentUser(), status, agentId, teamId));
    }
}
