package com.crm.realestate.integration;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.exports.ExportService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Shared setting for the export tests: two agencies, a manager, an agent on OWN scope and an
 * admin in Almaty, and a few records in each agency.
 */
abstract class CsvExportFixture {

    @Autowired protected MockMvc mockMvc;
    @Autowired protected ClientRepository clientRepository;
    @Autowired protected PropertyRepository propertyRepository;
    @Autowired protected DealRepository dealRepository;
    @Autowired protected AuditLogRepository auditLogRepository;
    @Autowired protected UserRepository userRepository;
    @Autowired protected TeamRepository teamRepository;
    @Autowired protected ExportService exportService;

    protected Team almaty;
    protected Team astana;
    protected User manager;
    protected User ownManager;
    protected User agent;
    protected User admin;
    protected User stranger;
    protected Client aigerim;
    protected Property flat;

    @BeforeEach
    void seed() {
        SecurityContextHolder.clearContext();
        auditLogRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Dana Manager", Role.MANAGER, DataScope.TEAM, almaty);
        ownManager = user("own@almaty.kz", "Own Manager", Role.MANAGER, DataScope.OWN, almaty);
        agent = user("agent@almaty.kz", "Arman Agent", Role.AGENT, DataScope.OWN, almaty);
        admin = user("admin@almaty.kz", "Admin", Role.ADMIN, DataScope.ALL, almaty);
        stranger = user("manager@astana.kz", "Astana Manager", Role.MANAGER, DataScope.TEAM, astana);

        aigerim = clientRepository.save(Client.builder().fullName("Бекова Айгерим")
                .phone("+77011112233").email("aigerim@mail.kz").type(ClientType.BUYER)
                .notes("Звонить после 18:00; \"срочно\", 2 комнаты\nлучше центр")
                .wantedCity("Алматы").wantedType(PropertyType.APARTMENT)
                .budgetMin(new BigDecimal("30000000")).budgetMax(new BigDecimal("45000000.50"))
                .minRooms(2).minAreaSqm(55.5).source(ClientSource.PUBLIC_LINK)
                .leadSource(com.crm.realestate.enums.LeadSource.REFERRAL).leadSourceDetail("Дана, соседка")
                .birthMonth(5).birthDay(14)
                .agent(agent).team(almaty).build());
        clientRepository.save(Client.builder().fullName("Алиев Тимур").phone("+77025556677")
                .type(ClientType.SELLER).agent(manager).team(almaty).build());
        clientRepository.save(Client.builder().fullName("Own Client").phone("+77030000000")
                .type(ClientType.BUYER).agent(ownManager).team(almaty).build());
        clientRepository.save(Client.builder().fullName("Astana Secret").phone("+77770000000")
                .type(ClientType.BUYER).agent(stranger).team(astana).build());

        flat = propertyRepository.save(Property.builder().title("2-комн., Абая 10")
                .address("Абая 10, кв 5").city("Алматы").type(PropertyType.APARTMENT)
                .status(PropertyStatus.AVAILABLE).price(new BigDecimal("42500000"))
                .areaSqm(61.4).rooms(2).floor(5).totalFloors(9).description("Светлая, с ремонтом")
                .agent(agent).team(almaty).build());
        propertyRepository.save(Property.builder().title("Дом в Талгаре").address("Талгар, Садовая 3")
                .city("Талгар").type(PropertyType.HOUSE).status(PropertyStatus.SOLD)
                .price(new BigDecimal("80000000")).agent(manager).team(almaty).build());
        propertyRepository.save(Property.builder().title("Astana office").address("Kabanbay 1")
                .city("Astana").type(PropertyType.OFFICE).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("1")).agent(stranger).team(astana).build());

        dealRepository.save(Deal.builder().title("Айгерим — Абая 10")
                .status(DealStatus.CLOSED_WON).client(aigerim).property(flat).agent(agent).team(almaty)
                .dealPrice(new BigDecimal("42000000")).commissionPercent(new BigDecimal("2.5"))
                .closedAt(LocalDateTime.of(2026, 9, 10, 14, 30))
                .build());
        dealRepository.save(Deal.builder().title("Lost one").status(DealStatus.CLOSED_LOST)
                .client(aigerim).agent(manager).team(almaty).lostReason(DealLostReason.PRICE)
                .lostNote("Too expensive, \"sorry\"").build());
    }

    @AfterEach
    void restoreCap() {
        ReflectionTestUtils.setField(exportService, "maxRows", ExportService.MAX_ROWS);
    }

    protected User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    protected void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    protected ResultActions export(String kind, String... params) throws Exception {
        var request = get("/export/" + kind);
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        return mockMvc.perform(request);
    }

    protected byte[] bytes(String kind, String... params) throws Exception {
        return export(kind, params).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsByteArray();
    }

    /** The file after its byte-order mark, which every export must start with. */
    protected String text(String kind, String... params) throws Exception {
        byte[] bytes = bytes(kind, params);
        assertThat(new byte[]{bytes[0], bytes[1], bytes[2]})
                .containsExactly((byte) 0xEF, (byte) 0xBB, (byte) 0xBF);
        return new String(bytes, 3, bytes.length - 3, StandardCharsets.UTF_8);
    }

    protected List<AuditLog> audit() {
        return auditLogRepository.findAll();
    }
}
