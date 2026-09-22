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

    /**
     * Every showing this buyer has been to, whoever booked it.
     *
     * <p>Not narrowed to the asking agent on purpose: the buyer turned the flat down, not the
     * agent, so a colleague's showing has to count or matching would offer it again.
     */
    List<Meeting> findByClientIdAndPropertyIdNotNull(Long clientId);

    /** The same question from the listing's side: who has been shown it, and what did they say. */
    List<Meeting> findByPropertyId(Long propertyId);

    long countByTeamIdAndCompletedFalseAndScheduledAtAfter(Long teamId, LocalDateTime now);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAll(Specification<Meeting> spec, org.springframework.data.domain.Sort sort);

    /** Moves this person's team-less meetings into their team — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Meeting m SET m.team = :team WHERE m.agent = :agent AND m.team IS NULL")
    int adoptTeamless(@Param("agent") com.crm.realestate.entity.User agent,
                      @Param("team") com.crm.realestate.entity.Team team);

    /** Hands meetings held in a team to a colleague — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Meeting m SET m.agent = :to WHERE m.agent = :from AND m.team = :team")
    int reassignInTeam(@Param("from") com.crm.realestate.entity.User from,
                       @Param("to") com.crm.realestate.entity.User to,
                       @Param("team") com.crm.realestate.entity.Team team);

    long countByAgentIdInAndScheduledAtAfter(List<Long> agentIds, LocalDateTime now);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByClientId(Long clientId);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByDealId(Long dealId);

    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findByAgentIdAndCompleted(Long agentId, boolean completed);

    @Query("SELECT m FROM Meeting m WHERE m.completed = false " +
           "AND m.scheduledAt > :now ORDER BY m.scheduledAt ASC")
    @EntityGraph(attributePaths = {"agent", "client", "deal"})
    List<Meeting> findAllUpcoming(@Param("now") LocalDateTime now);
}