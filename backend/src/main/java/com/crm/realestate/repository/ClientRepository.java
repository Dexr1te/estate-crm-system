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

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByAgentId(Long agentId);
    long countByAgentIdIn(List<Long> agentIds);

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByType(ClientType type);

    @EntityGraph(attributePaths = {"agent"})
    List<Client> findByAgentIdAndType(Long agentId, ClientType type);

    @Query("SELECT c FROM Client c WHERE " +
           "LOWER(c.fullName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(c.email)    LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "c.phone           LIKE CONCAT('%', :query, '%')")
    List<Client> searchClients(@Param("query") String query);

    boolean existsByEmail(String email);

    
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
                (
                    SELECT m2.scheduled_at
                    FROM meetings m2
                    WHERE m2.client_id = c.id
                    ORDER BY m2.scheduled_at DESC
                    LIMIT 1
                ) AS last_contact_at
            FROM clients c
            LEFT JOIN deals d ON d.client_id = c.id
            LEFT JOIN properties p ON p.id = d.property_id
            """, nativeQuery = true)
    List<Object[]> findClientsWithDetails();
}