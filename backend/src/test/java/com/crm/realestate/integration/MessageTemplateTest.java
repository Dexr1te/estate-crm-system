package com.crm.realestate.integration;

import com.crm.realestate.entity.MessageTemplate;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.MessageTemplateRepository;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The agency's message templates: seeded with sensible defaults on first need, in the manager's
 * language when the manager is the one asking; read by everybody in the agency, written only by
 * its manager or an admin, audited, and never seen or touched across the agency wall.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class MessageTemplateTest extends ChecklistFixture {

    private static final String URL = "/team/message-templates";

    @Autowired private MessageTemplateRepository messageTemplateRepository;

    @Test
    @DisplayName("an existing agency gets the defaults on first read, in its manager's language, once")
    void defaultsSeededOnFirstReadInManagersLanguage() throws Exception {
        JsonNode templates = json(as(manager, get(URL).header("Accept-Language", "kk-KZ,kk;q=0.9"))
                .andExpect(status().isOk()));
        assertThat(templates).hasSize(5);
        assertThat(templates.get(0).get("title").asText()).isEqualTo("Танысу");
        assertThat(templates.get(0).get("body").asText()).contains("{client}", "{agent}");
        assertThat(templates.get(1).get("body").asText()).contains("{listing}", "{price}", "{address}", "{link}");

        as(manager, get(URL)).andExpect(jsonPath("$.length()").value(5));
        assertThat(messageTemplateRepository.findByTeamIdOrderByIdAsc(almaty.getId())).hasSize(5);
    }

    @Test
    @DisplayName("seeded by somebody other than the manager, the defaults are in Russian")
    void agentFirstMeansRussian() throws Exception {
        as(agent, get(URL).header("Accept-Language", "en"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Знакомство"));
    }

    @Test
    @DisplayName("a new agency starts with the defaults in the language its manager's app uses")
    void newAgencySeededInManagersLanguage() throws Exception {
        User founder = user("mt-founder@kz.kz", "Marat Omarov", Role.MANAGER, DataScope.OWN, null);
        as(founder, post("/team").header("Accept-Language", "en-US")
                .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Shymkent Keys\"}"))
                .andExpect(status().isCreated());
        flushAndClear();
        Long teamId = userRepository.findById(founder.getId()).orElseThrow().getTeam().getId();
        assertThat(messageTemplateRepository.findByTeamIdOrderByIdAsc(teamId))
                .extracting(MessageTemplate::getTitle)
                .containsExactly("Introduction", "A listing for you", "Viewing invitation",
                        "After the viewing", "Price reduced");
        assertThat(teamRepository.findById(teamId).orElseThrow().isMessageTemplatesSeeded()).isTrue();
    }

    @Test
    @DisplayName("the manager adds, rewrites and deletes; each is audited and the agent reads the result")
    void managerCrud() throws Exception {
        as(manager, get(URL)).andExpect(status().isOk());

        JsonNode created = json(write(manager, post(URL),
                "{\"title\":\"  Keys ready \",\"body\":\" {client}, the keys to {listing} are ready. {agent} \"}")
                .andExpect(status().isCreated()));
        long id = created.get("id").asLong();
        assertThat(created.get("title").asText()).isEqualTo("Keys ready");
        assertThat(created.get("body").asText()).isEqualTo("{client}, the keys to {listing} are ready. {agent}");

        write(manager, put(URL + "/" + id), "{\"title\":\"Keys\",\"body\":\"{ Client }, come by.\"}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Keys"))
                .andExpect(jsonPath("$.body").value("{ Client }, come by."));

        as(agent, get(URL))
                .andExpect(jsonPath("$.length()").value(6))
                .andExpect(jsonPath("$[5].title").value("Keys"));

        as(manager, delete(URL + "/" + id)).andExpect(status().isNoContent());
        as(agent, get(URL)).andExpect(jsonPath("$.length()").value(5));

        assertThat(auditLogRepository.findAll())
                .filteredOn(log -> log.getEntityId() != null && log.getEntityId() == id)
                .extracting(log -> log.getAction())
                .containsExactlyInAnyOrder("CREATE_MESSAGE_TEMPLATE", "UPDATE_MESSAGE_TEMPLATE",
                        "DELETE_MESSAGE_TEMPLATE");
    }

    @Test
    @DisplayName("an agent reads the templates but cannot add, change or delete one")
    void agentsReadOnly() throws Exception {
        long id = json(as(agent, get(URL))).get(0).get("id").asLong();
        write(agent, post(URL), "{\"title\":\"Mine\",\"body\":\"Hi\"}").andExpect(status().isForbidden());
        write(agent, put(URL + "/" + id), "{\"title\":\"Mine\",\"body\":\"Hi\"}").andExpect(status().isForbidden());
        as(agent, delete(URL + "/" + id)).andExpect(status().isForbidden());
        assertThat(messageTemplateRepository.findById(id)).get()
                .extracting(MessageTemplate::getTitle).isEqualTo("Знакомство");
    }

    @Test
    @DisplayName("another agency's template is not found: not read, not changed, not deleted")
    void tenantWall() throws Exception {
        long theirs = json(as(stranger, get(URL))).get(0).get("id").asLong();
        as(manager, get(URL)).andExpect(jsonPath("$[?(@.id == " + theirs + ")]").isEmpty());

        write(manager, put(URL + "/" + theirs), "{\"title\":\"Taken\",\"body\":\"Hi\"}")
                .andExpect(status().isNotFound());
        as(manager, delete(URL + "/" + theirs)).andExpect(status().isNotFound());
        assertThat(messageTemplateRepository.findById(theirs)).get()
                .extracting(MessageTemplate::getTitle).isEqualTo("Знакомство");
    }

    @Test
    @DisplayName("an admin names the agency; without one there is nothing to read")
    void adminNamesTheAgency() throws Exception {
        User admin = user("mt-admin@crm.kz", "Platform Admin", Role.ADMIN, DataScope.ALL, null);
        as(admin, get(URL)).andExpect(status().isBadRequest());
        as(admin, get(URL).param("teamId", String.valueOf(astana.getId())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(5));
        write(admin, post(URL).param("teamId", String.valueOf(astana.getId())),
                "{\"title\":\"From the platform\",\"body\":\"Hello, {client}\"}")
                .andExpect(status().isCreated());
        assertThat(messageTemplateRepository.findByTeamIdOrderByIdAsc(astana.getId())).hasSize(6);
        assertThat(messageTemplateRepository.findByTeamIdOrderByIdAsc(almaty.getId())).isEmpty();
    }

    @Test
    @DisplayName("deleting every template leaves none: the defaults do not come back")
    void emptiedStaysEmpty() throws Exception {
        for (JsonNode template : json(as(manager, get(URL)))) {
            as(manager, delete(URL + "/" + template.get("id").asLong())).andExpect(status().isNoContent());
        }
        as(manager, get(URL)).andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("blank or long titles and texts, and placeholders the app cannot fill, are refused")
    void validated() throws Exception {
        write(manager, post(URL), "{\"title\":\"   \",\"body\":\"Hi\"}").andExpect(status().isBadRequest());
        write(manager, post(URL), "{\"title\":\"Hi\",\"body\":\"  \"}").andExpect(status().isBadRequest());
        write(manager, post(URL), "{\"title\":\"" + "x".repeat(81) + "\",\"body\":\"Hi\"}")
                .andExpect(status().isBadRequest());
        write(manager, post(URL), "{\"title\":\"Hi\",\"body\":\"" + "x".repeat(1001) + "\"}")
                .andExpect(status().isBadRequest());
        write(manager, post(URL), "{\"title\":\"Hi\",\"body\":\"Dear {name}, see {link}\"}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("UNKNOWN_PLACEHOLDER"));
        write(manager, post(URL), "{}").andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("an agency keeps at most fifty templates")
    void capped() throws Exception {
        as(manager, get(URL)).andExpect(status().isOk());
        for (int i = 5; i < 50; i++) {
            write(manager, post(URL), "{\"title\":\"T" + i + "\",\"body\":\"Hi\"}").andExpect(status().isCreated());
        }
        write(manager, post(URL), "{\"title\":\"One too many\",\"body\":\"Hi\"}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("MESSAGE_TEMPLATE_LIMIT"));
    }

    private ResultActions write(User who, org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
                                String body) throws Exception {
        return as(who, request.contentType(MediaType.APPLICATION_JSON).content(body));
    }
}
