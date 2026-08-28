package com.crm.realestate.controller;

import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.dto.response.DocumentResponse;
import com.crm.realestate.service.DocumentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/deals/{dealId}/documents")
@RequiredArgsConstructor
@Tag(name = "Documents", description = "Paperwork attached to a deal: contracts, plans, scans")
@SecurityRequirement(name = "bearerAuth")
public class DocumentController {

    private final DocumentService documentService;

    @GetMapping
    @Operation(summary = "List the documents attached to a deal")
    public ResponseEntity<List<DocumentResponse>> getByDeal(@PathVariable Long dealId) {
        return ResponseEntity.ok(documentService.getByDeal(dealId));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Attach a file to a deal")
    public ResponseEntity<DocumentResponse> upload(@PathVariable Long dealId,
                                                    @RequestPart("file") MultipartFile file) {
        return ResponseEntity.status(HttpStatus.CREATED).body(documentService.upload(dealId, file));
    }

    @GetMapping("/{documentId}/content")
    @Operation(summary = "Download a document")
    public ResponseEntity<Resource> download(@PathVariable Long dealId,
                                              @PathVariable Long documentId) {
        DocumentDownload download = documentService.download(dealId, documentId);

        // filename* rather than filename: names arrive in Russian and Kazakh,
        // and a plain filename parameter is latin-1 on the wire.
        ContentDisposition disposition = ContentDisposition.attachment()
                .filename(download.fileName(), StandardCharsets.UTF_8)
                .build();

        // Content-Length is left to the resource itself: the size in the database
        // is what was uploaded, and if the two ever disagreed the recorded one
        // would truncate or hang the response.
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .contentType(MediaType.parseMediaType(download.contentType()))
                .body(download.resource());
    }

    @DeleteMapping("/{documentId}")
    @Operation(summary = "Remove a document from a deal")
    public ResponseEntity<Void> delete(@PathVariable Long dealId, @PathVariable Long documentId) {
        documentService.delete(dealId, documentId);
        return ResponseEntity.noContent().build();
    }
}
