package com.crm.realestate.repository;

import com.crm.realestate.entity.ChecklistTemplateItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface ChecklistTemplateItemRepository extends JpaRepository<ChecklistTemplateItem, Long> {

    List<ChecklistTemplateItem> findByTeamId(Long teamId);

    boolean existsByTeamId(Long teamId);

    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM ChecklistTemplateItem i WHERE i.team.id = :teamId")
    int deleteByTeam(@Param("teamId") Long teamId);

    /**
     * Claims the right to write the default template: 1 for the one caller that flips the flag,
     * 0 for everyone after — so two first reads at once cannot both seed it.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Team t SET t.checklistTemplateSeeded = true "
            + "WHERE t.id = :teamId AND t.checklistTemplateSeeded = false")
    int markSeeded(@Param("teamId") Long teamId);

    /** Of the given teams, the ones whose template has been written — possibly empty on purpose. */
    @Query("SELECT t.id FROM Team t WHERE t.id IN :teamIds AND t.checklistTemplateSeeded = true")
    List<Long> seededAmong(@Param("teamIds") Collection<Long> teamIds);

    /** Rows of {@code [teamId, stage, required, count]}, in one grouped query. */
    @Query("SELECT i.team.id, i.stage, i.required, COUNT(i) FROM ChecklistTemplateItem i "
            + "WHERE i.team.id IN :teamIds GROUP BY i.team.id, i.stage, i.required")
    List<Object[]> statsByTeams(@Param("teamIds") Collection<Long> teamIds);
}
