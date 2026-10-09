package com.crm.realestate.service;

import com.crm.realestate.dto.response.PayoutsResponse;
import com.crm.realestate.dto.response.PayoutsResponse.Item;
import com.crm.realestate.dto.response.PayoutsResponse.PartyTotal;
import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.CommissionPartyKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PayoutStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.CommissionSplitRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * What the agency owes from its won deals' commission splits, and what it has paid out (V58).
 *
 * <p><b>Who sees what.</b> The agency's manager (or an admin naming the agency with {@code teamId})
 * sees every share of the agency's won deals, narrowed to one colleague with {@code agentId}; a
 * colleague from another agency reads as not found. An agent sees only the shares they hold,
 * whatever their data scope: what a colleague is owed is between the colleague and the manager. An
 * agent who asks for someone else's is refused (403 OWN_PAYOUTS_ONLY) rather than quietly shown
 * their own.
 *
 * <p><b>What counts.</b> A share is a payout once its deal is won; a deal reopened since drops out
 * of the lists, paid or not. The deal's own agent holds no row (V55), so their part is not listed.
 * A share's amount is the one the deal's split shows; one whose deal has no price or rate yet has
 * none and adds nothing to the totals.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommissionPayoutService {

    private final CommissionSplitRepository splitRepository;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final ScopeService scopeService;

    public PayoutsResponse list(User actor, PayoutStatus status, Long agentId, Long teamId) {
        PayoutStatus wanted = status == null ? PayoutStatus.UNPAID : status;
        Team team = teamOf(actor, teamId);
        boolean wholeTeam = scopeService.isManager(actor) || scopeService.isAdmin(actor);
        Long holder;
        if (wholeTeam) {
            holder = agentId == null ? null : member(team, agentId).getId();
        } else {
            if (agentId != null && !agentId.equals(actor.getId())) {
                throw new BusinessException(HttpStatus.FORBIDDEN, "OWN_PAYOUTS_ONLY",
                        "An agent sees only their own payouts");
            }
            holder = actor.getId();
        }
        List<CommissionSplit> shares = holder == null
                ? splitRepository.onTeamDeals(team.getId(), DealStatus.CLOSED_WON)
                : splitRepository.heldOnTeamDeals(team.getId(), DealStatus.CLOSED_WON, holder);
        return respond(shares, wanted, wholeTeam);
    }

    // Who -------------------------------------------------------------------------------------

    private Team teamOf(User actor, Long teamId) {
        if (scopeService.isAdmin(actor) && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (actor.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's payouts these are");
        }
        return actor.getTeam();
    }

    /** Anyone of this agency, still active or not: a share is owed either way. */
    private User member(Team team, Long userId) {
        return userRepository.findById(userId)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + userId));
    }

    // Answering -------------------------------------------------------------------------------

    private PayoutsResponse respond(List<CommissionSplit> shares, PayoutStatus status, boolean wholeTeam) {
        Map<Long, BigDecimal> commissions = new HashMap<>();
        BigDecimal unpaidTotal = BigDecimal.ZERO;
        BigDecimal paidTotal = BigDecimal.ZERO;
        Map<String, PartyTotal> owed = new LinkedHashMap<>();
        List<Item> items = new ArrayList<>();

        for (CommissionSplit share : shares) {
            Deal deal = share.getDeal();
            BigDecimal commission = commissions.computeIfAbsent(deal.getId(),
                    id -> CommissionSplitStore.commissionOf(deal));
            BigDecimal amount = CommissionSplitStore.amountOf(commission, share.getSharePercent());
            BigDecimal counted = amount == null ? BigDecimal.ZERO : amount;
            User user = share.getUser();

            if (share.isPaid()) {
                paidTotal = paidTotal.add(counted);
            } else {
                unpaidTotal = unpaidTotal.add(counted);
                PartyTotal party = owed.computeIfAbsent(partyKey(share), key -> PartyTotal.builder()
                        .kind(user == null ? CommissionPartyKind.CO_BROKER : CommissionPartyKind.COLLEAGUE)
                        .agentId(user == null ? null : user.getId())
                        .name(user == null ? share.getCoBrokerName() : user.getFullName())
                        .agency(user == null ? share.getCoBrokerAgency() : null)
                        .unpaid(BigDecimal.ZERO)
                        .build());
                party.setUnpaid(party.getUnpaid().add(counted));
                party.setShares(party.getShares() + 1);
            }

            if (share.isPaid() == (status == PayoutStatus.PAID)) {
                User paidBy = share.getPaidBy();
                items.add(Item.builder()
                        .shareId(share.getId())
                        .dealId(deal.getId())
                        .dealTitle(deal.getTitle())
                        .closedAt(deal.getClosedAt())
                        .kind(user == null ? CommissionPartyKind.CO_BROKER : CommissionPartyKind.COLLEAGUE)
                        .agentId(user == null ? null : user.getId())
                        .agentName(user == null ? share.getCoBrokerName() : user.getFullName())
                        .agency(user == null ? share.getCoBrokerAgency() : null)
                        .percent(share.getSharePercent())
                        .amount(amount)
                        .paid(share.isPaid())
                        .paidAt(share.getPaidAt())
                        .paidById(paidBy == null ? null : paidBy.getId())
                        .paidByName(paidBy == null ? null : paidBy.getFullName())
                        .note(share.getPayoutNote())
                        .build());
            }
        }

        items.sort(status == PayoutStatus.PAID ? LATEST_PAID_FIRST : LONGEST_WAITING_FIRST);
        List<PartyTotal> byAgent = new ArrayList<>(owed.values());
        byAgent.sort(Comparator.comparing(PartyTotal::getUnpaid).reversed()
                .thenComparing(p -> p.getName() == null ? "" : p.getName(), String.CASE_INSENSITIVE_ORDER));

        return PayoutsResponse.builder()
                .status(status)
                .wholeTeam(wholeTeam)
                .unpaidTotal(unpaidTotal)
                .paidTotal(paidTotal)
                .byAgent(byAgent)
                .items(items)
                .build();
    }

    /** A colleague by who they are; a co-broker, who has no account, by name and agency. */
    private static String partyKey(CommissionSplit share) {
        if (share.getUser() != null) {
            return "user:" + share.getUser().getId();
        }
        String agency = share.getCoBrokerAgency() == null ? "" : share.getCoBrokerAgency().trim();
        return "co-broker:" + share.getCoBrokerName().trim().toLowerCase(Locale.ROOT)
                + "|" + agency.toLowerCase(Locale.ROOT);
    }

    private static final Comparator<LocalDateTime> EARLIEST_FIRST =
            Comparator.nullsLast(Comparator.naturalOrder());

    private static final Comparator<Item> LONGEST_WAITING_FIRST =
            Comparator.comparing(Item::getClosedAt, EARLIEST_FIRST)
                    .thenComparing(Item::getDealId)
                    .thenComparing(Item::getShareId);

    private static final Comparator<Item> LATEST_PAID_FIRST =
            Comparator.comparing(Item::getPaidAt, Comparator.nullsLast(Comparator.<LocalDateTime>reverseOrder()))
                    .thenComparing(Item::getShareId, Comparator.reverseOrder());
}
