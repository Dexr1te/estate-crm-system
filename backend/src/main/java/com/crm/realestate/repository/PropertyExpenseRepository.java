package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyExpense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PropertyExpenseRepository extends JpaRepository<PropertyExpense, Long> {

    /** A listing's expenses, the latest paid first; each row names who recorded it. */
    @Query("SELECT e FROM PropertyExpense e LEFT JOIN FETCH e.createdBy "
            + "WHERE e.property.id = :propertyId ORDER BY e.spentOn DESC, e.id DESC")
    List<PropertyExpense> findByPropertyNewestFirst(@Param("propertyId") Long propertyId);

    /** One expense, only as one of this listing's. */
    @Query("SELECT e FROM PropertyExpense e LEFT JOIN FETCH e.createdBy "
            + "WHERE e.id = :id AND e.property.id = :propertyId")
    Optional<PropertyExpense> findOnProperty(@Param("id") Long id, @Param("propertyId") Long propertyId);
}
