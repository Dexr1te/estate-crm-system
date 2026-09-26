package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealStatusChange;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
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
import java.util.List;
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

    public DealResponse getById(Long id) {
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public DealResponse create(DealRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        requireLostReason(statusOf(request), null, request.getLostReason(), request.getLostNote());
        Deal deal = new Deal();
        mapRequestToEntity(request, deal, currentUser);
        applyLostReason(deal, null, request.getLostReason(), request.getLostNote());
        stampClosedAt(deal, null);
        syncPropertyStatusWithDeal(deal);
        Deal saved = dealRepository.save(deal);
        recordStatusChange(saved, null, currentUser);
        return toResponse(saved);
    }

    @Transactional
    public DealResponse update(Long id, DealRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = findVisibleById(id, currentUser);
        Property previousProperty = deal.getProperty();
        DealStatus previousStatus = deal.getStatus();
        requireLostReason(statusOf(request), previousStatus, request.getLostReason(), request.getLostNote());
        mapRequestToEntity(request, deal, currentUser);
        applyLostReason(deal, previousStatus, request.getLostReason(), request.getLostNote());
        stampClosedAt(deal, previousStatus);
        recordStatusChange(deal, previousStatus, currentUser);

        if (previousProperty != null && deal.getProperty() == null
                && previousProperty.getStatus() == PropertyStatus.RESERVED) {
            previousProperty.setStatus(PropertyStatus.AVAILABLE);
            propertyRepository.save(previousProperty);
        }

        if (previousProperty != null && deal.getProperty() != null
                && !previousProperty.getId().equals(deal.getProperty().getId())
                && previousProperty.getStatus() == PropertyStatus.RESERVED) {
            previousProperty.setStatus(PropertyStatus.AVAILABLE);
            propertyRepository.save(previousProperty);
        }

        syncPropertyStatusWithDeal(deal);
        return toResponse(dealRepository.save(deal));
    }

    @Transactional
    public DealResponse updateStatus(Long id, DealStatus newStatus,
                                     DealLostReason lostReason, String lostNote) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = findVisibleById(id, currentUser);
        DealStatus previousStatus = deal.getStatus();
        requireLostReason(newStatus, previousStatus, lostReason, lostNote);
        deal.setStatus(newStatus);
        applyLostReason(deal, previousStatus, lostReason, lostNote);
        stampClosedAt(deal, previousStatus);
        recordStatusChange(deal, previousStatus, currentUser);

        syncPropertyStatusWithDeal(deal);

        return toResponse(dealRepository.save(deal));
    }

    @Transactional
    public void delete(Long id) {
        dealRepository.delete(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    private List<DealResponse> findVisible(Specification<Deal> filter) {
        User currentUser = securityUtils.getCurrentUser();
        return dealRepository.findAll(filter.and(scopeService.visibleTo(currentUser)))
                .stream().map(this::toResponse).collect(Collectors.toList());
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

    /** What the agent earns on this deal, or null until both the price and the rate are known. */
    static BigDecimal commissionOf(BigDecimal dealPrice, BigDecimal commissionPercent) {
        if (dealPrice == null || commissionPercent == null) {
            return null;
        }
        return dealPrice.multiply(commissionPercent)
                .divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
    }

    private void syncPropertyStatusWithDeal(Deal deal) {
        if (deal.getProperty() == null) {
            return;
        }

        if (deal.getStatus() == DealStatus.CLOSED_WON) {
            deal.getProperty().setStatus(PropertyStatus.SOLD);
        } else if (deal.getStatus() == DealStatus.CLOSED_LOST) {
            deal.getProperty().setStatus(PropertyStatus.AVAILABLE);
        } else {
            deal.getProperty().setStatus(PropertyStatus.RESERVED);
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
        res.setCommission(commissionOf(deal.getDealPrice(), deal.getCommissionPercent()));
        res.setNotes(deal.getNotes());
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
