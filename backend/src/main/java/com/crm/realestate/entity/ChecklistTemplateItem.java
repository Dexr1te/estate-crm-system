package com.crm.realestate.entity;

import com.crm.realestate.enums.ChecklistStage;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

/**
 * One line of an agency's deal checklist template — what a deal at {@link #stage} should collect.
 * Copied onto each new deal; see V37 for why the words are the agency's own and not translated.
 */
@Entity
@Table(name = "checklist_template_items",
        indexes = @Index(name = "idx_checklist_template_items_team", columnList = "team_id, stage, position"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChecklistTemplateItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
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
}
