export type RuntimeConfigInput = {
  BACKEND_API_URL?: string;
  WEB_ORIGIN?: string;
};

export type ServerRuntimeConfig = {
  backendApiUrl: string;
  webOrigin: string;
};

function parseAbsoluteUrl(name: string, raw: string | undefined): URL {
  if (!raw?.trim()) {
    throw new Error(`${name} is required`);
  }

  let value: URL;
  try {
    value = new URL(raw.trim());
  } catch {
    throw new Error(`${name} must be an absolute HTTP(S) URL`);
  }

  if (
    (value.protocol !== "http:" && value.protocol !== "https:") ||
    value.username !== "" ||
    value.password !== "" ||
    value.search !== "" ||
    value.hash !== ""
  ) {
    throw new Error(`${name} must not contain credentials, query, or fragment`);
  }

  return value;
}

export function parseServerRuntimeConfig(input: RuntimeConfigInput): ServerRuntimeConfig {
  const backend = parseAbsoluteUrl("BACKEND_API_URL", input.BACKEND_API_URL);
  if (backend.pathname !== "/api" && backend.pathname !== "/api/") {
    throw new Error("BACKEND_API_URL must use the /api path");
  }

  const web = parseAbsoluteUrl("WEB_ORIGIN", input.WEB_ORIGIN);
  if (web.pathname !== "/") {
    throw new Error("WEB_ORIGIN must contain only an origin");
  }
  const loopbackHost = web.hostname.toLowerCase().replace(/^\[|\]$/g, "");
  if (web.protocol === "http:" && !["localhost", "127.0.0.1", "::1"].includes(loopbackHost)) {
    throw new Error("WEB_ORIGIN must use HTTPS except for loopback development");
  }

  return {
    backendApiUrl: `${backend.origin}/api`,
    webOrigin: web.origin,
  };
}

export function resolveBackendApiUrl(backendApiUrl: string, apiPath: string): URL {
  const base = new URL(backendApiUrl);
  if (
    (base.protocol !== "http:" && base.protocol !== "https:") ||
    base.username !== "" ||
    base.password !== "" ||
    (base.pathname !== "/api" && base.pathname !== "/api/") ||
    base.search !== "" ||
    base.hash !== ""
  ) {
    throw new Error("Invalid backend API base");
  }

  if (!apiPath.startsWith("/") || apiPath.startsWith("//") || /[\\\u0000-\u001f]/.test(apiPath)) {
    throw new Error("Invalid backend API path");
  }

  const route = apiPath.split(/[?#]/, 1)[0];
  let decodedRoute: string;
  try {
    decodedRoute = decodeURIComponent(route);
  } catch {
    throw new Error("Invalid backend API path");
  }
  if (
    decodedRoute.includes("\\") ||
    /%2f|%5c/i.test(route) ||
    decodedRoute.split("/").some((part) => part === "." || part === "..")
  ) {
    throw new Error("Invalid backend API path");
  }

  const target = new URL(apiPath.slice(1), `${base.origin}/api/`);
  if (
    target.origin !== base.origin ||
    !target.pathname.startsWith("/api/") ||
    target.hash !== ""
  ) {
    throw new Error("Invalid backend API path");
  }
  return target;
}
