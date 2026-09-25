package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import com.crm.realestate.enums.ClientType;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long>, org.springframework.data.jpa.repository.JpaSpecificationExecutor<Client> {

    /*
     * The response mapper reads these lazy associations off every row, so without a fetch graph a
     * list of N costs one statement plus one per association per row. Harmless against a local
     * database, seconds against a hosted one in another region. All are to-one, so joining them
     * cannot duplicate rows.
     */

    @Override
    @EntityGraph(attributePaths = {"agent"})
    List<Client> findAll();

    @Override
    @EntityGraph(attributePaths = {"agent"})
    Optional<Client> findById(Long id);

    @Override
    @EntityGraph(attributePaths = {"agent"})
    List<Client> findAll(org.springframework.data.jpa.domain.Specification<Client> spec);

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByAgentId(Long agentId);

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByType(ClientType type);

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByAgentIdAndType(Long agentId, ClientType type);

    /** Client addresses are unique per agency; a null team is matched as IS NULL. */
    boolean existsByEmailAndTeam(String email, com.crm.realestate.entity.Team team);

    long countByTeamId(Long teamId);

    /** Moves this person's team-less clients into their team — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Client c SET c.team = :team WHERE c.agent = :agent AND c.team IS NULL")
    int adoptTeamless(@Param("agent") com.crm.realestate.entity.User agent,
                      @Param("team") com.crm.realestate.entity.Team team);

    /** Hands clients held in a team to a colleague — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Client c SET c.agent = :to WHERE c.agent = :from AND c.team = :team")
    int reassignInTeam(@Param("from") com.crm.realestate.entity.User from,
                       @Param("to") com.crm.realestate.entity.User to,
                       @Param("team") com.crm.realestate.entity.Team team);

    /** Demo records carry a reserved email domain, which is how the seeder finds its own again. */
    List<Client> findByEmailEndingWithIgnoreCase(String suffix);

    /*
     * The scope rule from ScopeService.visibleTo, spelled out in SQL because this one is native.
     * A person with no team passes -1, which no row carries.
     *
     * The last contact is the latest logged touch or the latest meeting that has already happened,
     * whichever is later — a viewing booked for next week is not contact yet. GREATEST skips a
     * NULL in PostgreSQL (and H2), so a client with only one kind still gets a date. Both are
     * correlated subqueries on indexed columns, so the list stays one statement however long it is.
     */
    @Query(value = """
            SELECT
                c.id,
                c.full_name,
                c.phone,
                c.email,
                c.agent_id,
                d.status,
                d.budget,
                p.title AS property_title,
                (
                    SELECT m.scheduled_at
                    FROM meetings m
                    WHERE m.client_id = c.id
                      AND m.completed = false
                    ORDER BY m.scheduled_at ASC
                    LIMIT 1
                ) AS next_meeting_at,
                GREATEST(
                    (
                        SELECT MAX(a.occurred_at)
                        FROM client_activities a
                        WHERE a.client_id = c.id
                    ),
                    (
                        SELECT MAX(m2.scheduled_at)
                        FROM meetings m2
                        WHERE m2.client_id = c.id
                          AND m2.scheduled_at <= :now
                    )
                ) AS last_contact_at
            FROM clients c
            LEFT JOIN deals d ON d.client_id = c.id
            LEFT JOIN properties p ON p.id = d.property_id
            WHERE :everyone = TRUE
               OR (:teamId = -1 AND c.team_id IS NULL AND c.agent_id = :userId)
               OR (c.team_id = :teamId AND (:wholeTeam = TRUE OR c.agent_id = :userId))
            """, nativeQuery = true)
    List<Object[]> findClientsWithDetails(
            @Param("everyone") boolean everyone,
            @Param("teamId") long teamId,
            @Param("userId") long userId,
            @Param("wholeTeam") boolean wholeTeam,
            @Param("now") java.time.LocalDateTime now);
}