package com.crm.realestate.repository;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.enums.DealStatus;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository

public interface DealRepository extends JpaRepository<Deal, Long>, JpaSpecificationExecutor<Deal> {

    /*
     * Client, property and agent are read off every deal when it is mapped to a response, and all
     * three are lazy. Fetching them with the deal turns a list of N into one statement instead of
     * one plus three per row — invisible against a local database, seconds against a hosted one in
     * another region. All three are to-one associations, so joining them cannot duplicate rows.
     */

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findAll();

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findAll(Specification<Deal> spec);

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent"})
    Optional<Deal> findById(Long id);

    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findByAgentId(Long agentId);

    long countByTeamId(Long teamId);

    long countByTeamIdAndStatusNotIn(Long teamId, List<DealStatus> statuses);

    /** Moves this person's team-less deals into their team — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.team = :team WHERE d.agent = :agent AND d.team IS NULL")
    int adoptTeamless(@Param("agent") com.crm.realestate.entity.User agent,
                      @Param("team") com.crm.realestate.entity.Team team);

    /** Hands deals held in a team to a colleague — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.agent = :to WHERE d.agent = :from AND d.team = :team")
    int reassignInTeam(@Param("from") com.crm.realestate.entity.User from,
                       @Param("to") com.crm.realestate.entity.User to,
                       @Param("team") com.crm.realestate.entity.Team team);

    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findByClientId(Long clientId);

    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findByStatus(DealStatus status);

    /** Lets the demo seeder leave alone a listing some real deal has since been attached to. */
    boolean existsByPropertyId(Long propertyId);

    @EntityGraph(attributePaths = {"client", "property", "agent"})
    List<Deal> findByAgentIdAndStatus(Long agentId, DealStatus status);

    // для аналитики количество сделок по статусам у агента
    @Query("SELECT d.status, COUNT(d) FROM Deal d " +
           "WHERE d.agent.id = :agentId GROUP BY d.status")
    List<Object[]> countByStatusForAgent(@Param("agentId") Long agentId);

    // общая сводка по всем сделкам
    @Query("SELECT d.status, COUNT(d) FROM Deal d GROUP BY d.status")
    List<Object[]> countByStatus();

    /** Moves everything this client had onto another card — see ClientService.merge. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.client = :target WHERE d.client = :source")
    int moveToClient(@Param("source") com.crm.realestate.entity.Client source,
                     @Param("target") com.crm.realestate.entity.Client target);
}
