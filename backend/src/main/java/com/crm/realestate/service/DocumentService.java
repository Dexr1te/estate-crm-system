package com.crm.realestate.service;

import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.dto.response.DocumentResponse;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * The documents attached to a deal: contracts, floor plans, scans of an ID.
 *
 * Access follows the deal, not the document — whoever can see a deal can see
 * and add its paperwork. Removal is narrower: the person who uploaded a file,
 * or an admin/manager, because a deletion here also destroys the bytes.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DocumentService {

    /**
     * What may be attached. A whitelist rather than a blacklist: the store is
     * served back to phones, and an allowed list is the only version of this
     * check that stays correct as new executable formats appear.
     */
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
            "pdf", "doc", "docx", "xls", "xlsx", "csv", "txt", "rtf", "odt", "ods",
            "png", "jpg", "jpeg", "heic", "webp", "gif", "zip");

    private static final Map<String, String> CONTENT_TYPES = Map.ofEntries(
            Map.entry("pdf", "application/pdf"),
            Map.entry("doc", "application/msword"),
            Map.entry("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
            Map.entry("xls", "application/vnd.ms-excel"),
            Map.entry("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
            Map.entry("csv", "text/csv"),
            Map.entry("txt", "text/plain"),
            Map.entry("rtf", "application/rtf"),
            Map.entry("odt", "application/vnd.oasis.opendocument.text"),
            Map.entry("ods", "application/vnd.oasis.opendocument.spreadsheet"),
            Map.entry("png", "image/png"),
            Map.entry("jpg", "image/jpeg"),
            Map.entry("jpeg", "image/jpeg"),
            Map.entry("heic", "image/heic"),
            Map.entry("webp", "image/webp"),
            Map.entry("gif", "image/gif"),
            Map.entry("zip", "application/zip"));

    private static final int MAX_NAME_LENGTH = 255;

    /** Where a deal's paperwork lives in the store. */
    static final String DEALS_FOLDER = "deals";

    private final DocumentRepository documentRepository;
    private final DealRepository dealRepository;
    private final DocumentStorage storage;
    private final SecurityUtils securityUtils;
    private final ScopeService scopeService;

    public List<DocumentResponse> getByDeal(Long dealId) {
        requireVisibleDeal(dealId);
        return documentRepository.findByDealId(dealId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public DocumentResponse upload(Long dealId, MultipartFile file) {
        Deal deal = requireVisibleDeal(dealId);

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("The uploaded file is empty");
        }

        String fileName = cleanName(file.getOriginalFilename());
        String extension = extensionOf(fileName);
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException(
                    "This file type cannot be attached: " + (extension.isEmpty() ? fileName : extension));
        }

        Document document = new Document();
        document.setDeal(deal);
        document.setUploadedBy(securityUtils.getCurrentUser());
        document.setFileName(fileName);
        document.setFileType(extension);
        document.setFileSize(file.getSize());
        document.setFilePath(storage.store(file, DEALS_FOLDER, dealId, extension));

        return toResponse(documentRepository.save(document));
    }

    public DocumentDownload download(Long dealId, Long documentId) {
        Document document = findInDeal(dealId, documentId);
        return new DocumentDownload(
                storage.load(document.getFilePath()),
                document.getFileName(),
                CONTENT_TYPES.getOrDefault(document.getFileType(), "application/octet-stream"));
    }

    @Transactional
    public void delete(Long dealId, Long documentId) {
        Document document = findInDeal(dealId, documentId);
        User currentUser = securityUtils.getCurrentUser();

        boolean isUploader = document.getUploadedBy() != null
                && document.getUploadedBy().getId().equals(currentUser.getId());
        if (!isUploader && !scopeService.isAdmin(currentUser) && !scopeService.isManager(currentUser)) {
            throw new IllegalArgumentException("Only the person who uploaded this file can remove it");
        }

        String path = document.getFilePath();
        documentRepository.delete(document);
        storage.delete(path);
    }

    /** The deal, if the signed-in person is allowed to know it exists. */
    private Deal requireVisibleDeal(Long dealId) {
        Deal deal = dealRepository.findById(dealId)
                .orElseThrow(() -> new ResourceNotFoundException("Deal not found with id: " + dealId));
        if (!scopeService.canSee(securityUtils.getCurrentUser(), deal.getTeam(), deal.getAgent())) {
            throw new ResourceNotFoundException("Deal not found");
        }
        return deal;
    }

    /**
     * A document, checked against the deal in the URL as well as its own id —
     * otherwise any id would be readable through a deal the caller can see.
     */
    private Document findInDeal(Long dealId, Long documentId) {
        requireVisibleDeal(dealId);
        Document document = documentRepository.findById(documentId)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found with id: " + documentId));
        if (!document.getDeal().getId().equals(dealId)) {
            throw new ResourceNotFoundException("Document not found with id: " + documentId);
        }
        return document;
    }

    /** Strips any directory part a client may have sent and keeps the column's limit. */
    private String cleanName(String originalName) {
        String name = originalName == null ? "" : originalName.trim();
        int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
        if (slash >= 0) {
            name = name.substring(slash + 1);
        }
        if (name.isEmpty()) {
            throw new IllegalArgumentException("The uploaded file has no name");
        }
        return name.length() > MAX_NAME_LENGTH ? name.substring(name.length() - MAX_NAME_LENGTH) : name;
    }

    private String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot == fileName.length() - 1) {
            return "";
        }
        return fileName.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private DocumentResponse toResponse(Document document) {
        DocumentResponse res = new DocumentResponse();
        res.setId(document.getId());
        res.setFileName(document.getFileName());
        res.setFileType(document.getFileType());
        res.setFileSize(document.getFileSize());
        res.setDealId(document.getDeal().getId());
        res.setUploadedById(document.getUploadedBy().getId());
        res.setUploadedByName(document.getUploadedBy().getFullName());
        res.setUploadedAt(document.getUploadedAt());
        return res;
    }
}
