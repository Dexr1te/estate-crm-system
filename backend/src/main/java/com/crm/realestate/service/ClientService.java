package com.crm.realestate.service;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.response.ClientListItem;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.LeadSource;
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
    private final ClientMapper     clientMapper;
    private final ClientTagService tagService;

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
        return search(type, agentId, createdFrom, createdTo, search, null, null, pageable);
    }

    /**
     * A page of clients under every filter given, {@code tags} included (all of them), and only
     * those who came through {@code leadSource} when it is given.
     */
    public org.springframework.data.domain.Page<ClientResponse> search(
            ClientType type,
            Long agentId,
            LocalDate createdFrom,
            LocalDate createdTo,
            String search,
            List<String> tags,
            LeadSource leadSource,
            org.springframework.data.domain.Pageable pageable
    ) {
        User currentUser = securityUtils.getCurrentUser();
        Specification<Client> spec = ClientSpecification.build(type, agentId, createdFrom, createdTo, search, tags)
                .and(ClientSpecification.leadSource(leadSource))
                .and(scopeService.visibleTo(currentUser));
        return clientRepository.findAll(spec, pageable).map(this::toResponse);
    }

    /**
     * Every client under all the filters given, unpaged. Only a request naming tags or a lead
     * source ends up here: the older unpaged filters keep their one-filter-at-a-time answers for
     * the apps that use them.
     */
    public List<ClientResponse> filter(ClientType type, Long agentId, LocalDate createdFrom,
                                       LocalDate createdTo, String search, List<String> tags,
                                       LeadSource leadSource) {
        return findVisible(ClientSpecification.build(type, agentId, createdFrom, createdTo, search, tags)
                .and(ClientSpecification.leadSource(leadSource)));
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
                scopeService.seesWholeTeam(currentUser),
                LocalDateTime.now());
        return rows.stream()
                .map(row -> ClientListItem.builder()
                        .id(((Number) row[0]).longValue())
                        .fullName((String) row[1])
                        .phone((String) row[2])
                        .email((String) row[3])
                        .status(row[5] != null ? com.crm.realestate.enums.DealStatus.valueOf((String) row[5]) : null)
                        .budget(row[6] != null ? (BigDecimal) row[6] : null)
                        .propertyTitle((String) row[7])
                        .nextMeetingAt(toLocalDateTime(row[8]))
                        .lastContactAt(toLocalDateTime(row[9]))
                        .source(row[10] != null
                                ? com.crm.realestate.enums.ClientSource.valueOf((String) row[10])
                                : com.crm.realestate.enums.ClientSource.MANUAL)
                        .createdAt(toLocalDateTime(row[11]))
                        .build())
                .collect(Collectors.toList());
    }

    /** Native queries hand timestamps back as whatever the driver prefers; GREATEST varies too. */
    private static LocalDateTime toLocalDateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof java.sql.Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }
        if (value instanceof LocalDateTime local) {
            return local;
        }
        if (value instanceof java.time.OffsetDateTime offset) {
            return offset.toLocalDateTime();
        }
        throw new IllegalStateException("Unexpected timestamp type " + value.getClass());
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
        if (request.getTags() != null) {
            tagService.assign(client, request.getTags());
        }
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public ClientResponse update(Long id, ClientRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Client client = findVisibleById(id, currentUser);
        Long teamBefore = client.getTeam() == null ? null : client.getTeam().getId();
        mapRequestToEntity(request, client, currentUser);
        Long teamAfter = client.getTeam() == null ? null : client.getTeam().getId();
        if (request.getTags() != null) {
            tagService.assign(client, request.getTags());
        } else if (!java.util.Objects.equals(teamBefore, teamAfter) && !client.getTags().isEmpty()) {
            // Placed in an agency: the same words, but from that agency's vocabulary.
            tagService.assign(client, tagService.names(client));
        }
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public void delete(Long id) {
        Client client = findVisibleById(id, securityUtils.getCurrentUser());
        boolean tagged = !client.getTags().isEmpty();
        clientRepository.delete(client);
        if (tagged) {
            tagService.forgetUnused(client.getTeam());
        }
    }

    private List<ClientResponse> findVisible(Specification<Client> filter) {
        User currentUser = securityUtils.getCurrentUser();
        return clientRepository.findAll(filter.and(scopeService.visibleTo(currentUser)))
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    /**
     * The client, if this person may read it. Anything hanging off a client — its history, its
     * matches — goes through here, so it sits behind the same walls as the client itself.
     */
    public Client requireVisible(Long id, User currentUser) {
        return findVisibleById(id, currentUser);
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
        applyRequirements(request, client);
        if (isNew || request.isLeadSourceSent()) {
            applyLeadSource(client, request.getLeadSource(), request.getLeadSourceDetail());
        }
        if (request.getBirthday() != null) {
            ClientBirthday birthday = ClientBirthday.parse(request.getBirthday(), LocalDate.now());
            if (birthday == null) {
                ClientBirthday.clear(client);
            } else {
                birthday.applyTo(client);
            }
        }

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

    /**
     * What the buyer is looking for, or nothing at all.
     *
     * <p>A seller's requirements are cleared rather than kept: a client switched
     * from buying to selling would otherwise keep matching listings against a
     * wish list nobody can see on the screen any more.
     */
    private void applyRequirements(ClientRequest request, Client client) {
        boolean buying = request.getType() == ClientType.BUYER;
        client.setWantedType(buying ? request.getWantedType() : null);
        client.setWantedCity(buying ? blankToNull(request.getWantedCity()) : null);
        client.setBudgetMin(buying ? request.getBudgetMin() : null);
        client.setBudgetMax(buying ? request.getBudgetMax() : null);
        client.setMinRooms(buying ? request.getMinRooms() : null);
        client.setMinAreaSqm(buying ? request.getMinAreaSqm() : null);
    }

    /**
     * How the client reached the agency. The detail only means something beside a source, so it
     * goes with one that is cleared, and is trimmed to what the column holds.
     */
    public static void applyLeadSource(Client client, LeadSource source, String detail) {
        client.setLeadSource(source);
        String trimmed = source == null ? null : blankToNull(detail);
        client.setLeadSourceDetail(trimmed == null || trimmed.length() <= LEAD_SOURCE_DETAIL_MAX
                ? trimmed : trimmed.substring(0, LEAD_SOURCE_DETAIL_MAX));
    }

    /** What {@code clients.lead_source_detail} holds. */
    public static final int LEAD_SOURCE_DETAIL_MAX = 255;

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private ClientResponse toResponse(Client client) {
        return clientMapper.toResponse(client);
    }
}
