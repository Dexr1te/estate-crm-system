package com.crm.realestate.entity;

import com.crm.realestate.enums.ChecklistStage;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One thing a deal still needs, or no longer does. Goes with the deal; outlives the person who
 * ticked it and the document that proved it (V37). The cascade rules are declared here as well so
 * a schema generated from the entities — the test database is one — behaves like the migrated one.
 */
@Entity
@Table(name = "deal_checklist_items",
        indexes = @Index(name = "idx_deal_checklist_items_deal", columnList = "deal_id, stage, position"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DealChecklistItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Deal deal;

    // The agency this record belongs to — always the deal's. Access is decided by the deal.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private ChecklistStage stage;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false)
    private int position;

    @Column(nullable = false)
    private boolean required;

    /** Added on this deal rather than copied from the template; only these can be deleted. */
    @Column(nullable = false)
    private boolean custom;

    @Column(name = "done_at")
    private LocalDateTime doneAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "done_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User doneBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "document_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private Document document;
}
