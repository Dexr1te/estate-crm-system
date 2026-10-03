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
 * V50 as written, run against a deals table shaped like the one it meets in production, with a
 * deal already in it.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class DealLeaseMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v50-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("CREATE TABLE clients (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(255))");
            s.execute("CREATE TABLE deals (id BIGSERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL, "
                    + "deal_price NUMERIC(15, 2), team_id BIGINT)");
            s.execute("INSERT INTO clients (full_name) VALUES ('Landlord')");
            s.execute("INSERT INTO deals (title, deal_price) VALUES ('An old sale', 1000)");
        }
        String script = new ClassPathResource("db/migration/V50__deal_leases.sql")
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
    @DisplayName("a deal from before is a sale")
    void existingDealsAreSales() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT kind FROM deals")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getString(1)).isEqualTo("SALE");
        }
    }

    @Test
    @DisplayName("the database keeps the API's rules: a rent has its rent and days and no price; a sale has no lease")
    void checks() throws Exception {
        insert("'RENT'", "NULL", "100", "'2026-01-01'", "'2026-12-31'", "30", "1");
        insert("'RENT'", "NULL", "100", "'2026-01-01'", "'2026-01-02'", "NULL", "NULL");
        insert("'SALE'", "500", "NULL", "NULL", "NULL", "NULL", "NULL");

        assertThatThrownBy(() -> insert("'LEASE'", "NULL", "100", "'2026-01-01'", "'2026-12-31'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'RENT'", "NULL", "0", "'2026-01-01'", "'2026-12-31'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'RENT'", "NULL", "100", "'2026-01-01'", "'2026-01-01'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'RENT'", "NULL", "100", "NULL", "'2026-01-01'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'RENT'", "500", "100", "'2026-01-01'", "'2026-12-31'", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'RENT'", "NULL", "100", "'2026-01-01'", "'2026-12-31'", "0", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'SALE'", "500", "100", "NULL", "NULL", "NULL", "NULL"))
                .isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'SALE'", "500", "NULL", "NULL", "NULL", "NULL", "1"))
                .isInstanceOf(SQLException.class);
    }

    @Test
    @DisplayName("deleting the landlord's card leaves the lease without one")
    void landlordSetNull() throws Exception {
        insert("'RENT'", "NULL", "100", "'2026-01-01'", "'2026-12-31'", "NULL", "1");
        try (Statement s = db.createStatement()) {
            s.execute("DELETE FROM clients WHERE id = 1");
            try (ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM deals WHERE kind = 'RENT' AND landlord_id IS NULL")) {
                rs.next();
                assertThat(rs.getInt(1)).isEqualTo(1);
            }
        }
    }

    private void insert(String kind, String price, String rent, String start, String end, String reminder,
                        String landlord) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO deals (title, kind, deal_price, monthly_rent, lease_start, lease_end, "
                    + "lease_reminder_days, landlord_id) VALUES ('d', " + kind + ", " + price + ", " + rent + ", "
                    + date(start) + ", " + date(end) + ", " + reminder + ", " + landlord + ")");
        }
    }

    private static String date(String value) {
        return value.equals("NULL") ? "NULL" : "DATE " + value;
    }
}
