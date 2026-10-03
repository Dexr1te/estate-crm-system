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
 * V49 as written, run against tables shaped like the ones it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, checks that let through what the service never writes,
 * or a leaver taking their lines with them.
 */
class AuditLogMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v49-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, email VARCHAR(255))");
            s.execute("INSERT INTO teams (name) VALUES ('Almaty Realty')");
            s.execute("INSERT INTO users (email) VALUES ('agent@almaty.kz')");
        }
        String script = new ClassPathResource("db/migration/V49__audit_log.sql")
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
    @DisplayName("the database keeps the log's shape: known records and actions, a field exactly on edits")
    void checks() throws Exception {
        insert("'PROPERTY'", "'CREATED'", "NULL");
        insert("'DEAL'", "'STATUS_CHANGED'", "'status'");
        insert("'CLIENT'", "'UPDATED'", "'phone'");

        assertThatThrownBy(() -> insert("'MEETING'", "'CREATED'", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'DEAL'", "'RENAMED'", "'title'")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'DEAL'", "'CREATED'", "'title'")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'DEAL'", "'UPDATED'", "NULL")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("a leaver's lines stay with their name; an agency's go with it")
    void deletions() throws Exception {
        insert("'CLIENT'", "'UPDATED'", "'phone'");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users");
            try (ResultSet r = s.executeQuery("SELECT actor_id, actor_name FROM record_changes")) {
                assertThat(r.next()).isTrue();
                assertThat(r.getObject(1)).isNull();
                assertThat(r.getString(2)).isEqualTo("Aigul Bekova");
            }
            s.execute("DELETE FROM teams");
            try (ResultSet r = s.executeQuery("SELECT COUNT(*) FROM record_changes")) {
                r.next();
                assertThat(r.getInt(1)).isZero();
            }
        }
    }

    private void insert(String type, String action, String field) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO record_changes (team_id, entity_type, entity_id, actor_id, actor_name, action, field) "
                    + "VALUES (1, " + type + ", 7, 1, 'Aigul Bekova', " + action + ", " + field + ")");
        }
    }
}
