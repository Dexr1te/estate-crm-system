package com.crm.realestate.entity;

import com.crm.realestate.enums.OpenHouseInterest;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One line of an open house's sign-in sheet: who came, as they gave it at the door, and the
 * agency's client they turned out to be.
 *
 * <p>The sheet keeps the name and number as typed, so it still says who came after the client
 * card is merged away or deleted. See V44 for each reference's cascade.
 */
@Entity
@Table(name = "open_house_visitors",
        uniqueConstraints = @UniqueConstraint(name = "uq_open_house_visitors_phone",
                columnNames = {"open_house_id", "phone_normalized"}),
        indexes = @Index(name = "idx_open_house_visitors_client", columnList = "client_id"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OpenHouseVisitor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "open_house_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private OpenHouse openHouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @Column(name = "full_name", nullable = false, length = 120)
    private String fullName;

    @Column(nullable = false, length = 40)
    private String phone;

    @Column(name = "phone_normalized", nullable = false, length = 40)
    private String phoneNormalized;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private OpenHouseInterest interest;

    @Column(length = 1000)
    private String note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private Client client;

    @Column(name = "new_client", nullable = false)
    private boolean newClient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private ClientActivity activity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "signed_in_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User signedInBy;

    @Column(name = "signed_in_at", nullable = false, updatable = false)
    private LocalDateTime signedInAt;

    @PrePersist
    void onCreate() {
        if (signedInAt == null) {
            signedInAt = LocalDateTime.now();
        }
    }
}
