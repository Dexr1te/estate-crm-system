package com.crm.realestate.repository;

import com.crm.realestate.entity.Property;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PropertyRepository extends JpaRepository<Property, Long>, JpaSpecificationExecutor<Property> {

    /*
     * The response mapper reads these lazy associations off every row, so without a fetch graph a
     * list of N costs one statement plus one per association per row. Harmless against a local
     * database, seconds against a hosted one in another region. All are to-one, so joining them
     * cannot duplicate rows.
     */

    @Override
    @EntityGraph(attributePaths = {"agent"})
    List<Property> findAll();

    @Override
    @EntityGraph(attributePaths = {"agent"})
    Optional<Property> findById(Long id);

    @Override
    @EntityGraph(attributePaths = {"agent"})
    List<Property> findAll(Specification<Property> spec);

    @Override
    @EntityGraph(attributePaths = {"agent"})
    List<Property> findAll(Specification<Property> spec, org.springframework.data.domain.Sort sort);

    @EntityGraph(attributePaths = {"agent"})
    List<Property> findByAgentId(Long agentId);

    @EntityGraph(attributePaths = {"agent"})
    List<Property> findByStatus(PropertyStatus status);

    @EntityGraph(attributePaths = {"agent"})
    List<Property> findByType(PropertyType type);

    @EntityGraph(attributePaths = {"agent"})
    List<Property> findByCity(String city);

    /** Moves this person's team-less propertys into their team — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Property p SET p.team = :team WHERE p.agent = :agent AND p.team IS NULL")
    int adoptTeamless(@Param("agent") com.crm.realestate.entity.User agent,
                      @Param("team") com.crm.realestate.entity.Team team);

    /** Hands propertys held in a team to a colleague — see RecordHandoverService. */
    @org.springframework.data.jpa.repository.Modifying(flushAutomatically = true)
    @Query("UPDATE Property p SET p.agent = :to WHERE p.agent = :from AND p.team = :team")
    int reassignInTeam(@Param("from") com.crm.realestate.entity.User from,
                       @Param("to") com.crm.realestate.entity.User to,
                       @Param("team") com.crm.realestate.entity.Team team);

    /** The seeder's own listings — see DemoDataSeeder for why the prefix is visible. */
    List<Property> findByTitleStartingWith(String prefix);

    /**
     * The agency's listings a price insight compares against: same city (case and surrounding
     * spaces ignored) and type, with a positive price and area, any number of rooms — the rooms are
     * narrowed in memory so widening costs no extra statement. Newest first, and the caller caps the
     * page. The team wall is written out rather than taken from ScopeService so that an admin, too,
     * only ever sees their own agency's figures here.
     */
    @Query("SELECT new com.crm.realestate.repository.projection.PriceComparableRow("
            + "p.id, p.title, p.price, p.areaSqm, p.rooms, p.status, p.createdAt) FROM Property p "
            + "WHERE ((:teamId IS NOT NULL AND p.team.id = :teamId) "
            + "    OR (:teamId IS NULL AND p.team IS NULL AND p.agent.id = :userId)) "
            + "AND LOWER(TRIM(p.city)) = :city AND p.type = :type "
            + "AND p.areaSqm > 0 AND p.price > 0 "
            + "AND (:excludeId IS NULL OR p.id <> :excludeId) "
            + "ORDER BY p.createdAt DESC, p.id DESC")
    List<com.crm.realestate.repository.projection.PriceComparableRow> priceComparables(
            @Param("teamId") Long teamId, @Param("userId") Long userId,
            @Param("city") String city, @Param("type") PropertyType type,
            @Param("excludeId") Long excludeId,
            org.springframework.data.domain.Pageable page);

}
