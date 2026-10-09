package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyKeyHandover;
import com.crm.realestate.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PropertyKeyHandoverRepository extends JpaRepository<PropertyKeyHandover, Long> {

    /** The listing's keys that are out now, if they are, with who has them and who gave them. */
    @Query("SELECT h FROM PropertyKeyHandover h LEFT JOIN FETCH h.holderUser LEFT JOIN FETCH h.handedOutBy "
            + "WHERE h.property.id = :propertyId AND h.returnedAt IS NULL")
    Optional<PropertyKeyHandover> findOpen(@Param("propertyId") Long propertyId);

    /** The listing's handovers that are over, the newest first, as many as the page holds. */
    @Query("SELECT h FROM PropertyKeyHandover h LEFT JOIN FETCH h.holderUser LEFT JOIN FETCH h.handedOutBy "
            + "LEFT JOIN FETCH h.returnedBy "
            + "WHERE h.property.id = :propertyId AND h.returnedAt IS NOT NULL "
            + "ORDER BY h.handedOutAt DESC, h.id DESC")
    List<PropertyKeyHandover> findReturned(@Param("propertyId") Long propertyId, Pageable page);

    /** Every key out in an agency, each with its listing. */
    @Query("SELECT h FROM PropertyKeyHandover h JOIN FETCH h.property p LEFT JOIN FETCH h.holderUser "
            + "LEFT JOIN FETCH h.handedOutBy "
            + "WHERE h.returnedAt IS NULL AND h.team.id = :teamId")
    List<PropertyKeyHandover> findOpenInTeam(@Param("teamId") Long teamId);

    /** Every key out anywhere, for an admin. */
    @Query("SELECT h FROM PropertyKeyHandover h JOIN FETCH h.property p LEFT JOIN FETCH h.holderUser "
            + "LEFT JOIN FETCH h.handedOutBy "
            + "WHERE h.returnedAt IS NULL")
    List<PropertyKeyHandover> findAllOpen();

    /**
     * Someone's account closes: whatever keys they took are written down under their name instead,
     * so the record still says who has them — see AccountRemovalService.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PropertyKeyHandover h SET h.holderName = :name, h.holderUser = NULL WHERE h.holderUser = :user")
    int keepHolderByName(@Param("user") User user, @Param("name") String name);
}
