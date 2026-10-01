package com.crm.realestate.entity;

import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.service.ContactNormalizer;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

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

    /**
     * The phone as it is compared when looking for the same person entered twice. Derived from
     * {@link #phone} on every save, never set by hand.
     */
    @Setter(AccessLevel.NONE)
    @Column(name = "phone_normalized", length = 50)
    private String phoneNormalized;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ClientType type;     // BUYER или SELLER

    private String notes;

    /** Where the record came from; set once on creation. See {@code V35__client_source.sql}. */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20, updatable = false)
    @Builder.Default
    private ClientSource source = ClientSource.MANUAL;

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

    /**
     * The client's birthday, day and month, with the year only when it is known (V45). Read and
     * written through {@code ClientBirthday}, which keeps the three consistent.
     */
    @Column(name = "birth_month")
    private Integer birthMonth;

    @Column(name = "birth_day")
    private Integer birthDay;

    @Column(name = "birth_year")
    private Integer birthYear;

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

    /**
     * The agency's tags this client carries, at most {@code ClientTags.MAX_PER_CLIENT}. Set only
     * through {@code ClientTagService}, which keeps them inside the client's own agency. Loaded a
     * batch of clients at a time, so a list costs one extra statement per hundred rows rather than
     * one per row.
     */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "client_tag_links",
            joinColumns = @JoinColumn(name = "client_id"),
            inverseJoinColumns = @JoinColumn(name = "tag_id"))
    @OrderBy("nameKey ASC")
    @org.hibernate.annotations.BatchSize(size = 100)
    @Builder.Default
    private Set<ClientTag> tags = new LinkedHashSet<>();

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        phoneNormalized = ContactNormalizer.phone(phone);
        if (source == null) {
            source = ClientSource.MANUAL;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        phoneNormalized = ContactNormalizer.phone(phone);
    }
}