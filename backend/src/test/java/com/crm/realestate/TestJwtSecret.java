package com.crm.realestate;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

/**
 * Gives the test run a signing key, made up on the spot.
 *
 * <p>{@code JwtService} decodes the configured key as Base64, so the tests need a Base64 value —
 * and a Base64 blob committed under {@code jwt.secret} is indistinguishable from a real leaked key,
 * to a secret scanner and to a reader. So there is nothing to commit: the key is derived here, at
 * every test start, from a sentence that says what it is.
 *
 * <p>Registered for tests only, through {@code src/test/resources/META-INF/spring.factories}, and
 * added first so it wins over any {@code jwt.secret} the environment happens to carry.
 */
public class TestJwtSecret implements EnvironmentPostProcessor {

    private static final String NOT_A_SECRET =
            "estate-crm test signing key - in-memory database only, never a real deployment";

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        String key = Base64.getEncoder()
                .encodeToString(NOT_A_SECRET.getBytes(StandardCharsets.UTF_8));
        environment.getPropertySources()
                .addFirst(new MapPropertySource("test-jwt-secret", Map.of("jwt.secret", key)));
    }
}
