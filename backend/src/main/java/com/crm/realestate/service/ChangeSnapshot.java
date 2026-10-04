package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientTag;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeEntityType;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * The fields of a listing, deal or client the change log watches, each as the text a log line
 * stores. Taken before and after an edit; {@link ChangeLogService#changed} writes a line for every
 * field whose text differs.
 *
 * <p>The field names are the API's, and the app puts each into words. Values are what the app can
 * format: enum names, decimals without trailing zeros, ISO dates, and people and records by name.
 * A missing value is null, never an empty string, so clearing a field reads as "45 m² → —".
 */
public final class ChangeSnapshot {

    private ChangeSnapshot() {}

    /** Which record a line is about, and how it was called when the line was written. */
    public record Target(ChangeEntityType type, Long id, Team team, String label) {}

    public static Target target(Property p) {
        return new Target(ChangeEntityType.PROPERTY, p.getId(), p.getTeam(), p.getTitle());
    }

    public static Target target(Deal d) {
        return new Target(ChangeEntityType.DEAL, d.getId(), d.getTeam(), d.getTitle());
    }

    public static Target target(Client c) {
        return new Target(ChangeEntityType.CLIENT, c.getId(), c.getTeam(), c.getFullName());
    }

    public static Map<String, String> of(Property p) {
        Map<String, String> s = new LinkedHashMap<>();
        s.put("title", text(p.getTitle()));
        s.put("description", text(p.getDescription()));
        s.put("address", text(p.getAddress()));
        s.put("city", text(p.getCity()));
        s.put("type", name(p.getType()));
        s.put("status", name(p.getStatus()));
        s.put("price", number(p.getPrice()));
        s.put("areaSqm", number(p.getAreaSqm()));
        s.put("rooms", number(p.getRooms()));
        s.put("floor", number(p.getFloor()));
        s.put("totalFloors", number(p.getTotalFloors()));
        s.put("location", p.getLatitude() == null || p.getLongitude() == null ? null
                : number(p.getLatitude()) + "," + number(p.getLongitude()));
        s.put("mandateType", name(p.getMandateType()));
        s.put("mandateEndDate", date(p.getMandateEndDate()));
        s.put("agent", person(p.getAgent()));
        return s;
    }

    public static Map<String, String> of(Deal d) {
        Map<String, String> s = new LinkedHashMap<>();
        s.put("title", text(d.getTitle()));
        s.put("status", name(d.getStatus()));
        s.put("dealPrice", number(d.getDealPrice()));
        s.put("budget", number(d.getBudget()));
        s.put("commissionPercent", number(d.getCommissionPercent()));
        s.put("lostReason", name(d.getLostReason()));
        s.put("lostNote", text(d.getLostNote()));
        s.put("notes", text(d.getNotes()));
        s.put("client", d.getClient() == null ? null : text(d.getClient().getFullName()));
        s.put("property", d.getProperty() == null ? null : text(d.getProperty().getTitle()));
        s.put("agent", person(d.getAgent()));
        s.put("kind", name(d.getKind()));
        s.put("monthlyRent", number(d.getMonthlyRent()));
        s.put("leaseStart", d.getLeaseStart() == null ? null : d.getLeaseStart().toString());
        s.put("leaseEnd", d.getLeaseEnd() == null ? null : d.getLeaseEnd().toString());
        s.put("leaseReminderDays", number(d.getLeaseReminderDays()));
        s.put("landlord", d.getLandlord() == null ? null : text(d.getLandlord().getFullName()));
        return s;
    }

    public static Map<String, String> of(Client c) {
        Map<String, String> s = new LinkedHashMap<>();
        s.put("fullName", text(c.getFullName()));
        s.put("phone", text(c.getPhone()));
        s.put("email", text(c.getEmail()));
        s.put("type", name(c.getType()));
        s.put("leadSource", name(c.getLeadSource()));
        s.put("leadSourceDetail", text(c.getLeadSourceDetail()));
        s.put("referredBy", c.getReferredBy() == null ? null : text(c.getReferredBy().getName()));
        s.put("wantedType", name(c.getWantedType()));
        s.put("wantedCity", text(c.getWantedCity()));
        s.put("budgetMin", number(c.getBudgetMin()));
        s.put("budgetMax", number(c.getBudgetMax()));
        s.put("minRooms", number(c.getMinRooms()));
        s.put("minAreaSqm", number(c.getMinAreaSqm()));
        s.put("birthday", ClientBirthday.format(c));
        s.put("tags", c.getTags() == null || c.getTags().isEmpty() ? null
                : c.getTags().stream().map(ClientTag::getName).sorted(String.CASE_INSENSITIVE_ORDER)
                        .collect(Collectors.joining(", ")));
        s.put("notes", text(c.getNotes()));
        s.put("agent", person(c.getAgent()));
        return s;
    }

    static String person(User user) {
        return user == null ? null : text(user.getFullName());
    }

    private static String text(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private static String name(Enum<?> value) {
        return value == null ? null : value.name();
    }

    private static String date(LocalDate value) {
        return value == null ? null : value.toString();
    }

    /** 45000000.00 and 45000000 are the same price, so neither is a change. */
    private static String number(Number value) {
        if (value == null) {
            return null;
        }
        BigDecimal decimal = value instanceof BigDecimal b ? b : new BigDecimal(value.toString());
        if (decimal.signum() == 0) {
            return "0";
        }
        return decimal.stripTrailingZeros().toPlainString();
    }
}
