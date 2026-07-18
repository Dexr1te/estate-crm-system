package com.crm.realestate.specification;

import com.crm.realestate.entity.Meeting;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public final class MeetingSpecification {

    private MeetingSpecification() {}

    public static Specification<Meeting> build(
            Long agentId,
            Long clientId,
            Long dealId,
            Collection<Long> allowedAgentIds
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (agentId != null) {
                predicates.add(cb.equal(root.get("agent").get("id"), agentId));
            }
            if (clientId != null) {
                predicates.add(cb.equal(root.get("client").get("id"), clientId));
            }
            if (dealId != null) {
                predicates.add(cb.equal(root.get("deal").get("id"), dealId));
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
