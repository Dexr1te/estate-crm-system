package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.PropertyOffer;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.OfferStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface PropertyOfferRepository extends JpaRepository<PropertyOffer, Long> {

    /** A listing's offers, the highest first; each row names its buyer and its agent. */
    @Query("SELECT o FROM PropertyOffer o JOIN FETCH o.property JOIN FETCH o.client LEFT JOIN FETCH o.agent "
            + "WHERE o.property.id = :propertyId ORDER BY o.amount DESC, o.id DESC")
    List<PropertyOffer> findByPropertyHighestFirst(@Param("propertyId") Long propertyId);

    /** A buyer's offers, the latest first. */
    @Query("SELECT o FROM PropertyOffer o JOIN FETCH o.property JOIN FETCH o.client LEFT JOIN FETCH o.agent "
            + "WHERE o.client.id = :clientId ORDER BY o.createdAt DESC, o.id DESC")
    List<PropertyOffer> findByClientNewestFirst(@Param("clientId") Long clientId);

    @Query("SELECT o FROM PropertyOffer o JOIN FETCH o.property JOIN FETCH o.client LEFT JOIN FETCH o.agent "
            + "WHERE o.id = :id")
    Optional<PropertyOffer> findWithParties(@Param("id") Long id);

    /** The accepted offer of each of these listings, as [propertyId, offerId], in one statement. */
    @Query("SELECT o.property.id, o.id FROM PropertyOffer o "
            + "WHERE o.property.id IN :propertyIds AND o.status = :status")
    List<Object[]> findByStatusIn(@Param("propertyIds") Collection<Long> propertyIds,
                                  @Param("status") OfferStatus status);

    boolean existsByPropertyIdAndStatus(Long propertyId, OfferStatus status);

    /** The buyer's offers on the listing in these stored states — the open ones, to refuse a second. */
    List<PropertyOffer> findByPropertyIdAndClientIdAndStatusIn(Long propertyId, Long clientId,
                                                               Collection<OfferStatus> statuses);

    /** Moves a merged-away card's offers to the card that stays — see ClientDuplicateService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PropertyOffer o SET o.client = :target WHERE o.client = :source")
    int moveToClient(@Param("source") Client source, @Param("target") Client target);

    /** Hands offers someone follows in a team to a colleague — see RecordHandoverService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PropertyOffer o SET o.agent = :to WHERE o.agent = :from AND o.team = :team")
    int reassignInTeam(@Param("from") User from, @Param("to") User to, @Param("team") Team team);

    /** Hands every offer someone follows to their successor — see AccountRemovalService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE PropertyOffer o SET o.agent = :to WHERE o.agent = :from")
    int reassignAll(@Param("from") User from, @Param("to") User to);
}
