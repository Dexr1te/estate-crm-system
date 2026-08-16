package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Taking a user out of the system, whether an admin does it or the user does it to themselves.
 *
 * <p>Both paths have to move the same records out of the way first — deals, meetings and documents
 * cannot be orphaned by the schema — so the handover lives here rather than being written twice and
 * drifting.
 */
@Service
@RequiredArgsConstructor
public class AccountRemovalService {

    private final UserRepository     userRepository;
    private final ClientRepository   clientRepository;
    private final DealRepository     dealRepository;
    private final MeetingRepository  meetingRepository;
    private final DocumentRepository documentRepository;
    private final PropertyRepository propertyRepository;
    private final AuditLogService    auditLogService;

    @Value("${app.primary-admin-email:admin@gmail.com}")
    private String primaryAdminEmail;

    public boolean isPrimaryAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase(primaryAdminEmail);
    }

    /**
     * Deletes {@code target}, handing everything it owns to {@code replacementId}.
     *
     * @param action what to write in the audit trail — who asked matters after the row is gone.
     */
    @Transactional
    public void remove(User actor, User target, Long replacementId, String action) {
        if (isPrimaryAdmin(target)) {
            throw new RuntimeException("The primary admin account cannot be deleted");
        }

        final User replacement = replacementId == null ? null : findById(replacementId);
        if (replacement != null && replacement.getId().equals(target.getId())) {
            throw new RuntimeException("Pick a different user to take over the records");
        }

        Long targetId = target.getId();
        List<Deal> deals = dealRepository.findByAgentId(targetId);
        List<Meeting> meetings = meetingRepository.findByAgentId(targetId);
        List<Document> documents = documentRepository.findByUploadedById(targetId);
        List<Client> clients = clientRepository.findByAgentId(targetId);
        List<Property> properties = propertyRepository.findByAgentId(targetId);

        // These three cannot be orphaned by the schema, so without somewhere to put
        // them the delete would fail at the database with an opaque constraint error.
        if (replacement == null
                && !(deals.isEmpty() && meetings.isEmpty() && documents.isEmpty())) {
            throw new RuntimeException(String.format(
                    "%s still holds %d deal(s), %d meeting(s) and %d document(s). "
                            + "Choose someone to take them over.",
                    target.getFullName(), deals.size(), meetings.size(), documents.size()));
        }

        if (replacement != null) {
            deals.forEach(d -> d.setAgent(replacement));
            meetings.forEach(m -> m.setAgent(replacement));
            documents.forEach(d -> d.setUploadedBy(replacement));
            clients.forEach(c -> c.setAgent(replacement));
            properties.forEach(p -> p.setAgent(replacement));
            dealRepository.saveAll(deals);
            meetingRepository.saveAll(meetings);
            documentRepository.saveAll(documents);
            clientRepository.saveAll(clients);
            propertyRepository.saveAll(properties);
        }

        // When someone closes their own account the actor is the row about to go.
        // audit_logs.actor_id is ON DELETE SET NULL (V14), so the reference would
        // be cleared a moment later anyway — but leaning on that makes the write
        // depend on the database's cascade firing in the same transaction.
        // Recording no actor is both safer and lossless: DELETE_OWN_ACCOUNT plus
        // the entity id and the email below already say exactly who left.
        User auditActor = targetId.equals(actor.getId()) ? null : actor;
        auditLogService.record(auditActor, action, "User", targetId,
                "email=" + target.getEmail()
                        + (replacement == null ? "" : ", movedTo=" + replacement.getEmail()));

        userRepository.delete(target);
    }

    /**
     * Deletes the caller's own account.
     *
     * <p>Apple requires an app that holds an account to let the person holding it leave from inside
     * the app (App Store Review Guideline 5.1.1(v)). Two people cannot: the primary admin, whose
     * account is what the deployment is anchored to, and the last active admin, who would lock
     * everyone else out on the way out. Both are told to contact support instead.
     */
    @Transactional
    public void removeOwnAccount(User user, Long replacementId) {
        if (isPrimaryAdmin(user)) {
            throw new AccessDeniedException(
                    "The primary admin account cannot be deleted from the app. "
                            + "Contact support to close the workspace.");
        }
        if (user.getRole() == Role.ADMIN && isLastActiveAdmin()) {
            throw new AccessDeniedException(
                    "You are the last active admin. Promote another admin first, "
                            + "or contact support.");
        }
        remove(user, user, replacementId, "DELETE_OWN_ACCOUNT");
    }

    private boolean isLastActiveAdmin() {
        return userRepository.countByRoleAndStatusAndIsActiveTrue(Role.ADMIN, UserStatus.ACTIVE) <= 1;
    }

    private User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }
}
