package com.crm.realestate.dto.request;

import com.crm.realestate.enums.OpenHouseInterest;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/** One visitor at the door: a name and a number, and, if the agent asked, how keen they are. */
@Data
public class OpenHouseVisitorRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 120, message = "Name must be at most 120 characters")
    private String fullName;

    @NotBlank(message = "Phone is required")
    @Size(max = 40, message = "Phone must be at most 40 characters")
    private String phone;

    /** Null when nobody asked. */
    private OpenHouseInterest interest;

    @Size(max = 1000, message = "Note must be at most 1000 characters")
    private String note;
}
