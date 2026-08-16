package com.crm.realestate.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The association file iOS fetches to decide whether this host may open the app.
 *
 * <p>With it published and {@code applinks:<host>} in the app's entitlements, an invite link opens
 * the app directly instead of the landing page — which matters because a custom scheme
 * ({@code estatecrm://}) is quietly ignored by several mail clients, and an invite is the only way
 * into this app.
 *
 * <p>Apple requires it over HTTPS at {@code /.well-known/apple-app-site-association}, with a JSON
 * content type and <em>no</em> {@code .json} extension. It is fetched by Apple's CDN, not by the
 * device, so it must be reachable without a token — see {@code SecurityConfig}.
 */
@RestController
public class WellKnownController {

    /** Team ID from the Apple developer account, followed by the app's bundle identifier. */
    @Value("${app.ios-app-id:9746P6DV47.com.sultan.estatecrm}")
    private String iosAppId;

    @GetMapping(value = "/.well-known/apple-app-site-association",
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> appleAppSiteAssociation() {
        String body = """
                {
                  "applinks": {
                    "details": [
                      {
                        "appIDs": ["%s"],
                        "components": [
                          { "/": "/invite", "comment": "invite links open the app" },
                          { "/": "/invite/*", "comment": "invite links open the app" }
                        ]
                      }
                    ]
                  }
                }
                """.formatted(iosAppId);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                // Apple's CDN caches this; a short life keeps a bundle-id fix from taking a day.
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=3600")
                .body(body);
    }
}
