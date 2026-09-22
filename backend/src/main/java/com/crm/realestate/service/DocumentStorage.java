package com.crm.realestate.service;

import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

/**
 * Where the bytes of a deal document live.
 *
 * <p>What the database keeps on the document row is a <em>key</em>, not a
 * location: {@code <dealId>/<uuid>.<ext>}. Every implementation reads and
 * writes that same shape, so moving the store is a config change and not a data
 * migration — see {@code app.documents.storage}.
 *
 * <p>The name a person uploaded is never part of the key. It is kept in the
 * database and handed back on download, which removes both path traversal and
 * the question of what two people uploading "contract.pdf" do to each other.
 */
public interface DocumentStorage {

    /**
     * Stores [file] and returns the key to record on its row.
     *
     * <p>[folder] keeps the kinds apart in a store somebody may one day open by hand —
     * {@code deals/7/…} is paperwork, {@code properties/7/…} is photographs. Implementations treat
     * the whole key as opaque and nothing more.
     */
    String store(MultipartFile file, String folder, Long ownerId, String extension);

    /** The stored bytes. Throws {@link IllegalStateException} if they are gone. */
    Resource load(String key);

    /**
     * Removes the stored bytes, if they are still there.
     *
     * <p>A missing file is not an error: the row is what the app shows, and
     * refusing to delete it because the bytes already vanished would leave a
     * record nobody can act on.
     */
    void delete(String key);

    /** The key every implementation writes: a folder per kind and per owner, a UUID per file. */
    static String newKey(String folder, Long ownerId, String extension) {
        return folder + "/" + ownerId + "/" + UUID.randomUUID()
                + (extension.isEmpty() ? "" : "." + extension);
    }
}
