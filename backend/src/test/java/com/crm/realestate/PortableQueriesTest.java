package com.crm.realestate;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The tests run on H2 and production runs on PostgreSQL. {@code CriteriaBuilder.function("year", …)}
 * writes its name into the SQL as it is: H2 has YEAR(), MONTH() and DAY(), PostgreSQL has none of
 * them, so such a query passes every test here and fails on every real request. Hibernate's own
 * {@code HibernateCriteriaBuilder.year/month/day} render the right SQL for each database.
 */
class PortableQueriesTest {

    private static final Pattern NAMED_FUNCTION = Pattern.compile("\\.function\\(\\s*\"");

    @Test
    @DisplayName("no criteria query calls a database function by name")
    void noNamedFunctions() throws IOException {
        List<String> offenders = new ArrayList<>();
        try (Stream<Path> files = Files.walk(Path.of("src/main/java"))) {
            for (Path file : files.filter(f -> f.toString().endsWith(".java")).toList()) {
                List<String> lines = Files.readAllLines(file);
                for (int i = 0; i < lines.size(); i++) {
                    if (NAMED_FUNCTION.matcher(lines.get(i)).find()) {
                        offenders.add(file + ":" + (i + 1) + ": " + lines.get(i).trim());
                    }
                }
            }
        }
        assertThat(offenders)
                .as("use HibernateCriteriaBuilder's portable functions instead")
                .isEmpty();
    }
}
