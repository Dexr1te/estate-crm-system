package com.crm.realestate.service;

import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPriceChange;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPriceChangeRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.specification.MapBounds;
import com.crm.realestate.specification.PropertySpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Listings are the agency's stock: everyone in a team sees and maintains all of the team's, whatever
 * their data scope — see {@link ScopeService#visibleToTeam}.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository     userRepository;
    private final SecurityUtils      securityUtils;
    private final ScopeService       scopeService;
    private final PropertyMapper     propertyMapper;
    private final PropertyPriceChangeRepository priceChangeRepository;
    private final NotificationEvents notificationEvents;

    /** How far ahead an agreement's end counts as "running out". */
    public static final int MANDATE_WINDOW_DAYS = 14;

    /** Statuses of a listing still on the market, whose agreement therefore still matters. */
    private static final List<PropertyStatus> ON_THE_MARKET =
            List.of(PropertyStatus.AVAILABLE, PropertyStatus.RESERVED);

    public List<PropertyResponse> getAll() {
        return findVisible(PropertySpecification.build(null, null, null, null, null, null, null, null));
    }

    public List<PropertyResponse> filter(PropertyStatus status, PropertyType type,
                                          String city, BigDecimal minPrice, BigDecimal maxPrice) {
        return findVisible(PropertySpecification.build(status, type, city, minPrice, maxPrice, null, null, null));
    }

    public List<PropertyResponse> search(String query) {
        return findVisible(PropertySpecification.build(null, null, null, null, null, null, null, query));
    }

    // New: pageable + specification-based search for production-ready filtering and pagination
    public org.springframework.data.domain.Page<PropertyResponse> search(
            PropertyStatus status,
            PropertyType type,
            String city,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Integer rooms,
            Long agentId,
            String search,
            org.springframework.data.domain.Pageable pageable
    ) {
        return search(status, type, city, minPrice, maxPrice, rooms, agentId, search, null, null,
                pageable);
    }

    /**
     * The same, narrowed to the rectangle a map is showing and to listings with or without a pin.
     * Either may be null, and neither widens what the caller's team can see.
     */
    public org.springframework.data.domain.Page<PropertyResponse> search(
            PropertyStatus status,
            PropertyType type,
            String city,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Integer rooms,
            Long agentId,
            String search,
            MapBounds bounds,
            Boolean hasLocation,
            org.springframework.data.domain.Pageable pageable
    ) {
        User currentUser = securityUtils.getCurrentUser();
        Specification<Property> spec =
                PropertySpecification.build(status, type, city, minPrice, maxPrice, rooms, agentId, search)
                        .and(PropertySpecification.within(bounds))
                        .and(PropertySpecification.hasLocation(hasLocation))
                        .and(scopeService.visibleToTeam(currentUser));

        org.springframework.data.domain.Page<Property> page = propertyRepository.findAll(spec, pageable);
        Map<Long, PropertyPriceChange> latestChanges = propertyMapper.latestChanges(page.getContent());
        Map<Long, LocalDate> holds = propertyMapper.depositHolds(page.getContent());
        return page.map(p -> propertyMapper.toResponse(p, latestChanges.get(p.getId()), holds.get(p.getId())));
    }

    /**
     * The agency's listings still on the market whose seller agreement ends within
     * {@link #MANDATE_WINDOW_DAYS} days, or has already ended: the ones to renew with the seller
     * before somebody else lists them. Soonest (or longest gone) first. An agreement without an
     * end date never runs out, and a sold listing no longer needs one. Seen by the whole team,
     * like the listings themselves.
     */
    public List<PropertyResponse> mandatesEnding() {
        LocalDate horizon = LocalDate.now().plusDays(MANDATE_WINDOW_DAYS);
        Specification<Property> ending = (root, query, cb) -> cb.and(
                cb.isNotNull(root.get("mandateType")),
                cb.isNotNull(root.get("mandateEndDate")),
                cb.lessThanOrEqualTo(root.<LocalDate>get("mandateEndDate"), horizon),
                root.get("status").in(ON_THE_MARKET));
        User currentUser = securityUtils.getCurrentUser();
        return propertyMapper.toResponses(propertyRepository.findAll(
                ending.and(scopeService.visibleToTeam(currentUser)),
                Sort.by(Sort.Order.asc("mandateEndDate"), Sort.Order.asc("id"))));
    }

    public PropertyResponse getById(Long id) {
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public PropertyResponse create(PropertyRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = new Property();
        mapRequestToEntity(request, property, currentUser);
        Property saved = propertyRepository.save(property);
        notificationEvents.listingAvailable(saved, currentUser);
        return toResponse(saved);
    }

    /** An edit that moves the price leaves a row behind, so a reduction can be seen afterwards. */
    @Transactional
    public PropertyResponse update(Long id, PropertyRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = findVisibleById(id, currentUser);
        BigDecimal oldPrice = property.getPrice();
        PropertyStatus oldStatus = property.getStatus();
        mapRequestToEntity(request, property, currentUser);
        Property saved = propertyRepository.save(property);
        BigDecimal newPrice = saved.getPrice();
        if (oldPrice != null && newPrice != null && oldPrice.compareTo(newPrice) != 0) {
            priceChangeRepository.save(PropertyPriceChange.builder()
                    .property(saved)
                    .team(saved.getTeam())
                    .oldPrice(oldPrice)
                    .newPrice(newPrice)
                    .changedBy(currentUser)
                    .build());
        }
        if (oldStatus != PropertyStatus.AVAILABLE) {
            notificationEvents.listingAvailable(saved, currentUser);
        } else {
            notificationEvents.priceDropped(saved, oldPrice, newPrice, currentUser);
        }
        return toResponse(saved);
    }

    /** Every change of this listing's price, newest first. Seen by whoever can see the listing. */
    public List<PropertyPriceChangeResponse> priceHistory(Long id) {
        Property property = findVisibleById(id, securityUtils.getCurrentUser());
        return priceChangeRepository.findHistory(property.getId()).stream()
                .map(propertyMapper::toResponse)
                .toList();
    }

    @Transactional
    public PropertyResponse updateStatus(Long id, PropertyStatus status) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = findVisibleById(id, currentUser);
        PropertyStatus oldStatus = property.getStatus();
        property.setStatus(status);
        Property saved = propertyRepository.save(property);
        if (oldStatus != PropertyStatus.AVAILABLE) {
            notificationEvents.listingAvailable(saved, currentUser);
        }
        return toResponse(saved);
    }

    @Transactional
    public void delete(Long id) {
        propertyRepository.delete(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    // Private helpers

    private List<PropertyResponse> findVisible(Specification<Property> filter) {
        User currentUser = securityUtils.getCurrentUser();
        return propertyMapper.toResponses(
                propertyRepository.findAll(filter.and(scopeService.visibleToTeam(currentUser))));
    }

    /** Another agency's listing reads as missing, so its existence is not confirmed either. */
    private Property findVisibleById(Long id, User currentUser) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + id));
        if (!scopeService.canSeeInTeam(currentUser, property.getTeam(), property.getAgent())) {
            throw new ResourceNotFoundException("Property not found with id: " + id);
        }
        return property;
    }

    /**
     * A new listing is held by whoever adds it, in their team — it used to be saved with no agent at
     * all, which left it belonging to nobody. Only an admin may name another agent, and the listing
     * then lives in that agent's team.
     */
    private void mapRequestToEntity(PropertyRequest request, Property property, User currentUser) {
        boolean isNew = property.getId() == null;
        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setAddress(request.getAddress());
        property.setCity(request.getCity());
        property.setType(request.getType());
        property.setStatus(request.getStatus() != null ? request.getStatus() : PropertyStatus.AVAILABLE);
        property.setPrice(request.getPrice());
        property.setAreaSqm(request.getAreaSqm());
        property.setRooms(request.getRooms());
        property.setFloor(request.getFloor());
        property.setTotalFloors(request.getTotalFloors());
        property.setLatitude(request.getLatitude());
        property.setLongitude(request.getLongitude());
        property.setMandateType(request.getMandateType());
        property.setMandateEndDate(request.getMandateEndDate());

        if (scopeService.isAdmin(currentUser) && request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            // A listing already in an agency stays there; a team-less one may be placed in one.
            if (!isNew && property.getTeam() != null) {
                scopeService.requireSameTeam(property.getTeam(), agent.getTeam(), "Agent");
            }
            property.setAgent(agent);
            property.setTeam(agent.getTeam());
        } else if (isNew && !scopeService.isAdmin(currentUser)) {
            property.setAgent(currentUser);
            property.setTeam(currentUser.getTeam());
        }
    }

    private PropertyResponse toResponse(Property p) {
        return propertyMapper.toResponse(p);
    }
}
