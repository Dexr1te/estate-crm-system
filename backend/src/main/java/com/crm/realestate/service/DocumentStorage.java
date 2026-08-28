package com.crm.realestate.service;

import org.springframework.beans.factory.annotation.Value;
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
import java.util.UUID;

/**
 * Where the bytes of a deal document live.
 *
 * The filesystem, under a single configurable root. What the database keeps is
 * a path <em>relative</em> to that root, so moving the store (a bigger disk, a
 * mounted volume) is a config change and not a data migration.
 *
 * The name a person uploaded is never part of the path — it is kept in the
 * database and handed back on download. On disk every file is a UUID plus its
 * extension, which removes both path traversal and the question of what two
 * people uploading "contract.pdf" do to each other.
 */
@Component
public class DocumentStorage {

    private final Path root;

    public DocumentStorage(@Value("${app.documents.dir:uploads/documents}") String dir) {
        this.root = Paths.get(dir).toAbsolutePath().normalize();
    }

    /** Writes [file] under the deal's folder and returns the path to record. */
    public String store(MultipartFile file, Long dealId, String extension) {
        String relative = dealId + "/" + UUID.randomUUID() + (extension.isEmpty() ? "" : "." + extension);
        Path target = resolve(relative);
        try {
            Files.createDirectories(target.getParent());
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Could not store the uploaded file", e);
        }
        return relative;
    }

    public Resource load(String relativePath) {
        Path file = resolve(relativePath);
        try {
            Resource resource = new UrlResource(file.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                throw new IllegalStateException("File is missing from storage: " + relativePath);
            }
            return resource;
        } catch (IOException e) {
            throw new IllegalStateException("Could not read the stored file", e);
        }
    }

    /**
     * Removes the file, if it is still there.
     *
     * A missing file is not an error: the row is what the app shows, and
     * refusing to delete it because the bytes already vanished would leave a
     * record nobody can act on.
     */
    public void delete(String relativePath) {
        try {
            Files.deleteIfExists(resolve(relativePath));
        } catch (IOException e) {
            throw new IllegalStateException("Could not delete the stored file", e);
        }
    }

    /** Resolves a recorded path inside the root, refusing anything that escapes it. */
    private Path resolve(String relativePath) {
        Path resolved = root.resolve(relativePath).normalize();
        if (!resolved.startsWith(root)) {
            throw new IllegalStateException("Document path escapes the storage root: " + relativePath);
        }
        return resolved;
    }
}
