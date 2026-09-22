package com.crm.realestate.integration;

import com.crm.realestate.dto.request.MeetingRequest;
import com.crm.realestate.dto.request.ViewingOutcomeRequest;
import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.dto.response.PropertyMatch;
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
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.MatchingService;
import com.crm.realestate.service.MeetingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The verdict after a showing, and what matching does with it.
 *
 * <p>Without this a flat a buyer walked away from kept coming back to the top of
 * their matching listings, because the figures still fit. The verdict belongs to
 * the buyer and not to the flat: one person's no says nothing about the next
 * person, so it narrows that buyer's list and nobody else's.
 */
@SpringBootTest
@Transactional
class ViewingOutcomeTest {

    @Autowired private MeetingService     meetingService;
    @Autowired private MatchingService    matchingService;
    @Autowired private MeetingRepository  meetingRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private ClientRepository   clientRepository;
    @Autowired private UserRepository     userRepository;
    @Autowired private TeamRepository     teamRepository;

    private Team team;
    private User agent;
    private Client buyer;
    private Property shown;
    private Property other;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        meetingRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("agent@estate.crm", team);
        signIn(agent);

        buyer = clientRepository.save(Client.builder()
                .fullName("Irina Sokolova").type(ClientType.BUYER)
                .budgetMax(new BigDecimal("30000000"))
                .agent(agent).team(team).build());

        shown = listing("Severny Residence, apt 84");
        other = listing("Tverskaya 12, apt 5");
    }

    @Test
    @DisplayName("a listing the buyer turned down stops being offered to them")
    void aNoIsRemembered() {
        MeetingResponse viewing = book(shown);
        meetingService.recordOutcome(viewing.getId(), outcome(ViewingOutcome.REJECTED, "Too dark"));

        List<PropertyMatch> matches = matchingService.propertiesFor(buyer.getId());

        assertThat(matches).hasSize(1);
        assertThat(matches.get(0).getProperty().getId()).isEqualTo(other.getId());
    }

    @Test
    @DisplayName("one buyer's no does not hide the flat from another")
    void aVerdictBelongsToTheBuyerWhoGaveIt() {
        MeetingResponse viewing = book(shown);
        meetingService.recordOutcome(viewing.getId(), outcome(ViewingOutcome.REJECTED, null));

        Client someoneElse = clientRepository.save(Client.builder()
                .fullName("Aigerim Serikbaykyzy").type(ClientType.BUYER)
                .budgetMax(new BigDecimal("30000000"))
                .agent(agent).team(team).build());

        assertThat(matchingService.propertiesFor(someoneElse.getId()))
                .extracting(m -> m.getProperty().getId())
                .contains(shown.getId());
    }

    @Test
    @DisplayName("a listing already shown is marked, not hidden")
    void aSecondViewingIsStillPossible() {
        LocalDateTime when = LocalDateTime.now().plusDays(1).withNano(0);
        MeetingResponse viewing = book(shown, when);
        meetingService.recordOutcome(viewing.getId(), outcome(ViewingOutcome.INTERESTED, null));

        PropertyMatch match = matchingService.propertiesFor(buyer.getId()).stream()
                .filter(m -> m.getProperty().getId().equals(shown.getId()))
                .findFirst().orElseThrow();

        assertThat(match.getLastShownAt())
                .as("people come back with a spouse and decide differently")
                .isEqualTo(when);
    }

    @Test
    @DisplayName("nobody turning up says nothing about the flat")
    void aNoShowIsNotAVerdict() {
        MeetingResponse viewing = book(shown);
        meetingService.recordOutcome(viewing.getId(), outcome(ViewingOutcome.NO_SHOW, null));

        assertThat(matchingService.propertiesFor(buyer.getId()))
                .extracting(m -> m.getProperty().getId())
                .contains(shown.getId());
        assertThat(meetingRepository.findById(viewing.getId()).orElseThrow().isCompleted())
                .as("a showing nobody came to has not happened")
                .isFalse();
    }

    @Test
    @DisplayName("recording a verdict marks the showing as done")
    void aVerdictImpliesItHappened() {
        MeetingResponse viewing = book(shown);

        MeetingResponse after = meetingService.recordOutcome(
                viewing.getId(), outcome(ViewingOutcome.INTERESTED, "Wants a second look"));

        assertThat(after.isCompleted()).isTrue();
        assertThat(after.getOutcome()).isEqualTo(ViewingOutcome.INTERESTED);
        assertThat(after.getOutcomeNote()).isEqualTo("Wants a second look");
    }

    @Test
    @DisplayName("a buyer who turned it down is not listed as interested in it")
    void theMirrorForgetsThemToo() {
        MeetingResponse viewing = book(shown);
        meetingService.recordOutcome(viewing.getId(), outcome(ViewingOutcome.REJECTED, null));

        assertThat(matchingService.buyersFor(shown.getId())).isEmpty();
    }

    private MeetingResponse book(Property property) {
        return book(property, LocalDateTime.now().plusDays(1));
    }

    private MeetingResponse book(Property property, LocalDateTime when) {
        MeetingRequest request = new MeetingRequest();
        request.setTitle("Viewing");
        request.setScheduledAt(when);
        request.setClientId(buyer.getId());
        request.setAgentId(agent.getId());
        request.setPropertyId(property.getId());
        return meetingService.create(request);
    }

    private ViewingOutcomeRequest outcome(ViewingOutcome outcome, String note) {
        ViewingOutcomeRequest request = new ViewingOutcomeRequest();
        request.setOutcome(outcome);
        request.setNote(note);
        return request;
    }

    private Property listing(String title) {
        return propertyRepository.save(Property.builder()
                .title(title).address(title).city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3).areaSqm(62.0)
                .agent(agent).team(team).build());
    }

    private User user(String email, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
