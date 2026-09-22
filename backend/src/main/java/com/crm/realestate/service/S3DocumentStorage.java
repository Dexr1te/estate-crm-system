package com.crm.realestate.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.io.IOException;

/**
 * The store for a deployment that has somewhere proper to put bytes.
 *
 * <p>The database store this replaces keeps attachments beside the rows, which survives a restart
 * but spends the database's own size limit on files nobody queries — fine for contracts, wrong for
 * anything larger or more numerous. Here the database keeps the key and the object store keeps the
 * bytes.
 *
 * <p>The key is the one the row already records, so moving between stores stays a config change:
 * uploads made under another store are read from whichever store is configured now, and a key it
 * has never seen reads as missing rather than as an error.
 */
@Component
@ConditionalOnProperty(name = "app.documents.storage", havingValue = "s3")
@Slf4j
public class S3DocumentStorage implements DocumentStorage {

    private final S3Client s3;
    private final String bucket;

    public S3DocumentStorage(S3Client s3, @Value("${app.s3.bucket:}") String bucket) {
        if (bucket.isBlank()) {
            throw new IllegalStateException(
                    "app.documents.storage=s3 but S3_BUCKET is empty");
        }
        this.s3 = s3;
        this.bucket = bucket;
    }

    @Override
    public String store(MultipartFile file, Long ownerId, String extension) {
        String key = DocumentStorage.newKey(ownerId, extension);
        try {
            s3.putObject(
                    PutObjectRequest.builder()
                            .bucket(bucket)
                            .key(key)
                            .contentType(file.getContentType())
                            .contentLength(file.getSize())
                            .build(),
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
        } catch (IOException | S3Exception e) {
            throw new IllegalStateException("Could not store the uploaded file", e);
        }
        return key;
    }

    @Override
    public Resource load(String key) {
        try {
            return new ByteArrayResource(
                    s3.getObjectAsBytes(
                            GetObjectRequest.builder().bucket(bucket).key(key).build())
                            .asByteArray());
        } catch (NoSuchKeyException e) {
            throw new IllegalStateException("File is missing from storage: " + key, e);
        } catch (S3Exception e) {
            throw new IllegalStateException("Could not read the stored file", e);
        }
    }

    @Override
    public void delete(String key) {
        try {
            s3.deleteObject(DeleteObjectRequest.builder().bucket(bucket).key(key).build());
        } catch (NoSuchKeyException e) {
            log.info("Nothing to delete at {}; the row is what the app shows", key);
        } catch (S3Exception e) {
            throw new IllegalStateException("Could not delete the stored file", e);
        }
    }
}
