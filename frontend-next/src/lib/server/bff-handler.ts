import "server-only";

import type { NextRequest } from "next/server";
import { backendStream } from "./backend.ts";
import { matchPrivateOperation, operationApiPath, type PrivateOperation } from "./allowlist.ts";
import { bffError, bffFailure, isCredentialField, privateJson, safeAttachment } from "./bff-response.ts";
import { checkWriteRequest } from "./csrf.ts";
import { getServerRuntimeConfig } from "./env.ts";
import { readAccessBearer } from "./session.ts";

const uploadLimit = 25 * 1024 * 1024;
const resourceLimit = 20 * 1024 * 1024;
const jsonLimit = 1024 * 1024;
const exportRowLimit = 50_000;
const privateHeaders = {
  "cache-control": "private, no-store",
  "x-content-type-options": "nosniff",
};

type LimitedBody = { stream: ReadableStream<Uint8Array>; exceeded: () => boolean };

function limitedBody(body: ReadableStream<Uint8Array>, limit: number): LimitedBody {
  const reader = body.getReader();
  let bytes = 0;
  let tooLarge = false;
  const stream = new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const part = await reader.read();
        if (part.done) {
          controller.close();
          return;
        }
        bytes += part.value.byteLength;
        if (bytes > limit) {
          tooLarge = true;
          await reader.cancel();
          controller.error(new Error("Request body size limit exceeded"));
          return;
        }
        controller.enqueue(part.value);
      } catch (error) {
        controller.error(error);
      }
    },
    async cancel(reason) {
      await reader.cancel(reason);
    },
  });
  return { stream, exceeded: () => tooLarge };
}

async function readBoundedBody(body: ReadableStream<Uint8Array> | null, limit: number): Promise<Uint8Array | null> {
  if (!body) return null;
  const reader = body.getReader();
  const parts: Uint8Array[] = [];
  let bytes = 0;
  try {
    while (true) {
      const part = await reader.read();
      if (part.done) break;
      bytes += part.value.byteLength;
      if (bytes > limit) {
        try {
          await reader.cancel();
        } catch {
          // The size limit is already decisive; leave no more bytes to read.
        }
        return null;
      }
      parts.push(part.value);
    }
  } finally {
    reader.releaseLock();
  }
  const result = new Uint8Array(bytes);
  let offset = 0;
  for (const part of parts) {
    result.set(part, offset);
    offset += part.byteLength;
  }
  return result;
}

function streamWithLimit(body: ReadableStream<Uint8Array>, limit: number): ReadableStream<Uint8Array> {
  const reader = body.getReader();
  let bytes = 0;
  return new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const part = await reader.read();
        if (part.done) {
          controller.close();
          return;
        }
        bytes += part.value.byteLength;
        if (bytes > limit) {
          await reader.cancel();
          controller.error(new Error("Private response size limit exceeded"));
          return;
        }
        controller.enqueue(part.value);
      } catch (error) {
        controller.error(error);
      }
    },
    async cancel(reason) {
      await reader.cancel(reason);
    },
  });
}

function contentLength(request: Request, limit: number): "ok" | "too-large" | "invalid" {
  const raw = request.headers.get("content-length");
  if (raw === null) return "ok";
  if (!/^\d+$/.test(raw)) return "invalid";
  const value = Number(raw);
  if (!Number.isSafeInteger(value)) return "invalid";
  return value > limit ? "too-large" : "ok";
}

function pathSegments(request: NextRequest, parts: string[]): string[] | null {
  const rawPath = new URL(request.url).pathname;
  if (/%2f|%5c|\\|\/\.{1,2}(?:\/|$)|\/\/(?:[^/]|$)/i.test(rawPath)) return null;
  if (!parts.length || parts.some((part) => !/^[A-Za-z0-9_-]+$/.test(part))) return null;
  return parts;
}

function errorFromBackend(error: Parameters<typeof bffError>[0]): Response {
  return bffError(error);
}

function uploadError(code: string, status: number): Response {
  return bffFailure(status === 413 ? "validation" : "http", status, code);
}

function headerContentType(response: Response): string | null {
  const value = response.headers.get("content-type");
  if (!value || value.length > 200 || /[\u0000-\u001f\u007f]/.test(value)) return null;
  return value;
}

async function cancelBody(response: Response): Promise<void> {
  try {
    await response.body?.cancel();
  } catch {
    // The response is already being rejected and cannot be reused.
  }
}

async function cancelRequestBody(request: Request): Promise<void> {
  try {
    await request.body?.cancel();
  } catch {
    // Rejection is still returned without consuming an untrusted request body.
  }
}

async function rejectEarly(request: NextRequest, response: Response): Promise<Response> {
  await cancelRequestBody(request);
  return response;
}

async function privateJsonResponse(response: Response, signal: AbortSignal): Promise<Response> {
  if (response.status === 204 || response.status === 205) {
    await cancelBody(response);
    return new Response(null, { status: response.status, headers: privateHeaders });
  }
  const type = headerContentType(response);
  if (!type || !/^application\/(?:[a-z0-9.+-]+\+)?json(?:\s*;|$)/i.test(type)) {
    await cancelBody(response);
    return bffFailure("malformed", 502, "UPSTREAM_JSON_REQUIRED", "unknown");
  }
  const declared = Number(response.headers.get("content-length"));
  if (Number.isFinite(declared) && declared > jsonLimit) {
    await cancelBody(response);
    return bffFailure("malformed", 502, "UPSTREAM_JSON_TOO_LARGE");
  }
  let bytes: Uint8Array | null;
  try {
    bytes = await readBoundedBody(response.body, jsonLimit);
  } catch (error) {
    const reasonName = signal.aborted && signal.reason instanceof Error ? signal.reason.name : undefined;
    const errorName = error instanceof Error ? error.name : undefined;
    if (reasonName === "TimeoutError" || errorName === "TimeoutError") return bffFailure("timeout", 504, "UPSTREAM_READ_TIMEOUT", "unreadable");
    if (signal.aborted || reasonName === "AbortError" || errorName === "AbortError") return bffFailure("cancelled", 503, "UPSTREAM_READ_CANCELLED", "unreadable");
    return bffFailure("network", 503, "UPSTREAM_READ_FAILED", "unreadable");
  }
  if (bytes === null) return bffFailure("malformed", 502, "UPSTREAM_JSON_TOO_LARGE");
  let data: unknown;
  try {
    data = JSON.parse(new TextDecoder().decode(bytes));
  } catch {
    return bffFailure("malformed", 502, "UPSTREAM_JSON_INVALID", "malformed-json");
  }
  if (isCredentialField(data)) return bffFailure("malformed", 502, "UPSTREAM_CREDENTIAL_FIELD");
  return privateJson(data, response.status);
}

function contentLengthFromResponse(response: Response): number | null {
  const value = response.headers.get("content-length");
  if (value === null || !/^\d+$/.test(value)) return null;
  const number = Number(value);
  return Number.isSafeInteger(number) ? number : null;
}

async function streamPrivateResource(operation: PrivateOperation, response: Response): Promise<Response> {
  const type = headerContentType(response);
  const length = contentLengthFromResponse(response);
  if (!response.body || !type || operation.kind !== "export" && length !== null && length > resourceLimit) {
    await cancelBody(response);
    return bffFailure("malformed", 502, "UPSTREAM_RESOURCE_INVALID");
  }
  if (operation.kind === "image") {
    const imageType = type.split(";", 1)[0]?.trim().toLowerCase();
    if (!imageType || !/^image\/(?:jpeg|png|webp|gif|bmp)$/.test(imageType)) {
      await cancelBody(response);
      return bffFailure("malformed", 502, "UPSTREAM_IMAGE_TYPE_REJECTED");
    }
    return new Response(streamWithLimit(response.body, resourceLimit), {
      status: response.status,
      headers: { ...privateHeaders, "content-type": imageType },
    });
  }
  const disposition = response.headers.get("content-disposition");
  if (operation.kind === "export") {
    const rows = response.headers.get("x-export-rows");
    const rowCount = rows === null || !/^\d{1,5}$/.test(rows) ? -1 : Number(rows);
    if (!/^attachment(?:\s*;|$)/i.test(disposition ?? "") || rowCount < 0 || rowCount > exportRowLimit || !type.toLowerCase().startsWith("text/csv")) {
      await cancelBody(response);
      return bffFailure("malformed", 502, "UPSTREAM_EXPORT_HEADERS_INVALID");
    }
    return new Response(response.body, {
      status: response.status,
      headers: {
        ...privateHeaders,
        "content-type": "text/csv; charset=utf-8",
        "content-disposition": safeAttachment(disposition, "export.csv"),
        "x-export-rows": String(rowCount),
      },
    });
  }
  const mediaType = type.split(";", 1)[0]?.trim().toLowerCase() ?? "";
  const safeType = /^[a-z0-9!#$&^_.+-]+\/[a-z0-9!#$&^_.+-]+$/.test(mediaType) &&
    !/^(?:text\/html|application\/(?:xhtml\+xml|javascript|xml)|image\/svg\+xml)$/.test(mediaType)
    ? mediaType
    : "application/octet-stream";
  return new Response(streamWithLimit(response.body, resourceLimit), {
    status: response.status,
    headers: {
      ...privateHeaders,
      "content-type": safeType,
      "content-disposition": safeAttachment(disposition, "download"),
    },
  });
}

async function forward(
  request: NextRequest,
  operation: PrivateOperation,
  apiPath: string,
  bearerToken: string,
): Promise<Response> {
  const headers = new Headers();
  for (const name of ["accept", "content-type", "accept-language"]) {
    const value = request.headers.get(name);
    if (value !== null) headers.set(name, value);
  }
  let body: ReadableStream<Uint8Array> | string | undefined;
  let bodyLimit: LimitedBody | null = null;
  if (operation.kind === "json" && operation.method !== "GET") {
    const lengthState = contentLength(request, jsonLimit);
    if (lengthState === "too-large") return rejectEarly(request, uploadError("REQUEST_BODY_TOO_LARGE", 413));
    if (lengthState === "invalid") return rejectEarly(request, uploadError("REQUEST_CONTENT_LENGTH_INVALID", 400));
    if (!request.body) return uploadError("REQUEST_BODY_REQUIRED", 400);
    const bytes = await readBoundedBody(request.body, jsonLimit);
    if (bytes === null) return uploadError("REQUEST_BODY_TOO_LARGE", 413);
    if (bytes.byteLength === 0) return uploadError("REQUEST_BODY_REQUIRED", 400);
    const text = new TextDecoder().decode(bytes);
    let parsed: unknown;
    try {
      parsed = JSON.parse(text);
    } catch {
      return uploadError("REQUEST_JSON_INVALID", 400);
    }
    if (isCredentialField(parsed)) return uploadError("CREDENTIAL_FIELD_REJECTED", 400);
    body = text;
  } else if (operation.kind === "upload") {
    const lengthState = contentLength(request, uploadLimit);
    if (lengthState === "too-large") {
      return rejectEarly(request, uploadError("UPLOAD_TOO_LARGE", 413));
    }
    if (lengthState === "invalid") return rejectEarly(request, uploadError("UPLOAD_CONTENT_LENGTH_INVALID", 400));
    if (!request.body) return uploadError("UPLOAD_BODY_REQUIRED", 400);
    bodyLimit = limitedBody(request.body, uploadLimit);
    body = bodyLimit.stream;
  }
  const upstream = await backendStream(apiPath, {
    method: operation.method,
    headers,
    bearerToken,
    ...(body === undefined ? {} : { body }),
    ...(operation.kind === "upload" ? { duplex: "half" as const } : {}),
    signal: request.signal,
  });
  if (!upstream.ok) {
    if (bodyLimit?.exceeded()) return uploadError("UPLOAD_TOO_LARGE", 413);
    return errorFromBackend(upstream.error);
  }
  if (operation.kind === "json" || operation.kind === "upload") return privateJsonResponse(upstream.data, request.signal);
  return streamPrivateResource(operation, upstream.data);
}

export async function handlePrivateBff(request: NextRequest, rawParts: string[]): Promise<Response> {
  let runtimeConfig;
  try {
    runtimeConfig = getServerRuntimeConfig();
  } catch {
    return rejectEarly(request, bffFailure("unavailable", 503, "BFF_CONFIGURATION_UNAVAILABLE"));
  }
  let bearerToken: string | null;
  try {
    bearerToken = readAccessBearer(request, runtimeConfig.webOrigin);
  } catch {
    return rejectEarly(request, bffFailure("unavailable", 503, "BFF_CONFIGURATION_UNAVAILABLE"));
  }
  if (!bearerToken) return rejectEarly(request, bffFailure("unauthenticated", 401, "ACCESS_COOKIE_REQUIRED"));

  const parts = pathSegments(request, rawParts);
  if (!parts) return rejectEarly(request, bffFailure("not-found", 404, "BFF_ROUTE_NOT_FOUND"));
  const url = new URL(request.url);
  const operation = matchPrivateOperation(parts, url, request.method);
  if (!operation) return rejectEarly(request, bffFailure("not-found", 404, "BFF_ROUTE_NOT_FOUND"));
  if (operation.method !== request.method) return rejectEarly(request, bffFailure("http", 405, "BFF_METHOD_NOT_ALLOWED"));
  const csrfError = checkWriteRequest(request, operation);
  if (csrfError) return rejectEarly(request, bffFailure(csrfError.kind, csrfError.status, csrfError.code));
  try {
    return await forward(request, operation, operationApiPath(operation, url), bearerToken);
  } catch {
    return bffFailure("network", 503, "BACKEND_UNAVAILABLE");
  }
}
