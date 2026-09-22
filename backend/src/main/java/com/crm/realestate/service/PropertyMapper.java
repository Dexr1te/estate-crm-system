package com.crm.realestate.service;

import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.entity.Property;
import org.springframework.stereotype.Component;

/** The one definition of what a listing looks like over the wire. See {@link ClientMapper}. */
@Component
public class PropertyMapper {

    public PropertyResponse toResponse(Property p) {
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
