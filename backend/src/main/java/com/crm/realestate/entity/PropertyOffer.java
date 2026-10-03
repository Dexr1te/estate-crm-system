package com.crm.realestate.entity;

import com.crm.realestate.enums.OfferParty;
import com.crm.realestate.enums.OfferStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * A buyer's offer on a listing, with the figure on the table now and where it stands (V47).
 *
 * <p>It lives in the listing's agency and the whole agency sees it as it sees the listing. The
 * cascades are declared here as well as in V47 so the schema generated for tests behaves the way
 * the migrated one does. The one-accepted-offer-per-listing index cannot be: H2 has no partial
 * indexes, so in tests the service's own check is the only guard.
 */
@Entity
@Table(name = "property_offers",
        indexes = {
                @Index(name = "idx_property_offers_property", columnList = "property_id, amount"),
                @Index(name = "idx_property_offers_client", columnList = "client_id"),
                @Index(name = "idx_property_offers_team", columnList = "team_id")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyOffer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    /** The buyer. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    /** Who recorded it and follows it up. Named {@code agent} so the handover queries read alike. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User agent;

    /** The figure on the table now, in the agency's currency. */
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    /** Whose figure {@link #amount} is. */
    @Enumerated(EnumType.STRING)
    @Column(name = "last_party", nullable = false, length = 8)
    @Builder.Default
    private OfferParty lastParty = OfferParty.BUYER;

    @Column(length = 1000)
    private String note;

    /** The last day the offer stands, if it was given one. */
    @Column(name = "expires_on")
    private LocalDate expiresOn;

    /** As stored: never {@link OfferStatus#EXPIRED}; see {@link #statusOn}. */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    @Builder.Default
    private OfferStatus status = OfferStatus.NEW;

    @Column(name = "decided_at")
    private LocalDateTime decidedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /** Where the offer stands on {@code today}: an open one past its last day has expired. */
    public OfferStatus statusOn(LocalDate today) {
        if (status.isOpen() && expiresOn != null && expiresOn.isBefore(today)) {
            return OfferStatus.EXPIRED;
        }
        return status;
    }

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
