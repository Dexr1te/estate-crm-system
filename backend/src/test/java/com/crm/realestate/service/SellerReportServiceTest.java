package com.crm.realestate.service;

import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.dto.response.SellerReportResponse;
import com.crm.realestate.enums.ViewingOutcome;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class SellerReportServiceTest {

    private static final LocalDateTime NOW = LocalDateTime.of(2026, 9, 30, 12, 0);

    @Test
    @DisplayName("a viewing ticked off early counts as held; one whose time passed unticked does too")
    void heldIsDoneOrPast() {
        SellerReportResponse.Viewings v = SellerReportService.viewings(List.of(
                meeting(NOW.plusDays(1), true, ViewingOutcome.INTERESTED),
                meeting(NOW.minusHours(1), false, null),
                meeting(NOW.plusDays(3), false, null),
                meeting(NOW.plusDays(2), false, null)), NOW);

        assertThat(v.getTotal()).isEqualTo(4);
        assertThat(v.getHeld()).isEqualTo(2);
        assertThat(v.getUpcoming()).isEqualTo(2);
        assertThat(v.getAwaitingOutcome()).isEqualTo(1);
        assertThat(v.getNextAt()).isEqualTo(NOW.plusDays(2));
        assertThat(v.getLastHeldAt()).isEqualTo(NOW.plusDays(1));
        assertThat(v.getOutcomes()).containsOnlyKeys(ViewingOutcome.values())
                .containsEntry(ViewingOutcome.INTERESTED, 1)
                .containsEntry(ViewingOutcome.REJECTED, 0);
    }

    @Test
    @DisplayName("the original price is the first change's old price; a rise reads positive")
    void priceMovement() {
        SellerReportResponse.Price p = SellerReportService.price(new BigDecimal("33000000"), List.of(
                change("31000000", "33000000"), change("30000000", "31000000")));

        assertThat(p.getOriginal()).isEqualByComparingTo("30000000");
        assertThat(p.getChange()).isEqualByComparingTo("3000000");
        assertThat(p.getChangePercent()).isEqualTo(10.0);
        assertThat(p.getChanges()).extracting(PropertyPriceChangeResponse::getNewPrice)
                .containsExactly(new BigDecimal("31000000"), new BigDecimal("33000000"));
    }

    @Test
    @DisplayName("days on the market are calendar days, and never negative")
    void days() {
        assertThat(SellerReportService.daysOnMarket(NOW.minusHours(13), NOW)).isEqualTo(1);
        assertThat(SellerReportService.daysOnMarket(NOW.plusDays(2), NOW)).isZero();
        assertThat(SellerReportService.daysOnMarket(null, NOW)).isZero();
    }

    private static MeetingResponse meeting(LocalDateTime at, boolean completed, ViewingOutcome outcome) {
        MeetingResponse m = new MeetingResponse();
        m.setScheduledAt(at);
        m.setCompleted(completed);
        m.setOutcome(outcome);
        return m;
    }

    private static PropertyPriceChangeResponse change(String from, String to) {
        PropertyPriceChangeResponse c = new PropertyPriceChangeResponse();
        c.setOldPrice(new BigDecimal(from));
        c.setNewPrice(new BigDecimal(to));
        return c;
    }
}
