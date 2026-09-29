package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Whose cold clients, in what order, how many, and at what cost. */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ColdClientsScopeTest extends ColdClientsFixture {

    private void coldSeller(String name, com.crm.realestate.entity.User holder) {
        deal(client(name, holder, ClientType.SELLER, ClientSource.MANUAL, 30), "Deal " + name, DealStatus.LEAD);
    }

    @Test
    @DisplayName("an agent on own data sees their own, a manager the agency, nobody another agency")
    void scope() {
        coldSeller("Mine", agent);
        coldSeller("Colleague's", colleague);
        coldSeller("Astana", stranger);

        signIn(agent);
        assertThat(coldNames(14)).containsExactly("Mine");
        signIn(manager);
        assertThat(coldNames(14)).containsExactlyInAnyOrder("Mine", "Colleague's");
        signIn(colleague);
        assertThat(coldNames(14)).as("team scope").containsExactlyInAnyOrder("Mine", "Colleague's");
        signIn(stranger);
        assertThat(coldNames(14)).containsExactly("Astana");
    }

    @Test
    @DisplayName("negotiation before lead before matches before a page lead, then the longest silence")
    void ordering() {
        client("Page lead, long quiet", agent, ClientType.BUYER, ClientSource.PUBLIC_LINK, 80);
        lookingBuyer("Matches", agent, 30);
        flat(agent, "Almaty", "30000000");
        Client leadRecent = client("Lead, 20 days", agent, ClientType.SELLER, ClientSource.MANUAL, 60);
        deal(leadRecent, "l1", DealStatus.LEAD);
        called(leadRecent, 20);
        deal(client("Lead, 40 days", agent, ClientType.SELLER, ClientSource.MANUAL, 40), "l2", DealStatus.LEAD);
        deal(client("Negotiation", agent, ClientType.SELLER, ClientSource.MANUAL, 15),
                "n1", DealStatus.NEGOTIATION);
        signIn(agent);

        assertThat(coldNames(14)).containsExactly(
                "Negotiation", "Lead, 40 days", "Lead, 20 days", "Matches", "Page lead, long quiet");
    }

    @Test
    @DisplayName("the threshold is 7 to 90 days and the limit 1 to 100; outside is a 400")
    void bounds() throws Exception {
        coldSeller("Mine", agent);
        entityManager.flush();
        signIn(agent);

        mockMvc.perform(get("/clients/cold").param("days", "6")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_DAYS"));
        mockMvc.perform(get("/clients/cold").param("days", "91")).andExpect(status().isBadRequest());
        mockMvc.perform(get("/clients/cold").param("limit", "0")).andExpect(status().isBadRequest());
        mockMvc.perform(get("/clients/cold").param("days", "7")).andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1));
        mockMvc.perform(get("/clients/cold").param("days", "90")).andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("the limit caps the list")
    void limit() throws Exception {
        IntStream.range(0, 5).forEach(i -> coldSeller("Seller " + i, agent));
        entityManager.flush();
        signIn(agent);
        mockMvc.perform(get("/clients/cold").param("limit", "3"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(3));
    }

    @Test
    @DisplayName("the dashboard counts the cold, scoped and narrowed like its other figures")
    void dashboardCount() {
        coldSeller("Mine", agent);
        coldSeller("Colleague's", colleague);
        coldSeller("Astana", stranger);
        entityManager.flush();

        signIn(agent);
        assertThat(dashboardService.getSummary(null, null).getColdCount()).isEqualTo(1);
        signIn(manager);
        assertThat(dashboardService.getSummary(null, null).getColdCount()).isEqualTo(2);
        assertThat(dashboardService.getSummary(colleague.getId(), null).getColdCount()).isEqualTo(1);
        assertThat(dashboardService.getSummary(null, astana.getId()).getColdCount())
                .as("another agency's team narrows to nothing").isZero();
    }

    @Test
    @DisplayName("the list costs the same statements for 5 clients as for 50, matches included")
    void statementCountIsFlat() {
        signIn(manager);
        flat(agent, "Almaty", "30000000");
        seed(5);
        long few = statements(() -> coldClientService.list(14, 100));
        seed(45);
        long many = statements(() -> coldClientService.list(14, 100));

        assertThat(coldClientService.list(14, 100)).hasSize(100);
        assertThat(many).as("5 took %d statements, 50 took %d", few, many).isEqualTo(few);
        assertThat(many).isLessThanOrEqualTo(3);
    }

    /** Per round: a seller with a deal, a buyer with matches, and a page lead. */
    private void seed(int rounds) {
        IntStream.range(0, rounds).forEach(i -> {
            coldSeller("Seller " + i, agent);
            lookingBuyer("Buyer " + i, colleague, 30);
            client("Lead " + i, agent, ClientType.BUYER, ClientSource.PUBLIC_LINK, 30);
        });
    }
}
