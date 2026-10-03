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
 * V47 as written, run against tables shaped like the ones it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses. H2 has
 * no partial indexes, so the one-accepted-offer index is the one statement left out here; Postgres
 * applies it.
 */
class PropertyOfferMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v47-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, email VARCHAR(255))");
            s.execute("CREATE TABLE properties (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("CREATE TABLE clients (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO properties (title) VALUES ('A flat')");
            s.execute("INSERT INTO clients (full_name) VALUES ('A buyer')");
        }
        String script = new ClassPathResource("db/migration/V47__property_offers.sql")
                .getContentAsString(StandardCharsets.UTF_8);
        try (Statement s = db.createStatement()) {
            for (String statement : script.replaceAll("(?m)^--.*$", "").split(";")) {
                if (!statement.isBlank() && !statement.contains("uq_property_offers_accepted")) {
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
    @DisplayName("the database keeps the API's rules: amount, party, status, and when it was decided")
    void offerChecks() throws Exception {
        offer("100", "'BUYER'", "'NEW'", "NULL");
        offer("100", "'SELLER'", "'COUNTERED'", "NULL");
        offer("100", "'BUYER'", "'ACCEPTED'", "NOW()");

        assertThatThrownBy(() -> offer("0", "'BUYER'", "'NEW'", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> offer("100", "'AGENT'", "'NEW'", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> offer("100", "'BUYER'", "'EXPIRED'", "NOW()"))
                .as("EXPIRED is read, never stored").isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> offer("100", "'BUYER'", "'REJECTED'", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> offer("100", "'BUYER'", "'NEW'", "NOW()")).isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("history steps keep their own checks, and go with the offer")
    void eventChecks() throws Exception {
        offer("100", "'BUYER'", "'NEW'", "NULL");
        event("'OFFERED'", "100", "'BUYER'");
        event("'REJECTED'", "100", "NULL");

        assertThatThrownBy(() -> event("'EXPIRED'", "100", "NULL")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> event("'COUNTERED'", "0", "'SELLER'")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> event("'COUNTERED'", "10", "'AGENT'")).isInstanceOf(SQLException.class);

        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM properties");
            try (ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM property_offer_events")) {
                rs.next();
                assertThat(rs.getLong(1)).isZero();
            }
        }
    }

    private void offer(String amount, String party, String status, String decidedAt) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO property_offers (property_id, client_id, amount, last_party, status, decided_at) "
                    + "VALUES (1, 1, " + amount + ", " + party + ", " + status + ", " + decidedAt + ")");
        }
    }

    private void event(String action, String amount, String party) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO property_offer_events (offer_id, action, amount, party) "
                    + "VALUES (1, " + action + ", " + amount + ", " + party + ")");
        }
    }
}
