package com.crm.realestate.service;

import com.crm.realestate.dto.response.RecordChangeResponse;
import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.RecordChangeRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Reads the change log written by {@link ChangeLogService}.
 *
 * <p>A record's own history is seen by whoever can see the record, through the record's service,
 * so an agent on their own clients cannot read a colleague's client's history and another agency's
 * record reads as not found. The agency's whole feed is the manager's (or an admin's, who may name
 * the agency); an agent is refused with MANAGER_ONLY.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChangeHistoryService {

    public static final int MAX_PAGE_SIZE = 100;
    private static final Sort NEWEST_FIRST = Sort.by(Sort.Order.desc("changedAt"), Sort.Order.desc("id"));

    private final RecordChangeRepository repository;
    private final TeamRepository teamRepository;
    private final PropertyService propertyService;
    private final DealService dealService;
    private final ClientService clientService;
    private final SecurityUtils securityUtils;

    public Page<RecordChangeResponse> forProperty(Long id, int page, int size) {
        Long visible = propertyService.requireVisible(id, securityUtils.getCurrentUser()).getId();
        return history(ChangeEntityType.PROPERTY, visible, page, size);
    }

    public Page<RecordChangeResponse> forDeal(Long id, int page, int size) {
        Long visible = dealService.requireVisible(id, securityUtils.getCurrentUser()).getId();
        return history(ChangeEntityType.DEAL, visible, page, size);
    }

    public Page<RecordChangeResponse> forClient(Long id, int page, int size) {
        Long visible = clientService.requireVisible(id, securityUtils.getCurrentUser()).getId();
        return history(ChangeEntityType.CLIENT, visible, page, size);
    }

    /**
     * The agency's changes, newest first, narrowed by whichever filters are given. {@code from}
     * and {@code to} are days, both included. An admin without {@code teamId} reads every agency.
     */
    public Page<RecordChangeResponse> feed(User actor, Long teamId, ChangeEntityType entityType,
                                           Long actorId, ChangeAction action,
                                           LocalDate from, LocalDate to, int page, int size) {
        if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager reads its change log");
        }
        if (from != null && to != null && to.isBefore(from)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "ENDS_BEFORE_START",
                    "The range ends before it starts");
        }
        Team team = teamOf(actor, teamId);
        Specification<RecordChange> spec = (root, query, cb) -> {
            List<Predicate> where = new ArrayList<>();
            if (team != null) {
                where.add(cb.equal(root.get("team").get("id"), team.getId()));
            }
            if (entityType != null) {
                where.add(cb.equal(root.get("entityType"), entityType));
            }
            if (actorId != null) {
                where.add(cb.equal(root.join("actor", JoinType.LEFT).get("id"), actorId));
            }
            if (action != null) {
                where.add(cb.equal(root.get("action"), action));
            }
            if (from != null) {
                where.add(cb.greaterThanOrEqualTo(root.get("changedAt"), from.atStartOfDay()));
            }
            if (to != null) {
                where.add(cb.lessThan(root.get("changedAt"), to.plusDays(1).atStartOfDay()));
            }
            return cb.and(where.toArray(new Predicate[0]));
        };
        return repository.findAll(spec, pageable(page, size)).map(ChangeHistoryService::toResponse);
    }

    private Page<RecordChangeResponse> history(ChangeEntityType type, Long id, int page, int size) {
        return repository.findByEntityTypeAndEntityId(type, id, pageable(page, size))
                .map(ChangeHistoryService::toResponse);
    }

    /** The manager's own agency; an admin names one, or reads them all. */
    private Team teamOf(User actor, Long teamId) {
        if (actor.getRole() == Role.ADMIN) {
            return teamId == null ? null : teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (actor.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "The change log belongs to an agency");
        }
        return actor.getTeam();
    }

    private static Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), MAX_PAGE_SIZE), NEWEST_FIRST);
    }

    static RecordChangeResponse toResponse(RecordChange c) {
        return RecordChangeResponse.builder()
                .id(c.getId())
                .entityType(c.getEntityType())
                .entityId(c.getEntityId())
                .entityLabel(c.getEntityLabel())
                .action(c.getAction())
                .field(c.getField())
                .oldValue(c.getOldValue())
                .newValue(c.getNewValue())
                .actorId(c.getActor() == null ? null : c.getActor().getId())
                .actorName(c.getActorName())
                .changedAt(c.getChangedAt())
                .build();
    }
}
