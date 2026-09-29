package com.crm.realestate.repository;

import com.crm.realestate.entity.DealChecklistItem;
import com.crm.realestate.enums.ChecklistStage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface DealChecklistItemRepository extends JpaRepository<DealChecklistItem, Long> {

    /** The whole checklist of a deal with who ticked each line and what proves it, in one query. */
    @Query("SELECT i FROM DealChecklistItem i LEFT JOIN FETCH i.doneBy LEFT JOIN FETCH i.document "
            + "WHERE i.deal.id = :dealId")
    List<DealChecklistItem> findForDeal(@Param("dealId") Long dealId);

    boolean existsByDealId(Long dealId);

    @Query("SELECT COALESCE(MAX(i.position), -1) FROM DealChecklistItem i "
            + "WHERE i.deal.id = :dealId AND i.stage = :stage")
    int lastPosition(@Param("dealId") Long dealId, @Param("stage") ChecklistStage stage);

    /**
     * Rows of {@code [dealId, stage, required, total, done]} for the given deals, in one grouped
     * query however long the list is — {@code COUNT(doneAt)} counts only the ticked lines.
     */
    @Query("SELECT i.deal.id, i.stage, i.required, COUNT(i), COUNT(i.doneAt) FROM DealChecklistItem i "
            + "WHERE i.deal.id IN :dealIds GROUP BY i.deal.id, i.stage, i.required")
    List<Object[]> statsByDeals(@Param("dealIds") Collection<Long> dealIds);
}
