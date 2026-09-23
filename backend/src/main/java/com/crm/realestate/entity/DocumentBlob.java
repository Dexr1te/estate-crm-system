package com.crm.realestate.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

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

    /**
     * The length matters only to a generated schema: Flyway says {@code bytea}, which has no
     * limit, but Hibernate defaults an undeclared {@code byte[]} to 255 bytes. A database built
     * from the entities — the test one is — would take the first attachment and refuse the second,
     * which is a disagreement with production that a test should never have to discover.
     */
    @Column(name = "content", nullable = false)
    @JdbcTypeCode(SqlTypes.LONGVARBINARY)
    private byte[] content;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public DocumentBlob(String storageKey, byte[] content) {
        this.storageKey = storageKey;
        this.content = content;
        this.createdAt = LocalDateTime.now();
    }
}
