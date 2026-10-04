package com.crm.realestate.integration;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.service.imports.CsvTable;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The book taken out as a spreadsheet: the bytes Excel expects, headings in the caller's language,
 * the list's filters, exactly the caller's visibility, managers only, a cap, and a journal entry.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class CsvExportTest extends CsvExportFixture {

    @Test
    @DisplayName("Russian clients: BOM, semicolons, CRLF, quoted notes, labels the importer reads")
    void clientsInRussian() throws Exception {
        signIn(manager);
        String today = LocalDate.now().toString();
        export("clients", "lang", "ru", "search", "Бекова")
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", startsWith("text/csv")))
                .andExpect(header().string("Content-Disposition",
                        "attachment; filename=\"clients-" + today + ".csv\"; filename*=UTF-8''clients-"
                                + today + ".csv"))
                .andExpect(header().string("X-Export-Rows", "1"));
        String text = text("clients", "lang", "ru", "search", "Бекова");

        assertThat(text).startsWith("ФИО;Телефон;Email;Тип;Агент;Город;Тип недвижимости;Бюджет от;"
                + "Бюджет до;Комнаты;Площадь;Примечание;Теги;Источник лида;"
                + "Источник лида: подробности;День рождения;Источник;Создан\r\n");
        assertThat(text).contains("Бекова Айгерим;+77011112233;aigerim@mail.kz;Покупатель;Arman Agent;"
                + "Алматы;Квартира;30000000;45000000,5;2;55,5;"
                + "\"Звонить после 18:00; \"\"срочно\"\", 2 комнаты\nлучше центр\";;Рекомендация;Дана, соседка;--05-14;С публичной ссылки;");
        assertThat(text).matches("(?s).*;\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}\r\n$");
        // The only bare LF is the one inside the quoted note.
        assertThat(text.replace("\r\n", "").chars().filter(c -> c == '\n').count()).isEqualTo(1);
    }

    @Test
    @DisplayName("English uses commas by default; semicolon can be asked for; Kazakh headings")
    void languagesAndDelimiters() throws Exception {
        signIn(manager);
        assertThat(text("clients", "search", "Бекова")).startsWith(
                "Full name,Phone,Email,Type,Agent,City,Property type,Budget from,Budget to,Rooms,"
                        + "Area,Notes,Tags,Lead source,Lead source detail,Birthday,Source,Created\r\n")
                .contains(",Buyer,", ",45000000.5,", ",Referral,\"Дана, соседка\",--05-14,Public link,",
                        "\"Звонить после 18:00; \"\"срочно\"\", 2 комнаты\nлучше центр\"");
        assertThat(text("clients", "lang", "en", "delimiter", "semicolon")).startsWith("Full name;Phone;");
        assertThat(text("properties", "lang", "kk")).startsWith(
                "Атауы;Мекенжай;Қала;Түрі;Мәртебе;Баға;Аудан;Бөлме саны;Қабат;Қабат саны;Сипаттама;"
                        + "Агент;Құрылған;Сілтеме қаралымы\r\n")
                .contains(";Пәтер;Сатылымда;42500000;61,4;2;5;9;");
        export("clients", "delimiter", "tab").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EXPORT_BAD_DELIMITER"));
    }

    @Test
    @DisplayName("the list's filters narrow the export")
    void filters() throws Exception {
        signIn(manager);
        assertThat(rows("clients", "type", "SELLER")).extracting(r -> r.get(0)).containsExactly("Алиев Тимур");
        assertThat(rows("clients", "source", "PUBLIC_LINK")).extracting(r -> r.get(0)).containsExactly("Бекова Айгерим");
        assertThat(rows("clients", "agentId", manager.getId().toString())).hasSize(1);
        assertThat(rows("properties", "status", "SOLD")).extracting(r -> r.get(0)).containsExactly("Дом в Талгаре");
        assertThat(rows("properties", "city", "алматы", "minPrice", "40000000")).hasSize(1);
        assertThat(rows("deals", "status", "CLOSED_WON")).hasSize(1);
        assertThat(rows("deals", "closedFrom", "2026-09-01", "closedTo", "2026-09-30")).hasSize(1);
        assertThat(rows("deals", "createdFrom", "2000-01-01")).hasSize(2);
        export("clients", "type", "TENANT").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EXPORT_BAD_FILTER"));
    }

    @Test
    @DisplayName("deals: status, client, listing, commission worked out, closed date, lost reason")
    void deals() throws Exception {
        signIn(manager);
        String text = text("deals", "lang", "ru");
        assertThat(text).startsWith("Название;Статус;Клиент;Объект;Цена сделки;Бюджет;Комиссия %;"
                + "Комиссия;Агент;Создана;Закрыта;Причина проигрыша;Комментарий к проигрышу;Сплит комиссии\r\n");
        assertThat(text).contains("Айгерим — Абая 10;Выиграна;Бекова Айгерим;2-комн., Абая 10;"
                + "42000000;;2,5;1050000;Arman Agent;");
        assertThat(text).contains(";2026-09-10 14:30;;;\r\n");
        assertThat(text).contains("Lost one;Проиграна;Бекова Айгерим;;;;;;Dana Manager;")
                .contains(";Цена;\"Too expensive, \"\"sorry\"\"\";\r\n");
    }

    @Test
    @DisplayName("exactly the caller's visibility, and never another agency's")
    void scope() throws Exception {
        signIn(manager);
        assertThat(rows("clients")).extracting(r -> r.get(0))
                .containsExactlyInAnyOrder("Бекова Айгерим", "Алиев Тимур", "Own Client");
        assertThat(rows("properties")).hasSize(2);
        signIn(ownManager);
        assertThat(rows("clients")).extracting(r -> r.get(0)).containsExactly("Own Client");
        assertThat(rows("deals")).isEmpty();
        signIn(admin);
        assertThat(rows("clients")).hasSize(3).noneMatch(r -> r.get(0).equals("Astana Secret"));
        assertThat(rows("properties")).noneMatch(r -> r.get(0).equals("Astana office"));
        signIn(stranger);
        assertThat(rows("clients")).extracting(r -> r.get(0)).containsExactly("Astana Secret");
        assertThat(rows("clients", "agentId", agent.getId().toString())).isEmpty();
    }

    @Test
    @DisplayName("an agent cannot export at all, not even their own clients")
    void agentsCannotExport() throws Exception {
        signIn(agent);
        for (String kind : List.of("clients", "properties", "deals")) {
            export(kind).andExpect(status().isForbidden());
        }
        assertThat(audit()).isEmpty();
        export("tasks").andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("over the cap is a clear 400, written nowhere and journalled nowhere")
    void rowCap() throws Exception {
        ReflectionTestUtils.setField(exportService, "maxRows", 2);
        signIn(manager);
        export("clients").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EXPORT_TOO_MANY_ROWS"))
                .andExpect(jsonPath("$.message", containsString("at most 2 rows")));
        assertThat(audit()).isEmpty();
        assertThat(rows("clients", "type", "SELLER")).hasSize(1);
    }

    @Test
    @DisplayName("every export is journalled with who, what, the filters and the row count")
    void audited() throws Exception {
        signIn(manager);
        bytes("clients", "lang", "ru", "type", "SELLER", "search", "Тимур");
        List<AuditLog> entries = audit();
        assertThat(entries).hasSize(1);
        AuditLog entry = entries.get(0);
        assertThat(entry.getAction()).isEqualTo("EXPORT_CLIENTS");
        assertThat(entry.getActor().getId()).isEqualTo(manager.getId());
        assertThat(entry.getEntityType()).isEqualTo("Team");
        assertThat(entry.getEntityId()).isEqualTo(almaty.getId());
        assertThat(entry.getMetadata()).isEqualTo("rows=1 lang=ru type=SELLER search=Тимур");
    }

    /** Data rows of an export, parsed back the way the importer parses a file. */
    private List<List<String>> rows(String kind, String... params) throws Exception {
        byte[] bytes = bytes(kind, params);
        assertThat(new String(bytes, StandardCharsets.UTF_8)).isNotEmpty();
        return CsvTable.parse(bytes, 1000).rows().stream().map(CsvTable.Row::cells).toList();
    }
}
