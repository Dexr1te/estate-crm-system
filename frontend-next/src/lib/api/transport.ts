export type ApiErrorKind =
  | "unauthenticated"
  | "verification-needed"
  | "forbidden"
  | "not-found"
  | "validation"
  | "conflict"
  | "rate-limited"
  | "unavailable"
  | "timeout"
  | "network"
  | "cancelled"
  | "malformed"
  | "http";

export type ApiError = {
  kind: ApiErrorKind;
  status?: number;
  code?: string;
  validationErrors?: Record<string, string>;
  format: "error-response" | "json" | "plain-text" | "html" | "empty" | "malformed-json" | "unreadable" | "unknown" | "none";
  message: string;
};

export type ApiResult<T> = { ok: true; data: T } | { ok: false; error: ApiError };

type ErrorBody = Pick<ApiError, "code" | "validationErrors" | "format"> & {
  structured: boolean;
  safeText?: string;
  interrupted?: ApiError;
};

const maxErrorBodyBytes = 16 * 1024;
const maxSafeTextLength = 500;

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isJsonType(contentType: string): boolean {
  const type = contentType.split(";", 1)[0]?.trim().toLowerCase();
  return type === "application/json" || type?.endsWith("+json") === true;
}

function looksLikeHtml(value: string): boolean {
  return /<\s*(?:!doctype\b|\/?[a-z][\w:-]*)(?:\s|\/|>)/i.test(value);
}

function safeText(value: string): string | undefined {
  const text = value.replace(/[\u0000-\u001f\u007f]/g, " ").trim();
  if (!text || looksLikeHtml(text)) return undefined;
  return text.slice(0, maxSafeTextLength);
}

async function limitedText(response: Response): Promise<{ text: string; truncated: boolean }> {
  const reader = response.body?.getReader();
  if (!reader) return { text: "", truncated: false };

  const decoder = new TextDecoder();
  const chunks: string[] = [];
  let bytes = 0;
  let truncated = false;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      const remaining = maxErrorBodyBytes - bytes;
      const part = value.subarray(0, remaining);
      chunks.push(decoder.decode(part, { stream: true }));
      bytes += part.byteLength;
      if (part.byteLength !== value.byteLength) {
        truncated = true;
        try {
          await reader.cancel();
        } catch {
          // The bounded error sample is already enough to classify the response.
        }
        break;
      }
    }
    chunks.push(decoder.decode());
    return { text: chunks.join(""), truncated };
  } finally {
    reader.releaseLock();
  }
}

async function errorBody(response: Response, signal?: AbortSignal | null): Promise<ErrorBody> {
  if (signal?.aborted) {
    return {
      structured: false,
      format: "unreadable",
      interrupted: transportError(signal.reason, signal, response.status, "unreadable"),
    };
  }

  const mediaType = response.headers.get("content-type")?.split(";", 1)[0]?.trim().toLowerCase() ?? "";
  let sample: { text: string; truncated: boolean };
  try {
    sample = await limitedText(response);
  } catch (error) {
    const failure = transportError(error, signal, response.status, "unreadable");
    return {
      structured: false,
      format: "unreadable",
      ...(failure.kind === "cancelled" || failure.kind === "timeout" ? { interrupted: failure } : {}),
    };
  }

  const text = sample.text.trim();
  if (!text) return { structured: false, format: "empty" };
  if (mediaType === "text/html" || mediaType === "application/xhtml+xml") {
    return { structured: false, format: "html" };
  }

  if (isJsonType(mediaType)) {
    if (sample.truncated) {
      return { structured: false, format: looksLikeHtml(text) ? "html" : "malformed-json" };
    }
    let value: unknown;
    try {
      value = JSON.parse(text);
    } catch {
      return { structured: false, format: looksLikeHtml(text) ? "html" : "malformed-json" };
    }

    if (typeof value === "string") {
      return { structured: false, format: "plain-text", safeText: safeText(value) };
    }
    if (!record(value)) return { structured: false, format: "json" };

    const validationErrors = record(value.validationErrors)
      ? Object.fromEntries(Object.entries(value.validationErrors).filter((entry): entry is [string, string] => typeof entry[1] === "string"))
      : undefined;
    const code = typeof value.code === "string" && value.code.length > 0 ? value.code : undefined;
    return {
      structured:
        value.status === response.status &&
        typeof value.error === "string" &&
        typeof value.message === "string" &&
        typeof value.path === "string",
      format: "error-response",
      ...(code ? { code } : {}),
      ...(validationErrors ? { validationErrors } : {}),
    };
  }

  if (looksLikeHtml(text)) return { structured: false, format: "html" };
  if (mediaType === "text/plain" || !mediaType || sample.truncated) {
    return { structured: false, format: "plain-text", safeText: safeText(text) };
  }
  return { structured: false, format: "unknown" };
}

function httpError(response: Response, body: ErrorBody): ApiError {
  if (body.interrupted) return body.interrupted;

  let kind: ApiErrorKind = "http";
  if (response.status === 401) kind = "unauthenticated";
  else if (response.status === 403) kind = body.structured ? "forbidden" : "verification-needed";
  else if (response.status === 404) kind = "not-found";
  else if (response.status === 400 && Object.keys(body.validationErrors ?? {}).length > 0) kind = "validation";
  else if (response.status === 409) kind = "conflict";
  else if (response.status === 429) kind = "rate-limited";
  else if (response.status >= 500) kind = "unavailable";

  return {
    kind,
    status: response.status,
    format: body.format,
    message: response.status === 400 && body.safeText ? body.safeText : "The request could not be completed.",
    ...(body.code ? { code: body.code } : {}),
    ...(body.validationErrors ? { validationErrors: body.validationErrors } : {}),
  };
}

function transportError(
  error: unknown,
  signal?: AbortSignal | null,
  status?: number,
  format: ApiError["format"] = "none",
): ApiError {
  const reasonName = signal?.aborted && record(signal.reason) ? signal.reason.name : undefined;
  const errorName = record(error) ? error.name : undefined;
  const kind: ApiErrorKind = reasonName === "TimeoutError" || errorName === "TimeoutError"
    ? "timeout"
    : signal?.aborted || reasonName === "AbortError" || errorName === "AbortError"
      ? "cancelled"
      : "network";
  const message = kind === "timeout"
    ? "The request timed out."
    : kind === "cancelled"
      ? "The request was cancelled."
      : "The service could not be reached.";
  return { kind, format, message, ...(status === undefined ? {} : { status }) };
}

function malformed(response: Response, format: ApiError["format"]): ApiError {
  return {
    kind: "malformed",
    status: response.status,
    format,
    message: "The service returned an invalid response.",
  };
}

const apiErrorKinds = new Set<ApiErrorKind>([
  "unauthenticated", "verification-needed", "forbidden", "not-found", "validation", "conflict", "rate-limited",
  "unavailable", "timeout", "network", "cancelled", "malformed", "http",
]);
const apiErrorFormats = new Set<ApiError["format"]>([
  "error-response", "json", "plain-text", "html", "empty", "malformed-json", "unreadable", "unknown", "none",
]);

function validWireStatus(kind: ApiErrorKind, status: number): boolean {
  if (kind === "validation") return status === 400 || status === 413 || status === 415;
  const expected: Partial<Record<ApiErrorKind, number>> = {
    unauthenticated: 401,
    "verification-needed": 403,
    forbidden: 403,
    "not-found": 404,
    conflict: 409,
    "rate-limited": 429,
    network: 503,
    timeout: 504,
    cancelled: 503,
    malformed: 502,
  };
  if (kind === "unavailable") return status >= 500 && status <= 599;
  return expected[kind] === undefined ? status >= 400 && status <= 599 : expected[kind] === status;
}

async function trustedBffError(response: Response, signal?: AbortSignal | null): Promise<ApiError | null> {
  if (response.headers.get("x-crm-bff-error") !== "1") return null;
  let sample: { text: string; truncated: boolean };
  try {
    sample = await limitedText(response);
  } catch (error) {
    return transportError(error, signal, response.status, "unreadable");
  }
  if (sample.truncated) return malformed(response, "malformed-json");
  let value: unknown;
  try {
    value = JSON.parse(sample.text);
  } catch {
    return malformed(response, "malformed-json");
  }
  if (!record(value) || value.ok !== false || !record(value.error)) return malformed(response, "json");
  const candidate = value.error;
  if (
    typeof candidate.kind !== "string" || !apiErrorKinds.has(candidate.kind as ApiErrorKind) ||
    candidate.status !== response.status || !validWireStatus(candidate.kind as ApiErrorKind, response.status) ||
    typeof candidate.format !== "string" || !apiErrorFormats.has(candidate.format as ApiError["format"]) ||
    typeof candidate.message !== "string" || candidate.message.length > maxSafeTextLength ||
    /[\u0000-\u001f\u007f]/.test(candidate.message) || looksLikeHtml(candidate.message)
  ) return malformed(response, "json");

  const code = candidate.code;
  if (code !== undefined && (typeof code !== "string" || !/^[A-Z0-9_]{1,100}$/.test(code))) return malformed(response, "json");
  let validationErrors: Record<string, string> | undefined;
  if (candidate.validationErrors !== undefined) {
    if (!record(candidate.validationErrors) || Object.keys(candidate.validationErrors).length > 100) return malformed(response, "json");
    const entries = Object.entries(candidate.validationErrors);
    if (entries.some(([key, entry]) => key.length > 100 || typeof entry !== "string" || entry.length > 500)) {
      return malformed(response, "json");
    }
    validationErrors = Object.fromEntries(entries) as Record<string, string>;
  }
  return {
    kind: candidate.kind as ApiErrorKind,
    status: response.status,
    format: candidate.format as ApiError["format"],
    message: candidate.message,
    ...(typeof code === "string" ? { code } : {}),
    ...(validationErrors ? { validationErrors } : {}),
  };
}

async function readJsonInternal<T>(
  responsePromise: Promise<Response>,
  signal?: AbortSignal | null,
  acceptBffWire = false,
): Promise<ApiResult<T | undefined>> {
  let response: Response;
  try {
    response = await responsePromise;
  } catch (error) {
    return { ok: false, error: transportError(error, signal) };
  }

  if (!response.ok) {
    if (acceptBffWire) {
      try {
        const bffError = await trustedBffError(response, signal);
        if (bffError) return { ok: false, error: bffError };
      } catch {
        // Fall back to the ordinary bounded HTTP error parser.
      }
    }
    return { ok: false, error: httpError(response, await errorBody(response, signal)) };
  }
  if (response.status === 204 || response.status === 205) return { ok: true, data: undefined };

  const contentType = response.headers.get("content-type") ?? "";
  if (!isJsonType(contentType)) {
    const format = /html/i.test(contentType) ? "html" : response.body === null ? "empty" : "unknown";
    try {
      await response.body?.cancel();
    } catch {
      // The content type already shows this is not a JSON response.
    }
    return { ok: false, error: malformed(response, format) };
  }
  if (response.body === null) return { ok: false, error: malformed(response, "empty") };

  let text: string;
  try {
    text = await response.text();
  } catch (error) {
    return {
      ok: false,
      error: transportError(error, signal, response.status, "unreadable"),
    };
  }
  try {
    return { ok: true, data: JSON.parse(text) as T };
  } catch {
    return { ok: false, error: malformed(response, "malformed-json") };
  }
}

export function readJson<T>(responsePromise: Promise<Response>, signal?: AbortSignal | null): Promise<ApiResult<T | undefined>> {
  return readJsonInternal(responsePromise, signal, false);
}

async function readStreamInternal(
  responsePromise: Promise<Response>,
  signal?: AbortSignal | null,
  acceptBffWire = false,
): Promise<ApiResult<Response>> {
  let response: Response;
  try {
    response = await responsePromise;
  } catch (error) {
    return { ok: false, error: transportError(error, signal) };
  }
  if (response.ok) return { ok: true, data: response };
  if (acceptBffWire) {
    try {
      const bffError = await trustedBffError(response, signal);
      if (bffError) return { ok: false, error: bffError };
    } catch {
      // Fall back to the ordinary bounded HTTP error parser.
    }
  }
  return { ok: false, error: httpError(response, await errorBody(response, signal)) };
}

export function readStream(responsePromise: Promise<Response>, signal?: AbortSignal | null): Promise<ApiResult<Response>> {
  return readStreamInternal(responsePromise, signal, false);
}

function bffUrl(path: string): URL {
  if (typeof window === "undefined" || !path.startsWith("/") || path.startsWith("//") || path.includes("#") || /[\\\u0000-\u001f]/.test(path)) {
    throw new Error("Invalid BFF path");
  }
  const rawPath = path.split("?", 1)[0];
  let decodedPath: string;
  try {
    decodedPath = decodeURIComponent(rawPath);
  } catch {
    throw new Error("Invalid BFF path");
  }
  if (
    decodedPath.includes("\\") ||
    /%2f|%5c/i.test(rawPath) ||
    decodedPath.split("/").some((part) => part === "." || part === "..")
  ) {
    throw new Error("Invalid BFF path");
  }

  const url = new URL(path, window.location.origin);
  const allowedPrefix = ["/api/backend", "/api/session"].some(
    (prefix) => url.pathname === prefix || url.pathname.startsWith(`${prefix}/`),
  );
  if (url.origin !== window.location.origin || !allowedPrefix || url.hash !== "") {
    throw new Error("Invalid BFF path");
  }
  return url;
}

function bffRequest(url: URL, init: RequestInit): Promise<Response> {
  const headers = new Headers(init.headers);
  headers.delete("authorization");
  return fetch(url, {
    ...init,
    headers,
    cache: "no-store",
    credentials: "same-origin",
    redirect: "error",
  });
}

function invalidDestination(): ApiResult<never> {
  return {
    ok: false,
    error: { kind: "malformed", format: "none", message: "Invalid API destination." },
  };
}

export function bffJson<T>(path: string, init: RequestInit = {}): Promise<ApiResult<T | undefined>> {
  let url: URL;
  try {
    url = bffUrl(path);
  } catch {
    return Promise.resolve(invalidDestination());
  }
  return readJsonInternal(Promise.resolve().then(() => bffRequest(url, init)), init.signal, true);
}

export function bffStream(path: string, init: RequestInit = {}): Promise<ApiResult<Response>> {
  let url: URL;
  try {
    url = bffUrl(path);
  } catch {
    return Promise.resolve(invalidDestination());
  }
  return readStreamInternal(Promise.resolve().then(() => bffRequest(url, init)), init.signal, true);
}
