package com.crm.realestate.integration;

import com.crm.realestate.dto.response.ColdClient;
import com.crm.realestate.dto.response.ColdClient.NextStep;
import com.crm.realestate.dto.response.ColdClient.ReasonCode;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Property;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.ViewingOutcome;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Who qualifies as going cold, and who is left out. */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ColdClientsTest extends ColdClientsFixture {

    @Test
    @DisplayName("an open deal qualifies, with its title and stage, over HTTP")
    void openDealQualifies() throws Exception {
        Client aigerim = client("Aigerim", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        deal(aigerim, "Sale on Dostyk", DealStatus.NEGOTIATION);
        deal(aigerim, "Older lead", DealStatus.LEAD);
        entityManager.flush();
        signIn(agent);

        mockMvc.perform(get("/clients/cold"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].fullName").value("Aigerim"))
                .andExpect(jsonPath("$[0].agentName").value("Aigul Bekova"))
                .andExpect(jsonPath("$[0].lastContactAt").doesNotExist())
                .andExpect(jsonPath("$[0].silentDays").value(30))
                .andExpect(jsonPath("$[0].reasons[0].code").value("OPEN_DEAL"))
                .andExpect(jsonPath("$[0].reasons[0].dealTitle").value("Sale on Dostyk"))
                .andExpect(jsonPath("$[0].reasons[0].dealStatus").value("NEGOTIATION"))
                .andExpect(jsonPath("$[0].nextStep").value("FIRST_CALL"));
    }

    @Test
    @DisplayName("a buyer with current matches qualifies; a turned-down listing does not count")
    void matchesQualify() {
        Client daniyar = lookingBuyer("Daniyar", agent, 30);
        lookingBuyer("Nothing fits", agent, 30).setWantedCity("Shymkent");
        flat(colleague, "Almaty", "40000000");
        flat(colleague, "almaty", "54000000");                       // within the 10% tolerance
        Property seen = flat(colleague, "Almaty", "30000000");
        flat(colleague, "Almaty", "90000000");                       // over budget
        flat(stranger, "Almaty", "30000000");                        // another agency's stock
        meeting(daniyar, LocalDateTime.now().minusDays(40), seen, ViewingOutcome.REJECTED);
        called(daniyar, 20);
        signIn(agent);

        List<ColdClient> cold = list(14);
        assertThat(cold).extracting(ColdClient::getFullName).containsExactly("Daniyar");
        ColdClient row = cold.get(0);
        assertThat(row.getReasons()).hasSize(1);
        assertThat(row.getReasons().get(0).getCode()).isEqualTo(ReasonCode.MATCHES);
        assertThat(row.getReasons().get(0).getMatchCount()).isEqualTo(2);
        assertThat(row.getSilentDays()).isEqualTo(20);
        assertThat(row.getLastContactAt()).isNotNull();
        assertThat(row.getNextStep()).isEqualTo(NextStep.SEND_MATCHES);
    }

    @Test
    @DisplayName("a lead from a listing's public page qualifies on its own")
    void publicLeadQualifies() {
        client("From the page", agent, ClientType.BUYER, ClientSource.PUBLIC_LINK, 20);
        client("Typed in", agent, ClientType.BUYER, ClientSource.MANUAL, 20);
        signIn(agent);

        List<ColdClient> cold = list(14);
        assertThat(cold).extracting(ColdClient::getFullName).containsExactly("From the page");
        assertThat(cold.get(0).getReasons()).extracting(ColdClient.Reason::getCode)
                .containsExactly(ReasonCode.NEW_LEAD);
    }

    @Test
    @DisplayName("a seller with no deal, or with only closed ones, is not worth the list")
    void sellerWithoutOpenDealIsExcluded() {
        client("Seller", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        Client done = client("Done", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        deal(done, "Sold", DealStatus.CLOSED_WON);
        signIn(agent);

        assertThat(coldNames(14)).isEmpty();
    }

    @Test
    @DisplayName("recent contact — a call, a past meeting — or a booked meeting keeps a client off")
    void recentContactExcludes() {
        Client called = client("Called", agent, ClientType.SELLER, ClientSource.MANUAL, 60);
        deal(called, "d1", DealStatus.LEAD);
        called(called, 3);
        Client met = client("Met", agent, ClientType.SELLER, ClientSource.MANUAL, 60);
        deal(met, "d2", DealStatus.LEAD);
        meeting(met, LocalDateTime.now().minusDays(2), null, null);
        Client booked = client("Booked", agent, ClientType.SELLER, ClientSource.MANUAL, 60);
        deal(booked, "d3", DealStatus.LEAD);
        meeting(booked, LocalDateTime.now().plusDays(2), null, null);
        Client quiet = client("Quiet", agent, ClientType.SELLER, ClientSource.MANUAL, 60);
        deal(quiet, "d4", DealStatus.LEAD);
        called(quiet, 20);
        signIn(agent);

        assertThat(coldNames(14)).containsExactly("Quiet");
        assertThat(coldNames(30)).as("twenty days is not thirty").isEmpty();
    }

    @Test
    @DisplayName("an open task due later means someone is on it; an overdue or finished one does not")
    void tasks() {
        Client planned = client("Planned", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        deal(planned, "d1", DealStatus.LEAD);
        task(planned, LocalDateTime.now().plusDays(1), false);
        Client slipped = client("Slipped", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        deal(slipped, "d2", DealStatus.LEAD);
        task(slipped, LocalDateTime.now().minusDays(1), false);
        Client ticked = client("Ticked", agent, ClientType.SELLER, ClientSource.MANUAL, 30);
        deal(ticked, "d3", DealStatus.LEAD);
        task(ticked, LocalDateTime.now().plusDays(1), true);
        signIn(agent);

        assertThat(coldNames(14)).containsExactlyInAnyOrder("Slipped", "Ticked");
    }

    @Test
    @DisplayName("a card made a few days ago has not been silent for two weeks")
    void newCardIsNotCold() {
        client("New", agent, ClientType.BUYER, ClientSource.PUBLIC_LINK, 3);
        signIn(agent);
        assertThat(coldNames(14)).isEmpty();
        assertThat(coldNames(7)).isEmpty();
    }

    private List<ColdClient> list(int days) {
        entityManager.flush();
        entityManager.clear();
        return coldClientService.list(days, 100);
    }
}
