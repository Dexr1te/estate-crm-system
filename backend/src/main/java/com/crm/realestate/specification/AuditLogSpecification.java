package com.crm.realestate.specification;

import com.crm.realestate.entity.AuditLog;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public final class AuditLogSpecification {

    private AuditLogSpecification() {}

    public static Specification<AuditLog> build(
            Long actorId,
            String entityType,
            LocalDateTime from,
            LocalDateTime to
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (actorId != null) {
                predicates.add(cb.equal(root.get("actor").get("id"), actorId));
            }
            if (entityType != null && !entityType.isBlank()) {
                predicates.add(cb.equal(root.get("entityType"), entityType));
            }
            if (from != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), from));
            }
            if (to != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), to));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
