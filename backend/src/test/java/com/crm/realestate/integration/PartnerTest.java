package com.crm.realestate.integration;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.request.PartnerHandoffRequest;
import com.crm.realestate.dto.request.PartnerRequest;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.dto.response.PartnerHandoffResponse;
import com.crm.realestate.dto.response.PartnerReferralResponse;
import com.crm.realestate.dto.response.PartnerResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Partner;
import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.LeadSource;
import com.crm.realestate.enums.PartnerHandoffStatus;
import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.enums.ReferralFeeType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PartnerHandoffRepository;
import com.crm.realestate.repository.PartnerRepository;
import com.crm.realestate.repository.RecordChangeRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.ClientDuplicateService;
import com.crm.realestate.service.ClientService;
import com.crm.realestate.service.PartnerHandoffService;
import com.crm.realestate.service.PartnerService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.tuple;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Partners: the agency's directory of brokers, notaries and the rest; a client a partner sent,
 * as the lead source PARTNER; clients sent to a partner; and what the referrals came to in won
 * deals and fees. Everything stays inside the agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PartnerTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PartnerService partnerService;
    @Autowired private PartnerHandoffService handoffService;
    @Autowired private ClientService clientService;
    @Autowired private ClientDuplicateService duplicateService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private PartnerRepository partnerRepository;
    @Autowired private PartnerHandoffRepository handoffRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private RecordChangeRepository changeRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User colleague;
    private User teamAgent;
    private User manager;
    private User stranger;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("pt-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("pt-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        teamAgent = user("pt-team@almaty.kz", "Dana Seitova", Role.AGENT, DataScope.TEAM, almaty);
        manager = user("pt-manager@almaty.kz", "Marat Manager", Role.MANAGER, DataScope.TEAM, almaty);
        stranger = user("pt-stranger@astana.kz", "Erlan Other", Role.MANAGER, DataScope.TEAM, astana);
        signIn(agent);
    }

    // The directory ---------------------------------------------------------------------

    @Test
    @DisplayName("a partner is the agency's: every colleague sees it, another agency is told it does not exist")
    void directory() {
        PartnerResponse broker = partnerService.create(partner("  Ainur Sadykova ", PartnerKind.MORTGAGE_BROKER,
                ReferralFeeType.PERCENT, "20"));
        partnerService.create(partner("Notary Bekov", PartnerKind.LAWYER, null, null));

        assertThat(broker.getName()).isEqualTo("Ainur Sadykova");
        assertThat(broker.getCreatedById()).isEqualTo(agent.getId());
        assertThat(broker.getCreatedByName()).isEqualTo("Aigul Bekova");
        assertThat(broker.isCanEdit()).isTrue();
        assertThat(broker.getReferredClients()).isZero();
        assertThat(broker.getFeesOwed()).isEqualByComparingTo("0");

        signIn(colleague);
        assertThat(partnerService.list(null, null)).extracting(PartnerResponse::getName)
                .containsExactly("Ainur Sadykova", "Notary Bekov");
        assertThat(partnerService.list(PartnerKind.LAWYER, null)).extracting(PartnerResponse::getName)
                .containsExactly("Notary Bekov");
        assertThat(partnerService.list(null, "halyk")).extracting(PartnerResponse::getName)
                .containsExactly("Ainur Sadykova");
        assertThat(partnerService.get(broker.getId()).isCanEdit()).isFalse();

        signIn(stranger);
        assertThat(partnerService.list(null, null)).isEmpty();
        assertThatThrownBy(() -> partnerService.get(broker.getId())).isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("a referral fee is both halves or neither: a percent above 0 and at most 100, or an amount above 0")
    void feeRule() throws Exception {
        String base = "{\"name\":\"Broker\",\"kind\":\"MORTGAGE_BROKER\"";
        for (String bad : List.of(",\"feeType\":\"PERCENT\"}", ",\"feeValue\":10}",
                ",\"feeType\":\"PERCENT\",\"feeValue\":0}", ",\"feeType\":\"PERCENT\",\"feeValue\":101}",
                ",\"feeType\":\"FIXED\",\"feeValue\":-5}")) {
            mockMvc.perform(post("/partners").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                            .contentType(MediaType.APPLICATION_JSON).content(base + bad))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.code").value("INVALID_REFERRAL_FEE"));
        }
        mockMvc.perform(post("/partners").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(base + ",\"feeType\":\"FIXED\",\"feeValue\":150000}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.feeType").value("FIXED"))
                .andExpect(jsonPath("$.canEdit").value(true));
        mockMvc.perform(get("/partners").header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].feeValue").value(150000));
    }

    @Test
    @DisplayName("whoever added a partner, a manager or an admin changes it; a colleague may not")
    void editing() {
        Long id = partnerService.create(partner("Appraiser Ltd", PartnerKind.APPRAISER, null, null)).getId();

        signIn(colleague);
        assertThatThrownBy(() -> partnerService.update(id, partner("Mine now", PartnerKind.OTHER, null, null)))
                .isInstanceOf(AccessDeniedException.class);
        assertThatThrownBy(() -> partnerService.delete(id)).isInstanceOf(AccessDeniedException.class);

        signIn(manager);
        PartnerResponse changed = partnerService.update(id,
                partner("Appraiser Ltd", PartnerKind.APPRAISER, ReferralFeeType.FIXED, "50000"));
        assertThat(changed.getFeeValue()).isEqualByComparingTo("50000");
        assertThat(changed.getCreatedById()).as("editing does not change who added it").isEqualTo(agent.getId());

        signIn(stranger);
        assertThatThrownBy(() -> partnerService.delete(id)).isInstanceOf(ResourceNotFoundException.class);
    }

    // Referrals -------------------------------------------------------------------------

    @Test
    @DisplayName("a client sent by a partner has the lead source PARTNER and the partner beside it")
    void referredBy() throws Exception {
        Long broker = partnerService.create(partner("Ainur Sadykova", PartnerKind.MORTGAGE_BROKER, null, null)).getId();
        signIn(stranger);
        Long theirs = partnerService.create(partner("Astana Broker", PartnerKind.MORTGAGE_BROKER, null, null)).getId();
        signIn(agent);

        String body = "{\"fullName\":\"Saule\",\"type\":\"BUYER\",\"leadSource\":\"PARTNER\"";
        mockMvc.perform(post("/clients").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body + "}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PARTNER_REQUIRED"));
        mockMvc.perform(post("/clients").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body + ",\"referredByPartnerId\":" + theirs + "}"))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/clients").header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON).content(body + ",\"referredByPartnerId\":" + broker + "}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.leadSource").value("PARTNER"))
                .andExpect(jsonPath("$.referredByPartnerId").value(broker))
                .andExpect(jsonPath("$.referredByPartnerName").value("Ainur Sadykova"));

        signIn(agent);
        Client saule = clientRepository.findAll().stream()
                .filter(c -> c.getFullName().equals("Saule")).findFirst().orElseThrow();

        ClientRequest noSource = clientRequest("Saule K");
        ClientResponse renamed = clientService.update(saule.getId(), noSource);
        assertThat(renamed.getReferredByPartnerId()).as("a save without the lead source leaves the partner").isEqualTo(broker);

        ClientRequest website = clientRequest("Saule K");
        website.setLeadSource(LeadSource.WEBSITE);
        website.setReferredByPartnerId(broker);
        ClientResponse moved = clientService.update(saule.getId(), website);
        assertThat(moved.getLeadSource()).isEqualTo(LeadSource.WEBSITE);
        assertThat(moved.getReferredByPartnerId()).as("another source drops the partner").isNull();
    }

    @Test
    @DisplayName("the change log names the partner a client came from")
    void changeLog() {
        Long broker = partnerService.create(partner("Ainur Sadykova", PartnerKind.MORTGAGE_BROKER, null, null)).getId();
        ClientResponse client = clientService.create(clientRequest("Saule"));

        ClientRequest edit = clientRequest("Saule");
        edit.setLeadSource(LeadSource.PARTNER);
        edit.setReferredByPartnerId(broker);
        clientService.update(client.getId(), edit);

        assertThat(changeRepository.findByEntityTypeAndEntityIdOrderByIdAsc(ChangeEntityType.CLIENT, client.getId()))
                .filteredOn(line -> line.getField() != null)
                .extracting(RecordChange::getField, RecordChange::getOldValue, RecordChange::getNewValue)
                .contains(tuple("leadSource", null, "PARTNER"), tuple("referredBy", null, "Ainur Sadykova"));
    }

    @Test
    @DisplayName("a partner's numbers: referred clients, their won deals and the fee on each, rents on a month's rent")
    void stats() {
        Partner broker = partnerRepository.findById(partnerService.create(
                partner("Ainur Sadykova", PartnerKind.MORTGAGE_BROKER, ReferralFeeType.PERCENT, "20")).getId()).orElseThrow();
        Client mine = referred("Saule", agent, broker);
        Client theirs = referred("Erlan", colleague, broker);
        referred("Nobody won", agent, broker);
        deal(mine, DealStatus.CLOSED_WON, DealKind.SALE, "30000000", "3");      // 900 000 commission, 180 000 fee
        deal(mine, DealStatus.CLOSED_LOST, DealKind.SALE, "10000000", "3");     // lost: nothing
        deal(theirs, DealStatus.CLOSED_WON, DealKind.RENT, "500000", "100");    // one month's rent, 100 000 fee
        deal(theirs, DealStatus.CLOSED_WON, DealKind.SALE, "20000000", null);   // no commission recorded
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        PartnerResponse all = partnerService.get(broker.getId());
        assertThat(all.getReferredClients()).isEqualTo(3);
        assertThat(all.getWonDeals()).isEqualTo(3);
        assertThat(all.getFeesOwed()).isEqualByComparingTo("280000");
        assertThat(all.getWonDealsWithoutCommission()).isEqualTo(1);

        List<PartnerReferralResponse> referrals = partnerService.referrals(broker.getId());
        assertThat(referrals).extracting(PartnerReferralResponse::getFullName, PartnerReferralResponse::getWonDeals)
                .containsExactlyInAnyOrder(tuple("Saule", 1L), tuple("Erlan", 2L), tuple("Nobody won", 0L));
        assertThat(referrals).filteredOn(r -> r.getFullName().equals("Erlan")).first()
                .satisfies(r -> {
                    assertThat(r.getFeeOwed()).isEqualByComparingTo("100000");
                    assertThat(r.getWonDealsWithoutCommission()).isEqualTo(1);
                });

        signIn(agent);
        PartnerResponse own = partnerService.get(broker.getId());
        assertThat(own.getReferredClients()).as("an agent on their own records counts their own").isEqualTo(2);
        assertThat(own.getWonDeals()).isEqualTo(1);
        assertThat(own.getFeesOwed()).isEqualByComparingTo("180000");
        assertThat(partnerService.referrals(broker.getId())).extracting(PartnerReferralResponse::getFullName)
                .containsExactlyInAnyOrder("Saule", "Nobody won");

        signIn(manager);
        partnerService.update(broker.getId(), partner("Ainur Sadykova", PartnerKind.MORTGAGE_BROKER,
                ReferralFeeType.FIXED, "50000"));
        PartnerResponse fixed = partnerService.get(broker.getId());
        assertThat(fixed.getFeesOwed()).as("a fixed fee is owed once per won deal").isEqualByComparingTo("150000");
        assertThat(fixed.getWonDealsWithoutCommission()).isZero();
    }

    // Hand-offs -------------------------------------------------------------------------

    @Test
    @DisplayName("a client is sent to a partner, moved along, and listed from both ends behind the client's wall")
    void handoffs() throws Exception {
        Long notary = partnerService.create(partner("Notary Bekov", PartnerKind.LAWYER, null, null)).getId();
        Client saule = clientRepository.save(Client.builder().fullName("Saule").type(ClientType.BUYER)
                .agent(agent).team(almaty).build());

        PartnerHandoffResponse sent = handoffService.create(saule.getId(), handoff(notary, null, null, "  Papers for the sale "));
        assertThat(sent.getStatus()).isEqualTo(PartnerHandoffStatus.SENT);
        assertThat(sent.getSentOn()).isEqualTo(LocalDate.now());
        assertThat(sent.getNote()).isEqualTo("Papers for the sale");
        assertThat(sent.getSentByName()).isEqualTo("Aigul Bekova");
        assertThat(sent.getPartnerName()).isEqualTo("Notary Bekov");

        PartnerHandoffResponse moved = handoffService.update(saule.getId(), sent.getId(),
                handoff(notary, LocalDate.now().minusDays(2), PartnerHandoffStatus.IN_PROGRESS, null));
        assertThat(moved.getStatus()).isEqualTo(PartnerHandoffStatus.IN_PROGRESS);
        assertThat(moved.getSentOn()).isEqualTo(LocalDate.now().minusDays(2));

        assertThatThrownBy(() -> handoffService.create(saule.getId(),
                handoff(notary, LocalDate.now().plusDays(1), null, null)))
                .isInstanceOf(BusinessException.class).hasMessageContaining("still to come");

        assertThat(handoffService.forClient(saule.getId())).extracting(PartnerHandoffResponse::getId)
                .containsExactly(sent.getId());
        assertThat(partnerService.get(notary).getHandoffs()).isEqualTo(1);
        assertThat(partnerService.get(notary).getOpenHandoffs()).isEqualTo(1);

        signIn(colleague);
        assertThatThrownBy(() -> handoffService.forClient(saule.getId())).isInstanceOf(ResourceNotFoundException.class);
        assertThat(partnerService.handoffs(notary)).as("a colleague on their own records does not see it").isEmpty();

        signIn(teamAgent);
        assertThat(partnerService.handoffs(notary)).extracting(PartnerHandoffResponse::getClientName)
                .containsExactly("Saule");

        signIn(stranger);
        Long theirs = partnerService.create(partner("Astana Notary", PartnerKind.LAWYER, null, null)).getId();
        signIn(agent);
        assertThatThrownBy(() -> handoffService.create(saule.getId(), handoff(theirs, null, null, null)))
                .isInstanceOf(ResourceNotFoundException.class);

        mockMvc.perform(delete("/clients/{c}/partner-handoffs/{h}", saule.getId(), sent.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNoContent());
        assertThat(handoffRepository.count()).isZero();
    }

    // Deleting and what outlives what -------------------------------------------------------

    @Test
    @DisplayName("a partner a client points at cannot be deleted; one nothing points at can")
    void deleting() throws Exception {
        Partner broker = partnerRepository.findById(
                partnerService.create(partner("Broker", PartnerKind.MORTGAGE_BROKER, null, null)).getId()).orElseThrow();
        Partner notary = partnerRepository.findById(
                partnerService.create(partner("Notary", PartnerKind.LAWYER, null, null)).getId()).orElseThrow();
        Long unused = partnerService.create(partner("Unused", PartnerKind.OTHER, null, null)).getId();
        referred("Saule", colleague, broker);
        Client erlan = clientRepository.save(Client.builder().fullName("Erlan").type(ClientType.BUYER)
                .agent(agent).team(almaty).build());
        handoffService.create(erlan.getId(), handoff(notary.getId(), null, null, null));

        for (Long id : List.of(broker.getId(), notary.getId())) {
            mockMvc.perform(delete("/partners/{id}", id).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                    .andExpect(status().isConflict())
                    .andExpect(jsonPath("$.code").value("PARTNER_IN_USE"));
        }
        mockMvc.perform(delete("/partners/{id}", unused).header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNoContent());
        assertThat(partnerRepository.findById(unused)).isEmpty();
    }

    @Test
    @DisplayName("merging two cards keeps the target's source, fills a blank one, and moves the hand-offs")
    void merge() {
        Partner broker = partnerRepository.findById(
                partnerService.create(partner("Broker", PartnerKind.MORTGAGE_BROKER, null, null)).getId()).orElseThrow();
        Long notary = partnerService.create(partner("Notary", PartnerKind.LAWYER, null, null)).getId();
        Client target = clientRepository.save(Client.builder().fullName("Saule").type(ClientType.BUYER)
                .agent(agent).team(almaty).build());
        Client source = referred("Saule again", agent, broker);
        handoffService.create(source.getId(), handoff(notary, null, null, null));
        entityManager.flush();
        entityManager.clear();

        signIn(manager);
        ClientResponse merged = duplicateService.merge(target.getId(), source.getId());

        assertThat(merged.getLeadSource()).isEqualTo(LeadSource.PARTNER);
        assertThat(merged.getReferredByPartnerName()).isEqualTo("Broker");
        assertThat(handoffService.forClient(target.getId())).extracting(PartnerHandoffResponse::getPartnerName)
                .containsExactly("Notary");
        assertThat(partnerService.get(broker.getId()).getReferredClients()).isEqualTo(1);
    }

    @Test
    @DisplayName("the partners a leaver added stay with the agency, with their successor or with nobody")
    void accountRemoval() {
        User leaver = user("pt-leaver@almaty.kz", "Leaving Agent", Role.AGENT, DataScope.TEAM, almaty);
        User other = user("pt-other@almaty.kz", "Other Leaver", Role.AGENT, DataScope.TEAM, almaty);
        Client saule = clientRepository.save(Client.builder().fullName("Saule").type(ClientType.BUYER)
                .agent(agent).team(almaty).build());
        signIn(leaver);
        Long kept = partnerService.create(partner("Broker", PartnerKind.MORTGAGE_BROKER, null, null)).getId();
        Long handoff = handoffService.create(saule.getId(), handoff(kept, null, null, null)).getId();
        signIn(other);
        Long orphan = partnerService.create(partner("Notary", PartnerKind.LAWYER, null, null)).getId();

        accountRemovalService.remove(manager, leaver, manager.getId(), "DELETE_USER");
        accountRemovalService.remove(manager, other, null, "DELETE_USER");
        entityManager.flush();
        entityManager.clear();

        signIn(agent);
        assertThat(partnerService.get(kept).getCreatedById()).isEqualTo(manager.getId());
        assertThat(partnerService.get(orphan).getCreatedById()).isNull();
        assertThat(partnerService.get(orphan).isCanEdit()).isFalse();
        assertThat(handoffRepository.findById(handoff)).get()
                .satisfies(h -> assertThat(h.getSentBy()).isNull());
    }

    // Helpers ---------------------------------------------------------------------------

    private static PartnerRequest partner(String name, PartnerKind kind, ReferralFeeType feeType, String fee) {
        PartnerRequest request = new PartnerRequest();
        request.setName(name);
        request.setKind(kind);
        request.setCompany(kind == PartnerKind.MORTGAGE_BROKER ? "Halyk Bank" : null);
        request.setFeeType(feeType);
        request.setFeeValue(fee == null ? null : new BigDecimal(fee));
        return request;
    }

    private static PartnerHandoffRequest handoff(Long partnerId, LocalDate on, PartnerHandoffStatus status, String note) {
        PartnerHandoffRequest request = new PartnerHandoffRequest();
        request.setPartnerId(partnerId);
        request.setSentOn(on);
        request.setStatus(status);
        request.setNote(note);
        return request;
    }

    private static ClientRequest clientRequest(String name) {
        ClientRequest request = new ClientRequest();
        request.setFullName(name);
        request.setType(ClientType.BUYER);
        return request;
    }

    private Client referred(String name, User holder, Partner partner) {
        return clientRepository.save(Client.builder().fullName(name).type(ClientType.BUYER)
                .leadSource(LeadSource.PARTNER).referredBy(partner)
                .agent(holder).team(almaty).build());
    }

    private void deal(Client client, DealStatus status, DealKind kind, String amount, String percent) {
        Deal.DealBuilder deal = Deal.builder().title(status.name()).status(status).kind(kind)
                .client(client).agent(client.getAgent()).team(almaty)
                .commissionPercent(percent == null ? null : new BigDecimal(percent));
        if (kind == DealKind.RENT) {
            deal.monthlyRent(new BigDecimal(amount))
                    .leaseStart(LocalDate.now().minusMonths(1)).leaseEnd(LocalDate.now().plusMonths(11));
        } else {
            deal.dealPrice(new BigDecimal(amount));
        }
        dealRepository.save(deal.build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /**
     * The token for a request as {@code who}. The JWT filter keeps an authentication that is
     * already there, so the test's own is switched to the same person.
     */
    private String bearer(User who) {
        signIn(who);
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
