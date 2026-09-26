package com.crm.realestate.repository;

import com.crm.realestate.entity.DealStatusChange;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DealStatusChangeRepository extends JpaRepository<DealStatusChange, Long> {

    /** A deal's moves, oldest first. */
    @Query("SELECT c FROM DealStatusChange c WHERE c.deal.id = :dealId ORDER BY c.changedAt, c.id")
    List<DealStatusChange> findHistory(@Param("dealId") Long dealId);
}
