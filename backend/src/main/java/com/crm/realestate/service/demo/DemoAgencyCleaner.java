package com.crm.realestate.service.demo;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.DocumentStorage;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@Slf4j
public class DemoAgencyCleaner {

    public static final Duration LIFETIME = Duration.ofHours(24);

    private static final Long NONE = -1L;

    private static final String CLIENTS =
            "(SELECT id FROM clients WHERE team_id IN (:teams) OR agent_id IN (:users))";
    private static final String PROPERTIES =
            "(SELECT id FROM properties WHERE team_id IN (:teams) OR agent_id IN (:users))";
    private static final String DEALS =
            "(SELECT id FROM deals WHERE team_id IN (:teams) OR agent_id IN (:users))";
    private static final String ACTIVITIES =
            "client_activities WHERE team_id IN (:teams) OR client_id IN " + CLIENTS;
    private static final String OPEN_HOUSES =
            "open_houses WHERE team_id IN (:teams) OR property_id IN " + PROPERTIES;
    private static final String OFFERS = "property_offers WHERE team_id IN (:teams)"
            + " OR property_id IN " + PROPERTIES + " OR client_id IN " + CLIENTS;
    private static final String TASKS = "tasks WHERE team_id IN (:teams) OR assignee_id IN (:users)"
            + " OR client_id IN " + CLIENTS + " OR deal_id IN " + DEALS;
    private static final String DOCUMENTS = "documents WHERE deal_id IN " + DEALS
            + " OR uploaded_by IN (:users)";
    private static final String PHOTOS = "property_photos WHERE property_id IN " + PROPERTIES;

    private static final List<String> BEFORE_TASKS = List.of(
            "DELETE FROM stars WHERE user_id IN (:users)",
            "DELETE FROM notifications WHERE recipient_id IN (:users) OR team_id IN (:teams)",
            "DELETE FROM deal_comment_mentions WHERE user_id IN (:users) OR comment_id IN"
                    + " (SELECT id FROM deal_comments WHERE team_id IN (:teams) OR deal_id IN " + DEALS + ")",
            "DELETE FROM deal_comments WHERE team_id IN (:teams) OR deal_id IN " + DEALS,
            "DELETE FROM deal_checklist_items WHERE team_id IN (:teams) OR deal_id IN " + DEALS,
            "DELETE FROM checklist_template_items WHERE team_id IN (:teams)",
            "DELETE FROM deal_status_changes WHERE deal_id IN " + DEALS,
            "DELETE FROM deal_deposits WHERE team_id IN (:teams) OR deal_id IN " + DEALS,
            "DELETE FROM commission_splits WHERE user_id IN (:users) OR deal_id IN " + DEALS);

    private static final List<String> AFTER_FILES = List.of(
            "DELETE FROM property_share_links WHERE property_id IN " + PROPERTIES,
            "DELETE FROM client_activity_properties WHERE property_id IN " + PROPERTIES
                    + " OR activity_id IN (SELECT id FROM " + ACTIVITIES + ")",
            "DELETE FROM open_house_visitors WHERE team_id IN (:teams) OR open_house_id IN"
                    + " (SELECT id FROM " + OPEN_HOUSES + ")",
            "DELETE FROM " + ACTIVITIES,
            "DELETE FROM " + OPEN_HOUSES,
            "DELETE FROM property_offer_events WHERE offer_id IN (SELECT id FROM " + OFFERS + ")",
            "DELETE FROM " + OFFERS,
            "DELETE FROM property_price_changes WHERE team_id IN (:teams) OR property_id IN " + PROPERTIES,
            "DELETE FROM property_key_handovers WHERE team_id IN (:teams) OR property_id IN " + PROPERTIES,
            "DELETE FROM property_expenses WHERE team_id IN (:teams) OR property_id IN " + PROPERTIES,
            "DELETE FROM client_date_notices WHERE client_id IN " + CLIENTS,
            "DELETE FROM client_tag_links WHERE client_id IN " + CLIENTS
                    + " OR tag_id IN (SELECT id FROM client_tags WHERE team_id IN (:teams))",
            "DELETE FROM client_tags WHERE team_id IN (:teams)",
            "DELETE FROM partner_handoffs WHERE team_id IN (:teams) OR client_id IN " + CLIENTS
                    + " OR partner_id IN (SELECT id FROM partners WHERE team_id IN (:teams))",
            "DELETE FROM message_templates WHERE team_id IN (:teams)",
            "DELETE FROM monthly_goals WHERE team_id IN (:teams) OR agent_id IN (:users)",
            "DELETE FROM record_changes WHERE team_id IN (:teams)",
            "DELETE FROM time_off WHERE team_id IN (:teams) OR user_id IN (:users)",
            "DELETE FROM meetings WHERE team_id IN (:teams) OR agent_id IN (:users) OR client_id IN "
                    + CLIENTS + " OR deal_id IN " + DEALS,
            "DELETE FROM deals WHERE team_id IN (:teams) OR agent_id IN (:users)",
            "DELETE FROM clients WHERE team_id IN (:teams) OR agent_id IN (:users)",
            "DELETE FROM partners WHERE team_id IN (:teams)",
            "DELETE FROM properties WHERE team_id IN (:teams) OR agent_id IN (:users)",
            "DELETE FROM team_join_requests WHERE team_id IN (:teams) OR user_id IN (:users)"
                    + " OR invited_by IN (:users)",
            "UPDATE audit_logs SET actor_id = NULL WHERE actor_id IN (:users)",
            "UPDATE users SET created_by = NULL WHERE created_by IN (:users)",
            "UPDATE teams SET manager_id = NULL WHERE manager_id IN (:users)",
            "DELETE FROM users WHERE id IN (:users)",
            "DELETE FROM teams WHERE id IN (:teams)");

    private final UserRepository userRepository;
    private final DocumentStorage documentStorage;
    private final TransactionTemplate transactions;

    @PersistenceContext
    private EntityManager entityManager;

    public DemoAgencyCleaner(UserRepository userRepository, DocumentStorage documentStorage,
                             PlatformTransactionManager transactionManager) {
        this.userRepository = userRepository;
        this.documentStorage = documentStorage;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    @Scheduled(cron = "${app.demo.cleanup-cron:0 20 * * * *}")
    public void removeExpired() {
        removeExpired(LocalDateTime.now());
    }

    public int removeExpired(LocalDateTime now) {
        List<Agency> expired = Objects.requireNonNull(transactions.execute(status -> expired(now)));
        int removed = 0;
        for (Agency agency : expired) {
            if (remove(agency)) {
                removed++;
            }
        }
        if (!expired.isEmpty()) {
            log.info("Removed {} of {} expired demo agencies", removed, expired.size());
        }
        return removed;
    }

    private List<Agency> expired(LocalDateTime now) {
        Map<Long, Team> teams = new LinkedHashMap<>();
        List<Long> teamless = new ArrayList<>();
        for (User user : userRepository.findByEmailLikeCreatedBefore(
                DemoAccounts.TRY_EMAIL_PATTERN, now.minus(LIFETIME))) {
            if (user.getTeam() == null) {
                teamless.add(user.getId());
            } else {
                teams.putIfAbsent(user.getTeam().getId(), user.getTeam());
            }
        }

        List<Agency> agencies = new ArrayList<>();
        for (Team team : teams.values()) {
            List<User> members = userRepository.findByTeamId(team.getId());
            if (team.getManager() != null
                    || !members.stream().allMatch(m -> DemoAccounts.isTryAccount(m.getEmail()))) {
                log.warn("Demo agency {} has members outside the demo; leaving it alone", team.getId());
                continue;
            }
            agencies.add(new Agency(List.of(team.getId()), members.stream().map(User::getId).toList()));
        }
        if (!teamless.isEmpty()) {
            agencies.add(new Agency(List.of(NONE), teamless));
        }
        return agencies;
    }

    private boolean remove(Agency agency) {
        try {
            List<String> files = transactions.execute(status -> wipe(agency.teams(), agency.users()));
            Objects.requireNonNull(files).forEach(this::deleteFile);
            return true;
        } catch (RuntimeException e) {
            log.error("Could not remove demo agency {} (users {}): {}",
                    agency.teams(), agency.users(), e.getMessage());
            return false;
        }
    }

    private List<String> wipe(List<Long> teams, List<Long> users) {
        entityManager.flush();
        BEFORE_TASKS.forEach(sql -> run(sql, teams, users));

        List<Long> series = ids("SELECT DISTINCT series_id FROM " + TASKS, teams, users).stream()
                .filter(Objects::nonNull)
                .toList();
        run("DELETE FROM " + TASKS, teams, users);
        if (!series.isEmpty()) {
            entityManager.createNativeQuery("DELETE FROM task_series WHERE id IN (:series)"
                            + " AND NOT EXISTS (SELECT 1 FROM tasks t WHERE t.series_id = task_series.id)")
                    .setParameter("series", series)
                    .executeUpdate();
        }

        List<String> files = new ArrayList<>(strings("SELECT file_path FROM " + DOCUMENTS, teams, users));
        run("DELETE FROM " + DOCUMENTS, teams, users);
        files.addAll(strings("SELECT storage_key FROM " + PHOTOS, teams, users));
        files.addAll(strings("SELECT thumbnail_key FROM " + PHOTOS, teams, users));
        run("DELETE FROM " + PHOTOS, teams, users);

        AFTER_FILES.forEach(sql -> run(sql, teams, users));
        entityManager.flush();
        entityManager.clear();
        return files.stream().filter(Objects::nonNull).toList();
    }

    private void deleteFile(String key) {
        try {
            documentStorage.delete(key);
        } catch (RuntimeException e) {
            log.warn("Could not delete demo file {}: {}", key, e.getMessage());
        }
    }

    private void run(String sql, Collection<Long> teams, Collection<Long> users) {
        bind(entityManager.createNativeQuery(sql), sql, teams, users).executeUpdate();
    }

    private List<Long> ids(String sql, Collection<Long> teams, Collection<Long> users) {
        List<?> rows = bind(entityManager.createNativeQuery(sql), sql, teams, users).getResultList();
        return rows.stream().map(r -> r == null ? null : ((Number) r).longValue()).toList();
    }

    private List<String> strings(String sql, Collection<Long> teams, Collection<Long> users) {
        List<?> rows = bind(entityManager.createNativeQuery(sql), sql, teams, users).getResultList();
        return rows.stream().map(r -> r == null ? null : r.toString()).toList();
    }

    private record Agency(List<Long> teams, List<Long> users) {
    }

    private static Query bind(Query query, String sql, Collection<Long> teams, Collection<Long> users) {
        if (sql.contains(":teams")) {
            query.setParameter("teams", teams);
        }
        if (sql.contains(":users")) {
            query.setParameter("users", users);
        }
        return query;
    }
}
