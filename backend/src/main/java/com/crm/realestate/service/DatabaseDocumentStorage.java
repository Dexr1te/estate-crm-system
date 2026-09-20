package com.crm.realestate.service;

import com.crm.realestate.entity.DocumentBlob;
import com.crm.realestate.repository.DocumentBlobRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

/**
 * The store for a host whose filesystem does not survive a restart.
 *
 * <p>Anything written to disk on a container platform is gone on the next
 * deploy, and on a free plan on the next wake from sleep — which would leave a
 * deal listing paperwork nobody can open. In the database the bytes last as
 * long as the row that describes them, and the two move together: an upload
 * that fails after the file is written rolls the blob back with it, which the
 * filesystem store cannot do.
 *
 * <p>The cost is the database's own size limit, so this is the right store for
 * a working deployment and not for an archive. Point
 * {@code app.documents.storage} at {@code filesystem} once there is a real
 * volume to write to.
 */
@Component
@ConditionalOnProperty(name = "app.documents.storage", havingValue = "database", matchIfMissing = true)
@RequiredArgsConstructor
public class DatabaseDocumentStorage implements DocumentStorage {

    private final DocumentBlobRepository blobs;

    @Override
    public String store(MultipartFile file, Long dealId, String extension) {
        String key = DocumentStorage.newKey(dealId, extension);
        try {
            blobs.save(new DocumentBlob(key, file.getBytes()));
        } catch (IOException e) {
            throw new IllegalStateException("Could not store the uploaded file", e);
        }
        return key;
    }

    @Override
    public Resource load(String key) {
        return blobs.findById(key)
                .map(blob -> (Resource) new ByteArrayResource(blob.getContent()))
                .orElseThrow(() -> new IllegalStateException("File is missing from storage: " + key));
    }

    @Override
    public void delete(String key) {
        blobs.findById(key).ifPresent(blobs::delete);
    }
}
