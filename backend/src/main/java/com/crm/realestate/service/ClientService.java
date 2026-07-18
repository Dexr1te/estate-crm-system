package com.crm.realestate.service;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.response.ClientListItem;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientService {

    private final ClientRepository clientRepository;
    private final UserRepository   userRepository;
    private final SecurityUtils    securityUtils;
    private final ScopeService     scopeService;

    public List<ClientResponse> getAll() {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        Specification<Client> spec = com.crm.realestate.specification.ClientSpecification.build(null, null, null, null, null, allowedAgentIds);
        return clientRepository.findAll(spec)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public org.springframework.data.domain.Page<ClientResponse> search(
            ClientType type,
            Long agentId,
            LocalDate createdFrom,
            LocalDate createdTo,
            String search,
            org.springframework.data.domain.Pageable pageable
    ) {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        if (allowedAgentIds != null) {
            agentId = null; // ignore explicit agent filtering for scoped users
        }
        Specification<Client> spec = com.crm.realestate.specification.ClientSpecification.build(type, agentId, createdFrom, createdTo, search, allowedAgentIds);
        return clientRepository.findAll(spec, pageable).map(this::toResponse);
    }

    public List<ClientResponse> getByAgent(Long agentId) {
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, agentId)) {
            throw new ResourceNotFoundException("Client not found");
        }
        return clientRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<ClientResponse> getByType(ClientType type) {
        return clientRepository.findByType(type)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<ClientResponse> search(String query) {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        return clientRepository.searchClients(query)
                .stream()
                .map(this::toResponse)
                .filter(client -> allowedAgentIds == null || client.getAgentId() == null || allowedAgentIds.contains(client.getAgentId()))
                .collect(Collectors.toList());
    }

    public List<ClientListItem> getClientsWithDetails() {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        List<Object[]> rows = clientRepository.findClientsWithDetails();
        return rows.stream()
                .filter(row -> {
                    Long agentId = row[4] != null ? ((Number) row[4]).longValue() : null;
                    return allowedAgentIds == null || agentId == null || allowedAgentIds.contains(agentId);
                })
                .map(row -> ClientListItem.builder()
                        .id(((Number) row[0]).longValue())
                        .fullName((String) row[1])
                        .phone((String) row[2])
                        .email((String) row[3])
                        .status(row[5] != null ? com.crm.realestate.enums.DealStatus.valueOf((String) row[5]) : null)
                        .budget(row[6] != null ? (BigDecimal) row[6] : null)
                        .propertyTitle((String) row[7])
                        .nextMeetingAt(row[8] != null ? ((java.sql.Timestamp) row[8]).toLocalDateTime() : null)
                        .lastContactAt(row[9] != null ? ((java.sql.Timestamp) row[9]).toLocalDateTime() : null)
                        .build())
                .collect(Collectors.toList());
    }

    public ClientResponse getById(Long id) {
        Client client = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), client.getAgent() == null ? null : client.getAgent().getId())) {
            throw new ResourceNotFoundException("Client not found");
        }
        return toResponse(client);
    }

    @Transactional
    public ClientResponse create(ClientRequest request) {
        if (request.getEmail() != null && clientRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Client with this email already exists");
        }

        Client client = new Client();
        mapRequestToEntity(request, client, securityUtils.getCurrentUser());
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public ClientResponse update(Long id, ClientRequest request) {
        Client client = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), client.getAgent() == null ? null : client.getAgent().getId())) {
            throw new ResourceNotFoundException("Client not found");
        }
        mapRequestToEntity(request, client, securityUtils.getCurrentUser());
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public void delete(Long id) {
        Client client = findById(id);
        if (!scopeService.isWithinScope(securityUtils.getCurrentUser(), client.getAgent() == null ? null : client.getAgent().getId())) {
            throw new ResourceNotFoundException("Client not found");
        }
        clientRepository.delete(client);
    }

    private Client findById(Long id) {
        return clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + id));
    }

    private void mapRequestToEntity(ClientRequest request, Client client, User currentUser) {
        client.setFullName(request.getFullName());
        client.setEmail(request.getEmail());
        client.setPhone(request.getPhone());
        client.setType(request.getType());
        client.setNotes(request.getNotes());

        if (currentUser.getRole() == com.crm.realestate.enums.Role.ADMIN && request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            client.setAgent(agent);
        } else {
            client.setAgent(currentUser);
        }
    }

    private ClientResponse toResponse(Client client) {
        ClientResponse res = new ClientResponse();
        res.setId(client.getId());
        res.setFullName(client.getFullName());
        res.setEmail(client.getEmail());
        res.setPhone(client.getPhone());
        res.setType(client.getType());
        res.setNotes(client.getNotes());
        res.setCreatedAt(client.getCreatedAt());
        res.setUpdatedAt(client.getUpdatedAt());
        if (client.getAgent() != null) {
            res.setAgentId(client.getAgent().getId());
            res.setAgentName(client.getAgent().getFullName());
        }
        return res;
    }
}