import type { SessionIdentity } from "../session-types.ts";

export type EntryPath = "/admin/teams" | "/onboarding/team" | "/onboarding/waiting" | "/dashboard";
export type RouteRequirement = "authenticated" | "team" | "admin";

const entryPaths: readonly EntryPath[] = [
  "/admin/teams",
  "/onboarding/team",
  "/onboarding/waiting",
  "/dashboard",
];

export function canonicalEntryPath(identity: Pick<SessionIdentity, "role" | "teamId">): EntryPath {
  if (identity.role === "ADMIN") return "/admin/teams";
  if (identity.teamId !== null) return "/dashboard";
  return identity.role === "MANAGER" ? "/onboarding/team" : "/onboarding/waiting";
}

export function canOpenEntryPath(
  identity: Pick<SessionIdentity, "role" | "teamId">,
  path: string,
): path is EntryPath {
  if (!entryPaths.includes(path as EntryPath)) return false;
  if (path === "/admin/teams") return identity.role === "ADMIN";
  if (path === "/onboarding/team") return identity.role === "MANAGER" && identity.teamId === null;
  if (path === "/onboarding/waiting") return identity.role === "AGENT" && identity.teamId === null;
  return identity.role === "ADMIN" || identity.teamId !== null;
}

export function resolveEntryPath(
  identity: Pick<SessionIdentity, "role" | "teamId">,
  next: string | null,
): EntryPath {
  // shortcut: accepts exact registered entry routes only; expand when real pages and query policies are wired.
  return next !== null && canOpenEntryPath(identity, next) ? next : canonicalEntryPath(identity);
}

export function isNavigationActive(pathname: string, href: string): boolean {
  return pathname === href || pathname.startsWith(href + "/");
}

export function canEnterRoute(
  identity: Pick<SessionIdentity, "role" | "teamId">,
  requirement: RouteRequirement,
): boolean {
  if (requirement === "authenticated") return true;
  if (requirement === "admin") return identity.role === "ADMIN";
  return identity.role === "ADMIN" || identity.teamId !== null;
}
