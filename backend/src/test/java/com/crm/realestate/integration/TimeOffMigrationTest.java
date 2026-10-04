package com.crm.realestate.integration;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * V54 as written, run against users, teams and notifications shaped like the ones it meets in
 * production. The rest of the suite builds its schema from the entities, so without this nothing
 * would notice a migration that does not apply, or a check that lets through what the API never
 * writes.
 */
class TimeOffMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v54-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("""
                    CREATE TABLE notifications (
                        id            BIGSERIAL    PRIMARY KEY,
                        recipient_id  BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                        type          VARCHAR(40)  NOT NULL,
                        created_at    TIMESTAMP    NOT NULL DEFAULT NOW())
                    """);
            s.execute("INSERT INTO teams (name) VALUES ('Almaty Realty')");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul Bekova'), ('Timur Aliev')");
            // A notification from before the migration.
            s.execute("INSERT INTO notifications (recipient_id, type) VALUES (1, 'TASK_ASSIGNED')");
        }
        String script = new ClassPathResource("db/migration/V54__time_off.sql")
                .getContentAsString(StandardCharsets.UTF_8);
        try (Statement s = db.createStatement()) {
            for (String statement : script.replaceAll("(?m)^--.*$", "").split(";")) {
                if (!statement.isBlank()) {
                    s.execute(statement);
                }
            }
        }
    }

    @AfterEach
    void tearDown() throws Exception {
        db.close();
    }

    @Test
    @DisplayName("V54 applies, and a notification from before it is nobody's cover copy")
    void appliesToExistingRows() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT covering FROM notifications")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getBoolean(1)).isFalse();
        }
    }

    @Test
    @DisplayName("an absence has a known kind, does not end before it starts, and nobody covers for themselves")
    void checks() throws Exception {
        insert("'VACATION'", "'2026-10-10'", "'2026-10-12'", "2");
        insert("'DAY_OFF'", "'2026-10-20'", "'2026-10-20'", "NULL");
        for (String[] bad : new String[][]{
                {"'HOLIDAY'", "'2026-10-10'", "'2026-10-12'", "2"},
                {"'VACATION'", "'2026-10-12'", "'2026-10-10'", "2"},
                {"'VACATION'", "'2026-10-10'", "'2026-10-12'", "1"}}) {
            assertThatThrownBy(() -> insert(bad[0], bad[1], bad[2], bad[3]))
                    .as("%s from %s to %s covered by %s", (Object[]) bad)
                    .isInstanceOf(SQLException.class);
        }
    }

    @Test
    @DisplayName("an absence goes with its person, and a closed cover's account leaves it uncovered")
    void deletes() throws Exception {
        insert("'VACATION'", "'2026-10-10'", "'2026-10-12'", "2");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users WHERE id = 2");
            try (ResultSet rs = s.executeQuery("SELECT cover_id FROM time_off")) {
                assertThat(rs.next()).isTrue();
                assertThat(rs.getObject(1)).isNull();
            }
            s.execute("DELETE FROM users WHERE id = 1");
            try (ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM time_off")) {
                assertThat(rs.next()).isTrue();
                assertThat(rs.getInt(1)).isZero();
            }
        }
    }

    private void insert(String kind, String start, String end, String cover) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO time_off (team_id, user_id, cover_id, kind, start_date, end_date) "
                    + "VALUES (1, 1, " + cover + ", " + kind + ", " + start + ", " + end + ")");
        }
    }
}
