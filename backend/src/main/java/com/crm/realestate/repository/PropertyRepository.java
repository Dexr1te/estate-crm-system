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

}
