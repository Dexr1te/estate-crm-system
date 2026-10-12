import "server-only";

import { NextResponse, type NextRequest } from "next/server";
import { backendJson } from "./backend.ts";
import { bffError, bffFailure } from "./bff-response.ts";
import { checkSameOriginWrite } from "./csrf.ts";
import { getServerRuntimeConfig } from "./env.ts";
import {
  clearSessionCookies,
  parseAuthResponse,
  readAccessBearer,
  readRefreshBearer,
  setRefreshedSessionCookies,
  setSessionCookies,
} from "./session.ts";

const bodyLimit = 1024 * 1024;
const jsonContentType = /^application\/json(?:\s*;\s*charset\s*=\s*(?:utf-8|"utf-8"))?\s*$/i;

function privateJson(value: unknown, status = 200): NextResponse {
  return NextResponse.json(value, {
    status,
    headers: {
      "cache-control": "private, no-store",
      "x-content-type-options": "nosniff",
    },
  }) as NextResponse;
}

function nextResponse(response: Response): NextResponse {
  return new NextResponse(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers,
  }) as NextResponse;
}

function writeRejection(request: NextRequest): Response | null {
  const rejection = checkSameOriginWrite(request);
  return rejection ? bffFailure(rejection.kind, rejection.status, rejection.code) : null;
}

function declaredLength(request: Request): number | null | "invalid" {
  const raw = request.headers.get("content-length");
  if (raw === null) return null;
  if (!/^\d+$/.test(raw)) return "invalid";
  const value = Number(raw);
  return Number.isSafeInteger(value) ? value : "invalid";
}

async function cancelBody(request: Request): Promise<void> {
  try {
    await request.body?.cancel();
  } catch {
    // The request is already rejected; no body bytes will be forwarded.
  }
}

async function rejectWrite(request: NextRequest): Promise<Response | null> {
  const rejection = writeRejection(request);
  if (!rejection) return null;
  await cancelBody(request);
  return rejection;
}

async function readBody(request: Request, limit: number): Promise<Uint8Array | null> {
  if (!request.body) return new Uint8Array();
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.byteLength;
      if (size > limit) {
        try {
          await reader.cancel();
        } catch {
          // The limit is decisive; stop reading the untrusted body.
        }
        return null;
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return bytes;
}

async function readLoginBody(request: NextRequest): Promise<{ email: string; password: string } | Response> {
  if (!jsonContentType.test(request.headers.get("content-type") ?? "")) {
    await cancelBody(request);
    return bffFailure("validation", 415, "CONTENT_TYPE_REJECTED");
  }
  const length = declaredLength(request);
  if (length === "invalid") {
    await cancelBody(request);
    return bffFailure("validation", 400, "CONTENT_LENGTH_INVALID");
  }
  if (length !== null && length > bodyLimit) {
    await cancelBody(request);
    return bffFailure("validation", 413, "REQUEST_BODY_TOO_LARGE");
  }
  const bytes = await readBody(request, bodyLimit);
  if (bytes === null) return bffFailure("validation", 413, "REQUEST_BODY_TOO_LARGE");
  if (bytes.byteLength === 0) return bffFailure("validation", 400, "REQUEST_BODY_REQUIRED");
  let value: unknown;
  try {
    value = JSON.parse(new TextDecoder().decode(bytes));
  } catch {
    return bffFailure("validation", 400, "REQUEST_BODY_INVALID");
  }
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return bffFailure("validation", 400, "REQUEST_BODY_INVALID");
  }
  const login = value as Record<string, unknown>;
  if (typeof login.email !== "string" || typeof login.password !== "string") {
    return bffFailure("validation", 400, "REQUEST_BODY_INVALID");
  }
  return { email: login.email, password: login.password };
}

async function rejectBody(request: NextRequest): Promise<Response | null> {
  const length = declaredLength(request);
  if (length === "invalid") {
    await cancelBody(request);
    return bffFailure("validation", 400, "CONTENT_LENGTH_INVALID");
  }
  if (length !== null && length > 0) {
    await cancelBody(request);
    return bffFailure("validation", 400, "REQUEST_BODY_NOT_ALLOWED");
  }
  const bytes = await readBody(request, 0);
  return bytes === null || bytes.byteLength > 0
    ? bffFailure("validation", 400, "REQUEST_BODY_NOT_ALLOWED")
    : null;
}

function malformedSession(): Response {
  return bffFailure("malformed", 502, "UPSTREAM_SESSION_INVALID");
}

export async function handleSessionLogin(request: NextRequest): Promise<Response> {
  const rejected = await rejectWrite(request);
  if (rejected) return rejected;
  const login = await readLoginBody(request);
  if (login instanceof Response) return login;

  const result = await backendJson<unknown>("/auth/login", {
    method: "POST",
    headers: { accept: "application/json", "content-type": "application/json" },
    body: JSON.stringify(login),
    signal: request.signal,
  });
  if (!result.ok) return bffError(result.error);
  const auth = parseAuthResponse(result.data);
  if (!auth?.accessToken || !auth.refreshToken) return malformedSession();

  const { webOrigin } = getServerRuntimeConfig();
  const response = privateJson(auth.identity);
  if (!setSessionCookies(response, auth.accessToken, auth.refreshToken, webOrigin)) return malformedSession();
  return response;
}

export async function handleSessionMe(request: NextRequest): Promise<Response> {
  const { webOrigin } = getServerRuntimeConfig();
  const accessToken = readAccessBearer(request, webOrigin);
  if (!accessToken) return bffFailure("unauthenticated", 401, "SESSION_REQUIRED");
  const result = await backendJson<unknown>("/auth/me", { bearerToken: accessToken, signal: request.signal });
  if (!result.ok) return bffError(result.error);
  const auth = parseAuthResponse(result.data);
  if (!auth || auth.accessToken !== null || auth.refreshToken !== null) return malformedSession();
  return privateJson(auth.identity);
}

export async function handleSessionRefresh(request: NextRequest): Promise<Response> {
  const rejected = await rejectWrite(request);
  if (rejected) return rejected;
  const bodyError = await rejectBody(request);
  if (bodyError) return bodyError;
  const { webOrigin } = getServerRuntimeConfig();
  const refreshToken = readRefreshBearer(request, webOrigin);
  if (!refreshToken) {
    const response = nextResponse(bffFailure("unauthenticated", 401, "SESSION_REFRESH_REQUIRED"));
    clearSessionCookies(response, webOrigin);
    return response;
  }

  const result = await backendJson<unknown>("/auth/refresh", {
    method: "POST",
    headers: { accept: "application/json" },
    bearerToken: refreshToken,
    signal: request.signal,
  });
  if (!result.ok) {
    const response = nextResponse(bffError(result.error));
    if ([400, 401, 403].includes(result.error.status ?? 0)) {
      clearSessionCookies(response, webOrigin);
    }
    return response;
  }
  const auth = parseAuthResponse(result.data);
  if (!auth?.accessToken) return malformedSession();
  const response = privateJson(auth.identity);
  if (!setRefreshedSessionCookies(response, auth.accessToken, auth.refreshToken, webOrigin)) return malformedSession();
  return response;
}

export async function handleSessionLogout(request: NextRequest): Promise<Response> {
  const rejected = await rejectWrite(request);
  if (rejected) return rejected;
  const bodyError = await rejectBody(request);
  if (bodyError) return bodyError;
  const { webOrigin } = getServerRuntimeConfig();
  const response = new NextResponse(null, {
    status: 204,
    headers: { "cache-control": "private, no-store", "x-content-type-options": "nosniff" },
  });
  clearSessionCookies(response, webOrigin);
  return response;
}

export function unsupportedSessionRoute(status: 404 | 405, allow?: string): Response {
  const response = bffFailure(status === 404 ? "not-found" : "http", status, status === 404 ? "SESSION_ROUTE_NOT_FOUND" : "METHOD_NOT_ALLOWED");
  if (!allow) return response;
  const headers = new Headers(response.headers);
  headers.set("allow", allow);
  return new Response(response.body, { status, headers });
}
