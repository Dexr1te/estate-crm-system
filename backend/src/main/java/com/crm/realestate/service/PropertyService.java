package com.crm.realestate.service;

import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.specification.PropertySpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

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
        User currentUser = securityUtils.getCurrentUser();
        Specification<Property> spec =
                PropertySpecification.build(status, type, city, minPrice, maxPrice, rooms, agentId, search)
                        .and(scopeService.visibleToTeam(currentUser));

        return propertyRepository.findAll(spec, pageable).map(this::toResponse);
    }

    public PropertyResponse getById(Long id) {
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public PropertyResponse create(PropertyRequest request) {
        Property property = new Property();
        mapRequestToEntity(request, property, securityUtils.getCurrentUser());
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public PropertyResponse update(Long id, PropertyRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = findVisibleById(id, currentUser);
        mapRequestToEntity(request, property, currentUser);
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public PropertyResponse updateStatus(Long id, PropertyStatus status) {
        Property property = findVisibleById(id, securityUtils.getCurrentUser());
        property.setStatus(status);
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public void delete(Long id) {
        propertyRepository.delete(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    // Private helpers

    private List<PropertyResponse> findVisible(Specification<Property> filter) {
        User currentUser = securityUtils.getCurrentUser();
        return propertyRepository.findAll(filter.and(scopeService.visibleToTeam(currentUser)))
                .stream().map(this::toResponse).collect(Collectors.toList());
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
        PropertyResponse res = new PropertyResponse();
        res.setId(p.getId());
        res.setTitle(p.getTitle());
        res.setDescription(p.getDescription());
        res.setAddress(p.getAddress());
        res.setCity(p.getCity());
        res.setType(p.getType());
        res.setStatus(p.getStatus());
        res.setPrice(p.getPrice());
        res.setAreaSqm(p.getAreaSqm());
        res.setRooms(p.getRooms());
        res.setFloor(p.getFloor());
        res.setTotalFloors(p.getTotalFloors());
        res.setCreatedAt(p.getCreatedAt());
        res.setUpdatedAt(p.getUpdatedAt());
        if (p.getAgent() != null) {
            res.setAgentId(p.getAgent().getId());
            res.setAgentName(p.getAgent().getFullName());
        }
        return res;
    }
}
