package com.crm.realestate.service;

import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.entity.Client;
import org.springframework.stereotype.Component;

/**
 * The one definition of what a client looks like over the wire.
 *
 * <p>Lifted out of {@code ClientService} when matching started returning clients
 * too: two copies of this would drift the moment a field is added, and the
 * requirement fields were added the same day.
 */
@Component
public class ClientMapper {

    public ClientResponse toResponse(Client client) {
        ClientResponse res = new ClientResponse();
        res.setId(client.getId());
        res.setFullName(client.getFullName());
        res.setEmail(client.getEmail());
        res.setPhone(client.getPhone());
        res.setType(client.getType());
        res.setNotes(client.getNotes());
        res.setCreatedAt(client.getCreatedAt());
        res.setUpdatedAt(client.getUpdatedAt());
        res.setWantedType(client.getWantedType());
        res.setWantedCity(client.getWantedCity());
        res.setBudgetMin(client.getBudgetMin());
        res.setBudgetMax(client.getBudgetMax());
        res.setMinRooms(client.getMinRooms());
        res.setMinAreaSqm(client.getMinAreaSqm());
        if (client.getAgent() != null) {
            res.setAgentId(client.getAgent().getId());
            res.setAgentName(client.getAgent().getFullName());
        }
        return res;
    }
}
