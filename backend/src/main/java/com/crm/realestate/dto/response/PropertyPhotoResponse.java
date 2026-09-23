package com.crm.realestate.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

/** A photograph as the app lists it. The bytes come from its own endpoint. */
@Data
public class PropertyPhotoResponse {
    private Long id;
    private Long propertyId;
    private String fileName;
    private String contentType;
    private Long fileSize;
    private int sortOrder;
    private boolean hasThumbnail;
    private Long uploadedById;
    private LocalDateTime uploadedAt;
}
