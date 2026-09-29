package com.crm.realestate.service;

import com.crm.realestate.dto.response.PriceInsightResponse;
import com.crm.realestate.dto.response.PriceInsightResponse.Criteria;
import com.crm.realestate.dto.response.PriceInsightResponse.Range;
import com.crm.realestate.dto.response.PriceInsightResponse.Stats;
import com.crm.realestate.service.PriceInsightService.Sample;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * The arithmetic of a price insight, kept apart from the reading.
 *
 * <p>Percentiles interpolate linearly between the two nearest ranks, as Postgres'
 * {@code percentile_cont} does: for n sorted values the p-th sits at position p·(n−1).
 */
final class PriceStatistics {

    private PriceStatistics() {
    }

    static PriceInsightResponse summarise(List<Sample> used, Criteria criteria, Double areaSqm,
                                          int enough, int listed) {
        List<Sample> active = used.stream().filter(s -> !s.sold()).toList();
        List<Sample> sold = used.stream().filter(Sample::sold).toList();

        Stats soldStats = stats(rates(sold));
        List<Double> days = new ArrayList<>(sold.stream()
                .filter(s -> s.daysOnMarket() != null).map(s -> (double) s.daysOnMarket()).toList());
        if (!days.isEmpty()) {
            soldStats.setMedianDaysOnMarket((int) Math.round(percentile(days, 0.5)));
        }

        List<Double> everyRate = rates(used);
        Range suggested = null;
        if (areaSqm != null && !everyRate.isEmpty()) {
            suggested = Range.builder()
                    .low(money(percentile(everyRate, 0.25) * areaSqm))
                    .median(money(percentile(everyRate, 0.5) * areaSqm))
                    .high(money(percentile(everyRate, 0.75) * areaSqm))
                    .build();
        }

        return PriceInsightResponse.builder()
                .count(used.size())
                .lowConfidence(used.size() < enough)
                .criteria(criteria)
                .active(stats(rates(active)))
                .sold(soldStats)
                .suggested(suggested)
                .comparables(used.stream().limit(listed).map(Sample::toListing).toList())
                .build();
    }

    static Stats stats(List<Double> rates) {
        if (rates.isEmpty()) {
            return Stats.builder().count(0).build();
        }
        return Stats.builder()
                .count(rates.size())
                .p25PerSqm(money(percentile(rates, 0.25)))
                .medianPerSqm(money(percentile(rates, 0.5)))
                .p75PerSqm(money(percentile(rates, 0.75)))
                .build();
    }

    /** The p-th percentile (0–1) of these values, interpolated; the list need not be sorted. */
    static double percentile(List<Double> values, double p) {
        List<Double> sorted = new ArrayList<>(values);
        Collections.sort(sorted);
        double position = p * (sorted.size() - 1);
        int lower = (int) Math.floor(position);
        int upper = (int) Math.ceil(position);
        double fraction = position - lower;
        return sorted.get(lower) + (sorted.get(upper) - sorted.get(lower)) * fraction;
    }

    /** Money in whole units of the agency's currency. */
    static BigDecimal money(double value) {
        return BigDecimal.valueOf(Math.round(value));
    }

    private static List<Double> rates(List<Sample> samples) {
        return samples.stream().map(Sample::rate).toList();
    }
}
