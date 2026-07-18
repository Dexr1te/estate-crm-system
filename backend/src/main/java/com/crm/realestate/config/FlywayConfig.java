package com.crm.realestate.config;

import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Runs {@code flyway.repair()} before {@code flyway.migrate()} on startup.
 *
 * <p>Repair realigns the checksums stored in {@code flyway_schema_history} with the
 * migration files currently on the classpath and clears any failed-migration entries.
 * This lets the app recover automatically from a checksum mismatch — e.g. when an
 * already-applied migration file was edited — instead of failing the whole context
 * with "Migrations have failed validation".
 *
 * <p>Repair only touches Flyway's own bookkeeping table; it never alters application
 * data. It does NOT re-run migrations that were already applied.
 */
@Configuration
public class FlywayConfig {

    @Bean
    public FlywayMigrationStrategy repairThenMigrate() {
        return flyway -> {
            flyway.repair();
            flyway.migrate();
        };
    }
}
