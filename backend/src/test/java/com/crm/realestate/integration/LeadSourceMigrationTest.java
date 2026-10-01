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
 * V41 as written, run against a clients table shaped like the one it meets in production: public
 * page leads become website leads, everyone else stays unrecorded, and the checks refuse what the
 * API refuses.
 */
class LeadSourceMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v41-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("""
                    CREATE TABLE clients (
                        id BIGSERIAL PRIMARY KEY,
                        full_name VARCHAR(255) NOT NULL,
                        source VARCHAR(20) NOT NULL DEFAULT 'MANUAL',
                        team_id BIGINT REFERENCES teams(id))
                    """);
            s.execute("INSERT INTO clients (full_name, source) VALUES ('Typed', 'MANUAL')");
            s.execute("INSERT INTO clients (full_name, source) VALUES ('From the page', 'PUBLIC_LINK')");
            s.execute("INSERT INTO clients (full_name, source) VALUES ('Imported', 'IMPORT')");
        }
        String script = new ClassPathResource("db/migration/V41__client_lead_source.sql")
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
    @DisplayName("only public-page leads are backfilled, as website")
    void backfill() throws Exception {
        assertThat(leadSourceOf("From the page")).isEqualTo("WEBSITE");
        assertThat(leadSourceOf("Typed")).isNull();
        assertThat(leadSourceOf("Imported")).isNull();
    }

    @Test
    @DisplayName("an unknown source, or a detail with no source, is refused")
    void checks() throws Exception {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO clients (full_name, lead_source, lead_source_detail) "
                    + "VALUES ('Fine', 'REFERRAL', 'Dana')");
            assertThatThrownBy(() -> s.execute(
                    "INSERT INTO clients (full_name, lead_source) VALUES ('Bad', 'BILLBOARD')"))
                    .isInstanceOf(SQLException.class);
            assertThatThrownBy(() -> s.execute(
                    "INSERT INTO clients (full_name, lead_source_detail) VALUES ('Bad', 'Dana')"))
                    .isInstanceOf(SQLException.class);
        }
    }

    private String leadSourceOf(String name) throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT lead_source FROM clients WHERE full_name = '" + name + "'")) {
            rs.next();
            return rs.getString(1);
        }
    }
}
