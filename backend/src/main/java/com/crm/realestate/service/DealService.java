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
import com.crm.realestate.security.SecurityUtils;
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
    private final SecurityUtils      securityUtils;
    private final ScopeService       scopeService;

    public List<DealResponse> getAll() {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        if (allowedAgentIds == null) {
            return dealRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
        }
        return dealRepository.findByAgentIdIn(allowedAgentIds)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<DealResponse> getByAgent(Long agentId) {
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, agentId)) {
            throw new ResourceNotFoundException("Deal not found");
        }
        return dealRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<DealResponse> getByStatus(DealStatus status) {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        if (allowedAgentIds == null) {
            return dealRepository.findByStatus(status)
                    .stream().map(this::toResponse).collect(Collectors.toList());
        }
        return dealRepository.findAll(com.crm.realestate.specification.DealSpecification.build(status, null, null, allowedAgentIds))
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public DealResponse getById(Long id) {
        Deal deal = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), deal.getAgent() == null ? null : deal.getAgent().getId())) {
            throw new ResourceNotFoundException("Deal not found");
        }
        return toResponse(deal);
    }

    @Transactional
    public DealResponse create(DealRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Deal deal = new Deal();
        mapRequestToEntity(request, deal, currentUser);
        syncPropertyStatusWithDeal(deal);
        return toResponse(dealRepository.save(deal));
    }

    @Transactional
    public DealResponse update(Long id, DealRequest request) {
        Deal deal = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), deal.getAgent() == null ? null : deal.getAgent().getId())) {
            throw new ResourceNotFoundException("Deal not found");
        }
        Property previousProperty = deal.getProperty();
        mapRequestToEntity(request, deal, securityUtils.getCurrentUser());

        if (request.getStatus() == DealStatus.CLOSED_WON || request.getStatus() == DealStatus.CLOSED_LOST) {
            deal.setClosedAt(LocalDateTime.now());
        } else if (request.getStatus() != null) {
            deal.setClosedAt(null);
        }

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
    public DealResponse updateStatus(Long id, DealStatus newStatus) {
        Deal deal = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), deal.getAgent() == null ? null : deal.getAgent().getId())) {
            throw new ResourceNotFoundException("Deal not found");
        }
        deal.setStatus(newStatus);

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
        Deal deal = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), deal.getAgent() == null ? null : deal.getAgent().getId())) {
            throw new ResourceNotFoundException("Deal not found");
        }
        dealRepository.delete(deal);
    }


    private Deal findById(Long id) {
        return dealRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Deal not found with id: " + id));
    }

    private void mapRequestToEntity(DealRequest request, Deal deal, User currentUser) {
        deal.setTitle(request.getTitle());
        deal.setStatus(request.getStatus() != null ? request.getStatus() : DealStatus.LEAD);
        deal.setDealPrice(request.getDealPrice());
        deal.setBudget(request.getBudget());
        deal.setNotes(request.getNotes());

        Client client = clientRepository.findById(request.getClientId())
               .orElseThrow(() -> new ResourceNotFoundException(
                       "Client not found with id: " + request.getClientId()));
       if (!scopeService.isWithinScope(currentUser, client.getAgent() == null ? null : client.getAgent().getId())) {
           throw new ResourceNotFoundException("Client not found");
       }
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

       if (currentUser.getRole() == com.crm.realestate.enums.Role.ADMIN && request.getAgentId() != null) {
           User agent = userRepository.findById(request.getAgentId())
                   .orElseThrow(() -> new ResourceNotFoundException(
                           "Agent not found with id: " + request.getAgentId()));
           deal.setAgent(agent);
       } else {
           deal.setAgent(currentUser);
       }
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
