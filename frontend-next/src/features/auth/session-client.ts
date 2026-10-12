"use client";

import { bffJson } from "../../lib/api/transport.ts";
import type { ApiError, ApiResult } from "../../lib/api/transport.ts";
import { sessionIdentityScope, type SessionIdentity } from "../../lib/session-types.ts";

type IdentityResult = ApiResult<SessionIdentity | undefined>;
type IdentityChange = "initial" | "same" | "changed";
type RefreshResult = { result: IdentityResult; identityChange?: IdentityChange; terminal?: boolean };
type RecoveryResult = {
  refreshed: boolean;
  result?: IdentityResult;
  identityChange?: IdentityChange;
  verified?: boolean;
  terminal?: boolean;
};

let generation = 0;
let closing = false;
let identityFingerprint: string | null = null;
let writeQueue: Promise<void> = Promise.resolve();
let refreshFlight: Promise<RefreshResult> | null = null;
let verificationFlight: Promise<RecoveryResult> | null = null;
let rscRecoveryFlight: Promise<RecoveryResult> | null = null;
let rscRecoveryAttempted = false;
let rscRefreshRequested = false;
let rscSignoutRefreshRequested = false;
export type SessionLifecycle = { generation: number; closing: boolean; identityScope: string | null };
const listeners = new Set<() => void>();
let lifecycle: SessionLifecycle = { generation, closing, identityScope: null };

function publishLifecycle(): void {
  lifecycle = { generation, closing, identityScope: identityFingerprint };
  for (const listener of listeners) listener();
}

function cancelled<T>(): ApiResult<T> {
  return {
    ok: false,
    error: { kind: "cancelled", format: "none", message: "The session changed while the request was in progress." },
  };
}

function failure<T>(kind: ApiError["kind"], status: number, message: string): ApiResult<T> {
  return { ok: false, error: { kind, status, format: "none", message } };
}

function current(startedAt: number): boolean {
  return !closing && generation === startedAt;
}

function serializedWrite<T>(operation: () => Promise<T>): Promise<T> {
  const result = writeQueue.then(operation, operation);
  writeQueue = result.then(() => undefined, () => undefined);
  return result;
}

function identityResult(value: unknown): value is SessionIdentity {
  if (typeof value !== "object" || value === null) return false;
  const identity = value as Partial<SessionIdentity>;
  return Number.isSafeInteger(identity.userId) && (identity.userId ?? 0) > 0 &&
    typeof identity.fullName === "string" && typeof identity.email === "string" &&
    ["AGENT", "MANAGER", "ADMIN"].includes(identity.role ?? "") &&
    ["OWN", "TEAM", "ALL"].includes(identity.dataScope ?? "") &&
    ["PENDING_INVITE", "ACTIVE", "DEACTIVATED"].includes(identity.status ?? "") &&
    (identity.teamId === null || Number.isSafeInteger(identity.teamId)) &&
    (identity.teamName === null || typeof identity.teamName === "string") &&
    (identity.teamCurrency === null || typeof identity.teamCurrency === "string") &&
    typeof identity.mustChangePassword === "boolean";
}

function readIdentity(result: IdentityResult): IdentityResult {
  return result.ok && !identityResult(result.data)
    ? failure("malformed", 502, "The session response was invalid.")
    : result;
}

function recordIdentity(identity: SessionIdentity): IdentityChange {
  const next = sessionIdentityScope(identity);
  if (identityFingerprint === next) return "same";
  const change = identityFingerprint === null ? "initial" : "changed";
  identityFingerprint = next;
  generation += 1;
  publishLifecycle();
  return change;
}

function terminalRefreshError(result: IdentityResult): boolean {
  return !result.ok && [400, 401, 403].includes(result.error.status ?? 0);
}

async function logoutInsideQueue(): Promise<IdentityResult> {
  closing = true;
  identityFingerprint = null;
  const response = await bffJson<undefined>("/api/session/logout", { method: "POST" });
  return response.ok ? { ok: true, data: undefined } : response;
}

export function getSessionGeneration(): number {
  return generation;
}

export function getSessionLifecycle(): SessionLifecycle {
  return lifecycle;
}

export function subscribeSessionLifecycle(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function isSessionCurrent(startedAt: number): boolean {
  return current(startedAt);
}

export function confirmRscSession(identity: SessionIdentity): boolean {
  if (closing || identity.status !== "ACTIVE" || !identityResult(identity)) return false;
  const next = sessionIdentityScope(identity);
  if (identityFingerprint !== null && identityFingerprint !== next) return false;
  recordIdentity(identity);
  rscRecoveryAttempted = false;
  rscRefreshRequested = false;
  rscSignoutRefreshRequested = false;
  return true;
}

export async function reconcileRscSession(identity: SessionIdentity): Promise<"verified" | "mismatch" | "unavailable"> {
  if (closing || identity.status !== "ACTIVE" || !identityResult(identity)) return "mismatch";
  const expected = sessionIdentityScope(identity);
  if (identityFingerprint === null || identityFingerprint === expected) return confirmRscSession(identity) ? "verified" : "mismatch";
  const verified = await sessionMe();
  if (!verified.ok) return verified.error.kind === "cancelled" ? "mismatch" : "unavailable";
  return verified.data !== undefined && sessionIdentityScope(verified.data) === expected ? "verified" : "mismatch";
}

export function loginSession(email: string, password: string): Promise<IdentityResult> {
  closing = true;
  identityFingerprint = null;
  const startedAt = ++generation;
  publishLifecycle();
  rscRecoveryAttempted = false;
  rscRefreshRequested = false;
  rscSignoutRefreshRequested = false;
  return serializedWrite(async () => {
    if (generation !== startedAt) return cancelled();
    const result = readIdentity(await bffJson<SessionIdentity>("/api/session/login", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ email, password }),
    }));
    if (generation !== startedAt) return cancelled();
    if (result.ok && result.data?.status === "ACTIVE") {
      recordIdentity(result.data);
      if (typeof window !== "undefined" && typeof window.location.replace === "function") {
        window.location.replace(window.location.href);
        return result;
      }
      closing = false;
      publishLifecycle();
      return result;
    }
    if (result.ok) await logoutInsideQueue();
    return result;
  });
}

export async function sessionMe(): Promise<IdentityResult> {
  if (closing) return cancelled();
  const startedAt = generation;
  const result = readIdentity(await bffJson<SessionIdentity>("/api/session/me", { method: "GET" }));
  if (!current(startedAt)) return cancelled();
  if (result.ok && result.data?.status !== "ACTIVE") {
    await logoutSession();
    return cancelled();
  }
  if (result.ok && result.data) recordIdentity(result.data);
  return result;
}

export function logoutSession(): Promise<IdentityResult> {
  closing = true;
  identityFingerprint = null;
  generation += 1;
  publishLifecycle();
  return serializedWrite(logoutInsideQueue);
}

function refreshDetailed(): Promise<RefreshResult> {
  if (closing) return Promise.resolve({ result: cancelled() });
  if (refreshFlight) return refreshFlight;
  const startedAt = generation;
  const flight = serializedWrite(async (): Promise<RefreshResult> => {
    if (!current(startedAt)) return { result: cancelled() };
    const result = readIdentity(await bffJson<SessionIdentity>("/api/session/refresh", { method: "POST" }));
    if (!current(startedAt)) return { result: cancelled() };
    if (!result.ok) {
      if (terminalRefreshError(result)) {
        closing = true;
        identityFingerprint = null;
        generation += 1;
        publishLifecycle();
        return { result, terminal: true };
      }
      return { result };
    }
    if (result.data?.status !== "ACTIVE") {
      closing = true;
      identityFingerprint = null;
      generation += 1;
      publishLifecycle();
      await logoutInsideQueue();
      return { result: cancelled(), terminal: true };
    }
    const identityChange = recordIdentity(result.data);
    return { result, identityChange };
  });
  refreshFlight = flight;
  void flight.then(() => {
    if (refreshFlight === flight) refreshFlight = null;
  }, () => {
    if (refreshFlight === flight) refreshFlight = null;
  });
  return flight;
}

export async function refreshSession(): Promise<IdentityResult> {
  return (await refreshDetailed()).result;
}

async function verifySessionForResource(): Promise<RecoveryResult> {
  if (closing) return { refreshed: false, result: cancelled() };
  if (verificationFlight) return verificationFlight;
  const startedAt = generation;
  const flight = (async (): Promise<RecoveryResult> => {
    const probe = readIdentity(await bffJson<SessionIdentity>("/api/session/me", { method: "GET" }));
    if (!current(startedAt)) return { refreshed: false, result: cancelled() };
    if (probe.ok) {
      if (probe.data?.status !== "ACTIVE") {
        await logoutSession();
        return { refreshed: false, result: cancelled(), terminal: true };
      }
      const identityChange = probe.data ? recordIdentity(probe.data) : undefined;
      return { refreshed: false, result: probe, verified: true, identityChange };
    }
    if (probe.error.kind !== "unauthenticated" && probe.error.kind !== "verification-needed") {
      return { refreshed: false, result: probe };
    }
    const refresh = await refreshDetailed();
    return {
      refreshed: refresh.result.ok && refresh.result.data?.status === "ACTIVE",
      result: refresh.result,
      identityChange: refresh.identityChange,
      terminal: refresh.terminal,
    };
  })();
  verificationFlight = flight;
  try {
    return await flight;
  } finally {
    if (verificationFlight === flight) verificationFlight = null;
  }
}

function forbidden(error: ApiError): ApiError {
  return {
    ...error,
    kind: "forbidden",
    message: "You do not have permission to do this.",
  };
}

export async function runResourceRequest<T>(request: () => Promise<ApiResult<T>>): Promise<ApiResult<T>> {
  if (closing) return cancelled();
  const startedAt = generation;
  const first = await request();
  if (!current(startedAt)) return cancelled();
  if (first.ok || first.error.kind !== "unauthenticated" && first.error.kind !== "verification-needed") return first;

  const recovery = await verifySessionForResource();
  if (recovery.terminal && recovery.result && !recovery.result.ok) return recovery.result;
  if (recovery.verified) {
    if (recovery.identityChange === "changed") return cancelled();
    return first.error.kind === "verification-needed"
      ? { ok: false, error: forbidden(first.error) }
      : first;
  }
  if (recovery.result && !recovery.result.ok) return recovery.result;
  if (!recovery.refreshed) return first;
  if (recovery.identityChange === "changed") return cancelled();

  const replayGeneration = recovery.identityChange === "initial" ? generation : startedAt;
  if (!current(replayGeneration)) return cancelled();
  const replay = await request();
  if (!current(replayGeneration)) return cancelled();
  return replay;
}

export function recoverRscSession(): Promise<RecoveryResult> {
  if (closing) return Promise.resolve({ refreshed: false, result: cancelled(), terminal: true });
  if (rscRecoveryFlight) return rscRecoveryFlight;
  if (rscRecoveryAttempted) return Promise.resolve({ refreshed: false });
  rscRecoveryAttempted = true;
  const flight = refreshDetailed().then((refresh) => ({
    ...refresh,
    refreshed: refresh.result.ok && refresh.result.data?.status === "ACTIVE",
  }));
  rscRecoveryFlight = flight;
  void flight.then(() => {
    if (rscRecoveryFlight === flight) rscRecoveryFlight = null;
  }, () => {
    if (rscRecoveryFlight === flight) rscRecoveryFlight = null;
  });
  return flight;
}

export function resetRscRecoveryAttempt(): void {
  rscRecoveryAttempted = false;
  rscRefreshRequested = false;
  rscSignoutRefreshRequested = false;
}

export function claimRscRefresh(): boolean {
  if (rscRefreshRequested) return false;
  rscRefreshRequested = true;
  return true;
}

export function claimRscSignoutRefresh(): boolean {
  if (rscSignoutRefreshRequested) return false;
  rscSignoutRefreshRequested = true;
  return true;
}
