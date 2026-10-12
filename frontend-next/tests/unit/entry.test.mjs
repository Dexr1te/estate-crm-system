import assert from "node:assert/strict";
import test from "node:test";
import { canEnterRoute, canOpenEntryPath, canonicalEntryPath, isNavigationActive, resolveEntryPath } from "../../src/lib/navigation/entry.ts";

const identity = (role, teamId = null) => ({ role, teamId });

test("canonical entry follows current role and team membership", () => {
  assert.equal(canonicalEntryPath(identity("ADMIN")), "/admin/teams");
  assert.equal(canonicalEntryPath(identity("MANAGER")), "/onboarding/team");
  assert.equal(canonicalEntryPath(identity("AGENT")), "/onboarding/waiting");
  assert.equal(canonicalEntryPath(identity("MANAGER", 4)), "/dashboard");
  assert.equal(canonicalEntryPath(identity("AGENT", 4)), "/dashboard");
});

test("safe next overrides only a known route authorized for the verified identity", () => {
  assert.equal(resolveEntryPath(identity("ADMIN"), "/admin/teams"), "/admin/teams");
  assert.equal(resolveEntryPath(identity("ADMIN"), "/dashboard"), "/dashboard");
  assert.equal(resolveEntryPath(identity("AGENT"), "/onboarding/waiting"), "/onboarding/waiting");
  assert.equal(resolveEntryPath(identity("MANAGER", 4), "/dashboard"), "/dashboard");
  assert.equal(resolveEntryPath(identity("AGENT"), "/admin/teams"), "/onboarding/waiting");
  assert.equal(canOpenEntryPath(identity("ADMIN"), "/dashboard"), true);
});

test("navigation active state matches exact routes and slash-delimited descendants", () => {
  assert.equal(isNavigationActive("/proof/shell", "/proof/shell"), true);
  assert.equal(isNavigationActive("/proof/shell/child", "/proof/shell"), true);
  assert.equal(isNavigationActive("/proof/teammore", "/proof/team"), false);
});

test("safe next rejects external, encoded, ambiguous, and non-entry paths", () => {
  const agent = identity("AGENT", 4);
  for (const next of [
    "",
    "dashboard",
    "//evil.test",
    "https://evil.test",
    "/%2f%2fevil.test",
    "/%5cevil.test",
    "/admin/teams?next=%2f%2fevil.test",
    "/admin/teams#fragment",
    "/admin/teams/../dashboard",
    "/dashboard\\@evil.test",
    "/records/7",
  ]) {
    assert.equal(resolveEntryPath(agent, next), "/dashboard", next);
  }
  assert.equal(resolveEntryPath(agent, null), "/dashboard");
});

test("team and admin route requirements preserve the ADMIN exemption", () => {
  assert.equal(canEnterRoute(identity("ADMIN"), "team"), true);
  assert.equal(canEnterRoute(identity("AGENT"), "team"), false);
  assert.equal(canEnterRoute(identity("MANAGER", 4), "team"), true);
  assert.equal(canEnterRoute(identity("ADMIN"), "admin"), true);
  assert.equal(canEnterRoute(identity("MANAGER", 4), "admin"), false);
  assert.equal(canEnterRoute(identity("AGENT"), "authenticated"), true);
  assert.equal(canOpenEntryPath(identity("MANAGER"), "/onboarding/waiting"), false);
});
