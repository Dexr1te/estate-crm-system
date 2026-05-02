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
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository     userRepository;

    public List<PropertyResponse> getAll() {
        return propertyRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<PropertyResponse> filter(PropertyStatus status, PropertyType type,
                                          String city, BigDecimal minPrice, BigDecimal maxPrice) {
        String normalizedCity = (city == null || city.isBlank())
                ? null
                : city.trim().toLowerCase();

        return propertyRepository.filterProperties(status, type, normalizedCity, minPrice, maxPrice)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<PropertyResponse> search(String query) {
        return propertyRepository.searchProperties(query)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public PropertyResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional
    public PropertyResponse create(PropertyRequest request) {
        Property property = new Property();
        mapRequestToEntity(request, property);
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public PropertyResponse update(Long id, PropertyRequest request) {
        Property property = findById(id);
        mapRequestToEntity(request, property);
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public PropertyResponse updateStatus(Long id, PropertyStatus status) {
        Property property = findById(id);
        property.setStatus(status);
        return toResponse(propertyRepository.save(property));
    }

    @Transactional
    public void delete(Long id) {
        propertyRepository.delete(findById(id));
    }

    // Private helpers 

    private Property findById(Long id) {
        return propertyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + id));
    }

    private void mapRequestToEntity(PropertyRequest request, Property property) {
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

        if (request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            property.setAgent(agent);
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
