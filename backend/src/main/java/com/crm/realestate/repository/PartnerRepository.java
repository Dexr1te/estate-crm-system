package com.crm.realestate.repository;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Partner;
import com.crm.realestate.entity.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/**
 * An agency's partners, and what their referrals came to.
 *
 * <p>The counting queries narrow the referred clients the way a client list is narrowed: with
 * {@code whole} false only the clients {@code me} holds count. A partner is always the agency's,
 * and so is every client it is linked to, so the team wall is already behind the partner ids.
 */
public interface PartnerRepository extends JpaRepository<Partner, Long>, JpaSpecificationExecutor<Partner> {

    /** A list of partners names whoever added each, so that comes along. */
    @Override
    @EntityGraph(attributePaths = "createdBy")
    List<Partner> findAll(Specification<Partner> spec, Sort sort);

    /** How many clients each partner sent, among those the caller sees. Rows: partner id, count. */
    @Query("SELECT c.referredBy.id, COUNT(c) FROM Client c LEFT JOIN c.agent a "
            + "WHERE c.referredBy.id IN :ids AND (:whole = true OR a.id = :me) GROUP BY c.referredBy.id")
    List<Object[]> countReferred(@Param("ids") Collection<Long> ids, @Param("whole") boolean whole,
                                 @Param("me") Long me);

    /**
     * The won deals of the clients each partner sent, among the clients the caller sees, with the
     * partner's id beside each. The fee is worked out from the deal in Java (ReferralFee), the way
     * DealMoney reads a rent and a sale.
     */
    @Query("SELECT d, c.referredBy.id FROM Deal d JOIN d.client c LEFT JOIN c.agent a "
            + "WHERE c.referredBy.id IN :ids AND d.status = com.crm.realestate.enums.DealStatus.CLOSED_WON "
            + "AND (:whole = true OR a.id = :me)")
    List<Object[]> findWonDeals(@Param("ids") Collection<Long> ids, @Param("whole") boolean whole,
                                @Param("me") Long me);

    /** The won deals of one client, for a partner's list of the clients it sent. */
    @Query("SELECT d FROM Deal d WHERE d.client.id IN :clientIds "
            + "AND d.status = com.crm.realestate.enums.DealStatus.CLOSED_WON")
    List<Deal> findWonDealsOfClients(@Param("clientIds") Collection<Long> clientIds);

    /** Whether any client in the agency says this partner sent them, whoever holds the client. */
    @Query("SELECT COUNT(c) > 0 FROM Client c WHERE c.referredBy.id = :partnerId")
    boolean hasReferrals(@Param("partnerId") Long partnerId);

    /** Hands the partners someone added to their successor — see AccountRemovalService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Partner p SET p.createdBy = :to WHERE p.createdBy = :from")
    int reassignCreator(@Param("from") User from, @Param("to") User to);

    /** Forgets who added the partners, which stay with the agency — see AccountRemovalService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Partner p SET p.createdBy = NULL WHERE p.createdBy = :from")
    int forgetCreator(@Param("from") User from);
}
