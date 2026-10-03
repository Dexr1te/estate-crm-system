package com.crm.realestate.service;

import com.crm.realestate.dto.request.OfferCounterRequest;
import com.crm.realestate.dto.request.OfferDecisionRequest;
import com.crm.realestate.dto.request.PropertyOfferRequest;
import com.crm.realestate.dto.response.PropertyOfferResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyOffer;
import com.crm.realestate.entity.PropertyOfferEvent;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.OfferAction;
import com.crm.realestate.enums.OfferParty;
import com.crm.realestate.enums.OfferStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyOfferEventRepository;
import com.crm.realestate.repository.PropertyOfferRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Buyers' offers on a listing, and the negotiation that follows each one.
 *
 * <p><b>Who sees what.</b> An offer is on the listing, so it sits behind the listing's wall: the
 * whole agency sees a listing's offers and their figures whatever their data scope, and another
 * agency is told they do not exist. Who made an offer is the buyer's card, though, and that keeps
 * its own wall: an agent who sees only their own clients reads a colleague's buyer by the
 * colleague's name, not the buyer's. A buyer's own list of offers is behind the buyer's card.
 *
 * <p><b>Who changes what.</b> Recording an offer is open to anyone who can see both the listing
 * and the buyer. Countering, accepting, rejecting and withdrawing it is for the agent who recorded
 * it, the listing's agent, a manager or an admin.
 *
 * <p><b>How it moves.</b> An offer starts NEW with the buyer's figure. Each counter, from either
 * side, puts a new figure on the table and makes it COUNTERED. While open it can be ACCEPTED (the
 * figure on the table is the agreed price) or REJECTED; WITHDRAWN is the buyer walking away, and
 * can come even after acceptance, when the sale falls through. An open offer past its last day is
 * EXPIRED, worked out when read; it is over, and the buyer makes a new one if they still want it.
 *
 * <p><b>Accepting one.</b> A listing has one accepted offer at a time (409 OFFER_ALREADY_ACCEPTED).
 * Accepting does not touch the others: they stay open as backups, each marked
 * {@code otherAccepted}, because a sale agreed is not a sale closed, and if the accepted buyer
 * withdraws the next best offer is still there to accept. Nor does it touch the listing's status:
 * a deposit is what reserves the flat.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyOfferService {

    private final PropertyOfferRepository offerRepository;
    private final PropertyOfferEventRepository eventRepository;
    private final PropertyRepository propertyRepository;
    private final ClientService clientService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    // Reading -----------------------------------------------------------------------------

    /** A listing's offers, the highest first. */
    public List<PropertyOfferResponse> forProperty(Long propertyId) {
        User user = securityUtils.getCurrentUser();
        Property property = requireVisibleProperty(propertyId, user);
        return toResponses(offerRepository.findByPropertyHighestFirst(property.getId()), user);
    }

    /** A buyer's offers, the latest first. */
    public List<PropertyOfferResponse> forClient(Long clientId) {
        User user = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, user);
        return toResponses(offerRepository.findByClientNewestFirst(client.getId()), user);
    }

    /** One offer with its negotiation, the first step first. */
    public PropertyOfferResponse get(Long id) {
        User user = securityUtils.getCurrentUser();
        return withHistory(requireVisible(id, user), user);
    }

    // Writing -----------------------------------------------------------------------------

    @Transactional
    public PropertyOfferResponse create(Long propertyId, PropertyOfferRequest request) {
        User user = securityUtils.getCurrentUser();
        Property property = requireVisibleProperty(propertyId, user);
        Client client = clientService.requireVisible(request.getClientId(), user);
        scopeService.requireSameTeam(property.getTeam(), client.getTeam(), "Client");
        if (client.getType() != ClientType.BUYER) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "CLIENT_NOT_BUYER",
                    "An offer is made by a buyer");
        }
        if (property.getStatus() == PropertyStatus.SOLD) {
            throw new BusinessException(HttpStatus.CONFLICT, "PROPERTY_SOLD",
                    "This listing is sold and takes no more offers");
        }
        LocalDate today = LocalDate.now();
        requireExpiryAhead(request.getExpiresOn(), today);
        boolean alreadyOpen = offerRepository.findByPropertyIdAndClientIdAndStatusIn(
                        property.getId(), client.getId(), List.of(OfferStatus.NEW, OfferStatus.COUNTERED))
                .stream().anyMatch(o -> o.statusOn(today).isOpen());
        if (alreadyOpen) {
            throw new BusinessException(HttpStatus.CONFLICT, "OFFER_ALREADY_OPEN",
                    "This buyer already has an open offer on this listing; counter it instead");
        }

        PropertyOffer offer = offerRepository.save(PropertyOffer.builder()
                .property(property)
                .client(client)
                .team(property.getTeam())
                .agent(user)
                .amount(request.getAmount())
                .lastParty(OfferParty.BUYER)
                .note(strip(request.getNote()))
                .expiresOn(request.getExpiresOn())
                .status(OfferStatus.NEW)
                .build());
        step(offer, OfferAction.OFFERED, OfferParty.BUYER, offer.getNote(), user);
        return withHistory(offer, user);
    }

    /** A new figure on the table, from either side. */
    @Transactional
    public PropertyOfferResponse counter(Long id, OfferCounterRequest request) {
        User user = securityUtils.getCurrentUser();
        PropertyOffer offer = requireEditable(id, user);
        LocalDate today = LocalDate.now();
        requireOpen(offer, today);
        requireExpiryAhead(request.getExpiresOn(), today);
        offer.setAmount(request.getAmount());
        offer.setLastParty(request.getParty());
        offer.setStatus(OfferStatus.COUNTERED);
        if (request.getExpiresOn() != null) {
            offer.setExpiresOn(request.getExpiresOn());
        }
        offerRepository.save(offer);
        step(offer, OfferAction.COUNTERED, request.getParty(), strip(request.getNote()), user);
        return withHistory(offer, user);
    }

    /**
     * Agrees the figure on the table. Deliberately narrow: the offer has to be open and in date,
     * and no other offer on the listing may stand accepted. The other offers are left open.
     */
    @Transactional
    public PropertyOfferResponse accept(Long id, OfferDecisionRequest request) {
        User user = securityUtils.getCurrentUser();
        PropertyOffer offer = requireEditable(id, user);
        requireOpen(offer, LocalDate.now());
        if (offerRepository.existsByPropertyIdAndStatus(offer.getProperty().getId(), OfferStatus.ACCEPTED)) {
            throw new BusinessException(HttpStatus.CONFLICT, "OFFER_ALREADY_ACCEPTED",
                    "Another offer on this listing is already accepted; withdraw it first");
        }
        return decide(offer, OfferStatus.ACCEPTED, OfferAction.ACCEPTED, request, user);
    }

    @Transactional
    public PropertyOfferResponse reject(Long id, OfferDecisionRequest request) {
        User user = securityUtils.getCurrentUser();
        PropertyOffer offer = requireEditable(id, user);
        requireOpen(offer, LocalDate.now());
        return decide(offer, OfferStatus.REJECTED, OfferAction.REJECTED, request, user);
    }

    /** The buyer walks away: from an open offer, or from an accepted one when the sale falls through. */
    @Transactional
    public PropertyOfferResponse withdraw(Long id, OfferDecisionRequest request) {
        User user = securityUtils.getCurrentUser();
        PropertyOffer offer = requireEditable(id, user);
        OfferStatus now = offer.statusOn(LocalDate.now());
        if (!now.isOpen() && now != OfferStatus.ACCEPTED) {
            throw closed();
        }
        return decide(offer, OfferStatus.WITHDRAWN, OfferAction.WITHDRAWN, request, user);
    }

    private PropertyOfferResponse decide(PropertyOffer offer, OfferStatus status, OfferAction action,
                                         OfferDecisionRequest request, User user) {
        offer.setStatus(status);
        offer.setDecidedAt(LocalDateTime.now());
        offerRepository.saveAndFlush(offer);
        step(offer, action, null, request == null ? null : strip(request.getNote()), user);
        return withHistory(offer, user);
    }

    private void step(PropertyOffer offer, OfferAction action, OfferParty party, String note, User user) {
        eventRepository.save(PropertyOfferEvent.builder()
                .offer(offer)
                .action(action)
                .amount(offer.getAmount())
                .party(party)
                .note(note)
                .actor(user)
                .actorName(user.getFullName())
                .build());
    }

    // Rules -------------------------------------------------------------------------------

    private static void requireOpen(PropertyOffer offer, LocalDate today) {
        if (!offer.statusOn(today).isOpen()) {
            throw closed();
        }
    }

    private static BusinessException closed() {
        return new BusinessException(HttpStatus.CONFLICT, "OFFER_CLOSED",
                "This offer is no longer open");
    }

    private static void requireExpiryAhead(LocalDate expiresOn, LocalDate today) {
        if (expiresOn != null && expiresOn.isBefore(today)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "OFFER_EXPIRY_PAST",
                    "An offer cannot run out before today");
        }
    }

    private Property requireVisibleProperty(Long propertyId, User user) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + propertyId));
        if (!scopeService.canSeeInTeam(user, property.getTeam(), property.getAgent())) {
            throw new ResourceNotFoundException("Property not found with id: " + propertyId);
        }
        return property;
    }

    /** The offer, if the caller can see its listing. */
    private PropertyOffer requireVisible(Long id, User user) {
        PropertyOffer offer = offerRepository.findWithParties(id)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found with id: " + id));
        if (!scopeService.canSeeInTeam(user, offer.getTeam(), offer.getProperty().getAgent())) {
            throw new ResourceNotFoundException("Offer not found with id: " + id);
        }
        return offer;
    }

    private PropertyOffer requireEditable(Long id, User user) {
        PropertyOffer offer = requireVisible(id, user);
        if (!canEdit(offer, user)) {
            throw new AccessDeniedException(
                    "Only the agent following this offer, the listing's agent or a manager can change it");
        }
        return offer;
    }

    private boolean canEdit(PropertyOffer offer, User user) {
        return scopeService.isAdmin(user) || scopeService.isManager(user)
                || isUser(offer.getAgent(), user) || isUser(offer.getProperty().getAgent(), user);
    }

    private static boolean isUser(User someone, User user) {
        return someone != null && Objects.equals(someone.getId(), user.getId());
    }

    // Mapping -----------------------------------------------------------------------------

    private PropertyOfferResponse withHistory(PropertyOffer offer, User user) {
        PropertyOfferResponse response = toResponses(List.of(offer), user).get(0);
        response.setHistory(eventRepository.findHistory(offer.getId()).stream()
                .map(e -> PropertyOfferResponse.Step.builder()
                        .id(e.getId())
                        .action(e.getAction())
                        .amount(e.getAmount())
                        .party(e.getParty())
                        .note(e.getNote())
                        .actorId(e.getActor() == null ? null : e.getActor().getId())
                        .actorName(e.getActorName())
                        .createdAt(e.getCreatedAt())
                        .build())
                .toList());
        return response;
    }

    /** Every offer, with whether its listing has accepted another, read in one statement for the list. */
    private List<PropertyOfferResponse> toResponses(List<PropertyOffer> offers, User user) {
        if (offers.isEmpty()) {
            return List.of();
        }
        Map<Long, Long> accepted = new HashMap<>();
        for (Object[] row : offerRepository.findByStatusIn(
                offers.stream().map(o -> o.getProperty().getId()).distinct().toList(), OfferStatus.ACCEPTED)) {
            accepted.put((Long) row[0], (Long) row[1]);
        }
        LocalDate today = LocalDate.now();
        return offers.stream().map(o -> {
            Property p = o.getProperty();
            Client c = o.getClient();
            User agent = o.getAgent();
            OfferStatus status = o.statusOn(today);
            Long acceptedId = accepted.get(p.getId());
            boolean clientVisible = scopeService.canSee(user, c.getTeam(), c.getAgent());
            return PropertyOfferResponse.builder()
                    .id(o.getId())
                    .propertyId(p.getId())
                    .propertyTitle(p.getTitle())
                    .propertyAddress(p.getAddress())
                    .propertyPrice(p.getPrice())
                    .clientId(c.getId())
                    .clientVisible(clientVisible)
                    .clientName(clientVisible ? c.getFullName() : null)
                    .clientAgentName(c.getAgent() == null ? null : c.getAgent().getFullName())
                    .agentId(agent == null ? null : agent.getId())
                    .agentName(agent == null ? null : agent.getFullName())
                    .amount(o.getAmount())
                    .lastParty(o.getLastParty())
                    .note(o.getNote())
                    .expiresOn(o.getExpiresOn())
                    .status(status)
                    .otherAccepted(status.isOpen() && acceptedId != null && !acceptedId.equals(o.getId()))
                    .canEdit(canEdit(o, user))
                    .decidedAt(o.getDecidedAt())
                    .createdAt(o.getCreatedAt())
                    .updatedAt(o.getUpdatedAt())
                    .build();
        }).toList();
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
