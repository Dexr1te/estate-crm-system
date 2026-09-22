package com.crm.realestate.integration;

import com.crm.realestate.dto.request.MeetingRequest;
import com.crm.realestate.dto.response.MeetingResponse;
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
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.MeetingService;
import com.crm.realestate.service.PropertyService;
import jakarta.persistence.EntityManager;
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
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * A viewing knows which listing is being viewed.
 *
 * <p>It could not, until now: the address went into the title as text, so a
 * listing had no history of being shown and a viewing booked from a matching
 * listing had that listing retyped into it. The listing is optional — plenty of
 * meetings are not viewings — and it is held to the same walls as everything
 * else: it must belong to the client's agency, and deleting it later must not
 * take the record of the showing with it.
 */
@SpringBootTest
@Transactional
class ViewingTest {

    @Autowired private MeetingService     meetingService;
    @Autowired private PropertyService    propertyService;
    @Autowired private MeetingRepository  meetingRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private ClientRepository   clientRepository;
    @Autowired private UserRepository     userRepository;
    @Autowired private TeamRepository     teamRepository;
    @Autowired private EntityManager      entityManager;

    private Team team;
    private User agent;
    private Client buyer;
    private Property listing;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        meetingRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("agent@estate.crm", DataScope.TEAM, team);
        signIn(agent);

        buyer = clientRepository.save(Client.builder()
                .fullName("Irina Sokolova").type(ClientType.BUYER)
                .agent(agent).team(team).build());
        listing = listing("Severny Residence, apt 84", team, agent);
    }

    @Test
    @DisplayName("a viewing carries the listing it is a viewing of")
    void aViewingNamesItsListing() {
        MeetingResponse booked = meetingService.create(viewing(listing.getId()));

        assertThat(booked.getPropertyId()).isEqualTo(listing.getId());
        assertThat(booked.getPropertyTitle()).isEqualTo("Severny Residence, apt 84");
        assertThat(booked.getPropertyAddress()).isEqualTo("Severny Residence 12");
    }

    @Test
    @DisplayName("a meeting that is not a viewing carries no listing")
    void aPlainMeetingHasNoListing() {
        MeetingResponse booked = meetingService.create(viewing(null));

        assertThat(booked.getPropertyId()).isNull();
    }

    @Test
    @DisplayName("the listing can be taken off a meeting again")
    void aViewingCanStopBeingOne() {
        MeetingResponse booked = meetingService.create(viewing(listing.getId()));

        MeetingResponse updated = meetingService.update(booked.getId(), viewing(null));

        assertThat(updated.getPropertyId())
                .as("rescheduling to a call must not keep pointing at a flat")
                .isNull();
    }

    @Test
    @DisplayName("a listing lists its viewings, newest first")
    void aListingRemembersBeingShown() {
        meetingService.create(viewing(listing.getId(), LocalDateTime.now().plusDays(1)));
        meetingService.create(viewing(listing.getId(), LocalDateTime.now().plusDays(3)));
        meetingService.create(viewing(null, LocalDateTime.now().plusDays(2)));

        List<MeetingResponse> viewings = meetingService.getByProperty(listing.getId());

        assertThat(viewings).hasSize(2);
        assertThat(viewings.get(0).getScheduledAt())
                .isAfter(viewings.get(1).getScheduledAt());
    }

    @Test
    @DisplayName("another agency's listing cannot be booked for a viewing")
    void aStrangersListingIsNotBookable() {
        Team other = teamRepository.save(Team.builder().name("Astana Estate").build());
        User stranger = user("stranger@other.crm", DataScope.TEAM, other);
        Property theirs = listing("Their listing", other, stranger);

        assertThatThrownBy(() -> meetingService.create(viewing(theirs.getId())))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("deleting the listing keeps the record of having shown it")
    void thePastSurvivesTheListing() {
        MeetingResponse booked = meetingService.create(viewing(listing.getId()));

        propertyService.delete(listing.getId());
        entityManager.flush();
        entityManager.clear();

        var kept = meetingRepository.findById(booked.getId()).orElseThrow();
        assertThat(kept.getProperty())
                .as("the showing happened; only what was shown is gone")
                .isNull();
        assertThat(kept.getTitle()).isEqualTo("Viewing");
    }

    private MeetingRequest viewing(Long propertyId) {
        return viewing(propertyId, LocalDateTime.now().plusDays(1));
    }

    private MeetingRequest viewing(Long propertyId, LocalDateTime when) {
        MeetingRequest request = new MeetingRequest();
        request.setTitle("Viewing");
        request.setScheduledAt(when);
        request.setClientId(buyer.getId());
        request.setAgentId(agent.getId());
        request.setPropertyId(propertyId);
        return request;
    }

    private Property listing(String title, Team where, User owner) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Severny Residence 12").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3).areaSqm(62.0)
                .agent(owner).team(where).build());
    }

    private User user(String email, DataScope scope, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(scope).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
