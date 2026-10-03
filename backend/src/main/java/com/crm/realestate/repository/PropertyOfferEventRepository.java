package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyOfferEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PropertyOfferEventRepository extends JpaRepository<PropertyOfferEvent, Long> {

    /** An offer's negotiation, the first step first. */
    @Query("SELECT e FROM PropertyOfferEvent e WHERE e.offer.id = :offerId ORDER BY e.createdAt ASC, e.id ASC")
    List<PropertyOfferEvent> findHistory(@Param("offerId") Long offerId);
}
