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
 * V56 as written, run against teams, users and properties tables shaped like the ones it meets in
 * production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses. H2 has
 * no partial indexes, so the one-open-handover index is the one statement left out here; Postgres
 * applies it.
 */
class PropertyKeysMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v56-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE properties (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO teams (name) VALUES ('Almaty Realty')");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul Bekova'), ('Timur Aliev')");
            s.execute("INSERT INTO properties (title) VALUES ('Dostyk 5')");
        }
        String script = new ClassPathResource("db/migration/V56__property_keys.sql")
                .getContentAsString(StandardCharsets.UTF_8);
        try (Statement s = db.createStatement()) {
            for (String statement : script.replaceAll("(?m)^--.*$", "").split(";")) {
                if (!statement.isBlank() && !statement.contains("uq_property_key_handovers_open")) {
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
    @DisplayName("no listing's keys are out before anybody records it")
    void startsEmpty() throws Exception {
        assertThat(count("SELECT COUNT(*) FROM property_key_handovers")).isZero();
    }

    @Test
    @DisplayName("the database keeps the API's rules: one holder, a note of at most 500, back after out")
    void checks() throws Exception {
        handover("2", "NULL", "NOW()", "NULL");
        handover("NULL", "'Saule, the owner'", "NOW()", "NOW()");

        assertThatThrownBy(() -> handover("2", "'Saule'", "NOW()", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> handover("NULL", "NULL", "NOW()", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> handover("NULL", "'Saule'", "NOW()", "DATEADD('DAY', -1, NOW())"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> exec("INSERT INTO property_key_handovers (team_id, property_id, holder_name, note) "
                + "VALUES (1, 1, 'Saule', '" + "x".repeat(501) + "')")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("the story goes with its listing; who recorded it is forgotten with the account")
    void cascades() throws Exception {
        handover("2", "NULL", "NOW()", "NULL");
        exec("UPDATE property_key_handovers SET handed_out_by = 1, returned_by = 1");
        exec("DELETE FROM users WHERE id = 1");
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT handed_out_by, returned_by FROM property_key_handovers")) {
            rs.next();
            assertThat(rs.getObject(1)).isNull();
            assertThat(rs.getObject(2)).isNull();
        }
        assertThatThrownBy(() -> exec("DELETE FROM users WHERE id = 2"))
                .as("a holder's name is written down before their account goes")
                .isInstanceOf(SQLException.class);
        exec("DELETE FROM properties WHERE id = 1");
        assertThat(count("SELECT COUNT(*) FROM property_key_handovers")).isZero();
    }

    private void handover(String holderId, String holderName, String out, String back) throws SQLException {
        exec("INSERT INTO property_key_handovers (team_id, property_id, holder_user_id, holder_name, "
                + "handed_out_at, returned_at, due_back_at) VALUES (1, 1, " + holderId + ", " + holderName
                + ", " + out + ", " + back + ", CURRENT_DATE)");
    }

    private void exec(String sql) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute(sql);
        }
    }

    private long count(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getLong(1);
        }
    }
}
