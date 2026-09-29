package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ChecklistStage;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Something this one deal needs that the agency's template does not list. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DealChecklistItemRequest {

    @NotNull(message = "Stage is required")
    private ChecklistStage stage;

    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title takes at most 200 characters")
    private String title;

    private boolean required;
}
