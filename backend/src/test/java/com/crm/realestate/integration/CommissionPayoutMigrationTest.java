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
 * V58 as written, run on top of V55 against deals and users tables shaped like the ones it meets in
 * production, with a share already in it.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class CommissionPayoutMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v58-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255))");
            s.execute("CREATE TABLE deals (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO users (full_name) VALUES ('Aigul'), ('Timur'), ('Asel')");
            s.execute("INSERT INTO deals (title) VALUES ('An old sale')");
        }
        run("db/migration/V55__commission_splits.sql");
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO commission_splits (deal_id, user_id, share_percent) VALUES (1, 2, 30)");
        }
        run("db/migration/V58__commission_payouts.sql");
    }

    @AfterEach
    void tearDown() throws Exception {
        db.close();
    }

    @Test
    @DisplayName("a share from before is still owed")
    void existingSharesAreUnpaid() throws Exception {
        assertThat(count("SELECT COUNT(*) FROM commission_splits WHERE paid_at IS NULL "
                + "AND paid_by IS NULL AND payout_note IS NULL")).isEqualTo(1);
    }

    @Test
    @DisplayName("who paid it and the note come with a payout; a 500-character note fits, 501 does not")
    void checks() throws Exception {
        assertThatThrownBy(() -> update("paid_by = 3")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> update("payout_note = 'Cash'")).isInstanceOf(SQLException.class);
        update("paid_at = NOW(), paid_by = 3, payout_note = '" + "x".repeat(500) + "'");
        assertThatThrownBy(() -> update("payout_note = '" + "x".repeat(501) + "'"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> update("paid_by = 99")).isInstanceOf(SQLException.class);
        update("paid_at = NULL, paid_by = NULL, payout_note = NULL");
    }

    @Test
    @DisplayName("the payout stands when the account that marked it is closed")
    void payerClosed() throws Exception {
        update("paid_at = NOW(), paid_by = 3, payout_note = 'Transfer 4411'");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM users WHERE id = 3");
        }
        assertThat(count("SELECT COUNT(*) FROM commission_splits WHERE paid_at IS NOT NULL "
                + "AND paid_by IS NULL AND payout_note = 'Transfer 4411'")).isEqualTo(1);
    }

    private void run(String path) throws Exception {
        String script = new ClassPathResource(path).getContentAsString(StandardCharsets.UTF_8);
        try (Statement s = db.createStatement()) {
            for (String statement : script.replaceAll("(?m)^--.*$", "").split(";")) {
                if (!statement.isBlank()) {
                    s.execute(statement);
                }
            }
        }
    }

    private void update(String set) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("UPDATE commission_splits SET " + set + " WHERE id = 1");
        }
    }

    private long count(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet rs = s.executeQuery(sql)) {
            rs.next();
            return rs.getLong(1);
        }
    }
}
