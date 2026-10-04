package com.crm.realestate.service.exports;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.service.ClientBirthday;
import com.crm.realestate.service.ClientTagService;
import com.crm.realestate.service.CommissionSplitStore;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import static com.crm.realestate.service.exports.CsvWriter.date;
import static com.crm.realestate.service.exports.CsvWriter.whole;
import static com.crm.realestate.service.exports.ExportLabels.heading;
import static com.crm.realestate.service.exports.ExportLabels.imported;
import static com.crm.realestate.service.exports.ExportLabels.value;

/** The columns of each export, and one record written as its cells. */
@Component
@RequiredArgsConstructor
class ExportColumns {

    private static final BigDecimal ONE_HUNDRED = BigDecimal.valueOf(100);

    private final EntityManager entityManager;
    private final ClientTagService tagService;
    private final CommissionSplitStore splitStore;

    List<String> headings(ExportKind kind, int lang) {
        return switch (kind) {
            case CLIENTS -> Stream.concat(
                    Stream.of("fullName", "phone", "email", "type").map(k -> imported(k, lang)),
                    Stream.concat(Stream.of(heading("agent", lang)), Stream.concat(
                            Stream.of("wantedCity", "wantedType", "budgetMin", "budgetMax",
                                    "minRooms", "minAreaSqm", "notes", "tags", "leadSource", "leadSourceDetail",
                                    "birthday").map(k -> imported(k, lang)),
                            Stream.of("source", "created").map(k -> heading(k, lang))))).toList();
            case PROPERTIES -> Stream.concat(
                    Stream.of("title", "address", "city", "type", "status", "price", "areaSqm",
                            "rooms", "floor", "totalFloors", "description").map(k -> imported(k, lang)),
                    Stream.of("agent", "created", "linkViews").map(k -> heading(k, lang))).toList();
            case DEALS -> Stream.of("dealTitle", "dealStatus", "client", "listing", "dealPrice",
                    "budget", "commissionPercent", "commission", "agent", "dealCreated", "closed",
                    "lostReason", "lostNote", "commissionSplit").map(k -> heading(k, lang)).toList();
        };
    }

    /**
     * A client's tags are one cell, joined by ", " — a tag never holds a comma (see ClientTags),
     * and the import splits the cell on commas again.
     */
    List<String> client(Client c, Map<Long, List<String>> tags, CsvWriter csv, int lang) {
        return Arrays.asList(c.getFullName(), c.getPhone(), c.getEmail(), value(c.getType(), lang),
                name(c.getAgent()), c.getWantedCity(), value(c.getWantedType(), lang),
                csv.decimal(c.getBudgetMin()), csv.decimal(c.getBudgetMax()), whole(c.getMinRooms()),
                csv.decimal(c.getMinAreaSqm()), c.getNotes(),
                String.join(", ", tags.getOrDefault(c.getId(), List.of())),
                value(c.getLeadSource(), lang), leadSourceDetail(c),
                ClientBirthday.format(c), value(c.getSource(), lang), date(c.getCreatedAt()));
    }

    /**
     * The detail beside the lead source, with the partner's name in front of it for a client a
     * partner sent: a spreadsheet has no partner to link, so the name is what it keeps. The import
     * reads such a row back as a referral with this text as the detail.
     */
    private static String leadSourceDetail(Client c) {
        if (c.getReferredBy() == null) {
            return c.getLeadSourceDetail();
        }
        String partner = c.getReferredBy().getName();
        return c.getLeadSourceDetail() == null ? partner : partner + " - " + c.getLeadSourceDetail();
    }

    /** Each client's tag names, in name order: one query a page. */
    Map<Long, List<String>> tags(List<Client> page) {
        return tagService.namesByClient(page.stream().map(Client::getId).toList());
    }

    List<String> property(Property p, Map<Long, Long> views, CsvWriter csv, int lang) {
        return Arrays.asList(p.getTitle(), p.getAddress(), p.getCity(), value(p.getType(), lang),
                value(p.getStatus(), lang), csv.decimal(p.getPrice()), csv.decimal(p.getAreaSqm()),
                whole(p.getRooms()), whole(p.getFloor()), whole(p.getTotalFloors()),
                p.getDescription(), name(p.getAgent()), date(p.getCreatedAt()),
                whole(views.getOrDefault(p.getId(), 0L)));
    }

    /**
     * A deal's row. The commission is the deal's whole; the agent column names who holds the deal,
     * and the last column, when the commission is split, who gets what share of it — "Aigul Bekova
     * 60%, Ivan Petrov (Etazhi) 40%" — empty when it is all the agent's.
     */
    List<String> deal(Deal d, Map<Long, String> splits, CsvWriter csv, int lang) {
        BigDecimal base = com.crm.realestate.service.DealMoney.commissionBase(d);
        BigDecimal commission = base == null || d.getCommissionPercent() == null ? null
                : base.multiply(d.getCommissionPercent()).divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
        return Arrays.asList(d.getTitle(), value(d.getStatus(), lang),
                d.getClient() == null ? null : d.getClient().getFullName(),
                d.getProperty() == null ? null : d.getProperty().getTitle(),
                csv.decimal(d.getDealPrice()), csv.decimal(d.getBudget()),
                csv.decimal(d.getCommissionPercent()), csv.decimal(commission), name(d.getAgent()),
                date(d.getCreatedAt()), date(d.getClosedAt()), value(d.getLostReason(), lang),
                d.getLostNote(), splits.get(d.getId()));
    }

    /** Each split deal's shares in a line: one query a page. */
    Map<Long, String> splits(List<Deal> page) {
        return splitStore.describe(page);
    }

    /** How often each listing's public pages were opened, summed over all its links: one query. */
    Map<Long, Long> linkViews(List<Property> page) {
        List<Long> ids = page.stream().map(Property::getId).toList();
        Map<Long, Long> views = new HashMap<>();
        entityManager.createQuery("select l.property.id, sum(l.viewCount) from PropertyShareLink l "
                        + "where l.property.id in :ids group by l.property.id", Object[].class)
                .setParameter("ids", ids)
                .getResultList()
                .forEach(row -> views.put((Long) row[0], ((Number) row[1]).longValue()));
        return views;
    }

    private static String name(User user) {
        return user == null ? null : user.getFullName();
    }
}
