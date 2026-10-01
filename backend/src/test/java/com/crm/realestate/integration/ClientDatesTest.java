package com.crm.realestate.integration;

import com.crm.realestate.dto.response.UpcomingClientDate;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientDateKind;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.repository.ClientDateNoticeRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.service.ClientDateNotifier;
import com.crm.realestate.service.ClientDateService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Birthdays and purchase anniversaries: kept on the client, listed when they come up, and told to
 * the agent once on the day — the 29th of February included.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class ClientDatesTest extends ColdClientsFixture {

    private static final LocalDate OCT_1 = LocalDate.of(2026, 10, 1);

    @Autowired private ClientDateService dateService;
    @Autowired private ClientDateNotifier notifier;
    @Autowired private ClientDateNoticeRepository noticeRepository;
    @Autowired private NotificationRepository notificationRepository;

    // The birthday on the card --------------------------------------------------------------

    @Test
    @DisplayName("a birthday is saved with or without its year, left alone when not sent, and taken off with an empty one")
    void birthdayOnTheCard() throws Exception {
        signIn(agent);
        long id = idOf(save(post("/clients"), "\"birthday\":\"1990-05-14\"")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.birthday").value("1990-05-14")));

        save(put("/clients/" + id), "\"notes\":\"called\"")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.birthday").value("1990-05-14"));
        save(put("/clients/" + id), "\"birthday\":\"--02-29\"")
                .andExpect(jsonPath("$.birthday").value("--02-29"));
        Client stored = clientRepository.findById(id).orElseThrow();
        assertThat(stored.getBirthMonth()).isEqualTo(2);
        assertThat(stored.getBirthDay()).isEqualTo(29);
        assertThat(stored.getBirthYear()).isNull();

        save(put("/clients/" + id), "\"birthday\":\"\"")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.birthday").value(nullValue()));
    }

    @Test
    @DisplayName("a day that does not exist, a 29 February in a common year, the future, or another shape is refused")
    void invalidBirthdays() throws Exception {
        signIn(agent);
        String tomorrow = LocalDate.now().plusDays(1).toString();
        for (String bad : List.of("--02-30", "--13-01", "1990-02-29", "1899-12-31", tomorrow, "14.05.1990", "--5-14")) {
            save(post("/clients"), "\"birthday\":\"" + bad + "\"")
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.code").value("INVALID_BIRTHDAY"));
        }
        save(post("/clients"), "\"birthday\":\"2000-02-29\"").andExpect(status().isCreated());
    }

    @Test
    @DisplayName("a merge keeps the target's birthday, and takes the other card's when it had none")
    void mergeCarriesTheBirthday() throws Exception {
        Client target = buyer("Target", agent, 1);
        Client source = buyer("Source", agent, 1);
        birthday(source, 7, 3, 1980);
        entityManager.flush();
        signIn(manager);
        mockMvc.perform(post("/clients/" + target.getId() + "/merge")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"sourceId\":" + source.getId() + "}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.birthday").value("1980-07-03"));
    }

    @Test
    @DisplayName("an imported Birthday column is read day first or as the export writes it; a day that is not one is refused")
    void imported() throws Exception {
        signIn(manager);
        String csv = "Full name,Phone,Birthday\r\n"
                + "Dana,+77011234567,14.05.1990\r\n"
                + "Erlan,+77011234568,--02-29\r\n"
                + "Bad,+77011234569,31.02\r\n";
        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                        .multipart("/import/clients/commit")
                        .file(new org.springframework.mock.web.MockMultipartFile("file", "book.csv", "text/csv",
                                csv.getBytes(java.nio.charset.StandardCharsets.UTF_8))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created").value(2))
                .andExpect(jsonPath("$.invalid").value(1));
        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Dana")).singleElement()
                .satisfies(c -> assertThat(com.crm.realestate.service.ClientBirthday.format(c)).isEqualTo("1990-05-14"));
        assertThat(clientRepository.findAll()).filteredOn(c -> c.getFullName().equals("Erlan")).singleElement()
                .satisfies(c -> assertThat(com.crm.realestate.service.ClientBirthday.format(c)).isEqualTo("--02-29"));
    }

    // Coming up -----------------------------------------------------------------------------

    @Test
    @DisplayName("the next two weeks, today first: the age turned when the year is known, anniversaries counted in years")
    void upcomingWindow() {
        birthday(buyer("Today", agent, 1), 10, 1, 1990);
        birthday(buyer("No year", agent, 1), 10, 5, null);
        birthday(buyer("Last day", agent, 1), 10, 14, 2000);
        birthday(buyer("Too late", agent, 1), 10, 15, 2000);
        birthday(buyer("Yesterday", agent, 1), 9, 30, 2000);
        Client owner = buyer("Owner", agent, 1);
        won(owner, "Flat on Abay", LocalDateTime.of(2024, 10, 3, 15, 0));
        won(buyer("Bought this year", agent, 1), "Fresh", LocalDateTime.of(2026, 10, 2, 9, 0));
        lost(buyer("Lost", agent, 1), LocalDateTime.of(2024, 10, 2, 9, 0));

        signIn(agent);
        List<UpcomingClientDate> dates = upcoming(OCT_1, 14);
        assertThat(dates).extracting(UpcomingClientDate::getClientName)
                .containsExactly("Today", "Owner", "No year", "Last day");
        assertThat(dates.get(0).getDaysAway()).isZero();
        assertThat(dates.get(0).getYears()).isEqualTo(36);
        assertThat(dates.get(0).getKind()).isEqualTo(ClientDateKind.BIRTHDAY);
        UpcomingClientDate anniversary = dates.get(1);
        assertThat(anniversary.getKind()).isEqualTo(ClientDateKind.PURCHASE_ANNIVERSARY);
        assertThat(anniversary.getDate()).isEqualTo(LocalDate.of(2026, 10, 3));
        assertThat(anniversary.getYears()).isEqualTo(2);
        assertThat(anniversary.getDealTitle()).isEqualTo("Flat on Abay");
        assertThat(anniversary.getClientId()).isEqualTo(owner.getId());
        assertThat(dates.get(2).getYears()).isNull();
        assertThat(dates.get(3).getDaysAway()).isEqualTo(13);
    }

    @Test
    @DisplayName("a window across New Year finds January's dates in the next year")
    void acrossNewYear() {
        birthday(buyer("January", agent, 1), 1, 3, 1990);
        signIn(agent);
        List<UpcomingClientDate> dates = upcoming(LocalDate.of(2026, 12, 25), 14);
        assertThat(dates).singleElement().satisfies(d -> {
            assertThat(d.getDate()).isEqualTo(LocalDate.of(2027, 1, 3));
            assertThat(d.getYears()).isEqualTo(37);
            assertThat(d.getDaysAway()).isEqualTo(9);
        });
    }

    @Test
    @DisplayName("29 February is the 28th in a common year and itself in a leap year; a purchase that day too")
    void leapDay() {
        birthday(buyer("Leapling", agent, 1), 2, 29, 2000);
        won(buyer("Leap buyer", agent, 1), "Leap flat", LocalDateTime.of(2024, 2, 29, 12, 0));
        signIn(agent);

        assertThat(upcoming(LocalDate.of(2027, 2, 28), 1))
                .extracting(UpcomingClientDate::getClientName, UpcomingClientDate::getDate)
                .containsExactly(
                        org.assertj.core.groups.Tuple.tuple("Leapling", LocalDate.of(2027, 2, 28)),
                        org.assertj.core.groups.Tuple.tuple("Leap buyer", LocalDate.of(2027, 2, 28)));
        assertThat(upcoming(LocalDate.of(2027, 3, 1), 1)).isEmpty();
        assertThat(upcoming(LocalDate.of(2028, 2, 28), 1)).isEmpty();
        assertThat(upcoming(LocalDate.of(2028, 2, 29), 1))
                .extracting(UpcomingClientDate::getYears).containsExactly(28, 4);
    }

    @Test
    @DisplayName("an agent sees their own clients' dates even on team scope; a manager the agency's; never another agency's")
    void scope() {
        birthday(buyer("Agent's", agent, 1), 10, 2, null);
        birthday(buyer("Colleague's", colleague, 1), 10, 2, null);
        won(buyer("Colleague's owner", colleague, 1), "Sold", LocalDateTime.of(2020, 10, 2, 10, 0));
        birthday(buyer("Astana's", stranger, 1), 10, 2, null);

        signIn(agent);
        assertThat(names(upcoming(OCT_1, 14))).containsExactly("Agent's");
        signIn(colleague);
        assertThat(names(upcoming(OCT_1, 14))).containsExactly("Colleague's", "Colleague's owner");
        signIn(manager);
        assertThat(names(upcoming(OCT_1, 14))).containsExactly("Agent's", "Colleague's", "Colleague's owner");
        signIn(stranger);
        assertThat(names(upcoming(OCT_1, 14))).containsExactly("Astana's");
    }

    @Test
    @DisplayName("GET /clients/upcoming-dates takes days 1 to 60 and the caller's today")
    void endpoint() throws Exception {
        birthday(buyer("Soon", agent, 1), 10, 2, 1990);
        entityManager.flush();
        signIn(agent);
        mockMvc.perform(get("/clients/upcoming-dates").param("from", "2026-10-01"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].kind").value("BIRTHDAY"))
                .andExpect(jsonPath("$[0].date").value("2026-10-02"))
                .andExpect(jsonPath("$[0].daysAway").value(1))
                .andExpect(jsonPath("$[0].years").value(36))
                .andExpect(jsonPath("$[0].clientName").value("Soon"))
                .andExpect(jsonPath("$[0].agentName").value("Aigul Bekova"));
        mockMvc.perform(get("/clients/upcoming-dates").param("from", "2026-10-03").param("days", "1"))
                .andExpect(jsonPath("$.length()").value(0));
        mockMvc.perform(get("/clients/upcoming-dates").param("days", "0"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_DAYS"));
        mockMvc.perform(get("/clients/upcoming-dates").param("days", "61")).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("the list is a fixed number of statements however many clients have a date")
    void noNPlusOne() {
        for (int i = 0; i < 8; i++) {
            User holder = i % 2 == 0 ? agent : colleague;
            birthday(buyer("B" + i, holder, 1), 10, 2, null);
            won(buyer("W" + i, holder, 1), "Deal " + i, LocalDateTime.of(2020, 10, 3, 10, 0));
        }
        signIn(manager);
        assertThat(statements(() -> assertThat(dateService.upcoming(14, OCT_1)).hasSize(16)))
                .isLessThanOrEqualTo(4);
    }

    // On the day ------------------------------------------------------------------------------

    @Test
    @DisplayName("on the day the agent is told once, however often the reminder runs")
    void toldOnce() {
        Client ali = buyer("Ali", agent, 1);
        birthday(ali, 10, 1, 1990);
        won(ali, "Flat on Abay", LocalDateTime.of(2023, 10, 1, 12, 0));
        won(ali, "Garage", LocalDateTime.of(2024, 10, 1, 12, 0));
        birthday(buyer("Tomorrow", agent, 1), 10, 2, null);

        assertThat(notifier.notifyFor(OCT_1)).isEqualTo(2);
        assertThat(notifier.notifyFor(OCT_1)).isZero();

        List<Notification> told = notificationRepository.findByRecipientId(agent.getId());
        assertThat(told).extracting(Notification::getType)
                .containsExactlyInAnyOrder(NotificationType.CLIENT_BIRTHDAY, NotificationType.PURCHASE_ANNIVERSARY);
        assertThat(told).allSatisfy(n -> assertThat(n.getTargetId()).isEqualTo(ali.getId()));
        Notification birthday = told.stream()
                .filter(n -> n.getType() == NotificationType.CLIENT_BIRTHDAY).findFirst().orElseThrow();
        assertThat(birthday.getPayload()).contains("\"clientName\":\"Ali\"", "\"years\":36");
        Notification anniversary = told.stream()
                .filter(n -> n.getType() == NotificationType.PURCHASE_ANNIVERSARY).findFirst().orElseThrow();
        assertThat(anniversary.getPayload()).contains("\"years\":3", "Flat on Abay");
        assertThat(noticeRepository.count()).isEqualTo(2);

        // Next year it is news again.
        assertThat(notifier.notifyFor(LocalDate.of(2027, 10, 1))).isEqualTo(2);
    }

    @Test
    @DisplayName("29 February is told on the 28th in a common year, and not again on 1 March")
    void leapDayToldOnThe28th() {
        birthday(buyer("Leapling", agent, 1), 2, 29, 2000);
        assertThat(notifier.notifyFor(LocalDate.of(2027, 2, 28))).isEqualTo(1);
        assertThat(notifier.notifyFor(LocalDate.of(2027, 3, 1))).isZero();
        assertThat(notificationRepository.findByRecipientId(agent.getId()))
                .singleElement().satisfies(n -> assertThat(n.getPayload()).contains("\"years\":27"));
    }

    @Test
    @DisplayName("a client nobody holds is the manager's to greet; each agency hears only of its own")
    void unheldGoesToTheManager() {
        almaty.setManager(manager);
        teamRepository.save(almaty);
        Client nobodys = clientRepository.save(Client.builder().fullName("Nobody's")
                .type(com.crm.realestate.enums.ClientType.BUYER).team(almaty).build());
        birthday(nobodys, 10, 1, null);
        birthday(buyer("Astana's", stranger, 1), 10, 1, null);

        assertThat(notifier.notifyFor(OCT_1)).isEqualTo(2);
        assertThat(notificationRepository.findByRecipientId(manager.getId()))
                .singleElement().satisfies(n -> {
                    assertThat(n.getTargetId()).isEqualTo(nobodys.getId());
                    assertThat(n.getTeam().getId()).isEqualTo(almaty.getId());
                });
        assertThat(notificationRepository.findByRecipientId(stranger.getId())).hasSize(1);
        assertThat(notificationRepository.findByRecipientId(agent.getId())).isEmpty();
    }

    @Test
    @DisplayName("the notification reads back through the feed with its type and values")
    void inTheFeed() throws Exception {
        birthday(buyer("Ali", agent, 1), 10, 1, 1990);
        notifier.notifyFor(OCT_1);
        entityManager.flush();
        signIn(agent);
        mockMvc.perform(get("/notifications"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].type").value("CLIENT_BIRTHDAY"))
                .andExpect(jsonPath("$.content[0].params.clientName").value("Ali"))
                .andExpect(jsonPath("$.content[0].params.years").value(36));
    }

    // Helpers ---------------------------------------------------------------------------

    private void birthday(Client client, int month, int day, Integer year) {
        client.setBirthMonth(month);
        client.setBirthDay(day);
        client.setBirthYear(year);
        clientRepository.save(client);
    }

    private Deal won(Client client, String title, LocalDateTime closedAt) {
        Deal deal = deal(client, title, DealStatus.CLOSED_WON);
        deal.setClosedAt(closedAt);
        return dealRepository.save(deal);
    }

    private void lost(Client client, LocalDateTime closedAt) {
        Deal deal = deal(client, "Lost", DealStatus.CLOSED_LOST);
        deal.setClosedAt(closedAt);
        dealRepository.save(deal);
    }

    private List<UpcomingClientDate> upcoming(LocalDate from, int days) {
        entityManager.flush();
        entityManager.clear();
        return dateService.upcoming(days, from);
    }

    private static List<String> names(List<UpcomingClientDate> dates) {
        return dates.stream().map(UpcomingClientDate::getClientName).toList();
    }

    private ResultActions save(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
                               String extra) throws Exception {
        return mockMvc.perform(request.contentType(MediaType.APPLICATION_JSON)
                .content("{\"fullName\":\"Dana\",\"type\":\"BUYER\"," + extra + "}"));
    }

    private long idOf(ResultActions result) throws Exception {
        String body = result.andReturn().getResponse().getContentAsString();
        return new com.fasterxml.jackson.databind.ObjectMapper().readTree(body).get("id").asLong();
    }
}
