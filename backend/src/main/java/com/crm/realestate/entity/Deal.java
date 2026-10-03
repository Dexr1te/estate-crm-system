package com.crm.realestate.entity;

import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
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

    // Доля агента от цены сделки, в процентах
    @Column(name = "commission_percent", precision = 5, scale = 2)
    private BigDecimal commissionPercent;

    private String notes;

    // A sale or a rent. A rent has no dealPrice; see V50 and DealMoney.
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 8)
    @Builder.Default
    private DealKind kind = DealKind.SALE;

    // RENT only: the rent per month, the first and last day of the lease, and how many days
    // before the end the agent wants to hear about it (null = LeaseService.DEFAULT_REMINDER_DAYS).
    @Column(name = "monthly_rent", precision = 15, scale = 2)
    private BigDecimal monthlyRent;

    @Column(name = "lease_start")
    private LocalDate leaseStart;

    @Column(name = "lease_end")
    private LocalDate leaseEnd;

    @Column(name = "lease_reminder_days")
    private Integer leaseReminderDays;

    // RENT only: the client who lets the place. The deal's client is the tenant.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "landlord_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private Client landlord;

    // The leaseEnd the agent was last reminded about; see LeaseEndNotifier.
    @Column(name = "lease_reminded_for")
    private LocalDate leaseRemindedFor;

    // Why the deal was lost. Set only while status is CLOSED_LOST; null on deals lost before V28.
    @Enumerated(EnumType.STRING)
    @Column(name = "lost_reason", length = 32)
    private DealLostReason lostReason;

    @Column(name = "lost_note", length = 500)
    private String lostNote;

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

    // The agency this record belongs to. See ScopeService for what it decides.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

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
        if (kind == null) kind = DealKind.SALE;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}