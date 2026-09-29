package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ChecklistStage;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * An agency's whole deal checklist, as the manager wants it from now on. Replaces what is there;
 * the order of {@link #items} within a stage is the order on every new deal.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChecklistTemplateRequest {

    public static final int MAX_ITEMS = 60;

    @NotNull(message = "Items are required")
    @Size(max = MAX_ITEMS, message = "A checklist takes at most 60 items")
    @Valid
    private List<Item> items;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Item {

        @NotNull(message = "Stage is required")
        private ChecklistStage stage;

        @NotBlank(message = "Title is required")
        @Size(max = 200, message = "Title takes at most 200 characters")
        private String title;

        private boolean required;
    }
}
