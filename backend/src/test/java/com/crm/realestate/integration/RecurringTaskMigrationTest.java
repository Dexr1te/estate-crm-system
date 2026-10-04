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
 * V52 as written, run against a tasks table shaped like the one it meets in production, with a
 * task already in it.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class RecurringTaskMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v52-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE tasks (id BIGSERIAL PRIMARY KEY, title VARCHAR(200) NOT NULL, "
                    + "due_at TIMESTAMP NOT NULL, completed_at TIMESTAMP)");
            s.execute("INSERT INTO tasks (title, due_at) VALUES ('An old task', '2026-01-01 09:00')");
        }
        String script = new ClassPathResource("db/migration/V52__recurring_tasks.sql")
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
    @DisplayName("a task from before repeats nothing")
    void existingTasksDoNotRepeat() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT series_id, occurrence, next_created FROM tasks")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getObject(1)).isNull();
            assertThat(rs.getObject(2)).isNull();
            assertThat(rs.getBoolean(3)).isFalse();
        }
    }

    @Test
    @DisplayName("the database keeps the API's rules: weekdays only weekly, one end, 1-999 times")
    void checks() throws Exception {
        series("'WEEKLY'", "9", "NULL", "NULL");
        series("'MONTHLY'", "NULL", "'2031-12-31'", "NULL");
        series("'DAILY'", "NULL", "NULL", "999");

        assertThatThrownBy(() -> series("'HOURLY'", "NULL", "NULL", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> series("'WEEKLY'", "NULL", "NULL", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> series("'WEEKLY'", "128", "NULL", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> series("'DAILY'", "1", "NULL", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> series("'DAILY'", "NULL", "'2031-12-31'", "3")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> series("'DAILY'", "NULL", "NULL", "0")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("an occurrence is written once per series; losing the series keeps the tasks")
    void oneOccurrenceEach() throws Exception {
        series("'DAILY'", "NULL", "NULL", "NULL");
        try (Statement s = db.createStatement()) {
            s.execute("UPDATE tasks SET series_id = 1, occurrence = 1");
            assertThatThrownBy(() -> s.execute("INSERT INTO tasks (title, due_at, series_id, occurrence) "
                    + "VALUES ('Again', '2026-01-02 09:00', 1, 1)")).isInstanceOf(SQLException.class);
            s.execute("INSERT INTO tasks (title, due_at, series_id, occurrence) "
                    + "VALUES ('Next', '2026-01-02 09:00', 1, 2)");
            s.execute("DELETE FROM task_series");
            try (ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM tasks WHERE series_id IS NULL")) {
                rs.next();
                assertThat(rs.getInt(1)).isEqualTo(2);
            }
        }
    }

    private void series(String frequency, String weekdays, String until, String max) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO task_series (frequency, weekdays, anchor_at, until_date, max_occurrences) "
                    + "VALUES (" + frequency + ", " + weekdays + ", '2031-01-01 09:00', " + until + ", " + max + ")");
        }
    }
}
