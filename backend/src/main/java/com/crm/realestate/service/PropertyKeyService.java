package com.crm.realestate.service;

import com.crm.realestate.dto.request.KeyHandoverRequest;
import com.crm.realestate.dto.response.KeyHandoverResponse;
import com.crm.realestate.dto.response.PropertyKeysResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyKeyHandover;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyKeyHandoverRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

/**
 * A listing's keys: who has them, until when, and which of the agency's keys are out.
 *
 * <p><b>Who sees and does what.</b> The keys are the listing's, so they sit behind the listing's
 * wall ({@link PropertyService#requireVisible}): whoever may see the listing — the whole agency,
 * whatever their data scope — sees who has its keys, hands them out and takes them back. Another
 * agency is told the listing does not exist. The list of keys out is the same wall over the whole
 * agency: every key out of a listing the caller may see.
 *
 * <p><b>The rules.</b> The keys go to a colleague or to somebody outside the agency by name,
 * exactly one of the two (KEY_HOLDER_REQUIRED). A colleague is an active member of the listing's
 * agency — the caller's own; anybody else reads as not found. The last day they are to be back is
 * not already past (KEY_DUE_IN_PAST). A listing's keys are out once at a time: handing them out
 * again before they are back is 409 KEY_ALREADY_OUT, and taking back keys that are in the office
 * is 409 KEY_NOT_OUT. The listing's row is locked for either, so two phones at once cannot both
 * hand the same keys out.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyKeyService {

    /** How many past handovers a listing shows. */
    static final int HISTORY_LIMIT = 50;

    private final PropertyKeyHandoverRepository handoverRepository;
    private final PropertyService propertyService;
    private final UserRepository userRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final AgencyCalendar calendar;
    private final EntityManager entityManager;

    // Reading -----------------------------------------------------------------------------

    /** Who has the listing's keys now, and the handovers that are over, the newest first. */
    public PropertyKeysResponse forProperty(Long propertyId) {
        User me = securityUtils.getCurrentUser();
        return keysOf(propertyService.requireVisible(propertyId, me));
    }

    /**
     * Every key out of a listing the caller may see: the overdue ones first, then by the day they
     * are due back, the ones without a day last; the longest out first among equals.
     */
    public List<KeyHandoverResponse> out() {
        User me = securityUtils.getCurrentUser();
        List<PropertyKeyHandover> open;
        if (scopeService.isAdmin(me)) {
            open = handoverRepository.findAllOpen();
        } else if (scopeService.teamIdOf(me) != null) {
            open = handoverRepository.findOpenInTeam(scopeService.teamIdOf(me));
        } else {
            open = List.of();
        }
        LocalDate today = calendar.today();
        return open.stream()
                .filter(h -> scopeService.canSeeInTeam(me, h.getTeam(), h.getProperty().getAgent()))
                .sorted(Comparator.comparing((PropertyKeyHandover h) -> !h.overdueOn(today))
                        .thenComparing(PropertyKeyHandover::getDueBackAt,
                                Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparing(PropertyKeyHandover::getHandedOutAt)
                        .thenComparing(PropertyKeyHandover::getId))
                .map(h -> toResponse(h, h.getProperty(), today))
                .toList();
    }

    // Writing -----------------------------------------------------------------------------

    @Transactional
    public PropertyKeysResponse handOut(Long propertyId, KeyHandoverRequest request) {
        User me = securityUtils.getCurrentUser();
        Property property = propertyService.requireVisible(propertyId, me);
        String name = strip(request.getHolderName());
        if ((request.getHolderUserId() == null) == (name == null)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "KEY_HOLDER_REQUIRED",
                    "Say who takes the keys: a colleague or somebody by name, not both");
        }
        if (request.getDueBackAt() != null && request.getDueBackAt().isBefore(calendar.today())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "KEY_DUE_IN_PAST",
                    "The keys cannot be due back on a day that has passed");
        }
        User holder = request.getHolderUserId() == null ? null
                : colleague(property.getTeam(), request.getHolderUserId());

        entityManager.lock(property, LockModeType.PESSIMISTIC_WRITE);
        if (handoverRepository.findOpen(property.getId()).isPresent()) {
            throw new BusinessException(HttpStatus.CONFLICT, "KEY_ALREADY_OUT",
                    "This listing's keys are already out; take them back first");
        }
        handoverRepository.save(PropertyKeyHandover.builder()
                .team(property.getTeam())
                .property(property)
                .holderUser(holder)
                .holderName(holder == null ? name : null)
                .note(strip(request.getNote()))
                .dueBackAt(request.getDueBackAt())
                .handedOutBy(me)
                .build());
        return keysOf(property);
    }

    @Transactional
    public PropertyKeysResponse giveBack(Long propertyId) {
        User me = securityUtils.getCurrentUser();
        Property property = propertyService.requireVisible(propertyId, me);
        entityManager.lock(property, LockModeType.PESSIMISTIC_WRITE);
        PropertyKeyHandover open = handoverRepository.findOpen(property.getId())
                .orElseThrow(() -> new BusinessException(HttpStatus.CONFLICT, "KEY_NOT_OUT",
                        "This listing's keys are in the office"));
        LocalDateTime now = LocalDateTime.now();
        open.setReturnedAt(now.isBefore(open.getHandedOutAt()) ? open.getHandedOutAt() : now);
        open.setReturnedBy(me);
        handoverRepository.save(open);
        return keysOf(property);
    }

    // Rules -------------------------------------------------------------------------------

    /** An active member of the listing's agency; anybody else, or any for a team-less listing, is not found. */
    private User colleague(Team team, Long userId) {
        return userRepository.findById(userId)
                .filter(u -> team != null && u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .filter(User::isActive)
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
    }

    // Answering ---------------------------------------------------------------------------

    private PropertyKeysResponse keysOf(Property property) {
        LocalDate today = calendar.today();
        KeyHandoverResponse current = handoverRepository.findOpen(property.getId())
                .map(h -> toResponse(h, property, today))
                .orElse(null);
        List<KeyHandoverResponse> history = handoverRepository
                .findReturned(property.getId(), PageRequest.of(0, HISTORY_LIMIT)).stream()
                .map(h -> toResponse(h, property, today))
                .toList();
        return PropertyKeysResponse.builder().current(current).history(history).build();
    }

    private static KeyHandoverResponse toResponse(PropertyKeyHandover h, Property property, LocalDate today) {
        User holder = h.getHolderUser();
        User gave = h.getHandedOutBy();
        User took = h.getReturnedBy();
        return KeyHandoverResponse.builder()
                .id(h.getId())
                .propertyId(property.getId())
                .propertyTitle(property.getTitle())
                .propertyAddress(property.getAddress())
                .propertyCity(property.getCity())
                .holderUserId(holder == null ? null : holder.getId())
                .holderName(holder == null ? h.getHolderName() : holder.getFullName())
                .note(h.getNote())
                .handedOutAt(h.getHandedOutAt())
                .dueBackAt(h.getDueBackAt())
                .returnedAt(h.getReturnedAt())
                .handedOutById(gave == null ? null : gave.getId())
                .handedOutByName(gave == null ? null : gave.getFullName())
                .returnedById(took == null ? null : took.getId())
                .returnedByName(took == null ? null : took.getFullName())
                .overdue(h.overdueOn(today))
                .build();
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
