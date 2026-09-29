package com.crm.realestate.service;

import com.crm.realestate.dto.response.PriceInsightResponse;
import com.crm.realestate.dto.response.PriceInsightResponse.ComparableListing;
import com.crm.realestate.dto.response.PriceInsightResponse.Criteria;
import com.crm.realestate.dto.response.PriceInsightResponse.Position;
import com.crm.realestate.dto.response.PriceInsightResponse.RoomsRule;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.projection.ClosedSaleRow;
import com.crm.realestate.repository.projection.PriceComparableRow;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Is this price right? Answered from the agency's own book — never another agency's.
 *
 * <p><b>Comparables.</b> The caller's agency's listings in the same city (case and surrounding
 * spaces ignored) and of the same type, with a positive price and area, the listing itself left
 * out. Active ones are AVAILABLE or RESERVED; sold ones are SOLD or carry a won deal, and are
 * priced at the deal's price when it has one.
 *
 * <p><b>Widening.</b> Exact rooms, then rooms ±1, then any rooms: the first step with at least
 * {@value #ENOUGH} comparables wins. If none has, the widest is returned with {@code lowConfidence}.
 *
 * <p><b>Why in Java.</b> {@code percentile_cont} is Postgres-only (H2, which the tests run on, has
 * no ordered-set aggregates), and the widening wants the same rows three ways. So one statement
 * reads a narrow projection — id, title, price, area, rooms, status, date; no agent, no client — of
 * at most {@value #CAP} of the newest rows, and one more reads their won deals. An agency rarely has
 * that many listings of one type in one city; the cap bounds memory if one does, keeping the newest,
 * which are the fairest guide to today's prices. Two statements, whatever the size of the book.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PriceInsightService {

    static final int ENOUGH = 5;
    static final int CAP = 2000;
    static final int LISTED = 50;

    private final PropertyRepository propertyRepository;
    private final DealRepository dealRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    /** The insight for a listing being written: the form's figures, not yet saved. */
    public PriceInsightResponse insight(String city, PropertyType type, Integer rooms, Double areaSqm,
                                        Long excludeId) {
        if (city == null || city.isBlank()) throw invalid("city is required");
        if (type == null) throw invalid("type is required");
        if (rooms != null && rooms < 0) throw invalid("rooms must not be negative");
        if (areaSqm != null && (areaSqm.isNaN() || areaSqm <= 0)) throw invalid("areaSqm must be positive");
        return compute(securityUtils.getCurrentUser(), city, type, rooms, areaSqm, excludeId).insight();
    }

    /** The insight for a saved listing, and where its own price sits among the active ones. */
    public PriceInsightResponse insightFor(Long propertyId) {
        User currentUser = securityUtils.getCurrentUser();
        Property property = propertyRepository.findById(propertyId)
                .filter(p -> scopeService.canSeeInTeam(currentUser, p.getTeam(), p.getAgent()))
                .orElseThrow(() -> new ResourceNotFoundException("Property not found with id: " + propertyId));
        Double area = positive(property.getAreaSqm()) ? property.getAreaSqm() : null;
        if (property.getCity() == null || property.getCity().isBlank()) {
            return empty(property.getCity(), property.getType(), property.getRooms(), area, propertyId);
        }
        Result result = compute(currentUser, property.getCity(), property.getType(),
                property.getRooms(), area, propertyId);
        PriceInsightResponse insight = result.insight();
        BigDecimal price = property.getPrice();
        if (area != null && price != null && price.signum() > 0 && insight.getActive().getCount() > 0) {
            insight.setPosition(position(price.doubleValue() / area, result.activeRates()));
        }
        return insight;
    }

    private record Result(PriceInsightResponse insight, List<Double> activeRates) {
    }

    private Result compute(User user, String city, PropertyType type, Integer rooms,
                                         Double areaSqm, Long excludeId) {
        String key = city.trim().toLowerCase(Locale.ROOT);
        List<PriceComparableRow> rows = propertyRepository.priceComparables(
                scopeService.teamIdOf(user), user.getId(), key, type, excludeId, PageRequest.of(0, CAP));
        Map<Long, ClosedSaleRow> sales = latestSales(rows);

        List<Sample> all = rows.stream().map(r -> Sample.of(r, sales.get(r.id()))).toList();
        RoomsRule rule = RoomsRule.ANY;
        List<Sample> used = all;
        if (rooms != null) {
            for (RoomsRule step : new RoomsRule[] {RoomsRule.EXACT, RoomsRule.NEAR}) {
                int spread = step == RoomsRule.EXACT ? 0 : 1;
                List<Sample> within = all.stream()
                        .filter(c -> c.rooms() != null && Math.abs(c.rooms() - rooms) <= spread)
                        .toList();
                if (within.size() >= ENOUGH) {
                    rule = step;
                    used = within;
                    break;
                }
            }
        }
        int spread = rule == RoomsRule.EXACT ? 0 : 1;
        Criteria criteria = Criteria.builder()
                .city(city.trim()).type(type).rooms(rooms).areaSqm(areaSqm).excludeId(excludeId)
                .roomsRule(rule)
                .minRooms(rule == RoomsRule.ANY ? null : Math.max(0, rooms - spread))
                .maxRooms(rule == RoomsRule.ANY ? null : rooms + spread)
                .build();
        List<Double> activeRates = used.stream().filter(c -> !c.sold()).map(Sample::rate).toList();
        return new Result(PriceStatistics.summarise(used, criteria, areaSqm, ENOUGH, LISTED), activeRates);
    }

    /** The latest won deal on each sold-looking listing — one statement for all of them. */
    private Map<Long, ClosedSaleRow> latestSales(List<PriceComparableRow> rows) {
        Map<Long, ClosedSaleRow> latest = new HashMap<>();
        if (rows.isEmpty()) return latest;
        List<Long> ids = rows.stream().map(PriceComparableRow::id).toList();
        Comparator<ClosedSaleRow> newer = Comparator.comparing(ClosedSaleRow::closedAt,
                Comparator.nullsFirst(Comparator.naturalOrder()));
        for (ClosedSaleRow sale : dealRepository.closedSalesOf(ids)) {
            latest.merge(sale.propertyId(), sale, (a, b) -> newer.compare(a, b) >= 0 ? a : b);
        }
        return latest;
    }

    private static Position position(double rate, List<Double> activeRates) {
        double below = 0;
        for (double r : activeRates) {
            if (r < rate) below += 1;
            else if (r == rate) below += 0.5;
        }
        double median = PriceStatistics.percentile(activeRates, 0.5);
        return Position.builder()
                .pricePerSqm(PriceStatistics.money(rate))
                .percentile((int) Math.round(below * 100 / activeRates.size()))
                .vsMedianPercent(Math.round((rate / median - 1) * 1000) / 10.0)
                .build();
    }

    private static PriceInsightResponse empty(String city, PropertyType type, Integer rooms,
                                              Double area, Long excludeId) {
        Criteria criteria = Criteria.builder().city(city).type(type).rooms(rooms).areaSqm(area)
                .excludeId(excludeId).roomsRule(RoomsRule.ANY).build();
        return PriceStatistics.summarise(List.of(), criteria, area, ENOUGH, LISTED);
    }

    private static boolean positive(Double value) {
        return value != null && !value.isNaN() && value > 0;
    }

    private static BusinessException invalid(String message) {
        return new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_PRICE_INSIGHT", message);
    }

    /** One comparable as the statistics see it. */
    record Sample(Long id, String title, BigDecimal price, double areaSqm, Integer rooms,
                      PropertyStatus status, boolean sold, Integer daysOnMarket) {

        static Sample of(PriceComparableRow row, ClosedSaleRow sale) {
            boolean sold = row.status() == PropertyStatus.SOLD || sale != null;
            BigDecimal price = sale != null && sale.dealPrice() != null && sale.dealPrice().signum() > 0
                    ? sale.dealPrice() : row.price();
            Integer days = sale != null && sale.closedAt() != null && row.createdAt() != null
                    ? (int) Math.max(0, Duration.between(row.createdAt(), sale.closedAt()).toDays())
                    : null;
            return new Sample(row.id(), row.title(), price, row.areaSqm(), row.rooms(),
                    row.status(), sold, days);
        }

        double rate() {
            return price.doubleValue() / areaSqm;
        }

        ComparableListing toListing() {
            return ComparableListing.builder().id(id).title(title).price(price).areaSqm(areaSqm)
                    .pricePerSqm(PriceStatistics.money(rate())).rooms(rooms).status(status).sold(sold)
                    .build();
        }
    }
}
