package com.crm.realestate.specification;

import com.crm.realestate.entity.Property;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public final class PropertySpecification {

    private PropertySpecification() {}

    public static Specification<Property> build(
            PropertyStatus status,
            PropertyType type,
            String city,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Integer rooms,
            Long agentId,
            String search
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (type != null) {
                predicates.add(cb.equal(root.get("type"), type));
            }
            if (city != null && !city.isBlank()) {
                predicates.add(cb.equal(cb.lower(root.get("city")), city.trim().toLowerCase()));
            }
            if (minPrice != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("price"), minPrice));
            }
            if (maxPrice != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("price"), maxPrice));
            }
            if (rooms != null) {
                predicates.add(cb.equal(root.get("rooms"), rooms));
            }
            if (agentId != null) {
                predicates.add(cb.equal(root.get("agent").get("id"), agentId));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("title")), like),
                        cb.like(cb.lower(root.get("address")), like),
                        cb.like(cb.lower(root.get("city")), like)
                ));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    /**
     * Listings whose pin falls inside the rectangle the map is showing, edges included. A listing
     * with no pin is never inside. When the west edge is east of the east edge the rectangle
     * crosses the antimeridian, and the longitudes wrap.
     */
    public static Specification<Property> within(MapBounds bounds) {
        return (root, query, cb) -> {
            if (bounds == null) {
                return cb.conjunction();
            }
            Predicate lat = cb.between(root.get("latitude"), bounds.minLat(), bounds.maxLat());
            Predicate lng = bounds.minLng() <= bounds.maxLng()
                    ? cb.between(root.get("longitude"), bounds.minLng(), bounds.maxLng())
                    : cb.or(cb.greaterThanOrEqualTo(root.get("longitude"), bounds.minLng()),
                            cb.lessThanOrEqualTo(root.get("longitude"), bounds.maxLng()));
            return cb.and(lat, lng);
        };
    }

    /** Listings that have a pin (true), that have none (false), or all of them (null). */
    public static Specification<Property> hasLocation(Boolean located) {
        return (root, query, cb) -> {
            if (located == null) {
                return cb.conjunction();
            }
            return located
                    ? cb.and(cb.isNotNull(root.get("latitude")), cb.isNotNull(root.get("longitude")))
                    : cb.or(cb.isNull(root.get("latitude")), cb.isNull(root.get("longitude")));
        };
    }
}
