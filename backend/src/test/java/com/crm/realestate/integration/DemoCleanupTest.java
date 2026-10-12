package com.crm.realestate.integration;

import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealChecklistItem;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.Document;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyPhoto;
import com.crm.realestate.entity.Star;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.TaskSeries;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ChecklistStage;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.RepeatFrequency;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.StarType;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealChecklistItemRepository;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.DocumentBlobRepository;
import com.crm.realestate.repository.DocumentRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.PropertyPhotoRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.StarRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TaskSeriesRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DocumentStorage;
import com.crm.realestate.service.demo.DemoAgencyCleaner;
import com.crm.realestate.service.demo.DemoAgencyService;
import com.crm.realestate.service.demo.DemoRateLimiter;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class DemoCleanupTest {

    private static final List<String> TEAM_TABLES = List.of(
            "clients", "properties", "deals", "meetings", "tasks", "client_activities",
            "deal_comments", "deal_checklist_items", "notifications", "users");

    @Autowired private DemoAgencyService demoAgencyService;
    @Autowired private DemoAgencyCleaner cleaner;
    @Autowired private DemoRateLimiter rateLimiter;
    @Autowired private JdbcTemplate jdbc;
    @Autowired private EntityManager entityManager;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private TaskRepository taskRepository;
    @Autowired private TaskSeriesRepository taskSeriesRepository;
    @Autowired private DealCommentRepository commentRepository;
    @Autowired private ClientActivityRepository activityRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private StarRepository starRepository;
    @Autowired private DocumentRepository documentRepository;
    @Autowired private DocumentBlobRepository blobRepository;
    @Autowired private PropertyPhotoRepository photoRepository;
    @Autowired private DealChecklistItemRepository checklistRepository;
    @Autowired private AuditLogRepository auditLogRepository;
    @Autowired private DocumentStorage documentStorage;

    @BeforeEach
    void setUp() {
        rateLimiter.reset();
    }

    private AuthResponse startDemo() {
        return demoAgencyService.start("10.1.0.1");
    }

    private void age(AuthResponse demo, int hours) {
        entityManager.flush();
        Timestamp then = Timestamp.valueOf(LocalDateTime.now().minusHours(hours));
        jdbc.update("UPDATE users SET created_at = ? WHERE team_id = ?", then, demo.getTeamId());
        jdbc.update("UPDATE teams SET created_at = ? WHERE id = ?", then, demo.getTeamId());
        entityManager.clear();
    }

    private long rows(String table, String column, Long id) {
        Long count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM " + table + " WHERE " + column + " = ?", Long.class, id);
        return count == null ? 0 : count;
    }

    private record Footprint(Long seriesId, String documentKey, String photoKey) {
    }

    private Footprint fillOut(AuthResponse demo) {
        User agent = userRepository.findById(demo.getUserId()).orElseThrow();
        Team team = agent.getTeam();
        Client client = clientRepository.findByAgentId(agent.getId()).get(0);
        Deal deal = dealRepository.findByAgentId(agent.getId()).get(0);
        Property property = propertyRepository.findByAgentId(agent.getId()).get(0);

        TaskSeries series = taskSeriesRepository.save(TaskSeries.builder()
                .frequency(RepeatFrequency.values()[0]).anchorAt(LocalDateTime.now()).build());
        taskRepository.save(Task.builder().team(team).assignee(agent).createdBy(agent)
                .title("Call back").dueAt(LocalDateTime.now().plusDays(1))
                .client(client).deal(deal).series(series).occurrence(1).build());
        commentRepository.save(DealComment.builder().deal(deal).team(team).author(agent)
                .authorName(agent.getFullName()).body("Looks promising").build());
        activityRepository.save(ClientActivity.builder().client(client).team(team).author(agent)
                .authorName(agent.getFullName()).type(ActivityType.CALL).note("Called").build());
        notificationRepository.save(Notification.builder().team(team).recipient(agent)
                .type(NotificationType.TASK_ASSIGNED).build());
        starRepository.save(Star.builder().user(agent).entityType(StarType.DEAL)
                .entityId(deal.getId()).build());

        String documentKey = documentStorage.storeBytes("contract".getBytes(StandardCharsets.UTF_8),
                "application/pdf", "deals", deal.getId(), "pdf");
        Document document = documentRepository.save(Document.builder().fileName("contract.pdf")
                .fileType("pdf").fileSize(8L).filePath(documentKey).deal(deal).uploadedBy(agent).build());
        checklistRepository.save(DealChecklistItem.builder().deal(deal).team(team)
                .stage(ChecklistStage.LEAD).title("Contract signed").position(0)
                .required(true).custom(true).document(document).build());

        String photoKey = documentStorage.storeBytes("jpeg".getBytes(StandardCharsets.UTF_8),
                "image/jpeg", "photos", property.getId(), "jpg");
        photoRepository.save(PropertyPhoto.builder().property(property).storageKey(photoKey)
                .fileName("front.jpg").contentType("image/jpeg").fileSize(4L).sortOrder(0)
                .uploadedBy(agent).build());

        auditLogRepository.save(AuditLog.builder().actor(agent).action("EXPORT")
                .entityType("Client").entityId(client.getId()).build());
        return new Footprint(series.getId(), documentKey, photoKey);
    }

    @Test
    @DisplayName("a demo older than a day goes with everything in it; a newer one stays")
    void removesExpiredAndKeepsNewer() {
        AuthResponse old = startDemo();
        Footprint footprint = fillOut(old);
        AuthResponse fresh = startDemo();
        age(old, 25);
        age(fresh, 23);
        long auditEntries = auditLogRepository.count();

        assertThat(cleaner.removeExpired(LocalDateTime.now())).isEqualTo(1);

        assertThat(teamRepository.findById(old.getTeamId())).isEmpty();
        assertThat(userRepository.findById(old.getUserId())).isEmpty();
        for (String table : TEAM_TABLES) {
            assertThat(rows(table, "team_id", old.getTeamId())).as(table).isZero();
        }
        assertThat(rows("stars", "user_id", old.getUserId())).isZero();
        assertThat(rows("documents", "uploaded_by", old.getUserId())).isZero();
        assertThat(rows("property_photos", "uploaded_by", old.getUserId())).isZero();
        assertThat(rows("tasks", "assignee_id", old.getUserId())).isZero();
        assertThat(taskSeriesRepository.findById(footprint.seriesId())).isEmpty();
        assertThat(blobRepository.findById(footprint.documentKey())).isEmpty();
        assertThat(blobRepository.findById(footprint.photoKey())).isEmpty();
        assertThat(auditLogRepository.count()).isEqualTo(auditEntries);

        assertThat(teamRepository.findById(fresh.getTeamId())).isPresent();
        assertThat(userRepository.findByTeamId(fresh.getTeamId())).hasSize(2);
        assertThat(clientRepository.findByAgentId(fresh.getUserId())).hasSize(6);
        assertThat(dealRepository.findByAgentId(fresh.getUserId())).hasSize(5);

        assertThat(cleaner.removeExpired(LocalDateTime.now())).isZero();
    }

    @Test
    @DisplayName("the real agencies and the App Review account are never touched")
    void leavesEveryoneElseAlone() {
        Team agency = teamRepository.save(Team.builder().name("[Demo] Agency").build());
        User reviewer = userRepository.save(User.builder()
                .email("reviewer@demo.estatecrm.app").password("x").fullName("App Review")
                .role(Role.AGENT).dataScope(DataScope.OWN).team(agency)
                .status(UserStatus.ACTIVE).isActive(true).build());
        clientRepository.save(Client.builder().fullName("[Demo] Reviewer's client")
                .email("aigerim@demo.estatecrm.app").type(ClientType.BUYER)
                .agent(reviewer).team(agency).build());

        AuthResponse joined = startDemo();
        User outsider = userRepository.save(User.builder()
                .email("colleague@almaty.kz").password("x").fullName("Real Colleague")
                .role(Role.AGENT).dataScope(DataScope.OWN)
                .team(teamRepository.findById(joined.getTeamId()).orElseThrow())
                .status(UserStatus.ACTIVE).isActive(true).build());

        entityManager.flush();
        Timestamp longAgo = Timestamp.valueOf(LocalDateTime.now().minusDays(30));
        jdbc.update("UPDATE users SET created_at = ?", longAgo);
        entityManager.clear();

        assertThat(cleaner.removeExpired(LocalDateTime.now())).isZero();

        assertThat(userRepository.findById(reviewer.getId())).isPresent();
        assertThat(rows("clients", "team_id", agency.getId())).isEqualTo(1);
        assertThat(userRepository.findById(outsider.getId())).isPresent();
        assertThat(userRepository.findById(joined.getUserId())).isPresent();
        assertThat(rows("clients", "team_id", joined.getTeamId())).isEqualTo(6);
    }
}
