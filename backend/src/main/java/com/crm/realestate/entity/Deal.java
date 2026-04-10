package com.crm.realestate.entity;

import com.crm.realestate.enums.DealStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "deals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Deal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DealStatus status;    // LEAD → NEGOTIATION → CLOSED_WON / CLOSED_LOST

    @Column(precision = 15, scale = 2)
    private BigDecimal dealPrice;

    // Бюджет клиента (для фронтенда)
    @Column(precision = 15, scale = 2)
    private BigDecimal budget;

    private String notes;

    // Клиент по сделке
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    // nullable — на этапе LEAD объект может отсутствовать
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id")
    private Property property;

    // Ответственный агент
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    // Документы по сделке
    @OneToMany(mappedBy = "deal", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Document> documents = new ArrayList<>();

    // Встречи по сделке
    @OneToMany(mappedBy = "deal", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Meeting> meetings = new ArrayList<>();

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
    private LocalDateTime closedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) status = DealStatus.LEAD;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}