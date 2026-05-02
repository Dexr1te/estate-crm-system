package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    public List<DealResponse> getAll() {
        return dealRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<DealResponse> getByAgent(Long agentId) {
        return dealRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<DealResponse> getByStatus(DealStatus status) {
        return dealRepository.findByStatus(status)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public DealResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional
    public DealResponse create(DealRequest request) {
        Deal deal = new Deal();
        mapRequestToEntity(request, deal);
        syncPropertyStatusWithDeal(deal);
        return toResponse(dealRepository.save(deal));
    }

    @Transactional
    public DealResponse update(Long id, DealRequest request) {
        Deal deal = findById(id);
        Property previousProperty = deal.getProperty();
        mapRequestToEntity(request, deal);

        if (request.getStatus() == DealStatus.CLOSED_WON || request.getStatus() == DealStatus.CLOSED_LOST) {
            deal.setClosedAt(LocalDateTime.now());
        } else if (request.getStatus() != null) {
            deal.setClosedAt(null);
        }

        // If property is detached from deal, release previous one.
        if (previousProperty != null && deal.getProperty() == null
                && previousProperty.getStatus() == PropertyStatus.RESERVED) {
            previousProperty.setStatus(PropertyStatus.AVAILABLE);
            propertyRepository.save(previousProperty);
        }

        // If property changed, release previous reserved property.
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
    public DealResponse updateStatus(Long id, DealStatus newStatus) {
        Deal deal = findById(id);
        deal.setStatus(newStatus);

        // Если сделка закрыта — фиксируем время
        if (newStatus == DealStatus.CLOSED_WON || newStatus == DealStatus.CLOSED_LOST) {
            deal.setClosedAt(LocalDateTime.now());
        } else {
            deal.setClosedAt(null);
        }

        syncPropertyStatusWithDeal(deal);

        return toResponse(dealRepository.save(deal));
    }

    @Transactional
    public void delete(Long id) {
        dealRepository.delete(findById(id));
    }


    private Deal findById(Long id) {
        return dealRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Deal not found with id: " + id));
    }

    private void mapRequestToEntity(DealRequest request, Deal deal) {
        deal.setTitle(request.getTitle());
        deal.setStatus(request.getStatus() != null ? request.getStatus() : DealStatus.LEAD);
        deal.setDealPrice(request.getDealPrice());
        deal.setBudget(request.getBudget());
        deal.setNotes(request.getNotes());

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Client not found with id: " + request.getClientId()));
        deal.setClient(client);

        if (request.getPropertyId() != null) {
            Property property = propertyRepository.findById(request.getPropertyId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Property not found with id: " + request.getPropertyId()));
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

        User agent = userRepository.findById(request.getAgentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Agent not found with id: " + request.getAgentId()));
        deal.setAgent(agent);
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
        res.setNotes(deal.getNotes());
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
