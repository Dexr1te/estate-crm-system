package com.crm.realestate.service;

import com.crm.realestate.dto.response.ClientMatch;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.dto.response.PropertyMatch;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.specification.MatchSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Answers the question an agent asks all day: what do I show this buyer?
 *
 * <p>Both directions run through the same scoping as every other read here — a
 * buyer from another agency is not matched against these listings, and an agent
 * on own-data scope is not shown a colleague's client. So the answer differs by
 * who is asking, which is the point: it is a worklist, not a catalogue.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MatchingService {

    private final ClientRepository   clientRepository;
    private final PropertyRepository propertyRepository;
    private final MeetingRepository  meetingRepository;
    private final SecurityUtils      securityUtils;
    private final ScopeService       scopeService;
    private final ClientMapper       clientMapper;
    private final PropertyMapper     propertyMapper;

    /**
     * Listings that fit what this buyer asked for, the ones inside the budget
     * first and the ones just above it after.
     */
    public List<PropertyMatch> propertiesFor(Long clientId) {
        User currentUser = securityUtils.getCurrentUser();
        Client buyer = visibleClient(clientId, currentUser);

        // A seller has no requirements, and a buyer who stated none is not
        // looking for anything in particular yet. Neither is an error: the
        // screen simply has nothing to show.
        if (buyer.getType() != ClientType.BUYER || !MatchSpecification.hasAnyRequirement(buyer)) {
            return List.of();
        }

        BigDecimal ceiling = buyer.getBudgetMax();
        List<Meeting> history = meetingRepository.findByClientIdAndPropertyIdNotNull(buyer.getId());
        Set<Long> turnedDown = rejectedIn(history);
        Map<Long, LocalDateTime> lastShown = lastShownIn(history);

        return propertyRepository
                .findAll(MatchSpecification.listingsFor(buyer)
                        .and(scopeService.visibleToTeam(currentUser)))
                .stream()
                .filter(p -> !turnedDown.contains(p.getId()))
                .map(p -> new PropertyMatch(propertyMapper.toResponse(p),
                        isOver(p.getPrice(), ceiling), lastShown.get(p.getId())))
                .sorted(Comparator.comparing(PropertyMatch::isOverBudget)
                        .thenComparing(m -> m.getProperty().getPrice(),
                                Comparator.nullsLast(Comparator.naturalOrder())))
                .toList();
    }

    /** The mirror: buyers whose requirements this listing answers. */
    public List<ClientMatch> buyersFor(Long propertyId) {
        User currentUser = securityUtils.getCurrentUser();
        Property listing = visibleProperty(propertyId, currentUser);

        Set<Long> turnedItDown = rejectedBuyersOf(propertyId);

        return clientRepository
                .findAll(MatchSpecification.buyersFor(listing)
                        .and(scopeService.visibleTo(currentUser)))
                .stream()
                .filter(c -> !turnedItDown.contains(c.getId()))
                .map(c -> new ClientMatch(clientMapper.toResponse(c),
                        isOver(listing.getPrice(), c.getBudgetMax())))
                .sorted(Comparator.comparing(ClientMatch::isOverBudget)
                        .thenComparing(m -> m.getClient().getFullName(),
                                Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
                .toList();
    }

    /**
     * Listings this buyer has seen and said no to.
     *
     * <p>A verdict outlives the showing that produced it: once turned down, a listing stops being
     * offered to that buyer, however well it still fits the figures on paper.
     */
    private Set<Long> rejectedIn(List<Meeting> history) {
        return history.stream()
                .filter(m -> m.getOutcome() == ViewingOutcome.REJECTED)
                .map(m -> m.getProperty().getId())
                .collect(Collectors.toSet());
    }

    /** When each listing was last shown to this buyer, so the list can say so. */
    private Map<Long, LocalDateTime> lastShownIn(List<Meeting> history) {
        return history.stream().collect(Collectors.toMap(
                m -> m.getProperty().getId(),
                Meeting::getScheduledAt,
                (a, b) -> a.isAfter(b) ? a : b));
    }

    private Set<Long> rejectedBuyersOf(Long propertyId) {
        return meetingRepository.findByPropertyId(propertyId).stream()
                .filter(m -> m.getOutcome() == ViewingOutcome.REJECTED)
                .map(m -> m.getClient().getId())
                .collect(Collectors.toSet());
    }

    /** Above a stated ceiling, but inside the tolerance that let it through the query. */
    private boolean isOver(BigDecimal price, BigDecimal budgetMax) {
        return price != null && budgetMax != null && price.compareTo(budgetMax) > 0;
    }

    private Client visibleClient(Long id, User currentUser) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + id));
        if (!scopeService.canSee(currentUser, client.getTeam(), client.getAgent())) {
            throw new ResourceNotFoundException("Client not found with id: " + id);
        }
        return client;
    }

    private Property visibleProperty(Long id, User currentUser) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + id));
        if (!scopeService.canSeeInTeam(currentUser, property.getTeam(), property.getAgent())) {
            throw new ResourceNotFoundException("Property not found with id: " + id);
        }
        return property;
    }
}
