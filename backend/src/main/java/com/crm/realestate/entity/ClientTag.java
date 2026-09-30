package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One word of an agency's tag vocabulary. Clients carry these through {@link Client#getTags()};
 * see V39 for why the vocabulary is the agency's and how "the same tag" is decided.
 */
@Entity
@Table(name = "client_tags",
        uniqueConstraints = @UniqueConstraint(name = "uq_client_tags_team_key", columnNames = {"team_id", "name_key"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    /** As shown: the casing of whoever used it first in the agency. */
    @Column(nullable = false, length = 64)
    private String name;

    /** {@link #name} without case — what makes two spellings one tag. */
    @Column(name = "name_key", nullable = false, length = 64)
    private String nameKey;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
