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
 * V48 as written, run against a client_activities table shaped like the one it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or a check that lets through what the API never writes.
 */
class ClientHandoverMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v48-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE clients (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("""
                    CREATE TABLE client_activities (
                        id           BIGSERIAL    PRIMARY KEY,
                        client_id    BIGINT       NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
                        type         VARCHAR(20)  NOT NULL,
                        note         TEXT,
                        occurred_at  TIMESTAMP    NOT NULL DEFAULT NOW())
                    """);
            s.execute("INSERT INTO clients (full_name) VALUES ('Aliya Buyer')");
            // A call from before the migration.
            s.execute("INSERT INTO client_activities (client_id, type) VALUES (1, 'CALL')");
        }
        String script = new ClassPathResource("db/migration/V48__client_handover.sql")
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
    @DisplayName("V48 applies, and an entry from before it is no handover")
    void appliesToExistingRows() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT handover_from_name, handover_to_name FROM client_activities")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getObject(1)).isNull();
            assertThat(rs.getObject(2)).isNull();
        }
    }

    @Test
    @DisplayName("a handover line names both people and is a note")
    void handoverChecks() throws Exception {
        insert("'NOTE'", "'Aigul Bekova'", "'Timur Aliev'");
        insert("'NOTE'", "''", "'Timur Aliev'");
        for (String[] bad : new String[][]{
                {"'NOTE'", "'Aigul Bekova'", "NULL"},
                {"'NOTE'", "NULL", "'Timur Aliev'"},
                {"'CALL'", "'Aigul Bekova'", "'Timur Aliev'"}}) {
            assertThatThrownBy(() -> insert(bad[0], bad[1], bad[2]))
                    .as("%s from %s to %s", bad[0], bad[1], bad[2])
                    .isInstanceOf(SQLException.class);
        }
    }

    private void insert(String type, String from, String to) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO client_activities (client_id, type, handover_from_name, handover_to_name) "
                    + "VALUES (1, " + type + ", " + from + ", " + to + ")");
        }
    }
}
