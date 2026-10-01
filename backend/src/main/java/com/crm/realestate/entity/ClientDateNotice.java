package com.crm.realestate.entity;

import com.crm.realestate.enums.ClientDateKind;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * That the agent has been told about a client's birthday or purchase anniversary in a given year.
 *
 * <p>The unique key is what keeps it to once a year: the reminder runs every hour of the day, and
 * there may be more than one server running it. The delete rule is declared here as well as in V45
 * so the schema the tests generate from the entities behaves the same way.
 */
@Entity
@Table(name = "client_date_notices",
        uniqueConstraints = @UniqueConstraint(name = "uq_client_date_notices",
                columnNames = {"client_id", "kind", "occurrence_year"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientDateNotice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Client client;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private ClientDateKind kind;

    @Column(name = "occurrence_year", nullable = false)
    private Integer occurrenceYear;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
