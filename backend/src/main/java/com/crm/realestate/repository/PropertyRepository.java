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

import java.math.BigDecimal;
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

    @Query("SELECT p FROM Property p WHERE " +
           "(:status   IS NULL OR p.status = :status) AND " +
           "(:type     IS NULL OR p.type   = :type)   AND " +
           "(:city     IS NULL OR LOWER(p.city) = LOWER(:city)) AND " +
           "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.price <= :maxPrice)")
    List<Property> filterProperties(
            @Param("status")   PropertyStatus status,
            @Param("type")     PropertyType type,
            @Param("city")     String city,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice
    );

    @Query("SELECT p FROM Property p WHERE " +
           "LOWER(p.title)   LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(p.address) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(p.city)    LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Property> searchProperties(@Param("query") String query);
}
