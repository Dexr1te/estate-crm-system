package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * One change of a listing's asking price.
 *
 * <p>The listing itself only ever holds the current figure, so without these rows a reduction
 * overwrites the old price and nobody can tell it happened. The person who made the change may
 * later leave; the row outlives them with no author rather than going with them.
 */
@Entity
@Table(name = "property_price_changes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyPriceChange {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @Column(name = "old_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal oldPrice;

    @Column(name = "new_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal newPrice;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User changedBy;

    @Column(name = "changed_at", nullable = false, updatable = false)
    private LocalDateTime changedAt;

    @PrePersist
    void onCreate() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}
