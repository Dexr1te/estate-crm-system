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
 * V53 as written, run against tables shaped like the ones it meets in production, with a client
 * whose lead source V41 already recorded.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class PartnerMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v53-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255))");
            s.execute("CREATE TABLE clients (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255), "
                    + "lead_source VARCHAR(20), CONSTRAINT chk_clients_lead_source CHECK "
                    + "(lead_source IS NULL OR lead_source IN ('REFERRAL', 'WEBSITE', 'PORTAL', 'SOCIAL', "
                    + "'WALK_IN', 'COLD_CALL', 'REPEAT', 'OTHER')))");
            s.execute("INSERT INTO teams (name) VALUES ('Almaty Realty')");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul')");
            s.execute("INSERT INTO clients (full_name, lead_source) VALUES ('Old referral', 'REFERRAL')");
        }
        String script = new ClassPathResource("db/migration/V53__partners.sql")
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
    @DisplayName("a referral fee is both halves or neither, a percent within 0-100 or an amount above 0")
    void feeCheck() throws Exception {
        partner("'MORTGAGE_BROKER'", "NULL", "NULL");
        partner("'LAWYER'", "'PERCENT'", "100");
        partner("'AGENCY'", "'FIXED'", "150000");

        assertThatThrownBy(() -> partner("'BANK'", "NULL", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> partner("'OTHER'", "'PERCENT'", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> partner("'OTHER'", "NULL", "10")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> partner("'OTHER'", "'PERCENT'", "101")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> partner("'OTHER'", "'FIXED'", "0")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> partner("'OTHER'", "'SHARE'", "5")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("the partner is on a client exactly when the lead source is PARTNER, and is not deleted under it")
    void referredBy() throws Exception {
        partner("'MORTGAGE_BROKER'", "NULL", "NULL");
        execute("INSERT INTO clients (full_name, lead_source, referred_by_partner_id) VALUES ('Saule', 'PARTNER', 1)");
        execute("INSERT INTO clients (full_name, lead_source) VALUES ('Walk-in', 'WALK_IN')");
        execute("INSERT INTO clients (full_name) VALUES ('Unknown')");

        assertThatThrownBy(() -> execute("INSERT INTO clients (full_name, lead_source) VALUES ('x', 'PARTNER')"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> execute(
                "INSERT INTO clients (full_name, lead_source, referred_by_partner_id) VALUES ('x', 'REFERRAL', 1)"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> execute(
                "INSERT INTO clients (full_name, referred_by_partner_id) VALUES ('x', 1)"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> execute("DELETE FROM partners WHERE id = 1")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("a hand-off goes with the client's card, and forgets who sent it with their account")
    void handoffs() throws Exception {
        partner("'LAWYER'", "NULL", "NULL");
        execute("INSERT INTO partner_handoffs (client_id, partner_id, sent_by_id, sent_on) VALUES (1, 1, 1, DATE '2026-10-01')");
        assertThat(count("SELECT COUNT(*) FROM partner_handoffs WHERE status = 'SENT'")).isEqualTo(1);
        assertThatThrownBy(() -> execute("INSERT INTO partner_handoffs (client_id, partner_id, sent_on, status) "
                + "VALUES (1, 1, DATE '2026-10-01', 'LOST')")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> execute("DELETE FROM partners WHERE id = 1")).isInstanceOf(SQLException.class);

        execute("DELETE FROM users WHERE id = 1");
        assertThat(count("SELECT COUNT(*) FROM partner_handoffs WHERE sent_by_id IS NULL")).isEqualTo(1);
        execute("DELETE FROM clients WHERE id = 1");
        assertThat(count("SELECT COUNT(*) FROM partner_handoffs")).isZero();
    }

    private void partner(String kind, String feeType, String feeValue) throws SQLException {
        execute("INSERT INTO partners (team_id, created_by_id, name, kind, fee_type, fee_value) VALUES (1, 1, 'p', "
                + kind + ", " + feeType + ", " + feeValue + ")");
    }

    private void execute(String sql) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute(sql);
        }
    }

    private int count(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getInt(1);
        }
    }
}
