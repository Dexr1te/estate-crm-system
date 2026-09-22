package com.crm.realestate.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * The store behind {@code app.documents.storage=filesystem}, which is not the
 * default and so is not covered by the document endpoints' own test.
 * It stays supported for a deployment with a volume mounted, and the two things
 * worth holding it to are that a file survives the round trip and that a
 * recorded key cannot reach outside the root it was given.
 */
class FilesystemDocumentStorageTest {

    @TempDir
    Path root;

    @Test
    void storesReadsAndRemovesAFile() throws Exception {
        FilesystemDocumentStorage storage = new FilesystemDocumentStorage(root.toString());
        byte[] bytes = "a signed contract".getBytes(StandardCharsets.UTF_8);

        String key = storage.store(
                new MockMultipartFile("file", "Договор №14.pdf", "application/pdf", bytes),
                "deals", 7L, "pdf");

        assertThat(key).startsWith("deals/7/").endsWith(".pdf");
        // The uploaded name is the database's business, never the disk's.
        assertThat(key).doesNotContain("Договор");
        assertThat(storage.load(key).getInputStream().readAllBytes()).isEqualTo(bytes);

        storage.delete(key);
        assertThatThrownBy(() -> storage.load(key))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("missing from storage");
    }

    @Test
    void aKeyCannotClimbOutOfTheRoot() {
        FilesystemDocumentStorage storage = new FilesystemDocumentStorage(root.resolve("documents").toString());

        assertThatThrownBy(() -> storage.load("../../etc/passwd"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("escapes the storage root");
    }

    @Test
    void removingSomethingAlreadyGoneIsNotAnError() {
        FilesystemDocumentStorage storage = new FilesystemDocumentStorage(root.toString());

        storage.delete("deals/7/1a2b3c.pdf");
    }
}
