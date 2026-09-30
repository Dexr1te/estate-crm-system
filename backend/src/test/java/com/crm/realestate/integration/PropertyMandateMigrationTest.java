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
 * V38 as written, run against a properties table shaped like the one it meets in production.
 *
 * <p>The rest of the suite builds its schema from the entities, so without this nothing would
 * notice a migration that does not apply, or checks that let through what the API refuses.
 */
class PropertyMandateMigrationTest {

    private Connection db;

    @BeforeEach
    void setUp() throws Exception {
        db = DriverManager.getConnection(
                "jdbc:h2:mem:v38-" + UUID.randomUUID() + ";MODE=PostgreSQL", "sa", "");
        try (Statement s = db.createStatement()) {
            s.execute("CREATE TABLE teams (id BIGSERIAL PRIMARY KEY, name VARCHAR(255))");
            s.execute("""
                    CREATE TABLE properties (
                        id BIGSERIAL PRIMARY KEY,
                        title VARCHAR(255) NOT NULL,
                        status VARCHAR(20) NOT NULL,
                        team_id BIGINT REFERENCES teams(id))
                    """);
            // A listing from before the migration.
            s.execute("INSERT INTO properties (title, status) VALUES ('Older listing', 'AVAILABLE')");
        }
        String script = new ClassPathResource("db/migration/V38__property_mandate.sql")
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
    @DisplayName("V38 applies, and a listing from before it has no agreement")
    void appliesToExistingRows() throws Exception {
        try (Statement s = db.createStatement();
             ResultSet rs = s.executeQuery("SELECT mandate_type, mandate_end_date FROM properties")) {
            assertThat(rs.next()).isTrue();
            assertThat(rs.getString(1)).isNull();
            assertThat(rs.getDate(2)).isNull();
        }
    }

    @Test
    @DisplayName("the database keeps the same rules as the API: a known type, and no date alone")
    void checks() throws Exception {
        insert("'EXCLUSIVE'", "DATE '2026-10-12'");
        insert("'EXCLUSIVE'", "NULL");
        insert("'OPEN'", "DATE '2026-10-12'");
        insert("NULL", "NULL");

        assertThatThrownBy(() -> insert("NULL", "DATE '2026-10-12'")).isInstanceOf(SQLException.class);
        assertThatThrownBy(() -> insert("'SOLE'", "NULL")).isInstanceOf(SQLException.class);
    }

    private void insert(String type, String endDate) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.execute("INSERT INTO properties (title, status, mandate_type, mandate_end_date) "
                    + "VALUES ('Listing', 'AVAILABLE', " + type + ", " + endDate + ")");
        }
    }
}
