package com.crm.realestate.integration;

import com.crm.realestate.dto.response.LeaseEnding;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.RecordChangeRepository;
import com.crm.realestate.service.AnalyticsService;
import com.crm.realestate.service.LeaseEndNotifier;
import com.crm.realestate.service.LeaseService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Rent deals: the lease on the deal, the ones running out, renewing one, the reminder, and what a
 * rent counts for in the totals.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class DealLeaseTest extends ColdClientsFixture {

    private static final LocalDate OCT_1 = LocalDate.of(2026, 10, 1);

    @Autowired private LeaseService leaseService;
    @Autowired private LeaseEndNotifier notifier;
    @Autowired private AnalyticsService analyticsService;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private DealCommentRepository commentRepository;
    @Autowired private RecordChangeRepository changeRepository;

    // The lease on the deal -----------------------------------------------------------------

    @Test
    @DisplayName("a rent keeps its rent, lease and landlord, never a sale price, and earns its percentage of one month's rent")
    void rentOnTheDeal() throws Exception {
        Client tenant = buyer("Tenant", agent, 1);
        Client landlord = buyer("Landlord", agent, 1);
        Property flat = flat(agent, "Almaty", "50000000");
        signIn(agent);

        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"dealPrice\":999,\"monthlyRent\":300000,"
                + "\"commissionPercent\":50,\"leaseStart\":\"2026-01-01\",\"leaseEnd\":\"2026-12-31\","
                + "\"landlordId\":" + landlord.getId() + ",\"propertyId\":" + flat.getId())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.kind").value("RENT"))
                .andExpect(jsonPath("$.dealPrice").value(nullValue()))
                .andExpect(jsonPath("$.monthlyRent").value(300000))
                .andExpect(jsonPath("$.commission").value(150000.00))
                .andExpect(jsonPath("$.leaseStart").value("2026-01-01"))
                .andExpect(jsonPath("$.leaseEnd").value("2026-12-31"))
                .andExpect(jsonPath("$.leaseReminderDays").value(nullValue()))
                .andExpect(jsonPath("$.leaseReminderDaysEffective").value(30))
                .andExpect(jsonPath("$.landlordName").value("Landlord"));
        // Letting a flat neither reserves nor sells it.
        assertThat(propertyRepository.findById(flat.getId()).orElseThrow().getStatus())
                .isEqualTo(PropertyStatus.AVAILABLE);

        save(post("/deals"), tenant, "\"dealPrice\":1000")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.kind").value("SALE"))
                .andExpect(jsonPath("$.leaseEnd").value(nullValue()));
    }

    @Test
    @DisplayName("a rent needs its rent and both days, the end after the start; a landlord who is the tenant or a stranger is refused")
    void leaseRules() throws Exception {
        Client tenant = buyer("Tenant", agent, 1);
        Client astanas = buyer("Astana's", stranger, 1);
        signIn(agent);
        String dates = ",\"leaseStart\":\"2026-01-01\",\"leaseEnd\":\"2026-12-31\"";

        save(post("/deals"), tenant, "\"kind\":\"RENT\"" + dates)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("RENT_REQUIRED"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":0" + dates)
                .andExpect(jsonPath("$.code").value("RENT_REQUIRED"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":1,\"leaseStart\":\"2026-01-01\"")
                .andExpect(jsonPath("$.code").value("LEASE_DATES_REQUIRED"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":1,"
                + "\"leaseStart\":\"2026-01-01\",\"leaseEnd\":\"2026-01-01\"")
                .andExpect(jsonPath("$.code").value("LEASE_ENDS_BEFORE_START"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":1,\"leaseReminderDays\":0" + dates)
                .andExpect(jsonPath("$.code").value("INVALID_REMINDER_DAYS"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":1,\"landlordId\":" + tenant.getId() + dates)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("LANDLORD_IS_TENANT"));
        save(post("/deals"), tenant, "\"kind\":\"RENT\",\"monthlyRent\":1,\"landlordId\":" + astanas.getId() + dates)
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("saving without a kind leaves a rent's lease alone; saving it as a sale takes the lease off")
    void olderAppKeepsTheLease() throws Exception {
        Client tenant = buyer("Tenant", agent, 1);
        Deal rent = rent(tenant, null, DealStatus.LEAD, LocalDate.of(2026, 12, 31), null);
        entityManager.flush();
        signIn(agent);

        save(put("/deals/" + rent.getId()), tenant, "\"notes\":\"called\",\"dealPrice\":5")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.kind").value("RENT"))
                .andExpect(jsonPath("$.dealPrice").value(nullValue()))
                .andExpect(jsonPath("$.leaseEnd").value("2026-12-31"));
        save(put("/deals/" + rent.getId()), tenant, "\"kind\":\"SALE\",\"dealPrice\":5")
                .andExpect(jsonPath("$.kind").value("SALE"))
                .andExpect(jsonPath("$.dealPrice").value(5))
                .andExpect(jsonPath("$.monthlyRent").value(nullValue()))
                .andExpect(jsonPath("$.leaseEnd").value(nullValue()));
    }

    // Ending soon ---------------------------------------------------------------------------

    @Test
    @DisplayName("won rents ending in the window, soonest first; not sales, not lost or open rents, not ended ones")
    void endingWindow() {
        Client tenant = buyer("Tenant", agent, 1);
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusDays(20), null).setTitle("Later");
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1, null).setTitle("Today");
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusDays(30), null).setTitle("Last day");
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusDays(31), null).setTitle("Too late");
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.minusDays(1), null).setTitle("Ended");
        rent(tenant, null, DealStatus.NEGOTIATION, OCT_1.plusDays(5), null).setTitle("Open");
        rent(tenant, null, DealStatus.CLOSED_LOST, OCT_1.plusDays(5), null).setTitle("Lost");
        deal(tenant, "Sale", DealStatus.CLOSED_WON);

        signIn(agent);
        List<LeaseEnding> leases = ending(30);
        assertThat(leases).extracting(LeaseEnding::getDealTitle).containsExactly("Today", "Later", "Last day");
        assertThat(leases).extracting(LeaseEnding::getDaysLeft).containsExactly(0, 20, 30);
        assertThat(leases.get(0).getTenantName()).isEqualTo("Tenant");
        assertThat(leases.get(0).getTenantPhone()).isEqualTo("+7 701 000 00 00");
        assertThat(ending(7)).extracting(LeaseEnding::getDealTitle).containsExactly("Today");
    }

    @Test
    @DisplayName("the list keeps to the agency and the caller's data scope")
    void endingScope() {
        rent(buyer("Agent's", agent, 1), null, DealStatus.CLOSED_WON, OCT_1.plusDays(3), null);
        rent(buyer("Colleague's", colleague, 1), null, DealStatus.CLOSED_WON, OCT_1.plusDays(4), null);
        rent(buyer("Astana's", stranger, 1), null, DealStatus.CLOSED_WON, OCT_1.plusDays(5), null);

        signIn(agent);
        assertThat(tenants(ending(30))).containsExactly("Agent's");
        signIn(colleague);
        assertThat(tenants(ending(30))).containsExactly("Agent's", "Colleague's");
        signIn(manager);
        assertThat(tenants(ending(30))).containsExactly("Agent's", "Colleague's");
        signIn(stranger);
        assertThat(tenants(ending(30))).containsExactly("Astana's");
    }

    @Test
    @DisplayName("GET /deals/leases-ending names the tenant and the landlord, and takes days 1 to 365")
    void endpoint() throws Exception {
        rent(buyer("Tenant", agent, 1), buyer("Landlord", agent, 1), DealStatus.CLOSED_WON,
                OCT_1.plusDays(10), 45);
        entityManager.flush();
        signIn(agent);
        mockMvc.perform(get("/deals/leases-ending").param("from", "2026-10-01").param("days", "30"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].leaseEnd").value("2026-10-11"))
                .andExpect(jsonPath("$[0].daysLeft").value(10))
                .andExpect(jsonPath("$[0].reminderDays").value(45))
                .andExpect(jsonPath("$[0].monthlyRent").value(300000))
                .andExpect(jsonPath("$[0].tenantName").value("Tenant"))
                .andExpect(jsonPath("$[0].landlordName").value("Landlord"))
                .andExpect(jsonPath("$[0].agentName").value("Aigul Bekova"));
        mockMvc.perform(get("/deals/leases-ending").param("days", "0"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_DAYS"));
        mockMvc.perform(get("/deals/leases-ending").param("days", "366")).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("the list is a fixed number of statements however many leases there are")
    void noNPlusOne() {
        for (int i = 0; i < 8; i++) {
            rent(buyer("T" + i, i % 2 == 0 ? agent : colleague, 1), buyer("L" + i, agent, 1),
                    DealStatus.CLOSED_WON, OCT_1.plusDays(i), null);
        }
        signIn(manager);
        assertThat(statements(() -> assertThat(leaseService.ending(30, OCT_1)).hasSize(8)))
                .isLessThanOrEqualTo(3);
    }

    // Renewing ------------------------------------------------------------------------------

    @Test
    @DisplayName("renewing moves the last day on, may change the rent, and says so in the discussion")
    void renew() throws Exception {
        Deal lease = rent(buyer("Tenant", agent, 1), null, DealStatus.CLOSED_WON, OCT_1.plusDays(10), null);
        entityManager.flush();
        signIn(agent);

        renew(lease, "\"leaseEnd\":\"2027-10-11\",\"monthlyRent\":320000")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.leaseEnd").value("2027-10-11"))
                .andExpect(jsonPath("$.leaseStart").value("2025-10-12"))
                .andExpect(jsonPath("$.monthlyRent").value(320000))
                .andExpect(jsonPath("$.status").value("CLOSED_WON"))
                .andExpect(jsonPath("$.commentCount").value(1));
        assertThat(commentRepository.findAll()).singleElement()
                .satisfies(c -> assertThat(c.getBody()).contains("11.10.2027", "11.10.2026"));
        assertThat(dealRepository.count()).isEqualTo(1);
        assertThat(changeRepository.findByEntityTypeAndEntityIdOrderByIdAsc(ChangeEntityType.DEAL, lease.getId()))
                .extracting(RecordChange::getAction, RecordChange::getField, RecordChange::getNewValue)
                .containsExactlyInAnyOrder(
                        tuple(ChangeAction.UPDATED, "leaseEnd", "2027-10-11"),
                        tuple(ChangeAction.PRICE_CHANGED, "monthlyRent", "320000"));

        renew(lease, "\"leaseEnd\":\"2027-10-11\"")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("LEASE_END_NOT_LATER"));
    }

    @Test
    @DisplayName("only a won rent can be renewed, and another agency's deal does not exist")
    void renewRules() throws Exception {
        Client tenant = buyer("Tenant", agent, 1);
        Deal open = rent(tenant, null, DealStatus.NEGOTIATION, OCT_1.plusDays(10), null);
        Deal sale = deal(tenant, "Sale", DealStatus.CLOSED_WON);
        Deal astanas = rent(buyer("Astana's", stranger, 1), null, DealStatus.CLOSED_WON, OCT_1, null);
        entityManager.flush();
        signIn(agent);

        renew(open, "\"leaseEnd\":\"2030-01-01\"")
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("LEASE_NOT_RENEWABLE"));
        renew(sale, "\"leaseEnd\":\"2030-01-01\"").andExpect(status().isConflict());
        renew(astanas, "\"leaseEnd\":\"2030-01-01\"").andExpect(status().isNotFound());
        renew(open, "").andExpect(status().isBadRequest());
    }

    // The reminder --------------------------------------------------------------------------

    @Test
    @DisplayName("the agent is told once, on the first run inside the lead time, and again after a renewal")
    void reminder() {
        Client tenant = buyer("Tenant", agent, 1);
        Client landlord = buyer("Landlord", agent, 1);
        Deal soon = rent(tenant, landlord, DealStatus.CLOSED_WON, OCT_1.plusDays(30), null);
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusDays(31), null);
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusDays(40), 60).setTitle("Long notice");
        rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.minusDays(1), null).setTitle("Ended");
        rent(tenant, null, DealStatus.CLOSED_LOST, OCT_1.plusDays(3), null).setTitle("Lost");
        entityManager.flush();

        assertThat(notifier.notifyFor(OCT_1)).isEqualTo(2);
        assertThat(notifier.notifyFor(OCT_1)).isZero();
        assertThat(notifier.notifyFor(OCT_1.plusDays(1))).isEqualTo(1);

        List<Notification> told = notificationRepository.findByRecipientId(agent.getId());
        assertThat(told).hasSize(3).allSatisfy(n -> assertThat(n.getType()).isEqualTo(NotificationType.LEASE_ENDING));
        assertThat(told).filteredOn(n -> n.getTargetId().equals(soon.getId())).singleElement()
                .satisfies(n -> assertThat(n.getPayload())
                        .contains("\"tenantName\":\"Tenant\"", "\"landlordName\":\"Landlord\"",
                                "\"leaseEnd\":\"2026-10-31\"", "\"days\":30"));

        entityManager.clear();
        Deal renewed = dealRepository.findById(soon.getId()).orElseThrow();
        renewed.setLeaseEnd(LocalDate.of(2027, 10, 31));
        dealRepository.saveAndFlush(renewed);
        assertThat(notifier.notifyFor(LocalDate.of(2027, 10, 1))).isEqualTo(1);
    }

    @Test
    @DisplayName("the notification reads back through the feed")
    void inTheFeed() throws Exception {
        rent(buyer("Tenant", agent, 1), null, DealStatus.CLOSED_WON, OCT_1.plusDays(5), null);
        entityManager.flush();
        notifier.notifyFor(OCT_1);
        entityManager.flush();
        signIn(agent);
        mockMvc.perform(get("/notifications"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].type").value("LEASE_ENDING"))
                .andExpect(jsonPath("$.content[0].params.tenantName").value("Tenant"))
                .andExpect(jsonPath("$.content[0].params.days").value(5));
    }

    // What a rent counts for -------------------------------------------------------------------

    @Test
    @DisplayName("a won rent counts as a win and earns commission on one month's rent, but adds nothing to the sales value")
    void totals() {
        Client tenant = buyer("Tenant", agent, 1);
        Deal rent = rent(tenant, null, DealStatus.CLOSED_WON, OCT_1.plusYears(1), null);
        rent.setCommissionPercent(new BigDecimal("100"));
        rent.setClosedAt(LocalDateTime.now());
        Deal sale = deal(tenant, "Sale", DealStatus.CLOSED_WON);
        sale.setDealPrice(new BigDecimal("1000000"));
        sale.setCommissionPercent(new BigDecimal("2"));
        sale.setClosedAt(LocalDateTime.now());
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        assertThat(dashboardService.getSummary(null, null).getCommissionThisMonth())
                .isEqualByComparingTo("320000.00");
        var funnel = analyticsService.funnel(null, null, null);
        assertThat(funnel.getWon()).isEqualTo(2);
        assertThat(funnel.getWonValue()).isEqualByComparingTo("1000000.00");
    }

    @Test
    @DisplayName("merging the landlord's cards keeps the lease's landlord; merging them into the tenant drops it")
    void mergeCarriesTheLandlord() throws Exception {
        Client tenant = buyer("Tenant", agent, 1);
        Client landlord = buyer("Landlord", agent, 1);
        Client twin = buyer("Landlord twin", agent, 1);
        Deal lease = rent(tenant, landlord, DealStatus.CLOSED_WON, OCT_1.plusDays(5), null);
        entityManager.flush();
        signIn(manager);
        merge(twin, landlord);
        assertThat(dealRepository.findById(lease.getId()).orElseThrow().getLandlord().getId()).isEqualTo(twin.getId());
        merge(tenant, twin);
        assertThat(dealRepository.findById(lease.getId()).orElseThrow().getLandlord()).isNull();
    }

    // Helpers -----------------------------------------------------------------------------------

    /** A rent of 300 000 a month, a year long, ending on {@code end}. */
    private Deal rent(Client tenant, Client landlord, DealStatus status, LocalDate end, Integer reminderDays) {
        Deal deal = deal(tenant, "Lease", status);
        deal.setKind(DealKind.RENT);
        deal.setMonthlyRent(new BigDecimal("300000"));
        deal.setLeaseStart(end.minusYears(1).plusDays(1));
        deal.setLeaseEnd(end);
        deal.setLeaseReminderDays(reminderDays);
        deal.setLandlord(landlord);
        if (status == DealStatus.CLOSED_WON || status == DealStatus.CLOSED_LOST) {
            deal.setClosedAt(LocalDateTime.of(2025, 9, 1, 10, 0));
        }
        return dealRepository.save(deal);
    }

    private List<LeaseEnding> ending(int days) {
        entityManager.flush();
        entityManager.clear();
        return leaseService.ending(days, OCT_1);
    }

    private static List<String> tenants(List<LeaseEnding> leases) {
        return leases.stream().map(LeaseEnding::getTenantName).toList();
    }

    private ResultActions save(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
                               Client client, String extra) throws Exception {
        return mockMvc.perform(request.contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\":\"Lease\",\"clientId\":" + client.getId() + ",\"agentId\":" + agent.getId()
                        + "," + extra + "}"));
    }

    private ResultActions renew(Deal deal, String body) throws Exception {
        return mockMvc.perform(post("/deals/" + deal.getId() + "/renew-lease")
                .contentType(MediaType.APPLICATION_JSON).content("{" + body + "}"));
    }

    private void merge(Client target, Client source) throws Exception {
        mockMvc.perform(post("/clients/" + target.getId() + "/merge")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"sourceId\":" + source.getId() + "}"))
                .andExpect(status().isOk());
        entityManager.clear();
    }
}
