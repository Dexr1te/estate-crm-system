package com.crm.realestate.service;

import com.crm.realestate.dto.response.ClientDuplicate;
import com.crm.realestate.dto.response.ClientDuplicate.MatchedOn;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * The same person entered twice: spotting it, and folding the two cards into one.
 *
 * <p>The lookup is agency-wide whatever the caller's data scope — the point is that an agent on
 * their own clients learns a colleague already has this buyer. What it returns is kept to the
 * minimum for that ({@link ClientDuplicate}). It never looks outside the caller's agency.
 *
 * <p>The merge is a manager's or an admin's call, inside one agency, in one transaction.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientDuplicateService {

    /** More than this many cards for one phone is a data problem, not a list to scroll. */
    private static final int MAX_DUPLICATES = 20;

    private final ClientRepository clientRepository;
    private final DealRepository dealRepository;
    private final MeetingRepository meetingRepository;
    private final ClientActivityRepository activityRepository;
    private final TaskRepository taskRepository;
    private final ClientService clientService;
    private final ClientMapper clientMapper;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final AuditLogService auditLogService;
    private final EntityManager entityManager;

    public List<ClientDuplicate> find(String phone, String email, Long excludeId) {
        String normalizedPhone = ContactNormalizer.phone(phone);
        String normalizedEmail = ContactNormalizer.email(email);
        if (normalizedPhone == null && normalizedEmail == null) {
            return List.of();
        }
        User currentUser = securityUtils.getCurrentUser();
        return clientRepository.findDuplicates(scopeService.teamIdOf(currentUser), currentUser.getId(),
                        normalizedPhone, normalizedEmail, excludeId, PageRequest.of(0, MAX_DUPLICATES))
                .stream()
                .map(client -> toDuplicate(client, normalizedPhone, normalizedEmail,
                        scopeService.canSee(currentUser, client.getTeam(), client.getAgent())))
                .toList();
    }

    /**
     * Folds {@code sourceId} into {@code targetId}: its deals, meetings (viewing outcomes ride on
     * them), logged contacts and tasks move over; the target's empty contact details and buyer
     * requirements are filled from it; its notes are appended; then it is deleted.
     *
     * <p>Moves are bulk updates, one statement per kind of record. The persistence context is then
     * cleared before the source is deleted — a stale {@code deals} collection on it would otherwise
     * cascade the deletion to deals that now belong to the target.
     */
    @Transactional
    public ClientResponse merge(Long targetId, Long sourceId) {
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isManager(currentUser) && !scopeService.isAdmin(currentUser)) {
            throw new AccessDeniedException("Only a manager or an admin can merge clients");
        }
        if (Objects.equals(targetId, sourceId)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MERGE_SAME_CLIENT",
                    "A client cannot be merged into itself");
        }
        Client target = clientService.requireVisible(targetId, currentUser);
        Client source = clientService.requireVisible(sourceId, currentUser);
        if (!Objects.equals(teamIdOf(target), teamIdOf(source))) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "MERGE_ACROSS_AGENCIES",
                    "Clients from different agencies cannot be merged");
        }

        Client carried = snapshot(source);
        int deals = dealRepository.moveToClient(source, target);
        int meetings = meetingRepository.moveToClient(source, target);
        int activities = activityRepository.moveToClient(source, target);
        int tasks = taskRepository.moveToClient(source, target);
        auditLogService.record(currentUser, "MERGE_CLIENT", "Client", targetId,
                "source=" + sourceId + " name=" + carried.getFullName()
                        + " deals=" + deals + " meetings=" + meetings
                        + " activities=" + activities + " tasks=" + tasks);

        entityManager.flush();
        entityManager.clear();
        // Deleted first: the source's email would otherwise collide with the target's
        // (one address per agency) the moment it is copied over.
        clientRepository.deleteById(sourceId);
        clientRepository.flush();

        Client merged = clientRepository.findById(targetId)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + targetId));
        fillFrom(merged, carried);
        return clientMapper.toResponse(clientRepository.save(merged));
    }

    private static Long teamIdOf(Client client) {
        return client.getTeam() == null ? null : client.getTeam().getId();
    }

    /** What the target may take from the source, read before the source is gone. */
    private static Client snapshot(Client source) {
        return Client.builder()
                .fullName(source.getFullName())
                .email(source.getEmail())
                .phone(source.getPhone())
                .notes(source.getNotes())
                .wantedType(source.getWantedType())
                .wantedCity(source.getWantedCity())
                .budgetMin(source.getBudgetMin())
                .budgetMax(source.getBudgetMax())
                .minRooms(source.getMinRooms())
                .minAreaSqm(source.getMinAreaSqm())
                .build();
    }

    /**
     * Only what the target is missing. A seller keeps no requirements (see ClientService), so a
     * buyer's wish list is not copied onto one.
     */
    private static void fillFrom(Client target, Client source) {
        if (isBlank(target.getEmail())) {
            target.setEmail(source.getEmail());
        }
        if (isBlank(target.getPhone())) {
            target.setPhone(source.getPhone());
        }
        if (!isBlank(source.getNotes())) {
            target.setNotes(isBlank(target.getNotes())
                    ? source.getNotes()
                    : target.getNotes().stripTrailing() + "\n\n" + source.getNotes().strip());
        }
        if (target.getType() != ClientType.BUYER) {
            return;
        }
        if (target.getWantedType() == null) target.setWantedType(source.getWantedType());
        if (isBlank(target.getWantedCity())) target.setWantedCity(source.getWantedCity());
        if (target.getBudgetMin() == null) target.setBudgetMin(source.getBudgetMin());
        if (target.getBudgetMax() == null) target.setBudgetMax(source.getBudgetMax());
        if (target.getMinRooms() == null) target.setMinRooms(source.getMinRooms());
        if (target.getMinAreaSqm() == null) target.setMinAreaSqm(source.getMinAreaSqm());
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private static ClientDuplicate toDuplicate(Client client, String phone, String email,
                                               boolean visible) {
        boolean byPhone = phone != null && phone.equals(client.getPhoneNormalized());
        boolean byEmail = email != null && email.equals(ContactNormalizer.email(client.getEmail()));
        MatchedOn matchedOn = byPhone && byEmail ? MatchedOn.PHONE_AND_EMAIL
                : byPhone ? MatchedOn.PHONE : MatchedOn.EMAIL;
        User agent = client.getAgent();
        return ClientDuplicate.builder()
                .id(client.getId())
                .fullName(client.getFullName())
                .type(client.getType())
                .agentId(agent == null ? null : agent.getId())
                .agentName(agent == null ? null : agent.getFullName())
                .phone(client.getPhone())
                .email(client.getEmail())
                .matchedOn(matchedOn)
                .visible(visible)
                .build();
    }
}
