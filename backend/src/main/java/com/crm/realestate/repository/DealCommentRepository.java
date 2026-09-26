package com.crm.realestate.repository;

import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface DealCommentRepository extends JpaRepository<DealComment, Long> {

    /**
     * The latest comments on a deal, newest first — the caller turns the page around. With
     * {@code beforeId} set, only comments older than that one: the "show earlier" page.
     */
    @Query("SELECT c FROM DealComment c LEFT JOIN FETCH c.author "
            + "WHERE c.deal.id = :dealId AND (:beforeId IS NULL OR c.id < :beforeId) "
            + "ORDER BY c.id DESC")
    List<DealComment> findLatest(@Param("dealId") Long dealId, @Param("beforeId") Long beforeId,
                                 Pageable page);

    /** Rows of {@code [dealId, count]} for the given deals, in one grouped query. */
    @Query("SELECT c.deal.id, COUNT(c) FROM DealComment c WHERE c.deal.id IN :dealIds GROUP BY c.deal.id")
    List<Object[]> countByDeals(@Param("dealIds") Collection<Long> dealIds);

    long countByDealId(Long dealId);

    /**
     * Brings the discussion of deals that have just joined a team along with them — see
     * RecordHandoverService. Run after the deals themselves have moved.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE DealComment c SET c.team = :team WHERE c.team IS NULL AND c.deal.id IN "
            + "(SELECT d.id FROM Deal d WHERE d.team = :team AND d.agent = :agent)")
    int adoptTeamless(@Param("agent") User agent, @Param("team") Team team);
}
