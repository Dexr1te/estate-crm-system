package com.crm.realestate.controller;

import com.crm.realestate.service.exports.ExportFilters;
import com.crm.realestate.service.exports.ExportKind;
import com.crm.realestate.service.exports.ExportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.List;

/**
 * Clients, listings and deals as a CSV spreadsheet, under the list's own filters. Managers and
 * admins only; the rules are in {@link ExportService}.
 *
 * <p>The file is written straight to the response as rows are read, never built in memory. Rights,
 * the row cap and the audit entry are all settled before the first byte, so a refusal is still an
 * ordinary JSON error.
 */
@RestController
@RequestMapping("/export")
@RequiredArgsConstructor
@Tag(name = "Export", description = "Clients, listings and deals as a spreadsheet")
@SecurityRequirement(name = "bearerAuth")
public class ExportController {

    private final ExportService exportService;

    @GetMapping("/{kind}")
    @Operation(summary = "Download clients, properties or deals as CSV (UTF-8 with BOM, CRLF)")
    public void export(@PathVariable String kind,
                       @RequestParam(defaultValue = "en") String lang,
                       @RequestParam(required = false) String delimiter,
                       @RequestParam(required = false) String type,
                       @RequestParam(required = false) String status,
                       @RequestParam(required = false) String source,
                       @RequestParam(required = false) String city,
                       @RequestParam(required = false) Long agentId,
                       @RequestParam(required = false) String search,
                       @RequestParam(required = false) BigDecimal minPrice,
                       @RequestParam(required = false) BigDecimal maxPrice,
                       @RequestParam(required = false) Integer rooms,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdFrom,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdTo,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate closedFrom,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate closedTo,
                       @RequestParam(required = false) List<String> tags,
                       HttpServletResponse response) throws IOException {
        ExportFilters filters = new ExportFilters(type, status, source, city, agentId, search,
                minPrice, maxPrice, rooms, createdFrom, createdTo, closedFrom, closedTo, tags);
        ExportService.Plan plan = exportService.prepare(ExportKind.fromPath(kind), filters, lang, delimiter);

        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition(plan.filename()));
        response.setHeader("X-Export-Rows", String.valueOf(plan.rows()));
        response.setHeader(HttpHeaders.ACCESS_CONTROL_EXPOSE_HEADERS,
                HttpHeaders.CONTENT_DISPOSITION + ", X-Export-Rows");
        exportService.write(plan, response.getOutputStream());
        response.flushBuffer();
    }

    /** A plain name for old clients and the RFC 5987 one for everything that reads it. */
    static String contentDisposition(String filename) {
        String encoded = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");
        return "attachment; filename=\"" + filename + "\"; filename*=UTF-8''" + encoded;
    }
}
