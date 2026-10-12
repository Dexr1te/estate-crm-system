import "server-only";

import type { NextRequest, NextResponse } from "next/server";
import type { SessionIdentity } from "../session-types.ts";

export type { SessionIdentity } from "../session-types.ts";

const maxBearerLength = 16_384;
const bearerPattern = /^[A-Za-z0-9._~-]+$/;
const jwtPattern = /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/;

export type AuthResponse = {
  identity: SessionIdentity;
  accessToken: string | null;
  refreshToken: string | null;
};

function loopback(hostname: string): boolean {
  const normalized = hostname.toLowerCase().replace(/^\[|\]$/g, "");
  return normalized === "localhost" || normalized === "127.0.0.1" || normalized === "::1";
}

export function accessCookieName(webOrigin: string): "__Host-estate-access" | "estate-dev-access" {
  const origin = new URL(webOrigin);
  if (origin.protocol === "https:") return "__Host-estate-access";
  if (origin.protocol === "http:" && loopback(origin.hostname)) return "estate-dev-access";
  throw new Error("WEB_ORIGIN must use HTTPS except for loopback development");
}

export function refreshCookieName(webOrigin: string): "__Host-estate-refresh" | "estate-dev-refresh" {
  const origin = new URL(webOrigin);
  if (origin.protocol === "https:") return "__Host-estate-refresh";
  if (origin.protocol === "http:" && loopback(origin.hostname)) return "estate-dev-refresh";
  throw new Error("WEB_ORIGIN must use HTTPS except for loopback development");
}

function validBearer(value: string | undefined): string | null {
  return value && value.length <= maxBearerLength && bearerPattern.test(value) ? value : null;
}

function headerCookieValues(header: string | null, name: string): string[] {
  if (!header) return [];
  const values: string[] = [];
  for (const part of header.split(";")) {
    const separator = part.indexOf("=");
    if (separator < 0) continue;
    if (part.slice(0, separator).trim() === name) values.push(part.slice(separator + 1).trim());
  }
  return values;
}

export function readSessionBearer(source: string | null, name: string): string | null {
  const values = headerCookieValues(source, name);
  return values.length === 1 ? validBearer(values[0]) : null;
}

export function readAccessBearer(request: Pick<NextRequest, "headers">, webOrigin: string): string | null {
  return readSessionBearer(request.headers.get("cookie"), accessCookieName(webOrigin));
}

export function readRefreshBearer(request: Pick<NextRequest, "headers">, webOrigin: string): string | null {
  return readSessionBearer(request.headers.get("cookie"), refreshCookieName(webOrigin));
}

export function cookieMaxAge(token: string, now = Date.now()): number | null {
  if (token.length > maxBearerLength || !jwtPattern.test(token)) return null;
  const payload = token.split(".")[1];
  if (!payload) return null;
  try {
    const value: unknown = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
    if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
    const exp = (value as Record<string, unknown>).exp;
    if (typeof exp !== "number" || !Number.isSafeInteger(exp)) return null;
    const seconds = Math.floor(exp - now / 1000);
    return seconds > 0 ? seconds : null;
  } catch {
    return null;
  }
}

function cookieOptions(webOrigin: string, maxAge: number) {
  return {
    httpOnly: true,
    secure: new URL(webOrigin).protocol === "https:",
    sameSite: "lax" as const,
    path: "/",
    maxAge,
  };
}

export function setSessionCookies(
  response: NextResponse,
  accessToken: string,
  refreshToken: string,
  webOrigin: string,
): boolean {
  const accessMaxAge = cookieMaxAge(accessToken);
  const refreshMaxAge = cookieMaxAge(refreshToken);
  if (accessMaxAge === null || refreshMaxAge === null) return false;
  response.cookies.set(accessCookieName(webOrigin), accessToken, cookieOptions(webOrigin, accessMaxAge));
  response.cookies.set(refreshCookieName(webOrigin), refreshToken, cookieOptions(webOrigin, refreshMaxAge));
  return true;
}

export function setRefreshedSessionCookies(
  response: NextResponse,
  accessToken: string,
  refreshToken: string | null,
  webOrigin: string,
): boolean {
  const accessMaxAge = cookieMaxAge(accessToken);
  const refreshMaxAge = refreshToken === null ? null : cookieMaxAge(refreshToken);
  if (accessMaxAge === null || (refreshToken !== null && refreshMaxAge === null)) return false;
  response.cookies.set(accessCookieName(webOrigin), accessToken, cookieOptions(webOrigin, accessMaxAge));
  if (refreshToken !== null && refreshMaxAge !== null) {
    response.cookies.set(refreshCookieName(webOrigin), refreshToken, cookieOptions(webOrigin, refreshMaxAge));
  }
  return true;
}

export function clearSessionCookies(response: NextResponse, webOrigin: string): void {
  response.cookies.set(accessCookieName(webOrigin), "", cookieOptions(webOrigin, 0));
  response.cookies.set(refreshCookieName(webOrigin), "", cookieOptions(webOrigin, 0));
}

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function oneOf<T extends string>(value: unknown, allowed: readonly T[]): value is T {
  return typeof value === "string" && allowed.includes(value as T);
}

function nullableString(value: unknown): value is string | null {
  return value === null || typeof value === "string";
}

function safeId(value: unknown): value is number {
  return typeof value === "number" && Number.isSafeInteger(value) && value > 0;
}

export function sanitizeIdentity(value: unknown): SessionIdentity | null {
  if (!record(value)) return null;
  if (!safeId(value.userId) || typeof value.fullName !== "string" || typeof value.email !== "string") return null;
  if (!oneOf(value.role, ["AGENT", "MANAGER", "ADMIN"] as const)) return null;
  if (!oneOf(value.dataScope, ["OWN", "TEAM", "ALL"] as const)) return null;
  if (!oneOf(value.status, ["PENDING_INVITE", "ACTIVE", "DEACTIVATED"] as const)) return null;
  if (value.teamId !== null && !safeId(value.teamId)) return null;
  if (!nullableString(value.teamName) || !nullableString(value.teamCurrency)) return null;
  if (typeof value.mustChangePassword !== "boolean") return null;
  return {
    userId: value.userId,
    fullName: value.fullName,
    email: value.email,
    role: value.role,
    dataScope: value.dataScope,
    status: value.status,
    teamId: value.teamId,
    teamName: value.teamName,
    teamCurrency: value.teamCurrency,
    mustChangePassword: value.mustChangePassword,
  };
}

export function parseAuthResponse(value: unknown): AuthResponse | null {
  if (!record(value) || !Object.hasOwn(value, "accessToken") || !Object.hasOwn(value, "refreshToken")) return null;
  const identity = sanitizeIdentity(value);
  if (!identity) return null;
  if (value.accessToken !== null && typeof value.accessToken !== "string") return null;
  if (value.refreshToken !== null && typeof value.refreshToken !== "string") return null;
  return { identity, accessToken: value.accessToken, refreshToken: value.refreshToken };
}
