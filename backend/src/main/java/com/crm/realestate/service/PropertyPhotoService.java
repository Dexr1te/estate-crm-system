package com.crm.realestate.service;

import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.dto.response.PropertyPhotoResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPhoto;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPhotoRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * The photographs of a listing.
 *
 * <p>Access follows the listing, which the whole agency can see — a photograph is not private the
 * way a client's phone number is. Adding and removing are held to the same visibility and nothing
 * narrower: an agent who can edit a listing can picture it.
 *
 * <p>The bytes go through {@link DocumentStorage}, so photographs land wherever paperwork does. On
 * a database store that is the wrong place for them, which is what the S3 store exists for.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PropertyPhotoService {

    /** Where a listing's photographs live in the store. */
    static final String PHOTOS_FOLDER = "properties";

    /**
     * What a camera or a photo library produces, and nothing else.
     *
     * <p>Narrower than the document whitelist on purpose: this is a gallery, and anything that is
     * not an image would be shown as a broken tile rather than refused.
     */
    private static final Map<String, String> IMAGE_TYPES = Map.of(
            "jpg", "image/jpeg",
            "jpeg", "image/jpeg",
            "png", "image/png",
            "heic", "image/heic",
            "heif", "image/heif",
            "webp", "image/webp");

    private static final int MAX_NAME_LENGTH = 255;

    private final PropertyPhotoRepository photoRepository;
    private final PropertyRepository      propertyRepository;
    private final DocumentStorage         storage;
    private final SecurityUtils           securityUtils;
    private final ScopeService            scopeService;

    public List<PropertyPhotoResponse> getByProperty(Long propertyId) {
        requireVisibleProperty(propertyId);
        return photoRepository.findByPropertyIdOrderBySortOrderAscIdAsc(propertyId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public PropertyPhotoResponse upload(Long propertyId, MultipartFile file) {
        Property property = requireVisibleProperty(propertyId);

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("The uploaded file is empty");
        }

        String fileName = cleanName(file.getOriginalFilename());
        String extension = extensionOf(fileName);
        String contentType = IMAGE_TYPES.get(extension);
        if (contentType == null) {
            throw new IllegalArgumentException(
                    "A listing takes photographs, not: " + (extension.isEmpty() ? fileName : extension));
        }

        PropertyPhoto photo = PropertyPhoto.builder()
                .property(property)
                .fileName(fileName)
                .contentType(contentType)
                .fileSize(file.getSize())
                // Appended to the gallery; the first one uploaded stays the cover.
                .sortOrder(photoRepository.countByPropertyId(propertyId))
                .uploadedBy(securityUtils.getCurrentUser())
                .storageKey(storage.store(file, PHOTOS_FOLDER, propertyId, extension))
                .build();

        return toResponse(photoRepository.save(photo));
    }

    public DocumentDownload download(Long propertyId, Long photoId) {
        PropertyPhoto photo = findOnProperty(propertyId, photoId);
        return new DocumentDownload(
                storage.load(photo.getStorageKey()), photo.getFileName(), photo.getContentType());
    }

    @Transactional
    public void delete(Long propertyId, Long photoId) {
        PropertyPhoto photo = findOnProperty(propertyId, photoId);
        String key = photo.getStorageKey();
        photoRepository.delete(photo);
        storage.delete(key);
    }

    /** Another agency's listing reads as missing, so its existence is not confirmed either. */
    private Property requireVisibleProperty(Long propertyId) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Property not found with id: " + propertyId));
        if (!scopeService.canSeeInTeam(currentUser, property.getTeam(), property.getAgent())) {
            throw new ResourceNotFoundException("Property not found with id: " + propertyId);
        }
        return property;
    }

    /**
     * A photograph, checked against the listing in the URL as well as its own id — otherwise any
     * id would be readable through a listing the caller can see.
     */
    private PropertyPhoto findOnProperty(Long propertyId, Long photoId) {
        requireVisibleProperty(propertyId);
        PropertyPhoto photo = photoRepository.findById(photoId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Photo not found with id: " + photoId));
        if (!photo.getProperty().getId().equals(propertyId)) {
            throw new ResourceNotFoundException("Photo not found with id: " + photoId);
        }
        return photo;
    }

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

    private PropertyPhotoResponse toResponse(PropertyPhoto photo) {
        PropertyPhotoResponse res = new PropertyPhotoResponse();
        res.setId(photo.getId());
        res.setPropertyId(photo.getProperty().getId());
        res.setFileName(photo.getFileName());
        res.setContentType(photo.getContentType());
        res.setFileSize(photo.getFileSize());
        res.setSortOrder(photo.getSortOrder());
        res.setUploadedAt(photo.getUploadedAt());
        if (photo.getUploadedBy() != null) {
            res.setUploadedById(photo.getUploadedBy().getId());
        }
        return res;
    }
}
