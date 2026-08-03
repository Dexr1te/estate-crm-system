package com.crm.realestate.repository;

import com.crm.realestate.entity.Meeting;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository

public interface MeetingRepository extends JpaRepository<Meeting, Long>, JpaSpecificationExecutor<Meeting> {

    /*
     * The response mapper reads these lazy associations off every row, so without a fetch graph a
     * list of N costs one statement plus one per association per row. Harmless against a local
     * database, seconds against a hosted one in another region. All are to-one, so joining them
     * cannot duplicate rows.
     */

    @Override
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAll();

    @Override
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    Optional<Meeting> findById(Long id);

    @Override
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAll(Specification<Meeting> spec);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByAgentId(Long agentId);
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByAgentIdIn(List<Long> agentIds);
    long countByAgentIdIn(List<Long> agentIds);

    long countByScheduledAtAfter(LocalDateTime now);

    long countByAgentIdInAndScheduledAtAfter(List<Long> agentIds, LocalDateTime now);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByClientId(Long clientId);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByDealId(Long dealId);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByAgentIdAndCompleted(Long agentId, boolean completed);

    @Query("SELECT m FROM Meeting m WHERE m.agent.id = :agentId " +
           "AND m.scheduledAt BETWEEN :from AND :to ORDER BY m.scheduledAt ASC")
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findUpcomingByAgent(
            @Param("agentId") Long agentId,
            @Param("from")    LocalDateTime from,
            @Param("to")      LocalDateTime to
    );

    @Query("SELECT m FROM Meeting m WHERE m.agent.id IN :agentIds " +
           "AND m.completed = false " +
           "AND m.scheduledAt > :now ORDER BY m.scheduledAt ASC")
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAllUpcomingForAgents(
            @Param("agentIds") List<Long> agentIds,
            @Param("now") LocalDateTime now
    );

    @Query("SELECT m FROM Meeting m WHERE m.completed = false " +
           "AND m.scheduledAt > :now ORDER BY m.scheduledAt ASC")
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAllUpcoming(@Param("now") LocalDateTime now);
}