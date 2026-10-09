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
 * V59 as written, run against tables shaped like the ones it meets in production. The rest of the
 * suite builds its schema from the entities, so without this nothing would notice a migration that
 * does not apply, or a check that lets through what the API refuses.
 */
class PropertyExpenseMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v59-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE properties (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO teams (name) VALUES ('Almaty Realty')");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul Bekova')");
            s.execute("INSERT INTO properties (title) VALUES ('A flat')");
        }
        String script = new ClassPathResource("db/migration/V59__property_expenses.sql")
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
    @DisplayName("the database keeps the API's rules: a known category and an amount above zero")
    void checks() throws Exception {
        expense("'PHOTO'", "45000.50");
        expense("'OTHER'", "0.01");

        assertThatThrownBy(() -> expense("'COFFEE'", "100")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> expense("'PHOTO'", "0")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> expense("'PHOTO'", "-5")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> expense("NULL", "100")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("an expense goes with its listing, and outlives the account that recorded it")
    void cascades() throws Exception {
        expense("'PHOTO'", "100");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users");
            assertThat(count(s, "SELECT COUNT(*) FROM property_expenses WHERE created_by IS NULL")).isEqualTo(1);
            s.execute("DELETE FROM properties");
            assertThat(count(s, "SELECT COUNT(*) FROM property_expenses")).isZero();
        }
    }

    private void expense(String category, String amount) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO property_expenses (team_id, property_id, category, amount, spent_on, created_by) "
                    + "VALUES (1, 1, " + category + ", " + amount + ", DATE '2026-10-01', 1)");
        }
    }

    private static long count(Statement s, String sql) throws SQLException {
        try (ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getLong(1);
        }
    }
}
