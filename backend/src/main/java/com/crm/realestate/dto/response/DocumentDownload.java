package com.crm.realestate.dto.response;

import org.springframework.core.io.Resource;

/** A stored file on its way back out, with the name and type it should arrive as. */
public record DocumentDownload(Resource resource, String fileName, String contentType) {
}
