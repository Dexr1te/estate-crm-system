package com.crm.realestate.integration;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.service.ChecklistTemplateService;
import com.crm.realestate.service.DealService;
import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Checklist progress on the deal itself: counted on the list without a query per deal, counted
 * from the template for deals that have no copy yet, the soft gate on moving stage, and what goes
 * when the deal, the file or the person goes.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DealChecklistCountsTest extends ChecklistFixture {

    @Autowired private DealService dealService;
    @Autowired private ChecklistTemplateService templateService;
    @Autowired private EntityManagerFactory entityManagerFactory;

    @Test
    @DisplayName("the list counts current stage and earlier; a deal with no copy yet counts the template")
    void countsOnList() throws Exception {
        Deal copied = oldDeal("Copied", agent, almaty);
        Deal notYet = oldDeal("Not yet", agent, almaty);
        long first = json(as(agent, get("/deals/" + copied.getId() + "/checklist"))).get(0).get("id").asLong();
        as(agent, patch("/deals/" + copied.getId() + "/checklist/" + first)
                .contentType(MediaType.APPLICATION_JSON).content("{\"done\":true}")).andExpect(status().isOk());

        JsonNode deals = json(as(agent, get("/deals")).andExpect(status().isOk()));
        for (JsonNode d : deals) {
            // LEAD has two lines in the default template; one is ticked on the copied deal only.
            long expectedDone = d.get("id").asLong() == copied.getId() ? 1 : 0;
            assertThat(d.get("checklistDone").asLong()).isEqualTo(expectedDone);
            assertThat(d.get("checklistTotal").asLong()).isEqualTo(2);
            assertThat(d.get("openRequired").asLong()).isZero();
            assertThat(d.get("openRequiredByStage").get("NEGOTIATION").asLong()).isEqualTo(2);
        }
        assertThat(itemRepository.existsByDealId(notYet.getId())).as("listing does not write").isFalse();
    }

    @Test
    @DisplayName("moving on with required lines open is allowed, and says how many are open")
    void softGateOnStageChange() throws Exception {
        Deal deal = oldDeal("Flat", agent, almaty);
        as(agent, patch("/deals/" + deal.getId() + "/status").param("status", "NEGOTIATION"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("NEGOTIATION"))
                .andExpect(jsonPath("$.openRequired").value(1))
                .andExpect(jsonPath("$.checklistTotal").value(5));
        as(agent, patch("/deals/" + deal.getId() + "/status").param("status", "CLOSED_WON"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.openRequired").value(3))
                .andExpect(jsonPath("$.checklistTotal").value(7));
        as(agent, patch("/deals/" + deal.getId() + "/status").param("status", "CLOSED_LOST")
                        .param("lostReason", "PRICE"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.openRequired").value(0));
    }

    @Test
    @DisplayName("listing deals with checklists costs the same number of queries however many there are")
    void noQueryPerDeal() throws Exception {
        seed(3);
        long few = statementsListing();
        seed(12);
        long many = statementsListing();
        assertThat(many).as("3 deals took %d statements, 15 took %d", few, many).isEqualTo(few);
    }

    @Test
    @DisplayName("deleting a deal or agency takes its checklist; closing an account keeps the tick, forgets who")
    void cascades() throws Exception {
        as(manager, put("/team/checklist-template").contentType(MediaType.APPLICATION_JSON)
                .content("{\"items\":[{\"stage\":\"LEAD\",\"title\":\"ID\",\"required\":true}]}"));
        Deal deal = oldDeal("Flat", agent, almaty);
        long itemId = json(as(agent, get("/deals/" + deal.getId() + "/checklist"))).get(0).get("id").asLong();
        as(colleague, patch("/deals/" + deal.getId() + "/checklist/" + itemId)
                .contentType(MediaType.APPLICATION_JSON).content("{\"done\":true}")).andExpect(status().isOk());
        flushAndClear();

        userRepository.deleteById(colleague.getId());
        flushAndClear();
        assertThat(itemRepository.findById(itemId).orElseThrow().getDoneBy()).isNull();
        assertThat(itemRepository.findById(itemId).orElseThrow().getDoneAt()).isNotNull();

        dealRepository.deleteById(deal.getId());
        flushAndClear();
        assertThat(itemRepository.findById(itemId)).isEmpty();

        Team closing = teamRepository.save(Team.builder().name("Closing down").build());
        templateService.seedIfNeeded(closing, null);
        flushAndClear();
        assertThat(templateRepository.findByTeamId(closing.getId())).hasSize(7);
        teamRepository.deleteById(closing.getId());
        flushAndClear();
        assertThat(templateRepository.findByTeamId(closing.getId())).isEmpty();
    }

    private void seed(int count) throws Exception {
        IntStream.range(0, count).forEach(i -> oldDeal("Deal " + i, agent, almaty));
        flushAndClear();
        for (Deal d : dealRepository.findAll()) {
            as(agent, get("/deals/" + d.getId() + "/checklist"));
        }
        flushAndClear();
    }

    private long statementsListing() {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(agent.getEmail(), null, List.of()));
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        dealService.getAll();
        return stats.getPrepareStatementCount();
    }
}
