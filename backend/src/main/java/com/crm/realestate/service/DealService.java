package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealStatusChange;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DealStatusChangeRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.specification.DealSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DealService {

    private final DealRepository     dealRepository;
    private final ClientRepository   clientRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository     userRepository;
    private final SecurityUtils      securityUtils;
    private final ScopeService       scopeService;
    private final DealStatusChangeRepository statusChangeRepository;
    private final NotificationEvents notificationEvents;
    private final DealCommentRepository commentRepository;
    private final DealChecklistStore checklistStore;
    private final DealDepositStore depositStore;
    private final ChangeLogService changeLog;

    static final BigDecimal ONE_HUNDRED = BigDecimal.valueOf(100);
    static final int LOST_NOTE_MAX = 500;

    public List<DealResponse> getAll() {
        return findVisible(DealSpecification.build(null, null, null));
    }

    public List<DealResponse> getByAgent(Long agentId) {
        return findVisible(DealSpecification.build(null, null, agentId));
    }

    public List<DealResponse> getByStatus(DealStatus status) {
        return findVisible(DealSpecification.build(status, null, null));
    }

    /** One deal's response, for another service that has just changed it — the lease renewal. */
    DealResponse responseFor(Deal deal) {
        return respond(deal, commentRepository.countByDealId(deal.getId()));
    }

    public DealResponse getById(Long id) {
        Deal deal = findVisibleById(id, securityUtils.getCurrentUser());
        return respond(deal, commentRepository.countByDealId(deal.getId()));
    }

    @Transactional
    public DealResponse create(DealRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        requireLostReason(statusOf(request), null, request.getLostReason(), request.getLostNote());
        Deal deal = new Deal();
        mapRequestToEntity(request, deal, currentUser);
        applyLostReason(deal, null, request.getLostReason(), request.getLostNote());
        stampClosedAt(deal, null);
        syncPropertyStatusWithDeal(deal, currentUser);
        Deal saved = dealRepository.save(deal);
        changeLog.created(ChangeSnapshot.target(saved), currentUser);
        recordStatusChange(saved, null, currentUser);
        checklistStore.copyTemplate(saved, currentUser);
        return respond(saved, 0);
    }

    @Transactional
    public DealResponse update(Long id, DealRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = findVisibleById(id, currentUser);
        Property previousProperty = deal.getProperty();
        DealStatus previousStatus = deal.getStatus();
        DealKind previousKind = deal.getKind();
        Map<String, String> before = ChangeSnapshot.of(deal);
        requireLostReason(statusOf(request), previousStatus, request.getLostReason(), request.getLostNote());
        mapRequestToEntity(request, deal, currentUser);
        applyLostReason(deal, previousStatus, request.getLostReason(), request.getLostNote());
        stampClosedAt(deal, previousStatus);
        recordStatusChange(deal, previousStatus, currentUser);

        if (previousProperty != null && deal.getProperty() == null
                && previousProperty.getStatus() == PropertyStatus.RESERVED) {
            setPropertyStatus(previousProperty, PropertyStatus.AVAILABLE, currentUser);
            propertyRepository.save(previousProperty);
        }

        if (previousProperty != null && deal.getProperty() != null
                && !previousProperty.getId().equals(deal.getProperty().getId())
                && previousProperty.getStatus() == PropertyStatus.RESERVED) {
            setPropertyStatus(previousProperty, PropertyStatus.AVAILABLE, currentUser);
            propertyRepository.save(previousProperty);
        }

        // A sale turned into a rent lets go of the listing it was holding.
        if (previousKind == DealKind.SALE && deal.getKind() == DealKind.RENT && deal.getProperty() != null
                && deal.getProperty().getStatus() == PropertyStatus.RESERVED) {
            setPropertyStatus(deal.getProperty(), PropertyStatus.AVAILABLE, currentUser);
        }

        syncPropertyStatusWithDeal(deal, currentUser);
        Deal saved = dealRepository.save(deal);
        changeLog.changed(ChangeSnapshot.target(saved), currentUser, before, ChangeSnapshot.of(saved));
        return respond(saved, commentRepository.countByDealId(id));
    }

    @Transactional
    public DealResponse updateStatus(Long id, DealStatus newStatus,
                                     DealLostReason lostReason, String lostNote) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = findVisibleById(id, currentUser);
        DealStatus previousStatus = deal.getStatus();
        Map<String, String> before = ChangeSnapshot.of(deal);
        requireLostReason(newStatus, previousStatus, lostReason, lostNote);
        deal.setStatus(newStatus);
        applyLostReason(deal, previousStatus, lostReason, lostNote);
        stampClosedAt(deal, previousStatus);
        recordStatusChange(deal, previousStatus, currentUser);

        syncPropertyStatusWithDeal(deal, currentUser);

        Deal saved = dealRepository.save(deal);
        changeLog.changed(ChangeSnapshot.target(saved), currentUser, before, ChangeSnapshot.of(saved));
        return respond(saved, commentRepository.countByDealId(id));
    }

    /** The change log keeps the line saying so after the deal is gone. */
    @Transactional
    public void delete(Long id) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = findVisibleById(id, currentUser);
        changeLog.deleted(ChangeSnapshot.target(deal), currentUser);
        dealRepository.delete(deal);
    }

    private List<DealResponse> findVisible(Specification<Deal> filter) {
        User currentUser = securityUtils.getCurrentUser();
        List<Deal> deals = dealRepository.findAll(filter.and(scopeService.visibleTo(currentUser)));
        Map<Long, Long> counts = commentCounts(deals);
        Map<Long, DealChecklistStore.Summary> checklists = checklistStore.summarize(deals);
        return deals.stream()
                .map(d -> withChecklist(withCommentCount(toResponse(d), counts.getOrDefault(d.getId(), 0L)),
                        checklists.getOrDefault(d.getId(), DealChecklistStore.Summary.EMPTY)))
                .collect(Collectors.toList());
    }

    /** How many comments each deal has, in one grouped query however long the list is. */
    private Map<Long, Long> commentCounts(List<Deal> deals) {
        if (deals.isEmpty()) {
            return Map.of();
        }
        Map<Long, Long> counts = new HashMap<>();
        for (Object[] row : commentRepository.countByDeals(deals.stream().map(Deal::getId).toList())) {
            counts.put((Long) row[0], ((Number) row[1]).longValue());
        }
        return counts;
    }

    /** One deal's response with its comment count and checklist progress. */
    private DealResponse respond(Deal deal, long commentCount) {
        return withChecklist(withCommentCount(toResponse(deal), commentCount),
                checklistStore.summarize(List.of(deal)).getOrDefault(deal.getId(), DealChecklistStore.Summary.EMPTY));
    }

    private static DealResponse withChecklist(DealResponse response, DealChecklistStore.Summary summary) {
        response.setChecklistDone(summary.done());
        response.setChecklistTotal(summary.total());
        response.setOpenRequired(summary.openRequired());
        response.setOpenRequiredByStage(summary.openRequiredByStage());
        return response;
    }

    private static DealResponse withCommentCount(DealResponse response, long count) {
        response.setCommentCount(count);
        return response;
    }

    /**
     * The deal, if the caller may see it. Someone else's deal reads as missing, so its existence is
     * not confirmed either. Everything hanging off a deal — its discussion — is reached through here.
     */
    public Deal requireVisible(Long id, User currentUser) {
        return findVisibleById(id, currentUser);
    }

    /** Someone else's deal reads as missing, so its existence is not confirmed either. */
    private Deal findVisibleById(Long id, User currentUser) {
        Deal deal = dealRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Deal not found with id: " + id));
        if (!scopeService.canSee(currentUser, deal.getTeam(), deal.getAgent())) {
            throw new ResourceNotFoundException("Deal not found with id: " + id);
        }
        return deal;
    }

    /**
     * A deal lives in its client's agency, and everything it links has to come from there too.
     *
     * <p>A new deal goes to whoever creates it. Only an admin may name another agent, who must work
     * in the client's team. Editing never changes hands on its own: a manager moving a deal along
     * the pipeline is not taking it over.
     */
    private void mapRequestToEntity(DealRequest request, Deal deal, User currentUser) {
        boolean isNew = deal.getId() == null;
        deal.setTitle(request.getTitle());
        deal.setStatus(statusOf(request));
        deal.setDealPrice(request.getDealPrice());
        deal.setBudget(request.getBudget());
        deal.setCommissionPercent(request.getCommissionPercent());
        deal.setNotes(request.getNotes());

        Client client = clientRepository.findById(request.getClientId())
               .orElseThrow(() -> new ResourceNotFoundException(
                       "Client not found with id: " + request.getClientId()));
       if (!scopeService.canSee(currentUser, client.getTeam(), client.getAgent())) {
           throw new ResourceNotFoundException("Client not found with id: " + request.getClientId());
       }
       deal.setClient(client);
       deal.setTeam(client.getTeam());

       if (request.getPropertyId() != null) {
           Property property = propertyRepository.findById(request.getPropertyId())
                   .orElseThrow(() -> new ResourceNotFoundException(
                           "Property not found with id: " + request.getPropertyId()));
           if (!scopeService.canSeeInTeam(currentUser, property.getTeam(), property.getAgent())) {
               throw new ResourceNotFoundException("Property not found with id: " + request.getPropertyId());
           }
           scopeService.requireSameTeam(client.getTeam(), property.getTeam(), "Property");
           boolean isCurrentProperty = deal.getProperty() != null
                   && deal.getProperty().getId().equals(property.getId());
           if (property.getStatus() == PropertyStatus.SOLD && !isCurrentProperty) {
               throw new RuntimeException(
                       "Property is already sold and cannot be assigned to a deal: id=" + request.getPropertyId());
           }
           deal.setProperty(property);
       } else {
           deal.setProperty(null);
       }

       if (scopeService.isAdmin(currentUser) && request.getAgentId() != null) {
           User agent = userRepository.findById(request.getAgentId())
                   .orElseThrow(() -> new ResourceNotFoundException(
                           "Agent not found with id: " + request.getAgentId()));
           scopeService.requireSameTeam(client.getTeam(), agent.getTeam(), "Agent");
           deal.setAgent(agent);
       } else if (isNew) {
           deal.setAgent(currentUser);
       }
       applyLease(request, deal, currentUser);
    }

    /**
     * The sale-or-rent part of a request. A request that leaves {@code kind} out is from an app that
     * knows nothing of rents: a new deal is a sale, and an existing deal keeps its kind and its lease
     * as they are. A rent never has a sale price, whatever was sent; a sale never has a lease.
     */
    private void applyLease(DealRequest request, Deal deal, User currentUser) {
        DealKind kind = request.getKind() != null ? request.getKind()
                : deal.getKind() != null ? deal.getKind() : DealKind.SALE;
        deal.setKind(kind);
        if (kind == DealKind.SALE) {
            deal.setMonthlyRent(null);
            deal.setLeaseStart(null);
            deal.setLeaseEnd(null);
            deal.setLeaseReminderDays(null);
            deal.setLandlord(null);
            deal.setLeaseRemindedFor(null);
            return;
        }
        deal.setDealPrice(null);
        if (request.getKind() == null) {
            return;
        }
        if (request.getMonthlyRent() == null || request.getMonthlyRent().signum() <= 0) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RENT_REQUIRED",
                    "A rent deal needs a monthly rent above zero");
        }
        LeaseService.requireLeasePeriod(request.getLeaseStart(), request.getLeaseEnd());
        Integer reminder = request.getLeaseReminderDays();
        if (reminder != null && (reminder < 1 || reminder > LeaseService.MAX_REMINDER_DAYS)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REMINDER_DAYS",
                    "The reminder comes 1 to " + LeaseService.MAX_REMINDER_DAYS + " days before the lease ends");
        }
        deal.setMonthlyRent(request.getMonthlyRent());
        deal.setLeaseStart(request.getLeaseStart());
        deal.setLeaseEnd(request.getLeaseEnd());
        deal.setLeaseReminderDays(reminder);
        deal.setLandlord(landlordFor(request.getLandlordId(), deal, currentUser));
    }

    /** The landlord a request names: a client the caller may see, of the tenant's agency, not the tenant. */
    private Client landlordFor(Long landlordId, Deal deal, User currentUser) {
        if (landlordId == null) {
            return null;
        }
        Client landlord = clientRepository.findById(landlordId)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + landlordId));
        if (!scopeService.canSeeInTeam(currentUser, landlord.getTeam(), landlord.getAgent())) {
            throw new ResourceNotFoundException("Client not found with id: " + landlordId);
        }
        scopeService.requireSameTeam(deal.getClient().getTeam(), landlord.getTeam(), "Landlord");
        if (landlord.getId().equals(deal.getClient().getId())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LANDLORD_IS_TENANT",
                    "The landlord and the tenant are two different clients");
        }
        return landlord;
    }

    /**
     * A lost deal says why. Moving a deal into CLOSED_LOST takes a reason; re-saving one that was
     * already lost may leave it out and keeps what is there — including nothing, on deals lost
     * before reasons were asked for. Leaving CLOSED_LOST clears both, so a reopened deal does not
     * carry a verdict that no longer applies.
     */
    private void applyLostReason(Deal deal, DealStatus previousStatus,
                                 DealLostReason reason, String note) {
        if (deal.getStatus() != DealStatus.CLOSED_LOST) {
            deal.setLostReason(null);
            deal.setLostNote(null);
        } else if (reason != null) {
            deal.setLostReason(reason);
            deal.setLostNote(note == null || note.isBlank() ? null : note.trim());
        }
    }

    /**
     * Refuses a move to CLOSED_LOST without a reason, before anything on the deal is touched, so
     * a refused request leaves the loaded deal exactly as it was.
     */
    private void requireLostReason(DealStatus newStatus, DealStatus previousStatus,
                                   DealLostReason reason, String note) {
        if (newStatus != DealStatus.CLOSED_LOST) {
            return;
        }
        if (note != null && note.trim().length() > LOST_NOTE_MAX) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LOST_NOTE_TOO_LONG",
                    "The note on why the deal was lost takes at most " + LOST_NOTE_MAX + " characters");
        }
        if (reason == null && previousStatus != DealStatus.CLOSED_LOST) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "LOST_REASON_REQUIRED",
                    "Say why the deal was lost");
        }
    }

    private static DealStatus statusOf(DealRequest request) {
        return request.getStatus() != null ? request.getStatus() : DealStatus.LEAD;
    }

    /** Writes one history row when the status actually moved; {@code from} is null on creation. */
    private void recordStatusChange(Deal deal, DealStatus from, User by) {
        if (from == deal.getStatus()) {
            return;
        }
        statusChangeRepository.save(DealStatusChange.builder()
                .deal(deal).fromStatus(from).toStatus(deal.getStatus()).changedBy(by).build());
        notificationEvents.dealStatusChanged(deal, from, by);
        if (deal.getStatus() == DealStatus.CLOSED_WON) {
            // The deposit went towards the price.
            depositStore.applyOnWin(deal, by);
        }
    }

    /**
     * A deal closes once, when it first reaches a closed status. Saving it again — to correct the
     * commission, say — must not move that date, because the month it falls in is the month the
     * commission was earned.
     */
    private void stampClosedAt(Deal deal, DealStatus previousStatus) {
        boolean closed = deal.getStatus() == DealStatus.CLOSED_WON
                || deal.getStatus() == DealStatus.CLOSED_LOST;
        if (!closed) {
            deal.setClosedAt(null);
        } else if (deal.getStatus() != previousStatus || deal.getClosedAt() == null) {
            deal.setClosedAt(LocalDateTime.now());
        }
    }

    /**
     * What the agent earns on this deal, or null until both the base and the rate are known. The
     * base is the price of a sale and one month's rent of a rent — see {@link DealMoney}.
     */
    static BigDecimal commissionOf(BigDecimal dealPrice, BigDecimal commissionPercent) {
        if (dealPrice == null || commissionPercent == null) {
            return null;
        }
        return dealPrice.multiply(commissionPercent)
                .divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
    }

    /**
     * A sale moves its listing along: reserved while it runs, sold when won, free again when lost.
     * A rent does not: the statuses are about selling the place, and letting it sells nothing.
     */
    private void syncPropertyStatusWithDeal(Deal deal, User actor) {
        if (deal.getProperty() == null || deal.getKind() == DealKind.RENT) {
            return;
        }

        if (deal.getStatus() == DealStatus.CLOSED_WON) {
            setPropertyStatus(deal.getProperty(), PropertyStatus.SOLD, actor);
        } else if (deal.getStatus() == DealStatus.CLOSED_LOST) {
            setPropertyStatus(deal.getProperty(), PropertyStatus.AVAILABLE, actor);
        } else {
            setPropertyStatus(deal.getProperty(), PropertyStatus.RESERVED, actor);
        }
    }

    /**
     * A deal moves its listing along with it; the listing's change log says so, in the name of
     * whoever moved the deal.
     */
    private void setPropertyStatus(Property property, PropertyStatus status, User actor) {
        PropertyStatus old = property.getStatus();
        property.setStatus(status);
        if (old != status) {
            changeLog.fieldChanged(ChangeSnapshot.target(property), actor, "status",
                    old == null ? null : old.name(), status.name());
        }
    }

    private DealResponse toResponse(Deal deal) {
        DealResponse res = new DealResponse();
        res.setId(deal.getId());
        res.setTitle(deal.getTitle());
        res.setStatus(deal.getStatus());
        res.setDealPrice(deal.getDealPrice());
        res.setBudget(deal.getBudget());
        res.setCommissionPercent(deal.getCommissionPercent());
        res.setCommission(commissionOf(DealMoney.commissionBase(deal), deal.getCommissionPercent()));
        res.setNotes(deal.getNotes());
        res.setKind(deal.getKind());
        if (deal.getKind() == DealKind.RENT) {
            res.setMonthlyRent(deal.getMonthlyRent());
            res.setLeaseStart(deal.getLeaseStart());
            res.setLeaseEnd(deal.getLeaseEnd());
            res.setLeaseReminderDays(deal.getLeaseReminderDays());
            res.setLeaseReminderDaysEffective(LeaseService.reminderDays(deal));
            if (deal.getLandlord() != null) {
                res.setLandlordId(deal.getLandlord().getId());
                res.setLandlordName(deal.getLandlord().getFullName());
            }
        }
        res.setLostReason(deal.getLostReason());
        res.setLostNote(deal.getLostNote());
        res.setCreatedAt(deal.getCreatedAt());
        res.setUpdatedAt(deal.getUpdatedAt());
        res.setClosedAt(deal.getClosedAt());

        res.setClientId(deal.getClient().getId());
        res.setClientName(deal.getClient().getFullName());

        if (deal.getProperty() != null) {
            res.setPropertyId(deal.getProperty().getId());
            res.setPropertyTitle(deal.getProperty().getTitle());
            res.setPropertyAddress(deal.getProperty().getAddress());
        }

        res.setAgentId(deal.getAgent().getId());
        res.setAgentName(deal.getAgent().getFullName());

        return res;
    }
}
