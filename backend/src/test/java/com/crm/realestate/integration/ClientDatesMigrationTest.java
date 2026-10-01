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
 * V45 as written, run against a clients table shaped like the one it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class ClientDatesMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v45-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("""
                    CREATE TABLE clients (
                        id BIGSERIAL PRIMARY KEY,
                        full_name VARCHAR(255) NOT NULL,
                        team_id BIGINT REFERENCES teams(id))
                    """);
            // A client from before the migration.
            s.execute("INSERT INTO clients (full_name) VALUES ('Older client')");
        }
        String script = new ClassPathResource("db/migration/V45__client_dates.sql")
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
    @DisplayName("V45 applies, and a client from before it has no birthday")
    void appliesToExistingRows() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT birth_month, birth_day, birth_year FROM clients")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getObject(1)).isNull();
            assertThat(rs.getObject(2)).isNull();
            assertThat(rs.getObject(3)).isNull();
        }
    }

    @Test
    @DisplayName("the database keeps the API's rules: a real day of the year, both or neither, no year before 1900")
    void birthdayChecks() throws Exception {
        birthday("2", "29", "NULL");
        birthday("4", "30", "1990");
        birthday("12", "31", "1900");
        for (String[] bad : new String[][]{
                {"2", "30", "NULL"}, {"4", "31", "NULL"}, {"13", "1", "NULL"}, {"0", "1", "NULL"},
                {"5", "NULL", "NULL"}, {"NULL", "14", "NULL"}, {"NULL", "NULL", "1990"}, {"5", "14", "1899"}}) {
            assertThatThrownBy(() -> birthday(bad[0], bad[1], bad[2]))
                    .as(String.join("/", bad)).isInstanceOf(SQLException.class);
        }
    }

    @Test
    @DisplayName("a client is told about once per kind and year, and the notices go with the client")
    void noticesOncePerYear() throws Exception {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO client_date_notices (client_id, kind, occurrence_year) VALUES (1, 'BIRTHDAY', 2026)");
            s.execute("INSERT INTO client_date_notices (client_id, kind, occurrence_year) VALUES (1, 'BIRTHDAY', 2027)");
            s.execute("INSERT INTO client_date_notices (client_id, kind, occurrence_year) "
                    + "VALUES (1, 'PURCHASE_ANNIVERSARY', 2026)");
            assertThatThrownBy(() -> s.execute("INSERT INTO client_date_notices (client_id, kind, occurrence_year) "
                    + "VALUES (1, 'BIRTHDAY', 2026)")).isInstanceOf(SQLException.class);
            assertThatThrownBy(() -> s.execute("INSERT INTO client_date_notices (client_id, kind, occurrence_year) "
                    + "VALUES (1, 'NAME_DAY', 2026)")).isInstanceOf(SQLException.class);

            s.execute("DELETE FROM clients WHERE id = 1");
            try (ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM client_date_notices")) {
                rs.next();
                assertThat(rs.getLong(1)).isZero();
            }
        }
    }

    private void birthday(String month, String day, String year) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO clients (full_name, birth_month, birth_day, birth_year) VALUES ('C', "
                    + month + ", " + day + ", " + year + ")");
        }
    }
}
