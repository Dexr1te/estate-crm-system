package com.crm.realestate.integration;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The agency's checklist template: seeded with a sensible default on first need, in the manager's
 * language when the manager is the one asking, rewritten only by the manager, and audited.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class ChecklistTemplateTest extends ChecklistFixture {

    private static final String URL = "/team/checklist-template";

    @Test
    @DisplayName("an existing agency gets the default on first read, in its manager's language")
    void defaultSeededOnFirstReadInManagersLanguage() throws Exception {
        JsonNode items = json(as(manager, get(URL).header("Accept-Language", "kk-KZ,kk;q=0.9"))
                .andExpect(status().isOk()));
        assertThat(items).hasSize(7);
        assertThat(items.get(0).get("stage").asText()).isEqualTo("LEAD");
        assertThat(items.get(0).get("title").asText()).isEqualTo("Сатып алушының жеке куәлігінің көшірмесі");
        assertThat(items.get(0).get("required").asBoolean()).isTrue();
        assertThat(items.get(6).get("stage").asText()).isEqualTo("CLOSED_WON");

        // Read again: written once, not on every read.
        as(manager, get(URL)).andExpect(jsonPath("$.length()").value(7));
        assertThat(templateRepository.findByTeamId(almaty.getId())).hasSize(7);
    }

    @Test
    @DisplayName("seeded by somebody other than the manager, the default is in Russian")
    void agentFirstMeansRussian() throws Exception {
        as(agent, get(URL).header("Accept-Language", "en"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Копия удостоверения личности покупателя"));
    }

    @Test
    @DisplayName("a new agency starts with the default in the language its manager's app uses")
    void newAgencySeededInManagersLanguage() throws Exception {
        User founder = user("cl-founder@kz.kz", "Marat Omarov", Role.MANAGER, DataScope.OWN, null);
        as(founder, post("/team").header("Accept-Language", "en-US")
                .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Shymkent Keys\"}"))
                .andExpect(status().isCreated());
        flushAndClear();
        Long teamId = userRepository.findById(founder.getId()).orElseThrow().getTeam().getId();
        assertThat(templateRepository.findByTeamId(teamId))
                .extracting(i -> i.getTitle())
                .contains("Copy of the buyer's ID", "Signed sale contract");
        assertThat(teamRepository.findById(teamId).orElseThrow().isChecklistTemplateSeeded()).isTrue();
    }

    @Test
    @DisplayName("the manager replaces the template: order per stage kept, audited; agents read only")
    void managerEditsAgentsRead() throws Exception {
        replaceAs(manager, """
                {"items":[
                  {"stage":"NEGOTIATION","title":"  Deposit agreement ","required":true},
                  {"stage":"LEAD","title":"ID copy","required":true},
                  {"stage":"NEGOTIATION","title":"Title extract","required":false}
                ]}""")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("ID copy"))
                .andExpect(jsonPath("$[1].title").value("Deposit agreement"))
                .andExpect(jsonPath("$[1].position").value(0))
                .andExpect(jsonPath("$[2].position").value(1));

        assertThat(auditLogRepository.findAll()).anySatisfy(log -> {
            assertThat(log.getAction()).isEqualTo("UPDATE_CHECKLIST_TEMPLATE");
            assertThat(log.getEntityId()).isEqualTo(almaty.getId());
            assertThat(log.getMetadata()).isEqualTo("items=3, required=2");
        });

        as(agent, get(URL)).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(3));
        replaceAs(agent, "{\"items\":[]}").andExpect(status().isForbidden());
        as(stranger, get(URL)).andExpect(jsonPath("$[0].title").value("Копия удостоверения личности покупателя"));
    }

    @Test
    @DisplayName("a template emptied on purpose stays empty")
    void emptyStaysEmpty() throws Exception {
        replaceAs(manager, "{\"items\":[]}").andExpect(status().isOk());
        as(manager, get(URL)).andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("blank titles, long titles, unknown stages and too many items are refused")
    void validated() throws Exception {
        replaceAs(manager, "{\"items\":[{\"stage\":\"LEAD\",\"title\":\"   \"}]}")
                .andExpect(status().isBadRequest());
        replaceAs(manager, "{\"items\":[{\"stage\":\"LEAD\",\"title\":\"" + "x".repeat(201) + "\"}]}")
                .andExpect(status().isBadRequest());
        replaceAs(manager, "{\"items\":[{\"stage\":\"CLOSED_LOST\",\"title\":\"x\"}]}")
                .andExpect(status().isBadRequest());
        String many = "{\"stage\":\"LEAD\",\"title\":\"x\"},".repeat(61);
        replaceAs(manager, "{\"items\":[" + many.substring(0, many.length() - 1) + "]}")
                .andExpect(status().isBadRequest());
        replaceAs(manager, "{}").andExpect(status().isBadRequest());
    }

    private ResultActions replaceAs(User who, String body) throws Exception {
        return as(who, put(URL).contentType(MediaType.APPLICATION_JSON).content(body));
    }
}
