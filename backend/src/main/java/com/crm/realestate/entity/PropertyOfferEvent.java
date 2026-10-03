package com.crm.realestate.entity;

import com.crm.realestate.enums.OfferAction;
import com.crm.realestate.enums.OfferParty;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** One step in an offer's negotiation: the offer itself, a counter, or how it ended (V47). */
@Entity
@Table(name = "property_offer_events",
        indexes = @Index(name = "idx_property_offer_events_offer", columnList = "offer_id, created_at"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyOfferEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "offer_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private PropertyOffer offer;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private OfferAction action;

    /** The figure on the table after this step. */
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    /** Whose figure it was, for an offer or a counter; null for a decision. */
    @Enumerated(EnumType.STRING)
    @Column(length = 8)
    private OfferParty party;

    @Column(length = 1000)
    private String note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User actor;

    /** Kept with the step, so it still says who once the account is gone. */
    @Column(name = "actor_name")
    private String actorName;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
