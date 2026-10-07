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
     * Client, property, agent and landlord are read off every deal when it is mapped to a response, and all
     * four are lazy. Fetching them with the deal turns a list of N into one statement instead of
     * one plus four per row — invisible against a local database, seconds against a hosted one in
     * another region. All four are to-one associations, so joining them cannot duplicate rows.
     */

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    List<Deal> findAll();

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    List<Deal> findAll(Specification<Deal> spec);

    @Override
    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    Optional<Deal> findById(Long id);

    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
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

    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    List<Deal> findByClientId(Long clientId);

    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    List<Deal> findByStatus(DealStatus status);

    /** Lets the demo seeder leave alone a listing some real deal has since been attached to. */
    boolean existsByPropertyId(Long propertyId);

    @EntityGraph(attributePaths = {"client", "property", "agent", "landlord"})
    List<Deal> findByAgentIdAndStatus(Long agentId, DealStatus status);

    @Query("SELECT d.status, COUNT(d) FROM Deal d " +
           "WHERE d.agent.id = :agentId GROUP BY d.status")
    List<Object[]> countByStatusForAgent(@Param("agentId") Long agentId);

    @Query("SELECT d.status, COUNT(d) FROM Deal d GROUP BY d.status")
    List<Object[]> countByStatus();

    /** Moves everything this client had onto another card — see ClientService.merge. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.client = :target WHERE d.client = :source")
    int moveToClient(@Param("source") com.crm.realestate.entity.Client source,
                     @Param("target") com.crm.realestate.entity.Client target);

    /**
     * Notes that the agent has been told this deal's lease ends on {@code end}; 0 when somebody
     * already had — the next hour's run, or another server at the same moment. See LeaseEndNotifier.
     */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.leaseRemindedFor = :end WHERE d.id = :id AND d.leaseEnd = :end "
            + "AND (d.leaseRemindedFor IS NULL OR d.leaseRemindedFor <> :end)")
    int markLeaseReminded(@Param("id") Long id, @Param("end") java.time.LocalDate end);

    /** Moves the leases this client lets onto another card — see ClientDuplicateService.merge. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.landlord = :target WHERE d.landlord = :source")
    int moveLandlord(@Param("source") com.crm.realestate.entity.Client source,
                     @Param("target") com.crm.realestate.entity.Client target);

    /** After a merge a client may be both sides of one lease; it stays their tenancy, landlord unknown. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Deal d SET d.landlord = NULL WHERE d.landlord = :client AND d.client = :client")
    int forgetSelfLandlord(@Param("client") com.crm.realestate.entity.Client client);

    /** Won sales on these listings — what each actually sold for, and when. Rents are left out. */
    @Query("SELECT new com.crm.realestate.repository.projection.ClosedSaleRow("
            + "d.property.id, d.dealPrice, d.closedAt) FROM Deal d "
            + "WHERE d.status = com.crm.realestate.enums.DealStatus.CLOSED_WON "
            // A let flat was not sold: a rent says nothing about what the place is worth.
            + "AND d.kind = com.crm.realestate.enums.DealKind.SALE "
            + "AND d.property.id IN :propertyIds")
    List<com.crm.realestate.repository.projection.ClosedSaleRow> closedSalesOf(
            @Param("propertyIds") java.util.Collection<Long> propertyIds);

}
