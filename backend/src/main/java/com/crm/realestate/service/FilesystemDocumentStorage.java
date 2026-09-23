package com.crm.realestate.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * The store for a deployment with a real volume behind it.
 *
 * <p>The filesystem, under a single configurable root, with the key recorded on
 * the document row used as a path relative to that root — so a bigger disk or a
 * different mount is a config change and not a data migration.
 *
 * <p>Only correct where that root outlives the process. On a host that rebuilds
 * the container on deploy this loses every file it was given, which is why
 * {@link DatabaseDocumentStorage} is the default.
 */
@Component
@ConditionalOnProperty(name = "app.documents.storage", havingValue = "filesystem")
public class FilesystemDocumentStorage implements DocumentStorage {

    private final Path root;

    public FilesystemDocumentStorage(@Value("${app.documents.dir:uploads/documents}") String dir) {
        this.root = Paths.get(dir).toAbsolutePath().normalize();
    }

    @Override
    public String store(MultipartFile file, String folder, Long ownerId, String extension) {
        String key = DocumentStorage.newKey(folder, ownerId, extension);
        Path target = resolve(key);
        try {
            Files.createDirectories(target.getParent());
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Could not store the uploaded file", e);
        }
        return key;
    }

    @Override
    public String storeBytes(byte[] bytes, String contentType, String folder, Long ownerId,
            String extension) {
        String key = DocumentStorage.newKey(folder, ownerId, extension);
        Path target = resolve(key);
        try {
            Files.createDirectories(target.getParent());
            Files.write(target, bytes);
        } catch (IOException e) {
            throw new IllegalStateException("Could not store the generated file", e);
        }
        return key;
    }

    @Override
    public Resource load(String key) {
        Path file = resolve(key);
        try {
            Resource resource = new UrlResource(file.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                throw new IllegalStateException("File is missing from storage: " + key);
            }
            return resource;
        } catch (IOException e) {
            throw new IllegalStateException("Could not read the stored file", e);
        }
    }

    @Override
    public void delete(String key) {
        try {
            Files.deleteIfExists(resolve(key));
        } catch (IOException e) {
            throw new IllegalStateException("Could not delete the stored file", e);
        }
    }

    /** Resolves a recorded key inside the root, refusing anything that escapes it. */
    private Path resolve(String key) {
        Path resolved = root.resolve(key).normalize();
        if (!resolved.startsWith(root)) {
            throw new IllegalStateException("Document path escapes the storage root: " + key);
        }
        return resolved;
    }
}
