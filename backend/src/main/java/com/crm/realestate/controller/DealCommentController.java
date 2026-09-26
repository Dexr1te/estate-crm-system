package com.crm.realestate.controller;

import com.crm.realestate.dto.request.DealCommentRequest;
import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.dto.response.DealCommentPage;
import com.crm.realestate.dto.response.DealCommentResponse;
import com.crm.realestate.service.DealCommentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/deals/{dealId}/comments")
@RequiredArgsConstructor
@Tag(name = "Deal comments", description = "The discussion on a deal, with @mentions")
@SecurityRequirement(name = "bearerAuth")
public class DealCommentController {

    private final DealCommentService commentService;

    @GetMapping
    @Operation(summary = "The latest comments, oldest first",
            description = "Up to `limit` (default 50, at most 100) comments, older than `before` when given. "
                    + "`hasEarlier` says whether a further page exists above them.")
    public ResponseEntity<DealCommentPage> list(@PathVariable Long dealId,
                                                @RequestParam(required = false) Long before,
                                                @RequestParam(required = false) Integer limit) {
        return ResponseEntity.ok(commentService.list(dealId, before, limit));
    }

    @GetMapping("/mentionable")
    @Operation(summary = "Who can be @mentioned: active colleagues who can see the deal")
    public ResponseEntity<List<AgentOptionResponse>> mentionable(@PathVariable Long dealId) {
        return ResponseEntity.ok(commentService.mentionable(dealId));
    }

    @PostMapping
    @Operation(summary = "Add a comment",
            description = "Body ≤ 4000 characters. mentionedUserIds must each be able to see the deal (else 400).")
    public ResponseEntity<DealCommentResponse> create(@PathVariable Long dealId,
                                                      @Valid @RequestBody DealCommentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commentService.create(dealId, request));
    }

    @PutMapping("/{commentId}")
    @Operation(summary = "Correct a comment (author only)")
    public ResponseEntity<DealCommentResponse> update(@PathVariable Long dealId,
                                                      @PathVariable Long commentId,
                                                      @Valid @RequestBody DealCommentRequest request) {
        return ResponseEntity.ok(commentService.update(dealId, commentId, request));
    }

    @DeleteMapping("/{commentId}")
    @Operation(summary = "Delete a comment (author, manager or admin)")
    public ResponseEntity<Void> delete(@PathVariable Long dealId, @PathVariable Long commentId) {
        commentService.delete(dealId, commentId);
        return ResponseEntity.noContent().build();
    }
}
