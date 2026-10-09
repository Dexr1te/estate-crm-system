package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * One time a listing's keys left the office: who took them, until when, and when they came back
 * (V56).
 *
 * <p>The holder is a colleague ({@link #holderUser}) or somebody outside the agency by name
 * ({@link #holderName}), never both. The delete rules are declared here as well as in V56 so the
 * schema generated for tests behaves the way the migrated one does. The one-open-handover index
 * cannot be: H2 has no partial indexes, so in tests the service's own check is the only guard.
 */
@Entity
@Table(name = "property_key_handovers",
        indexes = {
                @Index(name = "idx_property_key_handovers_property", columnList = "property_id, handed_out_at"),
                @Index(name = "idx_property_key_handovers_team_open", columnList = "team_id, returned_at")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyKeyHandover {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    /** The colleague who has the keys, or null when {@link #holderName} says who does. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "holder_user_id")
    private User holderUser;

    /** Somebody outside the agency who has the keys: the owner, a cleaner, a buyer. */
    @Column(name = "holder_name")
    private String holderName;

    @Column(length = 500)
    private String note;

    @Column(name = "handed_out_at", nullable = false, updatable = false)
    private LocalDateTime handedOutAt;

    /** The last day the keys are to be back, if one was set. */
    @Column(name = "due_back_at")
    private LocalDate dueBackAt;

    /** When the keys came back; null while they are out. */
    @Column(name = "returned_at")
    private LocalDateTime returnedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "handed_out_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User handedOutBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "returned_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User returnedBy;

    @PrePersist
    void onCreate() {
        if (handedOutAt == null) {
            handedOutAt = LocalDateTime.now();
        }
    }

    public boolean isOut() {
        return returnedAt == null;
    }

    /** Out past the last day they were to be back. */
    public boolean overdueOn(LocalDate today) {
        return isOut() && dueBackAt != null && dueBackAt.isBefore(today);
    }
}
