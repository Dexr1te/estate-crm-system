package com.crm.realestate.dto.response;

import com.crm.realestate.enums.MandateType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class PropertyResponse {
    private Long id;
    private String title;
    private String description;
    private String address;
    private String city;
    private PropertyType type;
    private PropertyStatus status;
    private BigDecimal price;
    private Double areaSqm;
    private Integer rooms;
    private Integer floor;
    private Integer totalFloors;
    /** Degrees (WGS 84); both null when the listing has not been put on the map. */
    private Double latitude;
    private Double longitude;
    private Long agentId;
    private String agentName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    /** What it cost before the latest change of price, or null if it was never changed. */
    private BigDecimal previousPrice;
    private LocalDateTime priceChangedAt;
    /** The seller's agreement; null when none is recorded. */
    private MandateType mandateType;
    /** Its last day, as a date ("2026-10-12"); null when it has no end date. */
    private LocalDate mandateEndDate;
    /**
     * The last day the listing is held for a buyer who put down a deposit; null when no deal on it
     * has an active deposit. While set, the listing is reserved and is not offered as a match.
     */
    private LocalDate depositHoldUntil;
}