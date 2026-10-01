package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealDepositCloseRequest;
import com.crm.realestate.dto.request.DealDepositRequest;
import com.crm.realestate.dto.response.DealDepositResponse;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealDeposit;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.DealDepositRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

/**
 * The deposit a buyer puts down on a deal.
 *
 * <p>Deposits sit behind exactly the deal's walls: whoever may open the deal may read them, and
 * another agency's deal answers not found. Recording, correcting and closing one is for the deal's
 * agent or someone who runs the agency. A deal has at most one active deposit; a closed one stays as
 * history and can no longer be changed. Every change is written into the deal's discussion.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DealDepositService {

    /** How far ahead a hold's last day counts as "ending". */
    public static final int ENDING_WINDOW_DAYS = 7;

    private final DealDepositRepository depositRepository;
    private final DealDepositStore depositStore;
    private final DealService dealService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    public List<DealDepositResponse> list(Long dealId) {
        Deal deal = dealService.requireVisible(dealId, securityUtils.getCurrentUser());
        return depositRepository.findByDealIdOrderByIdDesc(deal.getId()).stream()
                .map(DealDepositService::toResponse)
                .toList();
    }

    @Transactional
    public DealDepositResponse record(Long dealId, DealDepositRequest request) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        requireEditor(deal, user);
        if (deal.getStatus() == DealStatus.CLOSED_WON || deal.getStatus() == DealStatus.CLOSED_LOST) {
            throw new BusinessException(HttpStatus.CONFLICT, "DEAL_CLOSED",
                    "A deposit is recorded on a deal still under way");
        }
        if (depositRepository.existsByDealIdAndOutcomeIsNull(deal.getId())) {
            throw new BusinessException(HttpStatus.CONFLICT, "DEPOSIT_ALREADY_ACTIVE",
                    "This deal already has an active deposit; close it first");
        }
        requireHoldAfterReceipt(request);
        DealDeposit deposit = DealDeposit.builder()
                .deal(deal)
                .team(deal.getTeam())
                .recordedBy(user)
                .build();
        apply(deposit, request);
        DealDeposit saved = depositRepository.save(deposit);
        depositStore.recorded(saved, user);
        return toResponse(saved);
    }

    @Transactional
    public DealDepositResponse update(Long dealId, Long depositId, DealDepositRequest request) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        requireEditor(deal, user);
        DealDeposit deposit = requireActiveOnDeal(deal, depositId);
        requireHoldAfterReceipt(request);
        boolean changed = !sameAmount(deposit.getAmount(), request.getAmount())
                || !Objects.equals(deposit.getReceivedOn(), request.getReceivedOn())
                || !Objects.equals(deposit.getHoldUntil(), request.getHoldUntil())
                || deposit.getHolder() != request.getHolder()
                || !Objects.equals(deposit.getNote(), clean(request.getNote()));
        apply(deposit, request);
        DealDeposit saved = depositRepository.save(deposit);
        if (changed) {
            depositStore.changed(saved, user);
        }
        return toResponse(saved);
    }

    @Transactional
    public DealDepositResponse close(Long dealId, Long depositId, DealDepositCloseRequest request) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        requireEditor(deal, user);
        DealDeposit deposit = requireActiveOnDeal(deal, depositId);
        if (request.getClosedOn().isBefore(deposit.getReceivedOn())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "DEPOSIT_CLOSED_BEFORE_RECEIVED",
                    "A deposit cannot end before the day it came in");
        }
        return toResponse(depositStore.close(deposit, request.getOutcome(), request.getClosedOn(), user));
    }

    /**
     * Active deposits whose hold ends within {@link #ENDING_WINDOW_DAYS} days or has already ended,
     * soonest (or longest gone) first: the buyers to chase for a decision. Scoped like the deals
     * themselves — an agent sees their own, a manager the agency's, never another agency's.
     */
    public List<DealDepositResponse> ending() {
        User user = securityUtils.getCurrentUser();
        LocalDate horizon = LocalDate.now().plusDays(ENDING_WINDOW_DAYS);
        Specification<DealDeposit> spec = (root, query, cb) -> {
            Subquery<Long> visible = query.subquery(Long.class);
            Root<Deal> deal = visible.from(Deal.class);
            visible.select(deal.get("id"))
                    .where(scopeService.<Deal>visibleTo(user).toPredicate(deal, query, cb));
            return cb.and(
                    cb.isNull(root.get("outcome")),
                    cb.lessThanOrEqualTo(root.<LocalDate>get("holdUntil"), horizon),
                    root.get("deal").get("id").in(visible));
        };
        return depositRepository.findAll(spec, Sort.by(Sort.Order.asc("holdUntil"), Sort.Order.asc("id")))
                .stream()
                .map(DealDepositService::toResponse)
                .toList();
    }

    // Rules -----------------------------------------------------------------------------

    private void requireEditor(Deal deal, User user) {
        boolean ownDeal = deal.getAgent() != null && deal.getAgent().getId().equals(user.getId());
        if (!ownDeal && !scopeService.isManager(user) && !scopeService.isAdmin(user)) {
            throw new AccessDeniedException("Only the deal's agent or a manager can change its deposit");
        }
    }

    private DealDeposit requireActiveOnDeal(Deal deal, Long depositId) {
        DealDeposit deposit = depositRepository.findById(depositId)
                .filter(d -> d.getDeal().getId().equals(deal.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Deposit not found with id: " + depositId));
        if (!deposit.isActive()) {
            throw new BusinessException(HttpStatus.CONFLICT, "DEPOSIT_CLOSED",
                    "This deposit has ended and can no longer be changed");
        }
        return deposit;
    }

    private static void requireHoldAfterReceipt(DealDepositRequest request) {
        if (request.getHoldUntil().isBefore(request.getReceivedOn())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "DEPOSIT_HOLD_BEFORE_RECEIVED",
                    "The hold cannot end before the deposit came in");
        }
    }

    private static void apply(DealDeposit deposit, DealDepositRequest request) {
        deposit.setAmount(request.getAmount());
        deposit.setReceivedOn(request.getReceivedOn());
        deposit.setHoldUntil(request.getHoldUntil());
        deposit.setHolder(request.getHolder());
        deposit.setNote(clean(request.getNote()));
    }

    private static boolean sameAmount(BigDecimal a, BigDecimal b) {
        return a != null && b != null && a.compareTo(b) == 0;
    }

    private static String clean(String note) {
        return note == null || note.isBlank() ? null : note.strip();
    }

    static DealDepositResponse toResponse(DealDeposit d) {
        Deal deal = d.getDeal();
        return DealDepositResponse.builder()
                .id(d.getId())
                .dealId(deal.getId())
                .dealTitle(deal.getTitle())
                .clientId(deal.getClient() == null ? null : deal.getClient().getId())
                .clientName(deal.getClient() == null ? null : deal.getClient().getFullName())
                .propertyId(deal.getProperty() == null ? null : deal.getProperty().getId())
                .propertyTitle(deal.getProperty() == null ? null : deal.getProperty().getTitle())
                .agentId(deal.getAgent() == null ? null : deal.getAgent().getId())
                .agentName(deal.getAgent() == null ? null : deal.getAgent().getFullName())
                .amount(d.getAmount())
                .receivedOn(d.getReceivedOn())
                .holdUntil(d.getHoldUntil())
                .holder(d.getHolder())
                .note(d.getNote())
                .active(d.isActive())
                .outcome(d.getOutcome())
                .closedOn(d.getClosedOn())
                .createdAt(d.getCreatedAt())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}
