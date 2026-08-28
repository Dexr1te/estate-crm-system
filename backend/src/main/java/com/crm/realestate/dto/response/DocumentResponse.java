package com.crm.realestate.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DocumentResponse {
    private Long id;
    private String fileName;
    private String fileType;
    private Long fileSize;
    private Long dealId;
    private Long uploadedById;
    private String uploadedByName;
    private LocalDateTime uploadedAt;
}
