package com.crm.realestate.entity;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
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
    private PropertyType type;           // APARTMENT, HOUSE, COMMERCIAL...

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PropertyStatus status;       // AVAILABLE, RESERVED, SOLD

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    private Double areaSqm;              // площадь м²
    private Integer rooms;
    private Integer floor;
    private Integer totalFloors;

    // Агент который ведёт объект
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    private User agent;

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