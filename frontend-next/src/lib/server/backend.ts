import "server-only";

import { readJson, readStream, type ApiError, type ApiResult } from "../api/transport.ts";
import { resolveBackendApiUrl } from "./backend-config.ts";
import { getServerRuntimeConfig } from "./env.ts";

export type BackendRequestInit = Omit<RequestInit, "headers"> & {
  headers?: HeadersInit;
  /** Request-scoped opaque bearer; the caller chooses the token purpose. */
  bearerToken?: string;
  /** Node fetch requires half duplex when a request body is a stream. */
  duplex?: "half";
};

type PreparedRequest = { url: URL; init: RequestInit };

function invalidDestination(): ApiResult<never> {
  const error: ApiError = {
    kind: "malformed",
    format: "none",
    message: "Invalid backend API destination.",
  };
  return { ok: false, error };
}

function prepareRequest(apiPath: string, options: BackendRequestInit = {}): PreparedRequest {
  const { bearerToken, ...init } = options;
  const providedHeaders = new Headers(init.headers);
  const headers = new Headers();
  for (const name of ["accept", "content-type", "accept-language"]) {
    const value = providedHeaders.get(name);
    if (value !== null) headers.set(name, value);
  }
  if (bearerToken) headers.set("authorization", `Bearer ${bearerToken}`);

  return {
    url: resolveBackendApiUrl(getServerRuntimeConfig().backendApiUrl, apiPath),
    init: { ...init, headers, cache: "no-store", credentials: "omit", redirect: "manual" },
  };
}

function response(apiPath: string, options: BackendRequestInit): Promise<Response> {
  const request = prepareRequest(apiPath, options);
  return Promise.resolve().then(() => fetch(request.url, request.init));
}

export function backendJson<T>(apiPath: string, options: BackendRequestInit = {}): Promise<ApiResult<T | undefined>> {
  try {
    return readJson(response(apiPath, options), options.signal);
  } catch {
    return Promise.resolve(invalidDestination());
  }
}

export function backendStream(apiPath: string, options: BackendRequestInit = {}): Promise<ApiResult<Response>> {
  try {
    return readStream(response(apiPath, options), options.signal);
  } catch {
    return Promise.resolve(invalidDestination());
  }
}
