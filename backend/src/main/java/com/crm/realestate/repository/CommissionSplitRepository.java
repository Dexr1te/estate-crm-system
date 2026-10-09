package com.crm.realestate.repository;

import com.crm.realestate.entity.CommissionSplit;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface CommissionSplitRepository extends JpaRepository<CommissionSplit, Long> {

    /** A deal's shares, in the order the editor listed them, with who paid each out. */
    @EntityGraph(attributePaths = {"user", "paidBy"})
    List<CommissionSplit> findByDealIdOrderByPositionAscIdAsc(Long dealId);

    /** The shares of all these deals, in one query: an export's page. */
    @EntityGraph(attributePaths = {"user"})
    List<CommissionSplit> findByDealIdInOrderByDealIdAscPositionAscIdAsc(Collection<Long> dealIds);

    boolean existsByDealIdAndUserId(Long dealId, Long userId);

    /** Every share {@code user} holds on a deal of {@code team}: what a leaver hands over. */
    @Query("SELECT s FROM CommissionSplit s JOIN FETCH s.deal d WHERE s.user = :user AND d.team = :team")
    List<CommissionSplit> heldInTeam(@Param("user") User user, @Param("team") Team team);

    /** Every share {@code user} holds, whichever agency the deal is in: a closed account's. */
    @Query("SELECT s FROM CommissionSplit s JOIN FETCH s.deal WHERE s.user = :user")
    List<CommissionSplit> heldBy(@Param("user") User user);

    /**
     * Shares {@code user} holds on deals they now hold themselves. The condition is the database's,
     * so a deal moved by a bulk update a moment ago counts.
     */
    @Query("SELECT s FROM CommissionSplit s JOIN FETCH s.deal d WHERE s.user = :user AND d.agent = :user")
    List<CommissionSplit> onOwnDeals(@Param("user") User user);

    /** Every share on the deals of {@code teamId} in {@code status}, paid or not: the payouts' rows. */
    @Query("SELECT s FROM CommissionSplit s JOIN FETCH s.deal d LEFT JOIN FETCH s.user LEFT JOIN FETCH s.paidBy "
            + "WHERE d.team.id = :teamId AND d.status = :status")
    List<CommissionSplit> onTeamDeals(@Param("teamId") Long teamId, @Param("status") DealStatus status);

    /** {@link #onTeamDeals} narrowed to the shares one person holds. */
    @Query("SELECT s FROM CommissionSplit s JOIN FETCH s.deal d JOIN FETCH s.user u LEFT JOIN FETCH s.paidBy "
            + "WHERE d.team.id = :teamId AND d.status = :status AND u.id = :userId")
    List<CommissionSplit> heldOnTeamDeals(@Param("teamId") Long teamId, @Param("status") DealStatus status,
                                          @Param("userId") Long userId);
}
