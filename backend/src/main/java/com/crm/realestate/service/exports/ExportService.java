package com.crm.realestate.service.exports;

import com.crm.realestate.entity.User;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.AuditLogService;
import com.crm.realestate.service.ScopeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;

/**
 * An agency's book taken out as a spreadsheet.
 *
 * <p><b>Who.</b> A manager or an admin. An agent cannot export at all: a whole client list with
 * phone numbers in one file is exactly what walks out of the door with someone who is leaving,
 * and the book belongs to the agency, not the person holding it. A manager exports for them when
 * there is a reason to.
 *
 * <p><b>What.</b> Exactly what the caller could see in the list, under the same filters: their own
 * records on an OWN data scope, the agency's on TEAM — and always inside the caller's own agency,
 * even for an admin, whose platform-wide view is for running the platform, not for downloading
 * other agencies' clients.
 *
 * <p><b>How much.</b> At most {@value #MAX_ROWS} rows; more is refused before anything is written,
 * with a request to narrow the filters. Rows are read {@value ExportSheets#PAGE} at a time.
 *
 * <p><b>Journal.</b> Every export is written to the audit log — kind, filters, row count — before
 * the first byte leaves: client personal data that left the system must be traceable.
 */
@Service
@RequiredArgsConstructor
public class ExportService {

    public static final int MAX_ROWS = 50_000;

    private final ExportSheets sheets;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final AuditLogService auditLogService;

    /** {@link #MAX_ROWS}; a field so a test can lower it rather than seed fifty thousand rows. */
    private int maxRows = MAX_ROWS;

    /** An export that has been allowed, counted and journalled, ready to be written. */
    public record Plan(ExportKind kind, ExportSheets.Query query, int language, char delimiter,
                       long rows, String filename) {
    }

    @Transactional
    public Plan prepare(ExportKind kind, ExportFilters filters, String lang, String delimiter) {
        User user = requireExporter();
        int language = ExportLabels.language(lang);
        char separator = delimiter(delimiter, language);
        ExportSheets.Query query = new ExportSheets.Query(kind, user, filters);
        long rows = sheets.count(query);
        if (rows > maxRows) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "EXPORT_TOO_MANY_ROWS",
                    "An export takes at most " + maxRows + " rows and this one has " + rows
                            + ". Narrow the filters and export in parts.");
        }
        String described = filters.describe();
        auditLogService.record(user, "EXPORT_" + kind.name(), "Team", user.getTeam().getId(),
                "rows=" + rows + " lang=" + new String[]{"en", "ru", "kk"}[language]
                        + (described.isEmpty() ? "" : " " + described));
        return new Plan(kind, query, language, separator, rows,
                kind.path() + "-" + LocalDate.now() + ".csv");
    }

    @Transactional(readOnly = true)
    public void write(Plan plan, OutputStream out) throws IOException {
        sheets.write(plan.query(), new CsvWriter(out, plan.delimiter()), plan.language());
    }

    private User requireExporter() {
        User user = securityUtils.getCurrentUser();
        if (!scopeService.isManager(user) && !scopeService.isAdmin(user)) {
            throw new AccessDeniedException("Only a manager or an admin can export");
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "An export is of your agency's records, and you are not in one");
        }
        return user;
    }

    /** The rule of the import template: commas in English, semicolons in Russian and Kazakh. */
    private static char delimiter(String requested, int language) {
        if (requested == null || requested.isBlank()) {
            return language == 0 ? ',' : ';';
        }
        return switch (requested) {
            case "comma" -> ',';
            case "semicolon" -> ';';
            default -> throw new BusinessException(HttpStatus.BAD_REQUEST, "EXPORT_BAD_DELIMITER",
                    "The delimiter is comma or semicolon");
        };
    }
}
