package com.crm.realestate.integration;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * V46 as written, run against tables shaped like the ones it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class DealDepositMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v46-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("CREATE TABLE users (id BIGSERIAL PRIMARY KEY, email VARCHAR(255))");
            s.execute("CREATE TABLE deals (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL)");
            s.execute("INSERT INTO deals (title) VALUES ('A deal')");
        }
        String script = new ClassPathResource("db/migration/V46__deal_deposits.sql")
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
    @DisplayName("the database keeps the API's rules: amount, dates, holder, and how a deposit ends")
    void checks() throws Exception {
        insert("100", "'2026-10-01'", "'2026-10-20'", "'AGENCY'", "NULL", "NULL");
        insert("100", "'2026-10-01'", "'2026-10-01'", "'NOTARY'", "'REFUNDED'", "'2026-10-05'");

        assertThatThrownBy(() -> insert("0", "'2026-10-01'", "'2026-10-20'", "'AGENCY'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("100", "'2026-10-10'", "'2026-10-09'", "'AGENCY'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("100", "'2026-10-01'", "'2026-10-20'", "'BANK'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("100", "'2026-10-01'", "'2026-10-20'", "'SELLER'", "'SPENT'", "'2026-10-05'"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("100", "'2026-10-01'", "'2026-10-20'", "'SELLER'", "'APPLIED'", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("100", "'2026-10-01'", "'2026-10-20'", "'SELLER'", "NULL", "'2026-10-05'"))
                .isInstanceOf(SQLException.class);
    }

    private void insert(String amount, String received, String until, String holder, String outcome,
                        String closedOn) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO deal_deposits (deal_id, amount, received_on, hold_until, holder, outcome, closed_on) "
                    + "VALUES (1, " + amount + ", DATE " + received + ", DATE " + until + ", " + holder + ", "
                    + outcome + ", " + (closedOn.equals("NULL") ? "NULL" : "DATE " + closedOn) + ")");
        }
    }
}
