import "server-only";

import type { NextRequest } from "next/server";
import type { PrivateOperation } from "./allowlist.ts";
import { getServerRuntimeConfig } from "./env.ts";

export type RequestRejection = { status: number; kind: "forbidden" | "validation" | "http"; code: string };

export function checkSameOriginWrite(request: NextRequest): RequestRejection | null {
  const { webOrigin } = getServerRuntimeConfig();
  if (request.headers.get("origin") !== webOrigin) return { status: 403, kind: "forbidden", code: "ORIGIN_REJECTED" };
  const fetchSite = request.headers.get("sec-fetch-site");
  if (fetchSite !== null && fetchSite.toLowerCase() !== "same-origin") {
    return { status: 403, kind: "forbidden", code: "FETCH_SITE_REJECTED" };
  }
  return null;
}

export function checkWriteRequest(request: NextRequest, operation: PrivateOperation): RequestRejection | null {
  if (operation.method === "GET") return null;
  const originRejection = checkSameOriginWrite(request);
  if (originRejection) return originRejection;
  const contentType = request.headers.get("content-type") ?? "";
  if (operation.id === "API164") {
    return /^application\/json(?:\s*;\s*charset\s*=\s*(?:utf-8|"utf-8"))?\s*$/i.test(contentType)
      ? null
      : { status: 415, kind: "validation", code: "CONTENT_TYPE_REJECTED" };
  }
  const boundary = /^multipart\/form-data\s*;\s*boundary=(?:"[A-Za-z0-9'()+_,./:=?-]{1,70}"|[A-Za-z0-9'()+_,./:=?-]{1,70})\s*$/i;
  return boundary.test(contentType)
    ? null
    : { status: 415, kind: "validation", code: "CONTENT_TYPE_REJECTED" };
}
