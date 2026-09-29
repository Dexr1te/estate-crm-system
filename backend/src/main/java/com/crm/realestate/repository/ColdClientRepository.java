package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Clients going cold — see {@link com.crm.realestate.service.ColdClientService} for the rule.
 *
 * <p>The whole question is one statement, however large the agency: silence, the open-task check,
 * the best open deal and the number of current matches are correlated subqueries on indexed
 * columns, evaluated only for clients that already passed the cheap filters (visible, older than
 * the threshold, nothing logged since it, nothing booked). Matching runs inside the database with
 * the same rules as {@code MatchSpecification.listingsFor}, and only for buyers who stated a
 * requirement — the per-client, per-request matching an endpoint like this would otherwise do is
 * exactly what it must not.
 *
 * <p>Scope is {@code ScopeService.visibleTo} spelled out in SQL, as in
 * {@link ClientRepository#findClientsWithDetails}: -1 stands for "no team" or "no narrowing".
 */
public interface ColdClientRepository extends org.springframework.data.repository.Repository<Client, Long> {

    String COLD = """
            SELECT * FROM (
                SELECT
                    c.id, c.full_name, c.phone, c.type, c.source, c.agent_id,
                    u.full_name AS agent_name,
                    c.created_at,
                    GREATEST(
                        (SELECT MAX(a.occurred_at) FROM client_activities a WHERE a.client_id = c.id),
                        (SELECT MAX(m.scheduled_at) FROM meetings m
                          WHERE m.client_id = c.id AND m.scheduled_at <= :now)
                    ) AS last_contact_at,
                    (SELECT MAX(CASE d.status WHEN 'NEGOTIATION' THEN 2 ELSE 1 END) FROM deals d
                      WHERE d.client_id = c.id AND d.status IN ('LEAD', 'NEGOTIATION')) AS deal_rank,
                    (SELECT d.title FROM deals d
                      WHERE d.client_id = c.id AND d.status IN ('LEAD', 'NEGOTIATION')
                      ORDER BY CASE d.status WHEN 'NEGOTIATION' THEN 0 ELSE 1 END, d.id DESC
                      LIMIT 1) AS deal_title,
                    CASE WHEN c.type = 'BUYER' AND (c.wanted_type IS NOT NULL OR c.wanted_city IS NOT NULL
                            OR c.budget_min IS NOT NULL OR c.budget_max IS NOT NULL
                            OR c.min_rooms IS NOT NULL OR c.min_area_sqm IS NOT NULL)
                    THEN (
                        SELECT COUNT(*) FROM properties p
                        WHERE p.status = 'AVAILABLE'
                          AND (p.team_id = c.team_id
                               OR (c.team_id IS NULL AND p.team_id IS NULL AND p.agent_id = c.agent_id))
                          AND (c.wanted_type IS NULL OR p.type = c.wanted_type)
                          AND (c.wanted_city IS NULL OR LOWER(p.city) = LOWER(TRIM(c.wanted_city)))
                          AND (c.budget_min IS NULL OR p.price >= c.budget_min)
                          AND (c.budget_max IS NULL OR p.price <= c.budget_max * 1.10)
                          AND (c.min_rooms IS NULL OR p.rooms >= c.min_rooms)
                          AND (c.min_area_sqm IS NULL OR p.area_sqm >= c.min_area_sqm)
                          AND NOT EXISTS (SELECT 1 FROM meetings r
                                           WHERE r.client_id = c.id AND r.property_id = p.id
                                             AND r.outcome = 'REJECTED')
                    ) ELSE 0 END AS match_count
                FROM clients c
                LEFT JOIN users u ON u.id = c.agent_id
                WHERE (:everyone = TRUE
                       OR (:teamId = -1 AND c.team_id IS NULL AND c.agent_id = :userId)
                       OR (c.team_id = :teamId AND (:wholeTeam = TRUE OR c.agent_id = :userId)))
                  AND (:agentId = -1 OR c.agent_id = :agentId)
                  AND (:narrowTeamId = -1 OR c.team_id = :narrowTeamId)
                  AND c.created_at <= :cutoff
                  AND NOT EXISTS (SELECT 1 FROM client_activities a
                                   WHERE a.client_id = c.id AND a.occurred_at > :cutoff)
                  AND NOT EXISTS (SELECT 1 FROM meetings m
                                   WHERE m.client_id = c.id AND m.scheduled_at > :cutoff)
                  AND NOT EXISTS (SELECT 1 FROM tasks t
                                   WHERE t.client_id = c.id AND t.completed_at IS NULL AND t.due_at > :now)
            ) x
            WHERE x.deal_rank IS NOT NULL OR x.source = 'PUBLIC_LINK' OR x.match_count > 0
            """;

    /**
     * Row: id, full_name, phone, type, source, agent_id, agent_name, created_at, last_contact_at,
     * deal_rank (2 negotiation, 1 lead, null none), deal_title, match_count. Most valuable first,
     * then the longest silence.
     */
    @Query(value = COLD + """
            ORDER BY CASE WHEN x.deal_rank = 2 THEN 0 WHEN x.deal_rank = 1 THEN 1
                          WHEN x.match_count > 0 THEN 2 ELSE 3 END,
                     COALESCE(x.last_contact_at, x.created_at) ASC,
                     x.id ASC
            LIMIT :limit
            """, nativeQuery = true)
    List<Object[]> findCold(@Param("everyone") boolean everyone,
                            @Param("teamId") long teamId,
                            @Param("userId") long userId,
                            @Param("wholeTeam") boolean wholeTeam,
                            @Param("agentId") long agentId,
                            @Param("narrowTeamId") long narrowTeamId,
                            @Param("now") LocalDateTime now,
                            @Param("cutoff") LocalDateTime cutoff,
                            @Param("limit") int limit);

    @Query(value = "SELECT COUNT(*) FROM (" + COLD + ") cold", nativeQuery = true)
    long countCold(@Param("everyone") boolean everyone,
                   @Param("teamId") long teamId,
                   @Param("userId") long userId,
                   @Param("wholeTeam") boolean wholeTeam,
                   @Param("agentId") long agentId,
                   @Param("narrowTeamId") long narrowTeamId,
                   @Param("now") LocalDateTime now,
                   @Param("cutoff") LocalDateTime cutoff);
}
