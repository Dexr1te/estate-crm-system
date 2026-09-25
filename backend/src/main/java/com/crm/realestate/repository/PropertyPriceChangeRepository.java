package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyPriceChange;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface PropertyPriceChangeRepository extends JpaRepository<PropertyPriceChange, Long> {

    /** A listing's price history, newest first, with the author fetched for the name. */
    @Query("SELECT c FROM PropertyPriceChange c LEFT JOIN FETCH c.changedBy "
            + "WHERE c.property.id = :propertyId ORDER BY c.changedAt DESC, c.id DESC")
    List<PropertyPriceChange> findHistory(@Param("propertyId") Long propertyId);

    /**
     * The most recent change of each of these listings, in one statement, so a list of listings
     * does not pay a round trip per row. Two changes in the same instant both come back; the
     * caller keeps the later id.
     */
    @Query("SELECT c FROM PropertyPriceChange c WHERE c.property.id IN :propertyIds "
            + "AND c.changedAt = (SELECT MAX(c2.changedAt) FROM PropertyPriceChange c2 "
            + "WHERE c2.property = c.property)")
    List<PropertyPriceChange> findLatestFor(@Param("propertyIds") Collection<Long> propertyIds);
}
