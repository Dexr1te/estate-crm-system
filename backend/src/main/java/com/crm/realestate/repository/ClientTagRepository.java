package com.crm.realestate.repository;

import com.crm.realestate.entity.ClientTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface ClientTagRepository extends JpaRepository<ClientTag, Long> {

    /** The agency's tags with these keys; a null team means the team-less vocabulary. */
    @Query("SELECT t FROM ClientTag t WHERE t.nameKey IN :keys "
            + "AND ((:teamId IS NULL AND t.team IS NULL) OR t.team.id = :teamId)")
    List<ClientTag> findByTeamAndKeys(@Param("teamId") Long teamId, @Param("keys") Collection<String> keys);

    /**
     * Rows of {@code [name, count]}: the agency's tags that some client carries, and how many do,
     * the most used first. One grouped query.
     */
    @Query("SELECT t.name, COUNT(c.id) FROM Client c JOIN c.tags t WHERE t.team.id = :teamId "
            + "GROUP BY t.id, t.name, t.nameKey ORDER BY COUNT(c.id) DESC, t.nameKey ASC")
    List<Object[]> usageByTeam(@Param("teamId") Long teamId);

    /** Rows of {@code [clientId, name]} for these clients, in name order — one statement a page. */
    @Query("SELECT c.id, t.name FROM Client c JOIN c.tags t WHERE c.id IN :clientIds ORDER BY t.nameKey")
    List<Object[]> namesByClients(@Param("clientIds") Collection<Long> clientIds);

    /**
     * Forgets the agency's tags that no client carries any more, so the next person to type one
     * chooses its casing again. The team-less vocabulary is swept when {@code teamId} is null.
     */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM ClientTag t WHERE ((:teamId IS NULL AND t.team IS NULL) OR t.team.id = :teamId) "
            + "AND NOT EXISTS (SELECT 1 FROM Client c JOIN c.tags x WHERE x.id = t.id)")
    int deleteUnused(@Param("teamId") Long teamId);
}
