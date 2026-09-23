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

import java.io.IOException;
import java.io.InputStream;

import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
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

    /** And their smaller copies, kept apart so a bucket stays readable by hand. */
    static final String THUMBNAILS_FOLDER = "properties/thumbs";

    /**
     * What the app can actually draw, keyed by what the bytes say they are.
     *
     * <p>Not the wider list a browser would take: Flutter decodes JPEG, PNG, GIF, WebP and BMP,
     * and an iPhone's HEIC is not among them. Storing one would mean a photograph that uploads
     * cleanly and then shows as an empty tile, which is a worse answer than refusing it.
     */
    private static final Map<String, String> EXTENSIONS = Map.of(
            "image/jpeg", "jpg",
            "image/png", "png",
            "image/gif", "gif",
            "image/bmp", "bmp",
            "image/webp", "webp");

    private static final int MAX_NAME_LENGTH = 255;

    private final PropertyPhotoRepository photoRepository;
    private final PropertyRepository      propertyRepository;
    private final DocumentStorage         storage;
    private final ImageNormalizer         normalizer;
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
        String contentType = normalizer.contentTypeOf(head(file))
                .filter(EXTENSIONS::containsKey)
                .orElseThrow(() -> new IllegalArgumentException(
                        "This is not an image the app can show: " + fileName));
        String extension = EXTENSIONS.get(contentType);

        PropertyPhoto photo = PropertyPhoto.builder()
                .property(property)
                .fileName(fileName)
                .contentType(contentType)
                .fileSize(file.getSize())
                // Appended to the gallery; the first one uploaded stays the cover.
                .sortOrder(photoRepository.countByPropertyId(propertyId))
                .uploadedBy(securityUtils.getCurrentUser())
                .storageKey(storage.store(file, PHOTOS_FOLDER, propertyId, extension))
                .thumbnailKey(normalizer.thumbnail(file)
                        .map(bytes -> storage.storeBytes(
                                bytes, "image/jpeg", THUMBNAILS_FOLDER, propertyId, "jpg"))
                        .orElse(null))
                .build();

        return toResponse(photoRepository.save(photo));
    }

    /**
     * Puts the gallery in the given order, first one first — which also decides the cover.
     *
     * <p>The request has to name every photograph the listing has, exactly once. A partial list
     * would leave the rest at positions that mean nothing, and an unknown id means the client is
     * working from a gallery somebody else has already changed; both are better refused than
     * half-applied.
     */
    @Transactional
    public List<PropertyPhotoResponse> reorder(Long propertyId, List<Long> photoIds) {
        requireVisibleProperty(propertyId);
        List<PropertyPhoto> photos =
                photoRepository.findByPropertyIdOrderBySortOrderAscIdAsc(propertyId);

        Set<Long> held = photos.stream().map(PropertyPhoto::getId).collect(Collectors.toSet());
        Set<Long> asked = new LinkedHashSet<>(photoIds);
        if (asked.size() != photoIds.size() || !asked.equals(held)) {
            throw new IllegalArgumentException(
                    "The order must name each photo of this listing exactly once");
        }

        Map<Long, PropertyPhoto> byId = photos.stream()
                .collect(Collectors.toMap(PropertyPhoto::getId, photo -> photo));
        for (int position = 0; position < photoIds.size(); position++) {
            byId.get(photoIds.get(position)).setSortOrder(position);
        }
        return photoRepository.saveAll(photos).stream()
                .sorted(Comparator.comparingInt(PropertyPhoto::getSortOrder))
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public DocumentDownload download(Long propertyId, Long photoId) {
        PropertyPhoto photo = findOnProperty(propertyId, photoId);
        return new DocumentDownload(
                storage.load(photo.getStorageKey()), photo.getFileName(), photo.getContentType());
    }

    /**
     * The small copy of the first photograph, for a row in a list.
     *
     * <p>Falls back to the full-size image when there is no thumbnail — a WebP cannot be decoded
     * here, and a listing whose cover is slow to load is better than one that shows nothing.
     */
    public DocumentDownload cover(Long propertyId) {
        requireVisibleProperty(propertyId);
        PropertyPhoto first = photoRepository
                .findByPropertyIdOrderBySortOrderAscIdAsc(propertyId).stream()
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "No photos on property " + propertyId));

        if (first.getThumbnailKey() == null) {
            return new DocumentDownload(storage.load(first.getStorageKey()),
                    first.getFileName(), first.getContentType());
        }
        return new DocumentDownload(
                storage.load(first.getThumbnailKey()), first.getFileName(), "image/jpeg");
    }

    @Transactional
    public void delete(Long propertyId, Long photoId) {
        PropertyPhoto photo = findOnProperty(propertyId, photoId);
        String key = photo.getStorageKey();
        String thumbnail = photo.getThumbnailKey();
        photoRepository.delete(photo);
        storage.delete(key);
        if (thumbnail != null) {
            storage.delete(thumbnail);
        }
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

    /** Enough of the file to tell what it is; every marker sits in the first bytes. */
    private byte[] head(MultipartFile file) {
        try (InputStream in = file.getInputStream()) {
            return in.readNBytes(16);
        } catch (IOException e) {
            throw new IllegalArgumentException("The uploaded file could not be read");
        }
    }

    private PropertyPhotoResponse toResponse(PropertyPhoto photo) {
        PropertyPhotoResponse res = new PropertyPhotoResponse();
        res.setId(photo.getId());
        res.setPropertyId(photo.getProperty().getId());
        res.setFileName(photo.getFileName());
        res.setContentType(photo.getContentType());
        res.setFileSize(photo.getFileSize());
        res.setSortOrder(photo.getSortOrder());
        res.setHasThumbnail(photo.getThumbnailKey() != null);
        res.setUploadedAt(photo.getUploadedAt());
        if (photo.getUploadedBy() != null) {
            res.setUploadedById(photo.getUploadedBy().getId());
        }
        return res;
    }
}
