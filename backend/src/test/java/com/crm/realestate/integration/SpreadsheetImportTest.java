package com.crm.realestate.integration;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.imports.CsvTable;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.util.Comparator;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * An agency's book brought in from a spreadsheet: checked without writing, then only the rows that
 * are sound go in, into the importer's agency, and the run is journalled.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class SpreadsheetImportTest {

    private static final String CLIENTS_RU = """
            ФИО;Телефон;Email;Тип;Город;Бюджет до;Комнаты
            Бекова Айгерим;+7 701 111 22 33;;Покупатель;Алматы;45 млн;2
            Алиев Тимур;8 (702) 555-66-77;timur@mail.kz;продавец;;;
            ;8 703 000 00 00;;покупатель;;;
            Сейтжан Мадина;87025556677;;покупатель;Астана;30 000 000;3
            Нурлан;8 704 123 45 67;SHARED@mail.kz;;;;
            Ерлан;8 705 222 33 44;;арендатор;;;
            """;

    @Autowired private MockMvc mockMvc;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;

    private Team almaty;
    private User manager;
    private User agent;
    private User stranger;
    private User admin;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        auditLogRepository.deleteAll();
        clientRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", Role.MANAGER, almaty);
        agent = user("agent@almaty.kz", Role.AGENT, almaty);
        stranger = user("agent@astana.kz", Role.AGENT, astana);
        admin = user("admin@almaty.kz", Role.ADMIN, almaty);

        // Already in the agency, typed differently from the sheet: Нурлан's email.
        clientRepository.save(Client.builder().fullName("Nurlan S.").email("shared@mail.kz")
                .type(ClientType.BUYER).agent(agent).team(almaty).build());
        // The same address in another agency is not a duplicate here.
        clientRepository.save(Client.builder().fullName("Other").phone("+7 701 111 22 33")
                .type(ClientType.BUYER).agent(stranger).team(astana).build());
    }

    @Test
    @DisplayName("a preview reads a Russian semicolon sheet, suggests the mapping and writes nothing")
    void previewWritesNothing() throws Exception {
        signIn(manager);
        long before = clientRepository.count();
        upload("clients", "preview", CLIENTS_RU.getBytes(StandardCharsets.UTF_8))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.delimiter").value(";"))
                .andExpect(jsonPath("$.encoding").value("UTF_8"))
                .andExpect(jsonPath("$.mapping[0]").value("fullName"))
                .andExpect(jsonPath("$.mapping[1]").value("phone"))
                .andExpect(jsonPath("$.mapping[3]").value("type"))
                .andExpect(jsonPath("$.mapping[4]").value("wantedCity"))
                .andExpect(jsonPath("$.mapping[5]").value("budgetMax"))
                .andExpect(jsonPath("$.totalRows").value(6))
                .andExpect(jsonPath("$.validRows").value(2))
                .andExpect(jsonPath("$.invalidRows").value(2))
                .andExpect(jsonPath("$.duplicateRows").value(2))
                .andExpect(jsonPath("$.problems[0].row").value(4))
                .andExpect(jsonPath("$.problems[0].errors.fullName").value("REQUIRED"))
                .andExpect(jsonPath("$.problems[1].row").value(5))
                .andExpect(jsonPath("$.problems[1].duplicate.source").value("FILE"))
                .andExpect(jsonPath("$.problems[1].duplicate.row").value(3))
                .andExpect(jsonPath("$.problems[2].duplicate.source").value("AGENCY"))
                .andExpect(jsonPath("$.problems[2].duplicate.matchedOn").value("EMAIL"))
                .andExpect(jsonPath("$.problems[2].duplicate.clientName").value("Nurlan S."))
                .andExpect(jsonPath("$.problems[3].errors.type").value("UNKNOWN_VALUE"))
                .andExpect(jsonPath("$.sample[0].values.budgetMax").value("45000000"));
        assertThat(clientRepository.count()).isEqualTo(before);
        assertThat(auditLogRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("Windows-1251 from a Russian Excel previews as Cyrillic")
    void windows1251() throws Exception {
        signIn(manager);
        upload("clients", "preview", CLIENTS_RU.getBytes(CsvTable.WINDOWS_1251))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.encoding").value("WINDOWS_1251"))
                .andExpect(jsonPath("$.headers[0]").value("ФИО"))
                .andExpect(jsonPath("$.sample[0].values.fullName").value("Бекова Айгерим"));
    }

    @Test
    @DisplayName("a commit writes only the valid rows, skips duplicates, and journals the run")
    void commitValidRowsOnly() throws Exception {
        signIn(manager);
        long before = clientRepository.count();
        upload("clients", "commit", CLIENTS_RU.getBytes(StandardCharsets.UTF_8))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.totalRows").value(6))
                .andExpect(jsonPath("$.created").value(2))
                .andExpect(jsonPath("$.skippedDuplicates").value(2))
                .andExpect(jsonPath("$.invalid").value(2))
                .andExpect(jsonPath("$.assignedToId").value(manager.getId()));

        List<Client> created = clientRepository.findAll().stream()
                .filter(c -> c.getTeam() != null && c.getTeam().getId().equals(almaty.getId()))
                .filter(c -> !c.getFullName().equals("Nurlan S."))
                .sorted(Comparator.comparing(Client::getFullName)).toList();
        assertThat(clientRepository.count()).isEqualTo(before + 2);
        assertThat(created).extracting(Client::getFullName).containsExactly("Алиев Тимур", "Бекова Айгерим");
        Client aigerim = created.get(1);
        assertThat(aigerim.getAgent().getId()).isEqualTo(manager.getId());
        assertThat(aigerim.getPhoneNormalized()).isEqualTo("77011112233");
        assertThat(aigerim.getBudgetMax()).isEqualByComparingTo("45000000");
        assertThat(aigerim.getMinRooms()).isEqualTo(2);
        assertThat(created.get(0).getType()).isEqualTo(ClientType.SELLER);

        List<AuditLog> logs = auditLogRepository.findAll();
        assertThat(logs).hasSize(1);
        assertThat(logs.get(0).getAction()).isEqualTo("IMPORT_CLIENTS");
        assertThat(logs.get(0).getMetadata()).contains("created=2", "skippedDuplicates=2", "invalid=2");
    }

    @Test
    @DisplayName("with duplicates kept, a phone-only duplicate goes in; an email clash never does")
    void keepDuplicates() throws Exception {
        signIn(manager);
        long before = clientRepository.count();
        upload("clients", "commit", CLIENTS_RU.getBytes(StandardCharsets.UTF_8), "skipDuplicates", "false")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created").value(3))
                .andExpect(jsonPath("$.skippedDuplicates").value(1));
        assertThat(clientRepository.count()).isEqualTo(before + 3);
    }

    @Test
    @DisplayName("rows go to a named colleague; another agency's agent reads as missing")
    void assignToAgent() throws Exception {
        signIn(manager);
        upload("clients", "commit", CLIENTS_RU.getBytes(StandardCharsets.UTF_8),
                "assignToAgentId", stranger.getId().toString())
                .andExpect(status().isNotFound());
        assertThat(auditLogRepository.findAll()).isEmpty();

        upload("clients", "commit", CLIENTS_RU.getBytes(StandardCharsets.UTF_8),
                "assignToAgentId", agent.getId().toString())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assignedToId").value(agent.getId()));
        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Бекова Айгерим"))
                .singleElement().satisfies(c -> {
                    assertThat(c.getAgent().getId()).isEqualTo(agent.getId());
                    assertThat(c.getTeam().getId()).isEqualTo(almaty.getId());
                });
    }

    @Test
    @DisplayName("an agent can neither preview, import nor download the template")
    void agentForbidden() throws Exception {
        signIn(agent);
        long before = clientRepository.count();
        upload("clients", "preview", CLIENTS_RU.getBytes(StandardCharsets.UTF_8)).andExpect(status().isForbidden());
        upload("clients", "commit", CLIENTS_RU.getBytes(StandardCharsets.UTF_8)).andExpect(status().isForbidden());
        mockMvc.perform(get("/import/clients/template")).andExpect(status().isForbidden());
        assertThat(clientRepository.count()).isEqualTo(before);
    }

    @Test
    @DisplayName("over 5 MB or over 5000 rows is refused before anything is read into the agency")
    void limits() throws Exception {
        signIn(manager);
        byte[] big = new byte[5 * 1024 * 1024 + 1];
        java.util.Arrays.fill(big, (byte) 'a');
        upload("clients", "preview", big)
                .andExpect(status().isPayloadTooLarge())
                .andExpect(jsonPath("$.code").value("IMPORT_FILE_TOO_LARGE"));

        StringBuilder many = new StringBuilder("ФИО;Телефон\n");
        for (int i = 0; i < 5001; i++) {
            many.append("Client ").append(i).append(";\n");
        }
        upload("clients", "commit", many.toString().getBytes(StandardCharsets.UTF_8))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("IMPORT_TOO_MANY_ROWS"));
        upload("clients", "preview", new byte[0])
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("IMPORT_EMPTY_FILE"));
        assertThat(auditLogRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("a changed mapping is what the rows are read through; a bad one is refused")
    void mappingChange() throws Exception {
        signIn(manager);
        String sheet = "Name;Contact;Extra\nAigerim;Almaty;8 701 999 88 77\n";
        upload("clients", "preview", sheet.getBytes(StandardCharsets.UTF_8))
                .andExpect(jsonPath("$.mapping[0]").value("fullName"))
                .andExpect(jsonPath("$.mapping[2]").doesNotExist());
        upload("clients", "preview", sheet.getBytes(StandardCharsets.UTF_8),
                "mapping", "[\"fullName\",\"wantedCity\",\"phone\"]")
                .andExpect(jsonPath("$.mapping[2]").value("phone"))
                .andExpect(jsonPath("$.sample[0].values.phone").value("8 701 999 88 77"))
                .andExpect(jsonPath("$.sample[0].values.wantedCity").value("Almaty"));
        upload("clients", "preview", sheet.getBytes(StandardCharsets.UTF_8), "mapping", "[\"fullName\"]")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("IMPORT_BAD_MAPPING"));
        upload("clients", "preview", sheet.getBytes(StandardCharsets.UTF_8),
                "mapping", "[\"fullName\",\"fullName\",null]")
                .andExpect(jsonPath("$.code").value("IMPORT_BAD_MAPPING"));
        upload("clients", "preview", sheet.getBytes(StandardCharsets.UTF_8),
                "mapping", "[\"fullName\",\"price\",null]")
                .andExpect(jsonPath("$.code").value("IMPORT_BAD_MAPPING"));
    }

    @Test
    @DisplayName("listings: prices in local formats, synonyms for type and status, floor as 5/9")
    void listings() throws Exception {
        signIn(admin);
        String sheet = """
                Название,Адрес,Город,Тип,Статус,Цена,Площадь,Комнаты,Этаж
                2-к у парка,"Абая 10, кв 5",Алматы,Квартира,В продаже,"12,5 млн","54,3",2,5/9
                Дом,Садовая 1,Алматы,дом,бронь,$250000,120,5,
                Без цены,Абая 1,Алматы,квартира,,договорная,,,
                """;
        upload("properties", "commit", sheet.getBytes(StandardCharsets.UTF_8))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created").value(2))
                .andExpect(jsonPath("$.invalid").value(1));
        List<Property> listings = propertyRepository.findAll().stream()
                .sorted(Comparator.comparing(Property::getPrice)).toList();
        assertThat(listings).hasSize(2);
        Property house = listings.get(0);
        Property flat = listings.get(1);
        assertThat(flat.getAddress()).isEqualTo("Абая 10, кв 5");
        assertThat(flat.getPrice()).isEqualByComparingTo("12500000");
        assertThat(flat.getAreaSqm()).isEqualTo(54.3);
        assertThat(flat.getFloor()).isEqualTo(5);
        assertThat(flat.getTotalFloors()).isEqualTo(9);
        assertThat(flat.getType()).isEqualTo(PropertyType.APARTMENT);
        assertThat(flat.getStatus()).isEqualTo(PropertyStatus.AVAILABLE);
        assertThat(flat.getTeam().getId()).isEqualTo(almaty.getId());
        assertThat(flat.getAgent().getId()).isEqualTo(admin.getId());
        assertThat(house.getType()).isEqualTo(PropertyType.HOUSE);
        assertThat(house.getStatus()).isEqualTo(PropertyStatus.RESERVED);
        assertThat(auditLogRepository.findAll()).singleElement()
                .satisfies(log -> assertThat(log.getAction()).isEqualTo("IMPORT_PROPERTIES"));
    }

    @Test
    @DisplayName("the template is UTF-8 with a byte-order mark, in the language asked for")
    void template() throws Exception {
        signIn(manager);
        byte[] ru = mockMvc.perform(get("/import/clients/template").param("lang", "ru"))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Disposition", org.hamcrest.Matchers.containsString("clients-template.csv")))
                .andReturn().getResponse().getContentAsByteArray();
        assertThat(ru[0] & 0xFF).isEqualTo(0xEF);
        String text = new String(ru, 3, ru.length - 3, StandardCharsets.UTF_8);
        assertThat(text).startsWith("ФИО;Телефон;Email;Тип");

        // What the template says is what a preview recognises.
        upload("clients", "preview", ru)
                .andExpect(jsonPath("$.encoding").value("UTF_8_BOM"))
                .andExpect(jsonPath("$.mapping[?(@ == null)]").isEmpty());
        mockMvc.perform(get("/import/properties/template"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Title,Address,City,Type")));
        mockMvc.perform(get("/import/deals/template")).andExpect(status().isNotFound());
    }

    private ResultActions upload(String kind, String step, byte[] bytes, String... params) throws Exception {
        var request = multipart("/import/" + kind + "/" + step)
                .file(new MockMultipartFile("file", "book.csv", "text/csv", bytes));
        for (int i = 0; i < params.length; i += 2) {
            request.param(params[i], params[i + 1]);
        }
        return mockMvc.perform(request);
    }

    private User user(String email, Role role, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(DataScope.TEAM).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
