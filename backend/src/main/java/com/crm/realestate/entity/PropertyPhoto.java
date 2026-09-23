package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One photograph of a listing.
 *
 * <p>The row holds what the app shows — a name, a type, a size and the position in the gallery —
 * and a key. The bytes are wherever {@code app.documents.storage} points, so a photograph and a
 * contract are stored the same way and only the metadata differs.
 */
@Entity
@Table(name = "property_photos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyPhoto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    @Column(name = "storage_key", nullable = false, length = 500)
    private String storageKey;

    /** A smaller copy for lists, or null when the format could not be decoded here. */
    @Column(name = "thumbnail_key", length = 500)
    private String thumbnailKey;

    @Column(name = "file_name", nullable = false)
    private String fileName;

    @Column(name = "content_type", nullable = false, length = 100)
    private String contentType;

    @Column(name = "file_size", nullable = false)
    private Long fileSize;

    /** Where it sits in the gallery. The first one is the cover the list shows. */
    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "uploaded_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User uploadedBy;

    @Column(name = "uploaded_at", nullable = false, updatable = false)
    private LocalDateTime uploadedAt;

    @PrePersist
    void onCreate() {
        uploadedAt = LocalDateTime.now();
    }
}
