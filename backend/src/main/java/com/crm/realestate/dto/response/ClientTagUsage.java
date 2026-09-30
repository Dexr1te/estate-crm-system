package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** A tag of the caller's agency and how many of its clients carry it — for suggestions. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClientTagUsage {
    private String name;
    private long count;
}
