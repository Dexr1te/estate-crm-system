package com.crm.realestate.integration;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealChecklistItem;
import com.crm.realestate.entity.Document;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * A deal's own checklist: copied from the template when the deal is made (or first read), ticked
 * by whoever may open the deal, proven with the deal's own documents, extended by its agent or a
 * manager — and behind exactly the deal's walls.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DealChecklistTest extends ChecklistFixture {

    @Test
    @DisplayName("a new deal copies the template; editing the template later leaves it alone")
    void creationCopiesTemplate() throws Exception {
        as(manager, put("/team/checklist-template").contentType(MediaType.APPLICATION_JSON).content("""
                {"items":[{"stage":"LEAD","title":"ID copy","required":true},
                          {"stage":"NEGOTIATION","title":"Deposit","required":false}]}"""))
                .andExpect(status().isOk());
        Long clientId = oldDeal("seed", agent, almaty).getClient().getId();
        JsonNode created = json(as(agent, post("/deals").contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\":\"Dostyk 5\",\"clientId\":" + clientId + ",\"agentId\":" + agent.getId() + "}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.checklistDone").value(0))
                .andExpect(jsonPath("$.checklistTotal").value(1)));
        long dealId = created.get("id").asLong();
        assertThat(itemRepository.findForDeal(dealId)).hasSize(2);

        as(manager, put("/team/checklist-template").contentType(MediaType.APPLICATION_JSON)
                .content("{\"items\":[]}")).andExpect(status().isOk());
        as(agent, get("/deals/" + dealId + "/checklist"))
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].title").value("ID copy"))
                .andExpect(jsonPath("$[0].custom").value(false))
                .andExpect(jsonPath("$[1].stage").value("NEGOTIATION"));
    }

    @Test
    @DisplayName("a deal from before the checklist gets its copy on first read, once")
    void lazyCopyForOldDeals() throws Exception {
        Deal old = oldDeal("Old deal", agent, almaty);
        assertThat(itemRepository.existsByDealId(old.getId())).isFalse();
        as(agent, get("/deals/" + old.getId() + "/checklist")).andExpect(jsonPath("$.length()").value(7));
        as(agent, get("/deals/" + old.getId() + "/checklist")).andExpect(jsonPath("$.length()").value(7));
        assertThat(itemRepository.findForDeal(old.getId())).hasSize(7);
    }

    @Test
    @DisplayName("ticking records who and when; un-ticking clears both")
    void toggleDone() throws Exception {
        Deal deal = oldDeal("Flat", agent, almaty);
        long itemId = firstItem(deal);
        as(colleague, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON).content("{\"done\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.done").value(true))
                .andExpect(jsonPath("$.doneByName").value("Timur Aliev"))
                .andExpect(jsonPath("$.doneAt").isNotEmpty());
        // Ticking again does not take the credit from whoever did it first.
        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON).content("{\"done\":true}"))
                .andExpect(jsonPath("$.doneByName").value("Timur Aliev"));
        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON).content("{\"done\":false}"))
                .andExpect(jsonPath("$.done").value(false))
                .andExpect(jsonPath("$.doneById").doesNotExist())
                .andExpect(jsonPath("$.doneAt").doesNotExist());
    }

    @Test
    @DisplayName("only a document of this deal can be attached; deleting the file un-links it")
    void attachDocument() throws Exception {
        Deal deal = oldDeal("Flat", agent, almaty);
        Deal other = oldDeal("Other flat", agent, almaty);
        Document own = document(deal, "passport.pdf");
        Document foreign = document(other, "someone-else.pdf");
        long itemId = firstItem(deal);

        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"documentId\":" + foreign.getId() + "}")).andExpect(status().isNotFound());
        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"documentId\":999999}")).andExpect(status().isNotFound());
        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"documentId\":" + own.getId() + "}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.documentId").value(own.getId()))
                .andExpect(jsonPath("$.documentName").value("passport.pdf"))
                .andExpect(jsonPath("$.done").value(false));
        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"detachDocument\":true}")).andExpect(jsonPath("$.documentId").doesNotExist());

        as(agent, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"documentId\":" + own.getId() + ",\"done\":true}")).andExpect(status().isOk());
        flushAndClear();
        documentRepository.deleteById(own.getId());
        flushAndClear();
        DealChecklistItem item = itemRepository.findById(itemId).orElseThrow();
        assertThat(item.getDocument()).isNull();
        assertThat(item.getDoneAt()).isNotNull();
    }

    @Test
    @DisplayName("custom items: the deal's agent or a manager adds and deletes; template items stay")
    void customItemRights() throws Exception {
        Deal deal = oldDeal("Flat", agent, almaty);
        String body = "{\"stage\":\"NEGOTIATION\",\"title\":\"Parking permit\",\"required\":true}";
        as(colleague, post("/deals/" + deal.getId() + "/checklist").contentType(MediaType.APPLICATION_JSON)
                .content(body)).andExpect(status().isForbidden());
        JsonNode added = json(as(agent, post("/deals/" + deal.getId() + "/checklist")
                .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.custom").value(true))
                .andExpect(jsonPath("$.position").value(3)));
        as(agent, post("/deals/" + deal.getId() + "/checklist").contentType(MediaType.APPLICATION_JSON)
                .content("{\"stage\":\"LEAD\",\"title\":\"  \"}")).andExpect(status().isBadRequest());

        long customId = added.get("id").asLong();
        as(colleague, delete(itemUrl(deal, customId))).andExpect(status().isForbidden());
        as(agent, delete(itemUrl(deal, firstItem(deal)))).andExpect(status().isBadRequest());
        as(manager, delete(itemUrl(deal, customId))).andExpect(status().isNoContent());
        assertThat(itemRepository.findById(customId)).isEmpty();
    }

    @Test
    @DisplayName("the checklist is exactly as visible as its deal")
    void visibility() throws Exception {
        Deal deal = oldDeal("Flat", agent, almaty);
        long itemId = firstItem(deal);
        as(stranger, get("/deals/" + deal.getId() + "/checklist")).andExpect(status().isNotFound());
        as(ownOnly, get("/deals/" + deal.getId() + "/checklist")).andExpect(status().isNotFound());
        as(stranger, patch(itemUrl(deal, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"done\":true}")).andExpect(status().isNotFound());
        as(ownOnly, delete(itemUrl(deal, itemId))).andExpect(status().isNotFound());
        Deal other = oldDeal("Other", agent, almaty);
        as(agent, patch(itemUrl(other, itemId)).contentType(MediaType.APPLICATION_JSON)
                .content("{\"done\":true}")).andExpect(status().isNotFound());
        as(manager, get("/deals/" + deal.getId() + "/checklist")).andExpect(status().isOk());
    }

    long firstItem(Deal deal) throws Exception {
        return json(as(deal.getAgent(), get("/deals/" + deal.getId() + "/checklist"))).get(0).get("id").asLong();
    }

    static String itemUrl(Deal deal, long itemId) {
        return "/deals/" + deal.getId() + "/checklist/" + itemId;
    }
}
