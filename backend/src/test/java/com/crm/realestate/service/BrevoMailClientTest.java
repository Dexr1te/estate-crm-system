package com.crm.realestate.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class BrevoMailClientTest {

    private HttpServer server;
    private final AtomicReference<String> path = new AtomicReference<>();
    private final AtomicReference<String> apiKey = new AtomicReference<>();
    private final AtomicReference<String> body = new AtomicReference<>();
    private volatile int status = 201;

    @BeforeEach
    void start() throws IOException {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/", exchange -> {
            path.set(exchange.getRequestMethod() + " " + exchange.getRequestURI().getPath());
            apiKey.set(exchange.getRequestHeaders().getFirst("api-key"));
            body.set(new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8));
            byte[] answer = "{\"messageId\":\"<1@smtp-relay.mailin.fr>\"}".getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().add("Content-Type", "application/json");
            exchange.sendResponseHeaders(status, answer.length);
            exchange.getResponseBody().write(answer);
            exchange.close();
        });
        server.start();
    }

    @AfterEach
    void stop() {
        server.stop(0);
    }

    private BrevoMailClient client(String key) {
        return new BrevoMailClient(RestClient.builder(), key,
                "http://127.0.0.1:" + server.getAddress().getPort());
    }

    @Test
    @DisplayName("a message goes to the transactional endpoint with the key and both parts")
    void sendsTheMessage() throws IOException {
        client("xkeysib-test").send("owner@gmail.com", "Estate CRM", "irina@example.kz",
                "Your Estate CRM code: 123456", "plain 123456", "<b>123456</b>");

        assertThat(path.get()).isEqualTo("POST /v3/smtp/email");
        assertThat(apiKey.get()).isEqualTo("xkeysib-test");
        JsonNode json = new ObjectMapper().readTree(body.get());
        assertThat(json.at("/sender/email").asText()).isEqualTo("owner@gmail.com");
        assertThat(json.at("/sender/name").asText()).isEqualTo("Estate CRM");
        assertThat(json.at("/to/0/email").asText()).isEqualTo("irina@example.kz");
        assertThat(json.at("/subject").asText()).isEqualTo("Your Estate CRM code: 123456");
        assertThat(json.at("/textContent").asText()).isEqualTo("plain 123456");
        assertThat(json.at("/htmlContent").asText()).isEqualTo("<b>123456</b>");
    }

    @Test
    @DisplayName("a refusal from Brevo is an exception, so the caller can say nothing was sent")
    void refusalThrows() {
        status = 401;
        assertThatThrownBy(() -> client("revoked").send("owner@gmail.com", "Estate CRM",
                "irina@example.kz", "s", "p", "h"))
                .isInstanceOf(RestClientException.class);
    }

    @Test
    @DisplayName("without a key nothing is attempted")
    void noKeyNoRequest() {
        BrevoMailClient client = client("");
        assertThat(client.isConfigured()).isFalse();
        assertThatThrownBy(() -> client.send("a@b.c", "n", "d@e.f", "s", "p", "h"))
                .isInstanceOf(IllegalStateException.class);
        assertThat(path.get()).isNull();
    }
}
