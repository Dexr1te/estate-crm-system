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
 * V55 as written, run against deals and users tables shaped like the ones it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class CommissionSplitMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v51-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255))");
            s.execute("CREATE TABLE deals (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul'), ('Timur')");
            s.execute("INSERT INTO deals (title) VALUES ('An old sale')");
        }
        String script = new ClassPathResource("db/migration/V55__commission_splits.sql")
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
    @DisplayName("a deal from before has no split: all of it is its agent's")
    void existingDealsAreUnsplit() throws Exception {
        assertThat(count("SELECT COUNT(*) FROM commission_splits")).isZero();
    }

    @Test
    @DisplayName("the database keeps the API's rules: one party per share, above 0 and at most 100, a person once")
    void checks() throws Exception {
        insert("2", "NULL", "NULL", "30");
        insert("NULL", "'Ivan Petrov'", "'Etazhi'", "20");
        insert("NULL", "'Olga'", "NULL", "100");

        assertThatThrownBy(() -> insert("2", "NULL", "NULL", "10")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("1", "'Ivan'", "NULL", "10")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("1", "NULL", "'Etazhi'", "10")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("NULL", "NULL", "NULL", "10")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("1", "NULL", "NULL", "0")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("1", "NULL", "NULL", "100.01")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("a share goes with its deal, and with a closed account")
    void cascades() throws Exception {
        insert("2", "NULL", "NULL", "30");
        insert("NULL", "'Ivan Petrov'", "NULL", "20");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users WHERE id = 2");
        }
        assertThat(count("SELECT COUNT(*) FROM commission_splits")).isEqualTo(1);
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM deals WHERE id = 1");
        }
        assertThat(count("SELECT COUNT(*) FROM commission_splits")).isZero();
    }

    private void insert(String userId, String name, String agency, String percent) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO commission_splits (deal_id, user_id, co_broker_name, co_broker_agency, share_percent) "
                    + "VALUES (1, " + userId + ", " + name + ", " + agency + ", " + percent + ")");
        }
    }

    private long count(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getLong(1);
        }
    }
}
