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
 * V57 as written, run against a users table shaped like the one it meets in production. The rest
 * of the suite builds its schema from the entities, so without this nothing would notice a
 * migration that does not apply, or a check that lets through what the API never writes.
 */
class StarMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v57-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul Bekova'), ('Timur Aliev')");
        }
        String script = new ClassPathResource("db/migration/V57__stars.sql")
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
    @DisplayName("a star is on a client, a property or a deal, and once per person per record")
    void checks() throws Exception {
        insert(1, "'CLIENT'", 10);
        insert(1, "'PROPERTY'", 10);
        insert(1, "'DEAL'", 10);
        insert(2, "'CLIENT'", 10);
        assertThatThrownBy(() -> insert(1, "'MEETING'", 10)).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert(1, "'CLIENT'", 10)).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert(3, "'CLIENT'", 11)).isInstanceOf(SQLException.class);
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT created_at FROM stars WHERE user_id = 2")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getTimestamp(1)).isNotNull();
        }
    }

    @Test
    @DisplayName("a person's stars go with their account")
    void deletes() throws Exception {
        insert(1, "'CLIENT'", 10);
        insert(2, "'DEAL'", 20);
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users WHERE id = 1");
            try (ResultSet rs = s.executeQuery("SELECT user_id FROM stars")) {
                assertThat(rs.next()).isTrue();
                assertThat(rs.getLong(1)).isEqualTo(2);
                assertThat(rs.next()).isFalse();
            }
        }
    }

    private void insert(long userId, String type, long entityId) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO stars (user_id, entity_type, entity_id) VALUES ("
                    + userId + ", " + type + ", " + entityId + ")");
        }
    }
}
