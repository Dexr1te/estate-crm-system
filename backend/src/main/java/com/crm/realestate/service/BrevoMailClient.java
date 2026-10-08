package com.crm.realestate.service;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Sends one email through Brevo's transactional API.
 *
 * <p>It goes over HTTPS rather than SMTP because some hosts block outbound SMTP outright — Render's
 * free plan drops ports 25, 465 and 587 — while a normal web request still gets through. The
 * sender address has to be one Brevo has verified for the account.
 */
@Component
public class BrevoMailClient {

    private static final Duration CONNECT_TIMEOUT = Duration.ofSeconds(5);
    private static final Duration READ_TIMEOUT = Duration.ofSeconds(10);

    private final RestClient http;
    private final String apiKey;

    public BrevoMailClient(RestClient.Builder builder,
                           @Value("${app.mail.brevo.api-key:}") String apiKey,
                           @Value("${app.mail.brevo.base-url:https://api.brevo.com}") String baseUrl) {
        JdkClientHttpRequestFactory requests = new JdkClientHttpRequestFactory(
                HttpClient.newBuilder().connectTimeout(CONNECT_TIMEOUT).build());
        requests.setReadTimeout(READ_TIMEOUT);
        this.http = builder.baseUrl(baseUrl).requestFactory(requests).build();
        this.apiKey = apiKey;
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    /** Throws when Brevo does not accept the message, so the caller can say it was not sent. */
    public void send(String fromEmail, String fromName, String toEmail,
                     String subject, String plain, String html) {
        if (!isConfigured()) {
            throw new IllegalStateException("BREVO_API_KEY is not set");
        }
        http.post()
                .uri("/v3/smtp/email")
                .header("api-key", apiKey)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .body(Map.of(
                        "sender", Map.of("email", fromEmail, "name", fromName),
                        "to", List.of(Map.of("email", toEmail)),
                        "subject", subject,
                        "textContent", plain,
                        "htmlContent", html))
                .retrieve()
                .toBodilessEntity();
    }
}
