import "server-only";

import { redirect } from "next/navigation";
import { SessionRecovery } from "../../features/auth/session-recovery.tsx";
import type { SessionIdentity } from "../session-types.ts";
import { canEnterRoute, canonicalEntryPath, type RouteRequirement } from "../navigation/entry.ts";
import { readRscSession, type RscSessionState } from "./rsc-session.ts";

type UnverifiedSession = Exclude<RscSessionState, { status: "active" }>;

export type RscRouteAccess =
  | { status: "allowed"; identity: SessionIdentity }
  | UnverifiedSession
  | { status: "redirect"; destination: ReturnType<typeof canonicalEntryPath> };

// Call at the page before private reads; a parent layout cannot stop parallel server rendering.
export async function readRscRouteAccess(requirement: RouteRequirement): Promise<RscRouteAccess> {
  const session = await readRscSession();
  if (session.status !== "active") return session;
  if (canEnterRoute(session.identity, requirement)) return { status: "allowed", identity: session.identity };
  if (requirement === "team" || requirement === "admin") {
    return { status: "redirect", destination: canonicalEntryPath(session.identity) };
  }
  return { status: "forbidden" };
}

export function RouteAccessFallback({ access }: { access: Exclude<RscRouteAccess, { status: "allowed" }> }) {
  if (access.status === "redirect") redirect(access.destination);
  if (access.status === "anonymous") redirect("/login");
  return <SessionRecovery reason={access.status} />;
}
