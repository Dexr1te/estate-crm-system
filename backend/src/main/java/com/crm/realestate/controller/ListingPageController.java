package com.crm.realestate.controller;

import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.service.ListingShareService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Locale;
import java.util.Optional;

/**
 * The page a listing's public link opens, and the photographs on it.
 *
 * <p>Reachable without an account — {@code /l/**} is in {@code SecurityConfig.PUBLIC_URLS} — and
 * answerable by token only. Anything wrong with the token, including a revoked link, gets the same
 * friendly 404, so the page never confirms that a listing exists.
 */
@RestController
@RequestMapping("/l")
@RequiredArgsConstructor
public class ListingPageController {

    /** Scripts, frames, forms and foreign images are all refused; the page has none of them. */
    private static final String CSP = "default-src 'none'; img-src 'self'; "
            + "style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; "
            + "frame-ancestors 'none'";

    private final ListingShareService shareService;
    private final ListingPageRenderer renderer;

    @GetMapping(value = "/{token}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> page(@PathVariable String token,
            @RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, required = false) String language) {
        Locale locale = renderer.pickLocale(language);
        return shareService.open(token)
                .map(listing -> html(HttpStatus.OK).body(renderer.listing(listing, locale)))
                .orElseGet(() -> html(HttpStatus.NOT_FOUND).body(renderer.notFound(locale)));
    }

    @GetMapping("/{token}/photos/{photoId}")
    public ResponseEntity<?> photo(@PathVariable String token, @PathVariable String photoId,
            @RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, required = false) String language) {
        Optional<DocumentDownload> photo = parseId(photoId)
                .flatMap(id -> shareService.photo(token, id));
        if (photo.isEmpty()) {
            return html(HttpStatus.NOT_FOUND).body(renderer.notFound(renderer.pickLocale(language)));
        }
        Resource bytes = photo.get().resource();
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(photo.get().contentType()))
                // A photo's bytes never change under its id; an hour keeps a revoke meaningful.
                .cacheControl(CacheControl.maxAge(Duration.ofHours(1)).cachePrivate())
                .header("X-Robots-Tag", "noindex, nofollow")
                .header("Referrer-Policy", "no-referrer")
                .header("X-Content-Type-Options", "nosniff")
                .body(bytes);
    }

    private ResponseEntity.BodyBuilder html(HttpStatus status) {
        return ResponseEntity.status(status)
                .header(HttpHeaders.CONTENT_TYPE,
                        MediaType.TEXT_HTML_VALUE + ";charset=" + StandardCharsets.UTF_8.name())
                // Every open is counted and a revoke must take effect at once.
                .header(HttpHeaders.CACHE_CONTROL, "no-store")
                .header(HttpHeaders.VARY, HttpHeaders.ACCEPT_LANGUAGE)
                .header("X-Robots-Tag", "noindex, nofollow")
                .header("Referrer-Policy", "no-referrer")
                .header("X-Content-Type-Options", "nosniff")
                .header("Content-Security-Policy", CSP);
    }

    /** A photo id that is not a number is a missing photo, not a 400 that tells a guesser more. */
    private static Optional<Long> parseId(String raw) {
        try {
            return Optional.of(Long.parseLong(raw));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }
}
