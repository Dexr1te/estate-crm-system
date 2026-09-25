package com.crm.realestate.service;

import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPriceChange;
import com.crm.realestate.repository.PropertyPriceChangeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * The one definition of what a listing looks like over the wire. See {@link ClientMapper}.
 *
 * <p>A listing carries its latest price change, so the list can say a flat has come down. Lists
 * go through {@link #toResponses}, which loads those for every row in one statement.
 */
@Component
@RequiredArgsConstructor
public class PropertyMapper {

    private final PropertyPriceChangeRepository priceChangeRepository;

    public PropertyResponse toResponse(Property p) {
        return toResponse(p, latestChanges(List.of(p)).get(p.getId()));
    }

    public List<PropertyResponse> toResponses(List<Property> properties) {
        Map<Long, PropertyPriceChange> latest = latestChanges(properties);
        return properties.stream().map(p -> toResponse(p, latest.get(p.getId()))).toList();
    }

    /** The newest price change of each listing, keyed by listing id; absent if never changed. */
    public Map<Long, PropertyPriceChange> latestChanges(Collection<Property> properties) {
        List<Long> ids = properties.stream().map(Property::getId).filter(Objects::nonNull).toList();
        if (ids.isEmpty()) {
            return Map.of();
        }
        return priceChangeRepository.findLatestFor(ids).stream().collect(Collectors.toMap(
                c -> c.getProperty().getId(),
                Function.identity(),
                (a, b) -> a.getId() > b.getId() ? a : b));
    }

    public PropertyResponse toResponse(Property p, PropertyPriceChange latestChange) {
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
        if (latestChange != null) {
            res.setPreviousPrice(latestChange.getOldPrice());
            res.setPriceChangedAt(latestChange.getChangedAt());
        }
        return res;
    }

    public PropertyPriceChangeResponse toResponse(PropertyPriceChange c) {
        PropertyPriceChangeResponse res = new PropertyPriceChangeResponse();
        res.setId(c.getId());
        res.setPropertyId(c.getProperty().getId());
        res.setOldPrice(c.getOldPrice());
        res.setNewPrice(c.getNewPrice());
        res.setChangedAt(c.getChangedAt());
        if (c.getChangedBy() != null) {
            res.setChangedById(c.getChangedBy().getId());
            res.setChangedByName(c.getChangedBy().getFullName());
        }
        return res;
    }
}
