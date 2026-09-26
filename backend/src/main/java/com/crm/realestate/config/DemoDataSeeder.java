package com.crm.realestate.config;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DocumentStorage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * The account App Review signs in with, and enough work for it to have something to look at.
 *
 * <p>Guideline 2.1 wants working credentials for anything behind a login. An account on the
 * agency's own records is not an option: it would hand a stranger real clients' names and phone
 * numbers. So the reviewer gets an ordinary agent on {@link DataScope#OWN} in a team of its own,
 * {@value #DEMO_TEAM}, whose only records are the ones seeded here. A team is the wall between
 * agencies, so the real ones cannot see these records and the reviewer cannot see theirs.
 *
 * <p>It has to run against production, because that is the host the submitted build talks to. So it
 * is off unless {@code app.demo.enabled} is true, turning it on is a deliberate act, and the log
 * says exactly what it did.
 *
 * <h2>Two things worth knowing before you run it</h2>
 *
 * <p><b>The records are labelled.</b> Clients and listings are prefixed {@code [Demo]} and every
 * demo email sits on a reserved domain. That is partly so an administrator scanning the agency's
 * own lists can tell at a glance what these are, and partly because those markers are how this
 * class finds its previous run to clear it — ownership is no guide, since deleting the account
 * hands its records to whoever the reviewer nominated.
 *
 * <p><b>It will not touch a demo account that already exists.</b> Re-running is a no-op while the
 * reviewer account is there. To rebuild the data, delete that account from the admin console and
 * restart.
 */
@Component
@ConditionalOnProperty(name = "app.demo.enabled", havingValue = "true")
@RequiredArgsConstructor
@Slf4j
public class DemoDataSeeder implements ApplicationRunner {

    /** Reserved for demo records, so a marker can never collide with a real client's address. */
    static final String DEMO_EMAIL_DOMAIN = "@demo.estatecrm.app";

    /** Visible on purpose: these rows live in the agency's production database. */
    static final String DEMO_PREFIX = "[Demo] ";

    /** The reviewer's agency. An agent outside any team would be shown nothing but a waiting screen. */
    static final String DEMO_TEAM = DEMO_PREFIX + "Agency";

    private final UserRepository     userRepository;
    private final TeamRepository     teamRepository;
    private final ClientRepository   clientRepository;
    private final PropertyRepository propertyRepository;
    private final DealRepository     dealRepository;
    private final MeetingRepository  meetingRepository;
    private final DocumentRepository documentRepository;
    private final DocumentStorage    documentStorage;
    private final PasswordEncoder    passwordEncoder;

    @Value("${app.demo.email:reviewer" + DEMO_EMAIL_DOMAIN + "}")
    private String reviewerEmail;

    @Value("${app.demo.password:}")
    private String reviewerPassword;

    @Value("${app.demo.full-name:App Review}")
    private String reviewerName;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (reviewerPassword == null || reviewerPassword.isBlank()) {
            log.error("app.demo.enabled=true but app.demo.password is empty — refusing to create "
                    + "the review account. Set DEMO_PASSWORD and restart.");
            return;
        }
        if (userRepository.existsByEmail(reviewerEmail)) {
            log.info("Demo account {} already exists; leaving it and its records alone. To rebuild "
                    + "them, delete the account from the admin console and restart.", reviewerEmail);
            return;
        }

        clearPreviousRun();

        Team team = teamRepository.findFirstByNameOrderByIdAsc(DEMO_TEAM)
                .orElseGet(() -> teamRepository.save(Team.builder().name(DEMO_TEAM).build()));

        // Someone for the reviewer to hand the records to. Deleting your own account requires
        // nominating a successor from the same team — without this there would be nobody to pick.
        User successor = userRepository.findByEmail(handoverEmail())
                .orElseGet(() -> userRepository.save(agent(handoverEmail(), DEMO_PREFIX + "Handover Account", team)));

        User reviewer = userRepository.save(agent(reviewerEmail, reviewerName, team));
        seedRecords(reviewer);

        log.info("Seeded demo account {} (agent, own-data scope) with 6 clients, 5 listings, "
                + "5 deals and 4 meetings. Successor for the deletion flow: {}.",
                reviewer.getEmail(), successor.getEmail());
    }

    private String handoverEmail() {
        return "handover" + DEMO_EMAIL_DOMAIN;
    }

    /**
     * Removes whatever the last run left behind.
     *
     * <p>Deleted in dependency order by hand rather than left to the cascades on {@code Client.deals}
     * and {@code Deal.meetings}. Those cascade from the inverse side of each association, so they
     * only fire for rows the session happens to have loaded into the parent's collection — which is
     * not the same set as the rows in the table, and the delete then fails on a foreign key.
     *
     * <p>Listings are the exception: nothing owns them, they have to be named separately, and one
     * that a real deal has since been attached to is left where it is.
     */
    private void clearPreviousRun() {
        List<Client> staleClients = clientRepository.findByEmailEndingWithIgnoreCase(DEMO_EMAIL_DOMAIN);
        List<Deal> staleDeals = staleClients.stream()
                .flatMap(c -> dealRepository.findByClientId(c.getId()).stream())
                .toList();

        // A meeting points at both a client and (optionally) a deal, so both routes are swept.
        staleClients.forEach(c -> meetingRepository.deleteAll(meetingRepository.findByClientId(c.getId())));
        staleDeals.forEach(d -> meetingRepository.deleteAll(meetingRepository.findByDealId(d.getId())));
        meetingRepository.flush();

        // Anything the reviewer attached to a deal. The row and the file on disk both go, or the
        // uploads directory keeps growing across submissions with nothing pointing at it.
        for (Deal deal : staleDeals) {
            for (Document document : documentRepository.findByDealId(deal.getId())) {
                documentRepository.delete(document);
                documentStorage.delete(document.getFilePath());
            }
        }
        documentRepository.flush();

        dealRepository.deleteAll(staleDeals);
        dealRepository.flush();
        clientRepository.deleteAll(staleClients);
        clientRepository.flush();

        List<Property> staleProperties = propertyRepository.findByTitleStartingWith(DEMO_PREFIX).stream()
                .filter(p -> !dealRepository.existsByPropertyId(p.getId()))
                .toList();
        propertyRepository.deleteAll(staleProperties);

        if (!staleClients.isEmpty() || !staleProperties.isEmpty()) {
            log.info("Cleared {} demo clients, {} deals and {} listings from a previous review.",
                    staleClients.size(), staleDeals.size(), staleProperties.size());
        }
    }

    /**
     * An agent, not an administrator.
     *
     * <p>Deliberate: {@code AccountRemovalService} refuses to delete the primary admin or the last
     * remaining one, and a reviewer who cannot finish "Delete account" reads it as the feature
     * being missing — which is the one thing Guideline 5.1.1(v) is checked for by hand.
     */
    private User agent(String email, String fullName, Team team) {
        return User.builder()
                .email(email)
                .password(passwordEncoder.encode(reviewerPassword))
                .fullName(fullName)
                .role(Role.AGENT)
                .dataScope(DataScope.OWN)
                .team(team)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                // The reviewer gets one password and should not be asked to invent another.
                .mustChangePassword(false)
                .build();
    }

    private void seedRecords(User agent) {
        Client aigerim = client(agent, "Aigerim Nurlanova", "aigerim", "+7 701 000 01 01",
                ClientType.BUYER, "Looking for a two-room flat near the centre. Viewings after 18:00.");
        Client daniyar = client(agent, "Daniyar Serikov", "daniyar", "+7 701 000 01 02",
                ClientType.BUYER, "Mortgage pre-approved. Wants a school within walking distance.");
        Client madina = client(agent, "Madina Abenova", "madina", "+7 701 000 01 03",
                ClientType.SELLER, "Selling the retail unit on Abay. Deal closed in her favour.");
        Client ruslan = client(agent, "Ruslan Iskakov", "ruslan", "+7 701 000 01 04",
                ClientType.BUYER, "Relocating from Astana. Needs the house before September.");
        Client zhanna = client(agent, "Zhanna Karimova", "zhanna", "+7 701 000 01 05",
                ClientType.SELLER, "Withdrew the office floor from sale; may relist in spring.");
        client(agent, "Timur Bekov", "timur", "+7 701 000 01 06",
                ClientType.BUYER, "First call taken, nothing shortlisted yet.");

        Property dostyk = property(agent, "2-room apartment on Dostyk", "Dostyk Ave 210",
                PropertyType.APARTMENT, PropertyStatus.AVAILABLE, "128000", 62.5, 2, 7, 12);
        Property alFarabi = property(agent, "3-room apartment on Al-Farabi", "Al-Farabi Ave 77",
                PropertyType.APARTMENT, PropertyStatus.RESERVED, "215000", 94.0, 3, 5, 9);
        Property house = property(agent, "Family house in Gornyi Gigant", "Zhamakayev St 12",
                PropertyType.HOUSE, PropertyStatus.AVAILABLE, "430000", 240.0, 5, 1, 2);
        Property office = property(agent, "Office floor at Nurly Tau", "Al-Farabi Ave 17/1",
                PropertyType.OFFICE, PropertyStatus.AVAILABLE, "310000", 180.0, null, 8, 16);
        Property retail = property(agent, "Retail space on Abay", "Abay Ave 44",
                PropertyType.COMMERCIAL, PropertyStatus.SOLD, "265000", 120.0, null, 1, 1);

        // One deal per pipeline column, so the board has something to drag in every one of them.
        Deal search = deal(agent, aigerim, null, "Apartment search for Aigerim",
                DealStatus.LEAD, null, "140000", null);
        Deal negotiation = deal(agent, daniyar, alFarabi, "Al-Farabi three-room for Daniyar",
                DealStatus.NEGOTIATION, "210000", "220000", null);
        Deal won = deal(agent, madina, retail, "Abay retail unit for Madina",
                DealStatus.CLOSED_WON, "265000", null, LocalDateTime.now().minusDays(12));
        Deal viewing = deal(agent, ruslan, house, "Gornyi Gigant house for Ruslan",
                DealStatus.NEGOTIATION, "430000", "450000", null);
        deal(agent, zhanna, office, "Nurly Tau office floor for Zhanna",
                DealStatus.CLOSED_LOST, null, null, LocalDateTime.now().minusDays(5));

        // Two ahead and two behind: the dashboard counts upcoming meetings, and the reminder
        // settings screen is only worth looking at if there is something left to be reminded about.
        meeting(agent, daniyar, negotiation, "Viewing at Al-Farabi 77",
                LocalDate.now().plusDays(1).atTime(11, 0), "Al-Farabi Ave 77", false);
        meeting(agent, ruslan, viewing, "Second viewing of the house",
                LocalDate.now().plusDays(3).atTime(15, 30), "Zhamakayev St 12", false);
        meeting(agent, aigerim, search, "Intake call",
                LocalDate.now().minusDays(2).atTime(10, 0), "Phone", true);
        meeting(agent, madina, won, "Handover of the keys",
                LocalDate.now().minusDays(9).atTime(13, 0), "Abay Ave 44", true);
    }

    private Client client(User agent, String name, String mailbox, String phone,
                          ClientType type, String notes) {
        return clientRepository.save(Client.builder()
                .fullName(DEMO_PREFIX + name)
                .email(mailbox + DEMO_EMAIL_DOMAIN)
                .phone(phone)
                .type(type)
                .notes(notes)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }

    private Property property(User agent, String title, String address, PropertyType type,
                              PropertyStatus status, String price, Double areaSqm,
                              Integer rooms, Integer floor, Integer totalFloors) {
        return propertyRepository.save(Property.builder()
                .title(DEMO_PREFIX + title)
                .address(address)
                .city("Almaty")
                .type(type)
                .status(status)
                .price(new BigDecimal(price))
                .areaSqm(areaSqm)
                .rooms(rooms)
                .floor(floor)
                .totalFloors(totalFloors)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }

    private Deal deal(User agent, Client client, Property property, String title,
                      DealStatus status, String dealPrice, String budget, LocalDateTime closedAt) {
        return dealRepository.save(Deal.builder()
                .title(title)
                .status(status)
                .client(client)
                .property(property)
                .agent(agent)
                .team(agent.getTeam())
                .dealPrice(dealPrice == null ? null : new BigDecimal(dealPrice))
                .budget(budget == null ? null : new BigDecimal(budget))
                .closedAt(closedAt)
                // A seeded lost deal says why, as a real one must now.
                .lostReason(status == DealStatus.CLOSED_LOST
                        ? com.crm.realestate.enums.DealLostReason.PRICE : null)
                .build());
    }

    private void meeting(User agent, Client client, Deal deal, String title,
                         LocalDateTime scheduledAt, String location, boolean completed) {
        meetingRepository.save(Meeting.builder()
                .title(title)
                .scheduledAt(scheduledAt)
                .location(location)
                .completed(completed)
                .client(client)
                .deal(deal)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }
}
