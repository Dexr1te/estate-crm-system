package com.crm.realestate.integration;

import com.crm.realestate.dto.response.ColdClient;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.ColdClientService;
import com.crm.realestate.service.DashboardService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Shared set-up for the going-cold tests: two agencies, a manager and two agents in the first,
 * and helpers that put a client's history where a test needs it in time.
 */
abstract class ColdClientsFixture {

    @Autowired protected MockMvc mockMvc;
    @Autowired protected ColdClientService coldClientService;
    @Autowired protected DashboardService dashboardService;
    @Autowired protected ClientRepository clientRepository;
    @Autowired protected ClientActivityRepository activityRepository;
    @Autowired protected DealRepository dealRepository;
    @Autowired protected MeetingRepository meetingRepository;
    @Autowired protected PropertyRepository propertyRepository;
    @Autowired protected TaskRepository taskRepository;
    @Autowired protected UserRepository userRepository;
    @Autowired protected TeamRepository teamRepository;
    @Autowired protected EntityManager entityManager;
    @Autowired protected EntityManagerFactory entityManagerFactory;

    protected Team almaty;
    protected Team astana;
    protected User manager;
    protected User agent;
    protected User colleague;
    protected User stranger;

    @BeforeEach
    void setUpAgencies() {
        SecurityContextHolder.clearContext();
        taskRepository.deleteAll();
        activityRepository.deleteAll();
        meetingRepository.deleteAll();
        dealRepository.deleteAll();
        propertyRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);
    }

    /** A client whose card is {@code ageDays} old. */
    protected Client client(String name, User holder, ClientType type, ClientSource source, int ageDays) {
        Client client = clientRepository.save(Client.builder()
                .fullName(name).phone("+7 701 000 00 00").type(type).source(source)
                .agent(holder).team(holder.getTeam()).build());
        backdate(client, ageDays);
        return client;
    }

    protected Client buyer(String name, User holder, int ageDays) {
        return client(name, holder, ClientType.BUYER, ClientSource.MANUAL, ageDays);
    }

    /** A buyer who wants a flat in Almaty. */
    protected Client lookingBuyer(String name, User holder, int ageDays) {
        Client client = buyer(name, holder, ageDays);
        client.setWantedCity("Almaty");
        client.setWantedType(PropertyType.APARTMENT);
        client.setBudgetMax(new BigDecimal("50000000"));
        return clientRepository.save(client);
    }

    protected void backdate(Client client, int days) {
        entityManager.flush();
        entityManager.createNativeQuery("UPDATE clients SET created_at = ?1 WHERE id = ?2")
                .setParameter(1, LocalDateTime.now().minusDays(days))
                .setParameter(2, client.getId())
                .executeUpdate();
    }

    protected Deal deal(Client client, String title, DealStatus status) {
        return dealRepository.save(Deal.builder().title(title).status(status)
                .client(client).agent(client.getAgent()).team(client.getTeam()).build());
    }

    protected Property flat(User holder, String city, String price) {
        return propertyRepository.save(Property.builder()
                .title("Flat in " + city).address("Abay 1").city(city)
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal(price)).agent(holder).team(holder.getTeam()).build());
    }

    protected void called(Client client, int daysAgo) {
        activityRepository.save(ClientActivity.builder().type(ActivityType.CALL)
                .occurredAt(LocalDateTime.now().minusDays(daysAgo))
                .client(client).author(client.getAgent()).authorName("x").team(client.getTeam()).build());
    }

    protected Meeting meeting(Client client, LocalDateTime at, Property property, ViewingOutcome outcome) {
        return meetingRepository.save(Meeting.builder().title("Viewing").scheduledAt(at)
                .property(property).outcome(outcome)
                .client(client).agent(client.getAgent()).team(client.getTeam()).build());
    }

    protected void task(Client client, LocalDateTime due, boolean done) {
        taskRepository.save(Task.builder().title("Call " + client.getFullName()).dueAt(due)
                .client(client).completedAt(done ? LocalDateTime.now() : null)
                .assignee(client.getAgent()).createdBy(client.getAgent()).team(client.getTeam()).build());
    }

    protected List<String> coldNames(int days) {
        entityManager.flush();
        entityManager.clear();
        return coldClientService.list(days, 100).stream().map(ColdClient::getFullName).toList();
    }

    protected long statements(Runnable work) {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.flush();
        entityManager.clear();
        stats.clear();
        work.run();
        return stats.getPrepareStatementCount();
    }

    protected User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    protected void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
