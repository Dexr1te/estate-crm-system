package com.crm.realestate.entity;

import com.crm.realestate.enums.MandateType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "properties")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Property {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String description;

    @Column(nullable = false)
    private String address;

    private String city;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PropertyType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PropertyStatus status;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    private Double areaSqm;
    private Integer rooms;
    private Integer floor;
    private Integer totalFloors;

    /** Where it stands, in degrees (WGS 84). Both or neither; null until an agent drops a pin. */
    private Double latitude;
    private Double longitude;

    /** The seller's agreement with the agency; null when none has been recorded. */
    @Enumerated(EnumType.STRING)
    @Column(name = "mandate_type", length = 20)
    private MandateType mandateType;

    /** The last day the agreement holds; null when it has no end date. Never set without a type. */
    @Column(name = "mandate_end_date")
    private LocalDate mandateEndDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    private User agent;

    // The agency this record belongs to. See ScopeService for what it decides.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) status = PropertyStatus.AVAILABLE;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}