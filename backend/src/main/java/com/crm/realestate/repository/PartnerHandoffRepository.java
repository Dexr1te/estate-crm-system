package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.PartnerHandoff;
import com.crm.realestate.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/** Clients sent to partners. Narrowed by the client's holder like {@link PartnerRepository}. */
public interface PartnerHandoffRepository extends JpaRepository<PartnerHandoff, Long> {

    /** A client's hand-offs, the latest first, each with its partner and sender. */
    @Query("SELECT h FROM PartnerHandoff h JOIN FETCH h.partner LEFT JOIN FETCH h.sentBy "
            + "WHERE h.client.id = :clientId ORDER BY h.sentOn DESC, h.id DESC")
    List<PartnerHandoff> findByClientLatestFirst(@Param("clientId") Long clientId);

    /** The clients sent to a partner that the caller sees, the latest first. */
    @Query("SELECT h FROM PartnerHandoff h JOIN FETCH h.client c LEFT JOIN FETCH h.sentBy LEFT JOIN c.agent a "
            + "WHERE h.partner.id = :partnerId AND (:whole = true OR a.id = :me) "
            + "ORDER BY h.sentOn DESC, h.id DESC")
    List<PartnerHandoff> findByPartnerLatestFirst(@Param("partnerId") Long partnerId,
                                                  @Param("whole") boolean whole, @Param("me") Long me);

    /** Per partner: hand-offs, and how many of them are not done. Rows: partner id, all, open. */
    @Query("SELECT h.partner.id, COUNT(h), "
            + "SUM(CASE WHEN h.status = com.crm.realestate.enums.PartnerHandoffStatus.DONE THEN 0 ELSE 1 END) "
            + "FROM PartnerHandoff h JOIN h.client c LEFT JOIN c.agent a "
            + "WHERE h.partner.id IN :ids AND (:whole = true OR a.id = :me) GROUP BY h.partner.id")
    List<Object[]> countByPartner(@Param("ids") Collection<Long> ids, @Param("whole") boolean whole,
                                  @Param("me") Long me);

    boolean existsByPartnerId(Long partnerId);

    /** Moves the hand-offs onto another card — see ClientDuplicateService.merge. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PartnerHandoff h SET h.client = :target WHERE h.client = :source")
    int moveToClient(@Param("source") Client source, @Param("target") Client target);

    /** Forgets who sent the clients; the hand-offs stay — see AccountRemovalService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PartnerHandoff h SET h.sentBy = NULL WHERE h.sentBy = :from")
    int forgetSender(@Param("from") User from);
}
