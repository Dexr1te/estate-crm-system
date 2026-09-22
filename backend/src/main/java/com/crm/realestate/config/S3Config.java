package com.crm.realestate.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;

import java.net.URI;

/**
 * The client for whichever S3-compatible store this deployment uses.
 *
 * <p>Built only when {@code app.documents.storage=s3}, because the settings below have no sensible
 * defaults and a deployment on another store must not fail to start over credentials it does not
 * need.
 *
 * <p>Path-style addressing by default. Virtual-host style puts the bucket in the hostname, which
 * AWS serves and most of the alternatives — MinIO, and anything behind a plain domain — do not.
 */
@Configuration
@ConditionalOnProperty(name = "app.documents.storage", havingValue = "s3")
public class S3Config {

    @Value("${app.s3.endpoint:}")
    private String endpoint;

    @Value("${app.s3.region:auto}")
    private String region;

    @Value("${app.s3.access-key:}")
    private String accessKey;

    @Value("${app.s3.secret-key:}")
    private String secretKey;

    @Value("${app.s3.path-style:true}")
    private boolean pathStyle;

    @Bean
    public S3Client s3Client() {
        if (accessKey.isBlank() || secretKey.isBlank()) {
            throw new IllegalStateException(
                    "app.documents.storage=s3 but S3_ACCESS_KEY / S3_SECRET_KEY are empty");
        }

        var builder = S3Client.builder()
                .region(Region.of(region))
                .httpClient(UrlConnectionHttpClient.create())
                .serviceConfiguration(S3Configuration.builder()
                        .pathStyleAccessEnabled(pathStyle)
                        .build())
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)));

        // Empty for AWS itself, which the SDK resolves from the region.
        if (!endpoint.isBlank()) {
            builder = builder.endpointOverride(URI.create(endpoint));
        }
        return builder.build();
    }
}
