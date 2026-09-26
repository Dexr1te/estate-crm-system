package com.crm.realestate.service;

import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.dto.response.ShareLinkResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPhoto;
import com.crm.realestate.entity.PropertyShareLink;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPhotoRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * Public links to listings.
 *
 * <p>Making and reading a link follows the listing's own visibility: whoever can see a listing can
 * send it. Revoking is narrower — the listing's agent, a manager or an admin — because it breaks a
 * link somebody else may already have sent to a client.
 *
 * <p>The public side answers by token only. An unknown token and a revoked one read the same, so a
 * guess learns nothing about which listings exist.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ListingShareService {

    /** 24 random bytes: 192 bits, 32 base64url characters. */
    private static final int TOKEN_BYTES = 24;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final PropertyShareLinkRepository linkRepository;
    private final PropertyRepository propertyRepository;
    private final PropertyPhotoRepository photoRepository;
    private final DocumentStorage storage;
    private final SecurityUtils securityUtils;
    private final ScopeService scopeService;

    @Value("${app.listing-url:}")
    private String listingUrl;

    /** What an unset — or set but empty, as in .env.example — listing-url falls back to. */
    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    public ShareLinkResponse get(Long propertyId) {
        requireVisibleProperty(propertyId);
        return linkRepository.findFirstByPropertyIdAndRevokedAtIsNull(propertyId)
                .map(this::toResponse)
                .orElseGet(ShareLinkResponse::none);
    }

    /** The listing's working link, made now if it has none. Asking twice gives the same link. */
    @Transactional
    public ShareLinkResponse create(Long propertyId) {
        Property property = requireVisibleProperty(propertyId);
        PropertyShareLink link = linkRepository.findFirstByPropertyIdAndRevokedAtIsNull(propertyId)
                .orElseGet(() -> linkRepository.save(PropertyShareLink.builder()
                        .token(newToken())
                        .property(property)
                        .createdBy(securityUtils.getCurrentUser())
                        .build()));
        return toResponse(link);
    }

    /** Switches the link off for good. A new one can be made; this token never works again. */
    @Transactional
    public void revoke(Long propertyId) {
        Property property = requireVisibleProperty(propertyId);
        User current = securityUtils.getCurrentUser();
        boolean ownsListing = property.getAgent() != null
                && Objects.equals(property.getAgent().getId(), current.getId());
        if (!ownsListing && !scopeService.isManager(current) && !scopeService.isAdmin(current)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "SHARE_LINK_FORBIDDEN",
                    "Only the listing's agent or a manager can switch its link off");
        }
        linkRepository.findFirstByPropertyIdAndRevokedAtIsNull(propertyId).ifPresent(link -> {
            link.setRevokedAt(LocalDateTime.now());
            linkRepository.save(link);
        });
    }

    /** What the public page shows, and one more view on the link. Empty for any bad token. */
    @Transactional
    public Optional<PublicListing> open(String token) {
        return findLink(token).map(link -> {
            // Read everything first: the counting query clears the persistence context.
            PublicListing listing = toPublic(link.getToken(), link.getProperty());
            linkRepository.recordView(link.getId(), LocalDateTime.now());
            return listing;
        });
    }

    /** One photograph of the linked listing, and only of that listing. */
    public Optional<DocumentDownload> photo(String token, Long photoId) {
        return findLink(token).flatMap(link -> photoRepository.findById(photoId)
                .filter(photo -> photo.getProperty().getId().equals(link.getProperty().getId()))
                .map(photo -> new DocumentDownload(storage.load(photo.getStorageKey()),
                        photo.getFileName(), photo.getContentType())));
    }

    /** The absolute address of a link, for the app and for the page's own preview tags. */
    public String urlOf(String token) {
        String prefix = listingUrl == null || listingUrl.isBlank()
                ? trimSlash(baseUrl) + "/api/l"
                : trimSlash(listingUrl.trim());
        return prefix + "/" + token;
    }

    private Optional<PropertyShareLink> findLink(String token) {
        if (token == null || token.isBlank() || token.length() > 64) {
            return Optional.empty();
        }
        return linkRepository.findByTokenAndRevokedAtIsNull(token);
    }

    private PublicListing toPublic(String token, Property p) {
        List<Long> photoIds = photoRepository.findByPropertyIdOrderBySortOrderAscIdAsc(p.getId())
                .stream().map(PropertyPhoto::getId).toList();
        User agent = p.getAgent();
        String agency = p.getTeam() != null ? p.getTeam().getName() : null;
        return new PublicListing(urlOf(token), p.getTitle(), p.getDescription(), p.getAddress(),
                p.getCity(), p.getType(), p.getStatus(), p.getPrice(), p.getAreaSqm(),
                p.getRooms(), p.getFloor(), p.getTotalFloors(), photoIds,
                agent != null ? agent.getFullName() : null,
                agent != null ? blankToNull(agent.getPhone()) : null,
                agency);
    }

    private ShareLinkResponse toResponse(PropertyShareLink link) {
        return new ShareLinkResponse(urlOf(link.getToken()), link.getViewCount(),
                link.getLastViewedAt(), link.getCreatedAt());
    }

    /** Another agency's listing reads as missing, as everywhere else. */
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

    static String newToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String trimSlash(String url) {
        return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    /** Everything the public page may show — and, by leaving them out, nothing it may not. */
    public record PublicListing(
            String url, String title, String description, String address, String city,
            PropertyType type, PropertyStatus status, BigDecimal price, Double areaSqm,
            Integer rooms, Integer floor, Integer totalFloors, List<Long> photoIds,
            String agentName, String agentPhone, String agencyName) {
    }
}
