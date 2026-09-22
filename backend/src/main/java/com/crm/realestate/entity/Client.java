package com.crm.realestate.entity;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "clients",
        uniqueConstraints = @UniqueConstraint(name = "uq_clients_team_email", columnNames = {"team_id", "email"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    // Unique within a team, not across the platform: two agencies may know the same person.
    private String email;

    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ClientType type;     // BUYER или SELLER

    private String notes;

    @Enumerated(EnumType.STRING)
    @Column(name = "wanted_type", length = 30)
    private PropertyType wantedType;

    @Column(name = "wanted_city", length = 120)
    private String wantedCity;

    @Column(name = "budget_min", precision = 15, scale = 2)
    private BigDecimal budgetMin;

    @Column(name = "budget_max", precision = 15, scale = 2)
    private BigDecimal budgetMax;

    @Column(name = "min_rooms")
    private Integer minRooms;

    @Column(name = "min_area_sqm")
    private Double minAreaSqm;

    // Агент который ведёт клиента
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    private User agent;

    // The agency this record belongs to. See ScopeService for what it decides.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Deal> deals = new ArrayList<>();

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}