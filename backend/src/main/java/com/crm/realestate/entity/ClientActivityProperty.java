package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.io.Serializable;

/**
 * A listing an entry in a client's history was about — the flats that went out in a message.
 *
 * <p>Mapped as its own row rather than a many-to-many on the entry so that both ends can declare
 * their cascade: the link goes with the entry, and with the listing. Both are also in V32, so the
 * schema generated for tests behaves the way the migrated one does.
 */
@Entity
@Table(name = "client_activity_properties",
        indexes = @Index(name = "idx_client_activity_properties_property", columnList = "property_id"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ClientActivityProperty {

    @EmbeddedId
    private Key id;

    @MapsId("activityId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private ClientActivity activity;

    @MapsId("propertyId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    public static ClientActivityProperty of(ClientActivity activity, Property property) {
        return new ClientActivityProperty(new Key(activity.getId(), property.getId()), activity, property);
    }

    @Embeddable
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        @Column(name = "activity_id")
        private Long activityId;

        @Column(name = "property_id")
        private Long propertyId;
    }
}
