import "server-only";

import type { ApiError, ApiErrorKind } from "../api/transport.ts";

const jsonHeaders = {
  "cache-control": "private, no-store",
  "content-type": "application/json; charset=utf-8",
  "x-content-type-options": "nosniff",
  "x-crm-bff-error": "1",
};

const safeMessages: Record<ApiErrorKind, string> = {
  unauthenticated: "Sign in to continue.",
  "verification-needed": "Your access needs verification.",
  forbidden: "You do not have permission to do this.",
  "not-found": "The requested item was not found.",
  validation: "Check the request and try again.",
  conflict: "The request conflicts with the current state.",
  "rate-limited": "Too many requests. Try again shortly.",
  unavailable: "The service is temporarily unavailable.",
  timeout: "The service took too long to respond.",
  network: "The service is temporarily unavailable.",
  cancelled: "The request was cancelled.",
  malformed: "The service returned an invalid response.",
  http: "The request could not be completed.",
};

function mappedStatus(error: ApiError): number {
  if (error.kind === "timeout") return 504;
  if (error.kind === "network") return 503;
  if (error.kind === "unavailable") return error.status && error.status >= 500 && error.status <= 599 ? error.status : 503;
  if (error.kind === "malformed") return 502;
  if (error.kind === "cancelled") return 503;
  return error.status && error.status >= 400 && error.status <= 599 ? error.status : 502;
}

export function bffError(error: ApiError, status = mappedStatus(error)): Response {
  const plainValidation = error.status === 400 && error.format === "plain-text"
    ? error.message.replace(/[\u0000-\u001f\u007f]/g, " ").replace(/<[^>]*>/g, "").slice(0, 500)
    : undefined;
  const safeError: ApiError = {
    kind: error.kind,
    status,
    format: error.format,
    message: plainValidation || safeMessages[error.kind],
    ...(error.code ? { code: error.code } : {}),
    ...(error.validationErrors ? { validationErrors: error.validationErrors } : {}),
  };
  return Response.json({ ok: false, error: safeError }, { status, headers: jsonHeaders });
}

export function bffFailure(
  kind: ApiErrorKind,
  status: number,
  code?: string,
  format: ApiError["format"] = "none",
): Response {
  return bffError({ kind, status, format, message: safeMessages[kind], ...(code ? { code } : {}) }, status);
}

export function privateJson(value: unknown, status = 200): Response {
  return Response.json(value, {
    status,
    headers: {
      "cache-control": "private, no-store",
      "content-type": "application/json; charset=utf-8",
      "x-content-type-options": "nosniff",
    },
  });
}

export function isCredentialField(value: unknown): boolean {
  if (Array.isArray(value)) return value.some(isCredentialField);
  if (typeof value !== "object" || value === null) return false;
  return Object.entries(value).some(([key, child]) => {
    if (child === null) return false;
    return /^(?:access.?token|refresh.?token|token|password|secret|authorization|jwt)$/i.test(key) || isCredentialField(child);
  });
}

export function safeAttachment(raw: string | null, fallback: string): string {
  const encoded = raw?.match(/filename\*\s*=\s*UTF-8''([^;]+)/i)?.[1];
  const plain = raw?.match(/filename\s*=\s*"?([^";]+)"?/i)?.[1];
  let name = fallback;
  if (encoded) {
    try {
      name = decodeURIComponent(encoded);
    } catch {
      name = fallback;
    }
  } else if (plain) {
    name = plain;
  }
  name = Array.from(name.replace(/[\\/\u0000-\u001f\u007f"<>:|?*]/g, "_").trim()).slice(0, 255).join("") || fallback;
  const rfc5987 = encodeURIComponent(name).replace(/[!'()*]/g, (character) => `%${character.charCodeAt(0).toString(16).toUpperCase()}`);
  return `attachment; filename*=UTF-8''${rfc5987}`;
}
