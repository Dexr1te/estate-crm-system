package com.crm.realestate.specification;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.enums.DealStatus;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public final class DealSpecification {

    private DealSpecification() {}

    public static Specification<Deal> build(
            DealStatus status,
            Long clientId,
            Long agentId,
            Collection<Long> allowedAgentIds
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (clientId != null) {
                predicates.add(cb.equal(root.get("client").get("id"), clientId));
            }
            if (agentId != null) {
                predicates.add(cb.equal(root.get("agent").get("id"), agentId));
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
