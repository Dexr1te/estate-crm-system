package com.crm.realestate.repository;

import com.crm.realestate.entity.Property;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PropertyRepository extends JpaRepository<Property, Long> {

    List<Property> findByAgentId(Long agentId);

    List<Property> findByStatus(PropertyStatus status);

    List<Property> findByType(PropertyType type);

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