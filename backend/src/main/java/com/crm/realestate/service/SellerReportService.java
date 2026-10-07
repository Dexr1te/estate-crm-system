package com.crm.realestate.service;

import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.dto.response.SellerReportResponse;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import com.crm.realestate.repository.projection.ClosedSaleRow;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * The report an agent hands the owner of a listing.
 *
 * <p>Built out of the reads the app already makes, each of which checks visibility on its own:
 * the listing and its price history from {@link PropertyService}, its viewings from
 * {@link MeetingService}, the buyers it fits from {@link MatchingService}. So another agency's
 * listing is missing here exactly as it is everywhere else, and an agent on own-data scope counts
 * the viewings and buyers they can see, not a colleague's.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SellerReportService {

    private final PropertyService propertyService;
    private final MeetingService meetingService;
    private final MatchingService matchingService;
    private final PropertyShareLinkRepository linkRepository;
    private final DealRepository dealRepository;

    public SellerReportResponse reportFor(Long propertyId) {
        // First, so a listing the caller cannot see is a 404 before anything else is read.
        PropertyResponse listing = propertyService.getById(propertyId);
        LocalDateTime now = LocalDateTime.now();

        LocalDateTime soldAt = dealRepository.closedSalesOf(List.of(propertyId)).stream()
                .map(ClosedSaleRow::closedAt)
                .filter(Objects::nonNull)
                .max(Comparator.naturalOrder())
                .orElse(null);
        LocalDateTime listedAt = listing.getCreatedAt();

        return SellerReportResponse.builder()
                .propertyId(listing.getId())
                .title(listing.getTitle())
                .address(listing.getAddress())
                .city(listing.getCity())
                .status(listing.getStatus())
                .listedAt(listedAt)
                .daysOnMarket(daysOnMarket(listedAt, soldAt != null ? soldAt : now))
                .soldAt(soldAt)
                .generatedOn(now.toLocalDate())
                .viewings(viewings(meetingService.getByProperty(propertyId), now))
                .publicLink(publicLink(propertyId))
                .price(price(listing.getPrice(), propertyService.priceHistory(propertyId)))
                .matchingBuyers(matchingService.buyersFor(propertyId).size())
                .build();
    }

    /** Calendar days, so a listing put up last night is one day old this morning. */
    static long daysOnMarket(LocalDateTime listedAt, LocalDateTime until) {
        if (listedAt == null || until == null) {
            return 0;
        }
        return Math.max(0, ChronoUnit.DAYS.between(listedAt.toLocalDate(), until.toLocalDate()));
    }

    /**
     * A viewing counts as held once it is marked done or its time has passed — an agent who
     * forgets to tick it off has still shown the flat.
     */
    static SellerReportResponse.Viewings viewings(List<MeetingResponse> meetings, LocalDateTime now) {
        Map<ViewingOutcome, Integer> outcomes = new EnumMap<>(ViewingOutcome.class);
        for (ViewingOutcome outcome : ViewingOutcome.values()) {
            outcomes.put(outcome, 0);
        }
        int held = 0;
        int awaiting = 0;
        LocalDateTime lastHeld = null;
        LocalDateTime next = null;
        for (MeetingResponse m : meetings) {
            LocalDateTime at = m.getScheduledAt();
            if (m.getOutcome() != null) {
                outcomes.merge(m.getOutcome(), 1, Integer::sum);
            }
            if (m.isCompleted() || at == null || !at.isAfter(now)) {
                held++;
                if (m.getOutcome() == null) {
                    awaiting++;
                }
                if (at != null && (lastHeld == null || at.isAfter(lastHeld))) {
                    lastHeld = at;
                }
            } else if (next == null || at.isBefore(next)) {
                next = at;
            }
        }
        return SellerReportResponse.Viewings.builder()
                .total(meetings.size())
                .held(held)
                .upcoming(meetings.size() - held)
                .outcomes(outcomes)
                .awaitingOutcome(awaiting)
                .lastHeldAt(lastHeld)
                .nextAt(next)
                .build();
    }

    private SellerReportResponse.PublicLink publicLink(Long propertyId) {
        List<Object[]> rows = linkRepository.totalsFor(propertyId);
        Object[] totals = rows.isEmpty() ? new Object[] {0L, 0L} : rows.get(0);
        return SellerReportResponse.PublicLink.builder()
                .active(linkRepository.findFirstByPropertyIdAndRevokedAtIsNull(propertyId).isPresent())
                .views(asLong(totals[0]))
                .leads(asLong(totals[1]))
                .build();
    }

    /** {@code newestFirst} is the price history as the history endpoint returns it. */
    static SellerReportResponse.Price price(BigDecimal current,
                                            List<PropertyPriceChangeResponse> newestFirst) {
        List<PropertyPriceChangeResponse> oldestFirst = new ArrayList<>(newestFirst);
        Collections.reverse(oldestFirst);
        BigDecimal original = oldestFirst.isEmpty() ? current : oldestFirst.get(0).getOldPrice();
        BigDecimal change = current != null && original != null
                ? current.subtract(original) : BigDecimal.ZERO;
        Double percent = original == null || original.signum() == 0 ? null
                : change.multiply(BigDecimal.valueOf(100))
                        .divide(original, 1, RoundingMode.HALF_UP).doubleValue();
        return SellerReportResponse.Price.builder()
                .current(current)
                .original(original)
                .change(change)
                .changePercent(percent)
                .changes(oldestFirst)
                .build();
    }

    private static long asLong(Object value) {
        return value instanceof Number n ? n.longValue() : 0L;
    }
}
