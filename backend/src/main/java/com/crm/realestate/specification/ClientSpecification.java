package com.crm.realestate.specification;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientTag;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.service.ClientTags;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public final class ClientSpecification {

    private ClientSpecification() {}

    public static Specification<Client> build(
            ClientType type,
            Long agentId,
            LocalDate createdFrom,
            LocalDate createdTo,
            String search
    ) {
        return build(type, agentId, createdFrom, createdTo, search, null);
    }

    /**
     * As above, and carrying every one of {@code tags}: a client tagged "investor" and "urgent"
     * answers a filter on both, one tagged only "investor" does not. Tags are compared as
     * {@link ClientTags} compares them, so the filter may be typed in any case.
     */
    public static Specification<Client> build(
            ClientType type,
            Long agentId,
            LocalDate createdFrom,
            LocalDate createdTo,
            String search,
            Collection<String> tags
    ) {
        List<String> tagKeys = ClientTags.normalise(tags).stream().map(ClientTags::key).toList();
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

            // One EXISTS per tag rather than a join, so a client is never returned twice and a
            // page's count stays true.
            for (String key : tagKeys) {
                Subquery<Long> carrying = query.subquery(Long.class);
                Root<Client> same = carrying.from(Client.class);
                Join<Client, ClientTag> tag = same.join("tags");
                carrying.select(same.get("id"))
                        .where(cb.equal(same.get("id"), root.get("id")), cb.equal(tag.get("nameKey"), key));
                predicates.add(cb.exists(carrying));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
