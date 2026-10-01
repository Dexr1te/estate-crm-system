package com.crm.realestate.integration;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;

import static org.hamcrest.Matchers.contains;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * What goes out comes back in: an exported sheet, handed to the importer's preview as it is, has
 * every importable column recognised, nothing unreadable, and the same values.
 *
 * <p>The preview is run by a manager of another agency, so the rows are not duplicates of the
 * records they came from and every one is read as a fresh, valid row.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class CsvExportRoundTripTest extends CsvExportFixture {

    @ParameterizedTest(name = "clients in {0}")
    @ValueSource(strings = {"en", "ru", "kk"})
    @DisplayName("clients re-import with every column mapped and nothing invalid")
    void clients(String lang) throws Exception {
        signIn(manager);
        byte[] file = bytes("clients", "lang", lang, "search", "Бекова");
        signIn(stranger);
        preview("clients", file)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.encoding").value("UTF_8_BOM"))
                .andExpect(jsonPath("$.delimiter").value("en".equals(lang) ? "," : ";"))
                .andExpect(jsonPath("$.mapping").value(contains(Arrays.asList(
                        "fullName", "phone", "email", "type", null, "wantedCity", "wantedType",
                        "budgetMin", "budgetMax", "minRooms", "minAreaSqm", "notes", "tags", "birthday", null, null).toArray())))
                .andExpect(jsonPath("$.totalRows").value(1))
                .andExpect(jsonPath("$.invalidRows").value(0))
                .andExpect(jsonPath("$.validRows").value(1))
                .andExpect(jsonPath("$.sample[0].values.fullName").value("Бекова Айгерим"))
                .andExpect(jsonPath("$.sample[0].values.type").value("BUYER"))
                .andExpect(jsonPath("$.sample[0].values.wantedType").value("APARTMENT"))
                .andExpect(jsonPath("$.sample[0].values.budgetMin").value("30000000"))
                .andExpect(jsonPath("$.sample[0].values.budgetMax").value("45000000.5"))
                .andExpect(jsonPath("$.sample[0].values.minAreaSqm").value("55.5"))
                .andExpect(jsonPath("$.sample[0].values.birthday").value("--05-14"))
                .andExpect(jsonPath("$.sample[0].values.notes")
                        .value("Звонить после 18:00; \"срочно\", 2 комнаты\nлучше центр"));
    }

    @ParameterizedTest(name = "whole client book in {0}")
    @ValueSource(strings = {"en", "ru", "kk"})
    @DisplayName("a whole client book re-imports with no invalid row")
    void wholeClientBook(String lang) throws Exception {
        signIn(manager);
        byte[] file = bytes("clients", "lang", lang);
        signIn(stranger);
        preview("clients", file)
                .andExpect(jsonPath("$.totalRows").value(3))
                .andExpect(jsonPath("$.invalidRows").value(0));
    }

    @ParameterizedTest(name = "listings in {0}")
    @ValueSource(strings = {"en", "ru", "kk"})
    @DisplayName("listings re-import with every column mapped and nothing invalid")
    void properties(String lang) throws Exception {
        signIn(manager);
        byte[] file = bytes("properties", "lang", lang);
        signIn(stranger);
        preview("properties", file)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mapping").value(contains(Arrays.asList(
                        "title", "address", "city", "type", "status", "price", "areaSqm", "rooms",
                        "floor", "totalFloors", "description", null, null, null).toArray())))
                .andExpect(jsonPath("$.totalRows").value(2))
                .andExpect(jsonPath("$.invalidRows").value(0))
                .andExpect(jsonPath("$.validRows").value(2))
                .andExpect(jsonPath("$.sample[0].values.title").value("2-комн., Абая 10"))
                .andExpect(jsonPath("$.sample[0].values.type").value("APARTMENT"))
                .andExpect(jsonPath("$.sample[0].values.status").value("AVAILABLE"))
                .andExpect(jsonPath("$.sample[0].values.price").value("42500000"))
                .andExpect(jsonPath("$.sample[0].values.areaSqm").value("61.4"))
                .andExpect(jsonPath("$.sample[0].values.floor").value("5"))
                .andExpect(jsonPath("$.sample[1].values.type").value("HOUSE"))
                .andExpect(jsonPath("$.sample[1].values.status").value("SOLD"));
    }

    private ResultActions preview(String kind, byte[] bytes) throws Exception {
        return mockMvc.perform(multipart("/import/" + kind + "/preview")
                .file(new MockMultipartFile("file", "export.csv", "text/csv", bytes)));
    }
}
