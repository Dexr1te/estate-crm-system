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
import com.crm.realestate.specification.ClientSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
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
        return findVisible(ClientSpecification.build(null, null, null, null, null));
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
        Specification<Client> spec = ClientSpecification.build(type, agentId, createdFrom, createdTo, search)
                .and(scopeService.visibleTo(currentUser));
        return clientRepository.findAll(spec, pageable).map(this::toResponse);
    }

    public List<ClientResponse> getByAgent(Long agentId) {
        return findVisible(ClientSpecification.build(null, agentId, null, null, null));
    }

    public List<ClientResponse> getByType(ClientType type) {
        return findVisible(ClientSpecification.build(type, null, null, null, null));
    }

    public List<ClientResponse> search(String query) {
        return findVisible(ClientSpecification.build(null, null, null, null, query));
    }

    public List<ClientListItem> getClientsWithDetails() {
        User currentUser = securityUtils.getCurrentUser();
        Long teamId = scopeService.teamIdOf(currentUser);
        List<Object[]> rows = clientRepository.findClientsWithDetails(
                scopeService.isAdmin(currentUser),
                teamId == null ? -1L : teamId,
                currentUser.getId(),
                scopeService.seesWholeTeam(currentUser));
        return rows.stream()
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
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public ClientResponse create(ClientRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = new Client();
        mapRequestToEntity(request, client, currentUser);

        if (client.getEmail() != null && clientRepository.existsByEmailAndTeam(client.getEmail(), client.getTeam())) {
            throw new RuntimeException("Client with this email already exists");
        }
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public ClientResponse update(Long id, ClientRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = findVisibleById(id, currentUser);
        mapRequestToEntity(request, client, currentUser);
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public void delete(Long id) {
        clientRepository.delete(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    private List<ClientResponse> findVisible(Specification<Client> filter) {
        User currentUser = securityUtils.getCurrentUser();
        return clientRepository.findAll(filter.and(scopeService.visibleTo(currentUser)))
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    /** Someone else's client reads as missing, so its existence is not confirmed either. */
    private Client findVisibleById(Long id, User currentUser) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + id));
        if (!scopeService.canSee(currentUser, client.getTeam(), client.getAgent())) {
            throw new ResourceNotFoundException("Client not found with id: " + id);
        }
        return client;
    }

    /**
     * Who holds the client, and which agency it lives in.
     *
     * <p>A new client goes to whoever creates it, in their team. Only an admin may name another
     * agent, and the client then lives in that agent's team. Editing never changes hands on its own:
     * a manager correcting a phone number is not taking the client over.
     */
    private void mapRequestToEntity(ClientRequest request, Client client, User currentUser) {
        boolean isNew = client.getId() == null;
        client.setFullName(request.getFullName());
        client.setEmail(request.getEmail());
        client.setPhone(request.getPhone());
        client.setType(request.getType());
        client.setNotes(request.getNotes());

        if (scopeService.isAdmin(currentUser) && request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            // A client already in an agency stays there; a team-less one may be placed in one.
            if (!isNew && client.getTeam() != null) {
                scopeService.requireSameTeam(client.getTeam(), agent.getTeam(), "Agent");
            }
            client.setAgent(agent);
            client.setTeam(agent.getTeam());
        } else if (isNew) {
            client.setAgent(currentUser);
            client.setTeam(currentUser.getTeam());
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
