package com.crm.realestate.repository;

import com.crm.realestate.entity.ClientActivityProperty;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface ClientActivityPropertyRepository
        extends JpaRepository<ClientActivityProperty, ClientActivityProperty.Key> {

    /** The listings behind a page of entries, in one query, with each listing's title on board. */
    @Query("SELECT ap FROM ClientActivityProperty ap JOIN FETCH ap.property p "
            + "WHERE ap.activity.id IN :activityIds ORDER BY p.id")
    List<ClientActivityProperty> findForActivities(@Param("activityIds") Collection<Long> activityIds);

    /**
     * When each listing last went out to this client: rows of {@code [propertyId, latestOccurredAt]}.
     * One grouped query for the whole match list, however long it is.
     */
    @Query("SELECT ap.property.id, MAX(a.occurredAt) FROM ClientActivityProperty ap JOIN ap.activity a "
            + "WHERE a.client.id = :clientId GROUP BY ap.property.id")
    List<Object[]> lastSentTo(@Param("clientId") Long clientId);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("DELETE FROM ClientActivityProperty ap WHERE ap.activity.id = :activityId")
    int deleteByActivity(@Param("activityId") Long activityId);
}
