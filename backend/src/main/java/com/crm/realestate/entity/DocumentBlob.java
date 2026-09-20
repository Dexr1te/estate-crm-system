package com.crm.realestate.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * The bytes of one stored document, keyed by what the document row records.
 *
 * <p>Kept apart from {@link Document} on purpose: a listing reads every column
 * of every document on a deal, and a blob column on that table would drag the
 * files through each of those queries.
 */
@Entity
@Table(name = "document_blobs")
@Getter
@Setter
@NoArgsConstructor
public class DocumentBlob {

    @Id
    @Column(name = "storage_key", length = 500, nullable = false, updatable = false)
    private String storageKey;

    @Column(name = "content", nullable = false)
    private byte[] content;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public DocumentBlob(String storageKey, byte[] content) {
        this.storageKey = storageKey;
        this.content = content;
        this.createdAt = LocalDateTime.now();
    }
}
