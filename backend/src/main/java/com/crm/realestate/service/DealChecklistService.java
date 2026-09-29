package com.crm.realestate.service;

import com.crm.realestate.dto.request.DealChecklistItemRequest;
import com.crm.realestate.dto.request.DealChecklistPatchRequest;
import com.crm.realestate.dto.response.ChecklistItemResponse;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealChecklistItem;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.DealChecklistItemRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

/**
 * What a deal still needs, stage by stage.
 *
 * <p>The checklist sits behind exactly the deal's walls: whoever may open the deal may read it and
 * tick lines off, and another agency's deal answers not found. Adding a line of its own to the
 * deal, or taking one away, is for the deal's agent or someone who runs the agency; lines copied
 * from the agency's template stay — un-ticking is how one says it does not apply yet.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class DealChecklistService {

    static final Comparator<DealChecklistItem> ORDER = Comparator
            .comparing(DealChecklistItem::getStage)
            .thenComparing(DealChecklistItem::getPosition)
            .thenComparing(DealChecklistItem::getId);

    private final DealChecklistItemRepository itemRepository;
    private final DocumentRepository documentRepository;
    private final DealChecklistStore checklistStore;
    private final DealService dealService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    public List<ChecklistItemResponse> list(Long dealId) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        checklistStore.ensureCopied(deal, user);
        return itemRepository.findForDeal(deal.getId()).stream()
                .sorted(ORDER)
                .map(DealChecklistService::toResponse)
                .toList();
    }

    public ChecklistItemResponse add(Long dealId, DealChecklistItemRequest request) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        requireEditor(deal, user);
        String title = request.getTitle() == null ? "" : request.getTitle().strip();
        if (title.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "CHECKLIST_TITLE_REQUIRED",
                    "A checklist item needs a title");
        }
        checklistStore.ensureCopied(deal, user);
        return toResponse(itemRepository.save(DealChecklistItem.builder()
                .deal(deal)
                .team(deal.getTeam())
                .stage(request.getStage())
                .title(title)
                .position(itemRepository.lastPosition(deal.getId(), request.getStage()) + 1)
                .required(request.isRequired())
                .custom(true)
                .build()));
    }

    /** Ticks or un-ticks a line, and links or unlinks one of this deal's documents. */
    public ChecklistItemResponse update(Long dealId, Long itemId, DealChecklistPatchRequest request) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        DealChecklistItem item = requireOnDeal(deal, itemId);
        if (Boolean.TRUE.equals(request.getDone()) && item.getDoneAt() == null) {
            item.setDoneAt(LocalDateTime.now());
            item.setDoneBy(user);
        } else if (Boolean.FALSE.equals(request.getDone())) {
            item.setDoneAt(null);
            item.setDoneBy(null);
        }
        if (Boolean.TRUE.equals(request.getDetachDocument())) {
            item.setDocument(null);
        } else if (request.getDocumentId() != null) {
            item.setDocument(requireDocumentOf(deal, request.getDocumentId()));
        }
        return toResponse(itemRepository.save(item));
    }

    /** Takes away a line added on this deal; lines from the template cannot be. */
    public void delete(Long dealId, Long itemId) {
        User user = securityUtils.getCurrentUser();
        Deal deal = dealService.requireVisible(dealId, user);
        DealChecklistItem item = requireOnDeal(deal, itemId);
        requireEditor(deal, user);
        if (!item.isCustom()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "CHECKLIST_ITEM_FROM_TEMPLATE",
                    "Only items added on this deal can be deleted");
        }
        itemRepository.delete(item);
    }

    private void requireEditor(Deal deal, User user) {
        boolean ownDeal = deal.getAgent() != null && deal.getAgent().getId().equals(user.getId());
        if (!ownDeal && !scopeService.isManager(user) && !scopeService.isAdmin(user)) {
            throw new AccessDeniedException("Only the deal's agent or a manager can change its checklist");
        }
    }

    private DealChecklistItem requireOnDeal(Deal deal, Long itemId) {
        return itemRepository.findById(itemId)
                .filter(i -> i.getDeal().getId().equals(deal.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Checklist item not found with id: " + itemId));
    }

    /** A document of another deal reads as missing, so its existence is not confirmed either. */
    private Document requireDocumentOf(Deal deal, Long documentId) {
        return documentRepository.findById(documentId)
                .filter(d -> d.getDeal().getId().equals(deal.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Document not found with id: " + documentId));
    }

    static ChecklistItemResponse toResponse(DealChecklistItem item) {
        return ChecklistItemResponse.builder()
                .id(item.getId())
                .stage(item.getStage())
                .title(item.getTitle())
                .position(item.getPosition())
                .required(item.isRequired())
                .custom(item.isCustom())
                .done(item.getDoneAt() != null)
                .doneAt(item.getDoneAt())
                .doneById(item.getDoneBy() == null ? null : item.getDoneBy().getId())
                .doneByName(item.getDoneBy() == null ? null : item.getDoneBy().getFullName())
                .documentId(item.getDocument() == null ? null : item.getDocument().getId())
                .documentName(item.getDocument() == null ? null : item.getDocument().getFileName())
                .build();
    }
}
