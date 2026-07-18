package com.crm.realestate.specification;

import com.crm.realestate.entity.Client;
import com.crm.realestate.enums.ClientType;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public final class ClientSpecification {

    private ClientSpecification() {}

    public static Specification<Client> build(
            ClientType type,
            Long agentId,
            LocalDate createdFrom,
            LocalDate createdTo,
            String search,
            java.util.Collection<Long> allowedAgentIds
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (type != null) {
                predicates.add(cb.equal(root.get("type"), type));
            }

            if (agentId != null) {
                predicates.add(cb.equal(root.get("agent").get("id"), agentId));
            }

            if (createdFrom != null) {
                LocalDateTime from = createdFrom.atStartOfDay();
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), from));
            }

            if (createdTo != null) {
                LocalDateTime to = createdTo.atTime(LocalTime.MAX);
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), to));
            }

            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("fullName")), like),
                        cb.like(cb.lower(root.get("email")), like),
                        cb.like(root.get("phone"), like)
                ));
            }

            if (allowedAgentIds != null) {
                if (allowedAgentIds.isEmpty()) {
                    return cb.disjunction();
                }
                predicates.add(root.get("agent").get("id").in(allowedAgentIds));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
