package com.crm.realestate.service;

import com.crm.realestate.dto.request.CommissionSplitRequest;
import com.crm.realestate.dto.response.CommissionSplitResponse;
import com.crm.realestate.dto.response.CommissionSplitResponse.Colleague;
import com.crm.realestate.dto.response.CommissionSplitResponse.Share;
import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.CommissionPartyKind;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/**
 * Splitting a deal's commission between its agent, colleagues and outside co-brokers.
 *
 * <p>Whoever may see the deal may see its split — a colleague with a share included, whatever
 * their data scope. Only the deal's agent, a manager or an admin may change it: a colleague
 * cannot raise their own share. A colleague given a share has to be an active agent or manager of
 * the deal's agency; someone from another agency reads as not found. A colleague already on the
 * split who has since been deactivated may stay on it, since the work was done.
 *
 * <p>The shares total exactly 100. The deal's agent holds what the others leave, so their own line
 * is stored nowhere, and a split that gives the agent everything is no split at all.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommissionSplitService {

    private final DealService dealService;
    private final CommissionSplitStore store;
    private final UserRepository userRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    public CommissionSplitResponse get(Long dealId) {
        User me = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, me);
        return respond(deal, store.of(deal), me);
    }

    @Transactional
    public CommissionSplitResponse replace(Long dealId, CommissionSplitRequest request) {
        User me = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, me);
        requireEditor(deal, me);
        List<CommissionSplit> current = store.of(deal);
        List<CommissionSplit> next = shares(deal, request.getShares(), current);
        store.replace(deal, next, me);
        return respond(deal, next, me);
    }

    /** Back to the whole commission for the deal's agent. */
    @Transactional
    public CommissionSplitResponse clear(Long dealId) {
        User me = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, me);
        requireEditor(deal, me);
        store.replace(deal, List.of(), me);
        return respond(deal, List.of(), me);
    }

    // Rules ------------------------------------------------------------------------------------

    private boolean canEdit(Deal deal, User user) {
        boolean ownDeal = deal.getAgent() != null && deal.getAgent().getId().equals(user.getId());
        return ownDeal || scopeService.isManager(user) || scopeService.isAdmin(user);
    }

    private void requireEditor(Deal deal, User user) {
        if (!canEdit(deal, user)) {
            throw new AccessDeniedException("Only the deal's agent or a manager can split its commission");
        }
    }

    /** The request's lines as rows, the agent's own left out, every rule checked. */
    private List<CommissionSplit> shares(Deal deal, List<CommissionSplitRequest.Share> lines,
                                         List<CommissionSplit> current) {
        BigDecimal total = BigDecimal.ZERO;
        Set<Long> people = new HashSet<>();
        Set<Long> alreadySharing = new HashSet<>();
        current.stream().filter(s -> s.getUser() != null).forEach(s -> alreadySharing.add(s.getUser().getId()));
        List<CommissionSplit> rows = new ArrayList<>();

        for (CommissionSplitRequest.Share line : lines) {
            total = total.add(line.getPercent());
            String coBroker = line.getCoBrokerName() == null ? null : line.getCoBrokerName().trim();
            boolean hasCoBroker = coBroker != null && !coBroker.isEmpty();
            if ((line.getUserId() == null) == !hasCoBroker) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "SPLIT_PARTY_REQUIRED",
                        "Each share goes to a colleague or to a co-broker by name, not both");
            }
            if (line.getUserId() != null) {
                if (!people.add(line.getUserId())) {
                    throw new BusinessException(HttpStatus.BAD_REQUEST, "SPLIT_DUPLICATE_PERSON",
                            "Each person appears once in a split");
                }
                if (deal.getAgent() != null && line.getUserId().equals(deal.getAgent().getId())) {
                    continue;
                }
                User colleague = colleague(deal, line.getUserId(), alreadySharing);
                rows.add(CommissionSplit.builder().user(colleague).sharePercent(line.getPercent()).build());
            } else {
                String agency = line.getCoBrokerAgency() == null || line.getCoBrokerAgency().isBlank()
                        ? null : line.getCoBrokerAgency().trim();
                rows.add(CommissionSplit.builder().coBrokerName(coBroker).coBrokerAgency(agency)
                        .sharePercent(line.getPercent()).build());
            }
        }
        if (total.compareTo(CommissionSplitStore.HUNDRED) != 0) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "SPLIT_TOTAL_NOT_100",
                    "The shares have to add up to 100%, not " + total.stripTrailingZeros().toPlainString() + "%");
        }
        return rows;
    }

    /** A colleague who may be given a share; another agency's is not found. */
    private User colleague(Deal deal, Long userId, Set<Long> alreadySharing) {
        User user = userRepository.findById(userId)
                .filter(u -> deal.getTeam() != null && u.getTeam() != null
                        && u.getTeam().getId().equals(deal.getTeam().getId()))
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        if (!isActiveMember(user) && !alreadySharing.contains(userId)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "SPLIT_COLLEAGUE_INACTIVE",
                    user.getFullName() + " is not an active member of the agency");
        }
        return user;
    }

    private static boolean isActiveMember(User user) {
        return user.isActive() && user.getStatus() == UserStatus.ACTIVE
                && (user.getRole() == Role.AGENT || user.getRole() == Role.MANAGER);
    }

    // Answering --------------------------------------------------------------------------------

    private CommissionSplitResponse respond(Deal deal, List<CommissionSplit> rows, User me) {
        BigDecimal commission = DealService.commissionOf(DealMoney.commissionBase(deal), deal.getCommissionPercent());
        List<Share> others = new ArrayList<>();
        BigDecimal othersAmount = BigDecimal.ZERO;
        for (CommissionSplit row : rows) {
            BigDecimal amount = commission == null ? null
                    : commission.multiply(row.getSharePercent()).divide(CommissionSplitStore.HUNDRED, 2, RoundingMode.HALF_UP);
            if (amount != null) {
                othersAmount = othersAmount.add(amount);
            }
            User user = row.getUser();
            others.add(Share.builder()
                    .kind(user == null ? CommissionPartyKind.CO_BROKER : CommissionPartyKind.COLLEAGUE)
                    .userId(user == null ? null : user.getId())
                    .name(user == null ? row.getCoBrokerName() : user.getFullName())
                    .agency(user == null ? row.getCoBrokerAgency() : null)
                    .percent(row.getSharePercent())
                    .amount(amount)
                    .active(user == null || isActiveMember(user))
                    .build());
        }
        User agent = deal.getAgent();
        List<Share> shares = new ArrayList<>();
        shares.add(Share.builder()
                .kind(CommissionPartyKind.AGENT)
                .userId(agent == null ? null : agent.getId())
                .name(agent == null ? null : agent.getFullName())
                .percent(CommissionSplitStore.agentShare(rows))
                .amount(commission == null ? null : commission.subtract(othersAmount))
                .active(agent != null && agent.isActive())
                .build());
        shares.addAll(others);

        boolean editable = canEdit(deal, me);
        List<Colleague> colleagues = !editable || deal.getTeam() == null ? List.of()
                : userRepository.findByTeamIdAndIsActiveTrueOrderByFullNameAsc(deal.getTeam().getId()).stream()
                        .filter(CommissionSplitService::isActiveMember)
                        .filter(u -> agent == null || !Objects.equals(u.getId(), agent.getId()))
                        .map(u -> Colleague.builder().id(u.getId()).fullName(u.getFullName()).build())
                        .toList();

        return CommissionSplitResponse.builder()
                .dealId(deal.getId())
                .commission(commission)
                .split(!rows.isEmpty())
                .editable(editable)
                .shares(shares)
                .colleagues(colleagues)
                .build();
    }
}
