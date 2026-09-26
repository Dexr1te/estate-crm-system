package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * A listing's public link as the app shows it. {@code url} is null when the listing has no working
 * link, so "is there one?" is a single read rather than a 404 to interpret.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ShareLinkResponse {
    private String url;
    private long viewCount;
    private LocalDateTime lastViewedAt;
    private LocalDateTime createdAt;

    public static ShareLinkResponse none() {
        return new ShareLinkResponse(null, 0, null, null);
    }
}
