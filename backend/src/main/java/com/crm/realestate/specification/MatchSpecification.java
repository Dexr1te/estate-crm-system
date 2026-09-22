package com.crm.realestate.specification;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyStatus;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * The two halves of the same question: which listings answer a buyer's
 * requirements, and which buyers a listing answers.
 *
 * <p>Both read the requirement columns the same way. A requirement left empty is
 * not a requirement, so it drops out of the query rather than matching nothing —
 * a buyer who named only a ceiling should see everything under it. A ceiling is
 * the one requirement that bends: {@link #OVER_BUDGET_TOLERANCE} lets a listing
 * a little above it through, and the caller marks those rather than hiding them.
 */
public final class MatchSpecification {

    /** How far above a stated ceiling a listing may sit and still be worth showing. */
    public static final BigDecimal OVER_BUDGET_TOLERANCE = new BigDecimal("1.10");

    private MatchSpecification() {}

    /** Listings for sale that fit [buyer]. Empty requirements match nothing — see the class note. */
    public static Specification<Property> listingsFor(Client buyer) {
        return (root, query, cb) -> {
            if (!hasAnyRequirement(buyer)) {
                return cb.disjunction();
            }

            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("status"), PropertyStatus.AVAILABLE));

            if (buyer.getWantedType() != null) {
                predicates.add(cb.equal(root.get("type"), buyer.getWantedType()));
            }
            if (isStated(buyer.getWantedCity())) {
                predicates.add(cb.equal(cb.lower(root.get("city")),
                        buyer.getWantedCity().trim().toLowerCase()));
            }
            if (buyer.getBudgetMin() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("price"), buyer.getBudgetMin()));
            }
            if (buyer.getBudgetMax() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("price"), ceiling(buyer.getBudgetMax())));
            }
            if (buyer.getMinRooms() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("rooms"), buyer.getMinRooms()));
            }
            if (buyer.getMinAreaSqm() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("areaSqm"), buyer.getMinAreaSqm()));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    /** Buyers whose requirements [listing] answers. */
    public static Specification<Client> buyersFor(Property listing) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("type"), ClientType.BUYER));

            // A buyer who has stated nothing is not looking for this in particular.
            predicates.add(cb.or(
                    root.get("wantedType").isNotNull(),
                    root.get("wantedCity").isNotNull(),
                    root.get("budgetMin").isNotNull(),
                    root.get("budgetMax").isNotNull(),
                    root.get("minRooms").isNotNull(),
                    root.get("minAreaSqm").isNotNull()));

            predicates.add(orUnstated(cb, root.get("wantedType"),
                    cb.equal(root.get("wantedType"), listing.getType())));

            if (isStated(listing.getCity())) {
                predicates.add(orUnstated(cb, root.get("wantedCity"),
                        cb.equal(cb.lower(root.get("wantedCity")),
                                listing.getCity().trim().toLowerCase())));
            } else {
                predicates.add(root.get("wantedCity").isNull());
            }

            if (listing.getPrice() != null) {
                predicates.add(orUnstated(cb, root.get("budgetMin"),
                        cb.lessThanOrEqualTo(root.get("budgetMin"), listing.getPrice())));
                predicates.add(orUnstated(cb, root.get("budgetMax"),
                        cb.greaterThanOrEqualTo(
                                cb.prod(root.get("budgetMax"), OVER_BUDGET_TOLERANCE),
                                listing.getPrice())));
            }

            // A requirement the listing cannot answer — rooms it does not state —
            // rules the buyer out rather than passing silently.
            predicates.add(listing.getRooms() == null
                    ? root.get("minRooms").isNull()
                    : orUnstated(cb, root.get("minRooms"),
                            cb.lessThanOrEqualTo(root.get("minRooms"), listing.getRooms())));
            predicates.add(listing.getAreaSqm() == null
                    ? root.get("minAreaSqm").isNull()
                    : orUnstated(cb, root.get("minAreaSqm"),
                            cb.lessThanOrEqualTo(root.get("minAreaSqm"), listing.getAreaSqm())));

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    /** The highest price a stated ceiling still tolerates. */
    public static BigDecimal ceiling(BigDecimal budgetMax) {
        return budgetMax.multiply(OVER_BUDGET_TOLERANCE);
    }

    public static boolean hasAnyRequirement(Client buyer) {
        return buyer.getWantedType() != null
                || isStated(buyer.getWantedCity())
                || buyer.getBudgetMin() != null
                || buyer.getBudgetMax() != null
                || buyer.getMinRooms() != null
                || buyer.getMinAreaSqm() != null;
    }

    private static Predicate orUnstated(
            jakarta.persistence.criteria.CriteriaBuilder cb,
            jakarta.persistence.criteria.Path<?> column,
            Predicate satisfied) {
        return cb.or(column.isNull(), satisfied);
    }

    private static boolean isStated(String value) {
        return value != null && !value.isBlank();
    }
}
