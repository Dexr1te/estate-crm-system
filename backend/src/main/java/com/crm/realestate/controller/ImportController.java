package com.crm.realestate.controller;

import com.crm.realestate.dto.response.ImportPreviewResponse;
import com.crm.realestate.dto.response.ImportResultResponse;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.service.imports.ImportKind;
import com.crm.realestate.service.imports.ImportService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Clients and listings brought in from a spreadsheet saved as CSV. Managers and admins only; the
 * rule is enforced in {@link ImportService}.
 *
 * <p>{@code mapping} is a JSON array with one entry per column of the file: the field key that
 * column fills, or null. Left out on a preview, the suggested mapping is used.
 */
@RestController
@RequestMapping("/import/{kind}")
@RequiredArgsConstructor
@Tag(name = "Import", description = "Clients and listings from a spreadsheet")
@SecurityRequirement(name = "bearerAuth")
public class ImportController {

    private final ImportService importService;
    private final ObjectMapper objectMapper;

    @PostMapping(value = "/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Read a CSV and report what would be imported, without writing anything")
    public ResponseEntity<ImportPreviewResponse> preview(@PathVariable String kind,
                                                         @RequestPart("file") MultipartFile file,
                                                         @RequestParam(required = false) String mapping) {
        return ResponseEntity.ok(importService.preview(ImportKind.fromPath(kind), file, parse(mapping)));
    }

    @PostMapping(value = "/commit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Import the valid rows of a CSV in one transaction")
    public ResponseEntity<ImportResultResponse> commit(@PathVariable String kind,
                                                       @RequestPart("file") MultipartFile file,
                                                       @RequestParam(required = false) String mapping,
                                                       @RequestParam(defaultValue = "true") boolean skipDuplicates,
                                                       @RequestParam(required = false) Long assignToAgentId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(importService.commit(
                ImportKind.fromPath(kind), file, parse(mapping), skipDuplicates, assignToAgentId));
    }

    @GetMapping("/template")
    @Operation(summary = "An empty CSV with the headings an import recognises")
    public ResponseEntity<byte[]> template(@PathVariable String kind,
                                           @RequestParam(defaultValue = "en") String lang) {
        ImportKind importKind = ImportKind.fromPath(kind);
        return ResponseEntity.ok()
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment()
                        .filename(importKind.path() + "-template.csv").build().toString())
                .body(importService.template(importKind, lang));
    }

    private List<String> parse(String mapping) {
        if (mapping == null || mapping.isBlank()) {
            return null;
        }
        try {
            return objectMapper.readValue(mapping, new TypeReference<List<String>>() { });
        } catch (JsonProcessingException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_BAD_MAPPING",
                    "The mapping is not a JSON array of field names");
        }
    }
}
