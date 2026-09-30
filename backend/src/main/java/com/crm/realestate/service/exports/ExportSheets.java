package com.crm.realestate.service.exports;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.service.ScopeService;
import com.crm.realestate.specification.ClientSpecification;
import com.crm.realestate.specification.DealSpecification;
import com.crm.realestate.specification.PropertySpecification;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Locale;

/**
 * Reads the rows of an export a page at a time, keyed on the id, and hands each page to
 * {@link ExportColumns}. Every association a row reads is fetched with it, so a page costs one
 * statement (two for clients and listings, whose tags and public-link views are read per page) however many rows it
 * holds, and the session is cleared between pages so fifty thousand rows are never all in memory.
 */
@Component
@RequiredArgsConstructor
class ExportSheets {

    static final int PAGE = 500;

    private final EntityManager entityManager;
    private final ScopeService scopeService;
    private final ExportColumns columns;

    /** What to export, for whom, narrowed how. */
    record Query(ExportKind kind, User user, ExportFilters filters) {
    }

    long count(Query query) {
        return switch (query.kind()) {
            case CLIENTS -> count(Client.class, clients(query));
            case PROPERTIES -> count(Property.class, properties(query));
            case DEALS -> count(Deal.class, deals(query));
        };
    }

    void write(Query query, CsvWriter csv, int language) throws IOException {
        csv.row(columns.headings(query.kind(), language));
        switch (query.kind()) {
            case CLIENTS -> {
                Specification<Client> spec = clients(query);
                long after = 0;
                for (List<Client> page; !(page = page(Client.class, spec, after, "agent")).isEmpty(); ) {
                    var tags = columns.tags(page);
                    for (Client client : page) csv.row(columns.client(client, tags, csv, language));
                    after = page.get(page.size() - 1).getId();
                    entityManager.clear();
                }
            }
            case PROPERTIES -> {
                Specification<Property> spec = properties(query);
                long after = 0;
                for (List<Property> page; !(page = page(Property.class, spec, after, "agent")).isEmpty(); ) {
                    var views = columns.linkViews(page);
                    for (Property property : page) csv.row(columns.property(property, views, csv, language));
                    after = page.get(page.size() - 1).getId();
                    entityManager.clear();
                }
            }
            case DEALS -> {
                Specification<Deal> spec = deals(query);
                long after = 0;
                for (List<Deal> page; !(page = page(Deal.class, spec, after, "agent", "client", "property")).isEmpty(); ) {
                    for (Deal deal : page) csv.row(columns.deal(deal, csv, language));
                    after = page.get(page.size() - 1).getId();
                    entityManager.clear();
                }
            }
        }
        csv.flush();
    }

    // Which rows --------------------------------------------------------------------------------

    private Specification<Client> clients(Query q) {
        ExportFilters f = q.filters();
        ClientSource source = parse(ClientSource.class, f.source());
        Specification<Client> bySource = (root, cq, cb) ->
                source == null ? cb.conjunction() : cb.equal(root.get("source"), source);
        return ClientSpecification.build(parse(ClientType.class, f.type()), f.agentId(),
                        f.createdFrom(), f.createdTo(), f.search(), f.tags())
                .and(bySource)
                .and(scopeService.visibleTo(q.user()))
                .and(inAgency(q.user()));
    }

    private Specification<Property> properties(Query q) {
        ExportFilters f = q.filters();
        // The listing list shows the whole agency's stock to everyone in it; so does its export.
        return PropertySpecification.build(parse(PropertyStatus.class, f.status()),
                        parse(PropertyType.class, f.type()), f.city(), f.minPrice(), f.maxPrice(),
                        f.rooms(), f.agentId(), f.search())
                .and(scopeService.visibleToTeam(q.user()))
                .and(inAgency(q.user()));
    }

    private Specification<Deal> deals(Query q) {
        ExportFilters f = q.filters();
        Specification<Deal> extra = (root, cq, cb) -> {
            Predicate p = cb.conjunction();
            if (f.search() != null && !f.search().isBlank()) {
                p = cb.and(p, cb.like(cb.lower(root.get("title")),
                        "%" + f.search().trim().toLowerCase(Locale.ROOT) + "%"));
            }
            p = between(cb, p, root, "createdAt", f.createdFrom(), f.createdTo());
            return between(cb, p, root, "closedAt", f.closedFrom(), f.closedTo());
        };
        return DealSpecification.build(parse(DealStatus.class, f.status()), null, f.agentId())
                .and(extra)
                .and(scopeService.visibleTo(q.user()))
                .and(inAgency(q.user()));
    }

    private static Predicate between(CriteriaBuilder cb, Predicate p, Root<Deal> root, String field,
                                     LocalDate from, LocalDate to) {
        if (from != null) p = cb.and(p, cb.greaterThanOrEqualTo(root.get(field), from.atStartOfDay()));
        if (to != null) p = cb.and(p, cb.lessThanOrEqualTo(root.get(field), to.atTime(LocalTime.MAX)));
        return p;
    }

    /** Never another agency's records — not even for an admin, who otherwise sees them all. */
    private static <T> Specification<T> inAgency(User user) {
        Long teamId = user.getTeam().getId();
        return (root, cq, cb) -> cb.equal(root.get("team").get("id"), teamId);
    }

    private static <E extends Enum<E>> E parse(Class<E> type, String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Enum.valueOf(type, value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EXPORT_BAD_FILTER",
                    "Unknown " + type.getSimpleName() + ": " + value);
        }
    }

    // Reading -----------------------------------------------------------------------------------

    private <T> long count(Class<T> type, Specification<T> spec) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> q = cb.createQuery(Long.class);
        Root<T> root = q.from(type);
        q.select(cb.count(root)).where(spec.toPredicate(root, q, cb));
        return entityManager.createQuery(q).getSingleResult();
    }

    private <T> List<T> page(Class<T> type, Specification<T> spec, long afterId, String... fetch) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<T> q = cb.createQuery(type);
        Root<T> root = q.from(type);
        for (String association : fetch) {
            root.fetch(association, JoinType.LEFT);
        }
        q.select(root)
                .where(cb.and(spec.toPredicate(root, q, cb), cb.greaterThan(root.get("id"), afterId)))
                .orderBy(cb.asc(root.get("id")));
        return entityManager.createQuery(q).setMaxResults(PAGE).getResultList();
    }
}
