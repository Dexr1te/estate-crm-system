package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.OpenHouseVisitor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface OpenHouseVisitorRepository extends JpaRepository<OpenHouseVisitor, Long> {

    /** The sign-in sheet, latest arrival first, with the client and its agent each line names. */
    @Query("SELECT v FROM OpenHouseVisitor v LEFT JOIN FETCH v.client c LEFT JOIN FETCH c.agent "
            + "LEFT JOIN FETCH v.signedInBy "
            + "WHERE v.openHouse.id = :openHouseId ORDER BY v.signedInAt DESC, v.id DESC")
    List<OpenHouseVisitor> findSheet(@Param("openHouseId") Long openHouseId);

    boolean existsByOpenHouseIdAndPhoneNormalized(Long openHouseId, String phoneNormalized);

    long countByOpenHouseId(Long openHouseId);

    /**
     * Visitors, new clients and the interested, per open house, in one statement. Row: open house
     * id, visitors, new clients, interested.
     */
    @Query("SELECT v.openHouse.id, COUNT(v), "
            + "SUM(CASE WHEN v.newClient = true THEN 1 ELSE 0 END), "
            + "SUM(CASE WHEN v.interest = com.crm.realestate.enums.OpenHouseInterest.INTERESTED THEN 1 ELSE 0 END) "
            + "FROM OpenHouseVisitor v WHERE v.openHouse.id IN :ids GROUP BY v.openHouse.id")
    List<Object[]> summarise(@Param("ids") Collection<Long> ids);

    /** Moves the sheet's lines onto another card — see ClientDuplicateService.merge. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE OpenHouseVisitor v SET v.client = :target WHERE v.client = :source")
    int moveToClient(@Param("source") Client source, @Param("target") Client target);
}
