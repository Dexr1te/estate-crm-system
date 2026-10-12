import "server-only";

import { cache } from "react";
import { headers } from "next/headers";
import type { ApiError } from "../api/transport.ts";
import type { SessionIdentity } from "../session-types.ts";
import { backendJson } from "./backend.ts";
import { getServerRuntimeConfig } from "./env.ts";
import { accessCookieName, parseAuthResponse, readSessionBearer, refreshCookieName } from "./session.ts";

export type RscSessionState =
  | { status: "anonymous" }
  | { status: "recover" }
  | { status: "active"; identity: SessionIdentity }
  | { status: "signout" }
  | { status: "forbidden" }
  | { status: "unavailable" };

function isAuthenticationFailure(error: ApiError): boolean {
  return error.kind === "unauthenticated" || error.kind === "verification-needed";
}

export const readRscSession = cache(async function readRscSession(): Promise<RscSessionState> {
  const { webOrigin } = getServerRuntimeConfig();
  const requestHeaders = await headers();
  const cookieSource = requestHeaders.get("cookie");
  const access = readSessionBearer(cookieSource, accessCookieName(webOrigin));
  const refresh = readSessionBearer(cookieSource, refreshCookieName(webOrigin));
  if (!access) return refresh ? { status: "recover" } : { status: "anonymous" };

  const result = await backendJson<unknown>("/auth/me", { bearerToken: access });
  if (!result.ok) {
    if (isAuthenticationFailure(result.error)) return refresh ? { status: "recover" } : { status: "anonymous" };
    if (result.error.kind === "forbidden") return { status: "forbidden" };
    return { status: "unavailable" };
  }
  const auth = parseAuthResponse(result.data);
  if (!auth || auth.accessToken !== null || auth.refreshToken !== null) return { status: "unavailable" };
  return auth.identity.status === "ACTIVE"
    ? { status: "active", identity: auth.identity }
    : { status: "signout" };
});
