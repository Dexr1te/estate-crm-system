package com.crm.realestate.entity;

import com.crm.realestate.enums.AgencyCurrency;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "teams")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Team {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Not unique: two agencies may well share a name.
    @Column(nullable = false)
    private String name;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id", unique = true)
    private User manager;

    @OneToMany(mappedBy = "team", cascade = CascadeType.ALL, orphanRemoval = false)
    @Builder.Default
    private List<User> members = new ArrayList<>();

    /** What its prices are shown in; the amounts themselves carry no currency (V36). */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 3)
    @Builder.Default
    private AgencyCurrency currency = AgencyCurrency.USD;

    /**
     * Whether the default deal checklist has been written for this agency (V37). Never written by
     * saving the team — only by the guarded update in ChecklistTemplateItemRepository — so a
     * rename that loaded the team before the template was seeded cannot put the flag back.
     */
    @Column(name = "checklist_template_seeded", nullable = false, updatable = false)
    @Builder.Default
    private boolean checklistTemplateSeeded = false;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
