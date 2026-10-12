import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = fileURLToPath(new URL("../..", import.meta.url));

function run(source) {
  const result = spawnSync(process.execPath, ["--experimental-strip-types", "--input-type=module", "-e", source], {
    cwd: root,
    encoding: "utf8",
    timeout: 10_000,
    env: { ...process.env },
  });
  assert.equal(result.status, 0, result.stderr);
}

const setup = `
  import assert from "node:assert/strict";
  globalThis.window = { location: { origin: "http://127.0.0.1:3000" } };
  const identity = {
    userId: 7, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE",
    teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false,
  };
  const success = (value = identity) => Response.json(value);
  const error = (kind, status, code = "TEST_ERROR") => new Response(JSON.stringify({
    ok: false,
    error: { kind, status, code, format: "none", message: "Safe test response." },
  }), { status, headers: { "content-type": "application/json", "x-crm-bff-error": "1" } });
  const { runResourceRequest, loginSession, logoutSession, sessionMe } = await import("./src/features/auth/session-client.ts");
`;

test("parallel resource 401 responses share one refresh and replay once", () => {
  run(`${setup}
    const calls = [];
    const resourceCounts = new Map();
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/me") return error("unauthenticated", 401);
      if (path === "/api/session/refresh") return success();
      if (path.startsWith("/api/backend/")) {
        const count = (resourceCounts.get(path) ?? 0) + 1;
        resourceCounts.set(path, count);
        return count === 1 ? error("unauthenticated", 401) : success({ id: count });
      }
      throw new Error("unexpected path " + path);
    };
    const results = await Promise.all([
      runResourceRequest(() => import("./src/lib/api/transport.ts").then(({ bffJson }) => bffJson("/api/backend/deals/1"))),
      runResourceRequest(() => import("./src/lib/api/transport.ts").then(({ bffJson }) => bffJson("/api/backend/clients/1"))),
    ]);
    assert.ok(results.every((result) => result.ok));
    assert.equal(calls.filter((path) => path === "/api/session/me").length, 1);
    assert.equal(calls.filter((path) => path === "/api/session/refresh").length, 1);
    assert.equal(calls.filter((path) => path.startsWith("/api/backend/")).length, 4);
  `);
});

test("unknown 403 probes me and does not refresh a valid session; structured 403 never probes", () => {
  run(`${setup}
    const calls = [];
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/backend/deals/1") return error("verification-needed", 403);
      if (path === "/api/session/me") return success();
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const unknown = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(unknown.ok, false);
    assert.equal(unknown.error.kind, "forbidden");
    assert.deepEqual(calls, ["/api/backend/deals/1", "/api/session/me"]);

    calls.length = 0;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/backend/deals/1") return error("forbidden", 403, "TEAM_REQUIRED");
      throw new Error("unexpected path " + path);
    };
    const denied = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(denied.ok, false);
    assert.equal(denied.error.kind, "forbidden");
    assert.deepEqual(calls, ["/api/backend/deals/1"]);
  `);
});

test("logout waits for in-flight refresh, closes replay, and discards stale identity", () => {
  run(`${setup}
    const calls = [];
    let completeRefresh;
    let refreshStarted;
    const started = new Promise((resolve) => { refreshStarted = resolve; });
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success();
      if (path === "/api/backend/deals/1") return error("unauthenticated", 401);
      if (path === "/api/session/me") return error("unauthenticated", 401);
      if (path === "/api/session/refresh") {
        refreshStarted();
        return new Promise((resolve) => { completeRefresh = resolve; });
      }
      if (path === "/api/session/logout") return new Response(null, { status: 204 });
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const request = runResourceRequest(() => bffJson("/api/backend/deals/1"));
    await started;
    const logout = logoutSession();
    completeRefresh(success());
    const [resourceResult, logoutResult] = await Promise.all([request, logout]);
    assert.equal(resourceResult.ok, false);
    assert.equal(resourceResult.error.kind, "cancelled");
    assert.equal(logoutResult.ok, true);
    assert.equal(calls.filter((path) => path === "/api/backend/deals/1").length, 1, "no resource replay after logout begins");
    assert.ok(calls.indexOf("/api/session/logout") > calls.indexOf("/api/session/refresh"));
  `);
});

test("network uncertainty and direct login failures never enter resource recovery", () => {
  run(`${setup}
    const calls = [];
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/backend/deals/1") throw new TypeError("socket closed after send");
      if (path === "/api/session/login") return error("unauthenticated", 401, "LOGIN_REJECTED");
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const uncertain = await runResourceRequest(() => bffJson("/api/backend/deals/1", { method: "POST", body: "{}" }));
    assert.equal(uncertain.ok, false);
    assert.equal(uncertain.error.kind, "network");
    const login = await loginSession("ada@example.test", "bad-password");
    assert.equal(login.ok, false);
    assert.deepEqual(calls, ["/api/backend/deals/1", "/api/session/login"]);
  `);
});

test("refresh 400 ends the client session while 408 and 429 surface as transient recovery failures", () => {
  run(`${setup}
    const calls = [];
    let refreshStatus = 400;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success();
      if (path === "/api/backend/deals/1") return error("unauthenticated", 401);
      if (path === "/api/session/me") return error("unauthenticated", 401);
      if (path === "/api/session/refresh") {
        if (refreshStatus === 400) return error("http", 400, "REFRESH_REJECTED");
        if (refreshStatus === 408) return error("http", 408, "BACKEND_TIMEOUT");
        return error("rate-limited", 429, "TOO_MANY_REQUESTS");
      }
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const { getSessionGeneration, isSessionCurrent, recoverRscSession } = await import("./src/features/auth/session-client.ts");
    const { sessionRecoveryPresentation } = await import("./src/features/auth/session-recovery-state.ts");
    const initialGeneration = getSessionGeneration();
    const invalid = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(invalid.ok, false);
    assert.equal(invalid.error.status, 400);
    assert.equal(isSessionCurrent(initialGeneration), false, "invalid refresh closes the session generation");
    assert.equal(calls.filter((path) => path === "/api/backend/deals/1").length, 1);
    const closedRsc = await recoverRscSession();
    assert.equal(closedRsc.terminal, true, "an already-closed session cannot leave an RSC recovery island retrying refresh");
    assert.equal(sessionRecoveryPresentation("recover", Boolean(closedRsc.terminal)).canRetry, false);

    await loginSession("ada@example.test", "password");
    refreshStatus = 408;
    const timeoutGeneration = getSessionGeneration();
    const timeout = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(timeout.ok, false);
    assert.equal(timeout.error.status, 408);
    assert.equal(isSessionCurrent(timeoutGeneration), true, "408 keeps the session available for a later attempt");

    refreshStatus = 429;
    const rateLimited = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(rateLimited.ok, false);
    assert.equal(rateLimited.error.kind, "rate-limited");
    assert.equal(rateLimited.error.status, 429);
    assert.equal(calls.filter((path) => path === "/api/backend/deals/1").length, 3);
  `);
});

test("a refresh identity change advances generation and prevents replay as another user", () => {
  run(`${setup}
    const calls = [];
    const otherIdentity = { ...identity, userId: 8, fullName: "Grace Manager", role: "MANAGER", dataScope: "TEAM", teamId: 3 };
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success();
      if (path === "/api/backend/deals/1") return error("unauthenticated", 401);
      if (path === "/api/session/me") return error("unauthenticated", 401);
      if (path === "/api/session/refresh") return success(otherIdentity);
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const { getSessionGeneration } = await import("./src/features/auth/session-client.ts");
    const login = await loginSession("ada@example.test", "password");
    assert.equal(login.ok, true);
    const initialGeneration = getSessionGeneration();
    const result = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
    assert.equal(result.ok, false);
    assert.equal(result.error.kind, "cancelled");
    assert.ok(getSessionGeneration() > initialGeneration);
    assert.equal(calls.filter((path) => path === "/api/backend/deals/1").length, 1);
  `);
});

test("session me is a direct read and never triggers refresh; late me identity is discarded on logout", () => {
  run(`${setup}
    const calls = [];
    let completeMe;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success();
      if (path === "/api/session/me") return new Promise((resolve) => { completeMe = resolve; });
      if (path === "/api/session/logout") return new Response(null, { status: 204 });
      throw new Error("unexpected path " + path);
    };
    const loggedIn = await loginSession("ada@example.test", "password");
    assert.equal(loggedIn.ok, true);
    const me = sessionMe();
    while (!completeMe) await new Promise((resolve) => setTimeout(resolve, 0));
    const logout = logoutSession();
    completeMe(error("unauthenticated", 401));
    const [meResult, logoutResult] = await Promise.all([me, logout]);
    assert.equal(meResult.ok, false);
    assert.equal(meResult.error.kind, "cancelled");
    assert.equal(logoutResult.ok, true);
    assert.equal(calls.filter((path) => path === "/api/session/refresh").length, 0);
    assert.equal(calls.filter((path) => path === "/api/session/me").length, 1);
  `);
});

test("successful browser login keeps the lifecycle closed and replaces the current document", () => {
  run(`
    import assert from "node:assert/strict";
    const identity = {
      userId: 7, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE",
      teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false,
    };
    const replacements = [];
    globalThis.window = { location: { origin: "http://127.0.0.1:3000", href: "http://127.0.0.1:3000/proof/shell", replace: (value) => replacements.push(value) } };
    globalThis.fetch = async () => Response.json(identity);
    const { loginSession, getSessionLifecycle } = await import("./src/features/auth/session-client.ts");
    const result = await loginSession("ada@example.test", "password");
    assert.equal(result.ok, true);
    assert.deepEqual(replacements, ["http://127.0.0.1:3000/proof/shell"]);
    assert.equal(getSessionLifecycle().closing, true, "private children remain withheld until the fresh document loads");
  `);
});

test("a stale RSC identity is reconciled against current /me and cannot roll the client back", () => {
  run(`${setup}
    const other = { ...identity, userId: 8, fullName: "Grace Manager", email: "grace@example.test", role: "MANAGER", dataScope: "TEAM", teamId: 3 };
    const calls = [];
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login" || path === "/api/session/me") return Response.json(other);
      throw new Error("unexpected path " + path);
    };
    const { getSessionGeneration, getSessionLifecycle, reconcileRscSession } = await import("./src/features/auth/session-client.ts");
    assert.equal((await loginSession("grace@example.test", "password")).ok, true);
    const before = getSessionGeneration();
    assert.equal(await reconcileRscSession(identity), "mismatch", "RSC A is stale while /me verifies B");
    assert.equal(getSessionLifecycle().identityScope, (await import("./src/lib/session-types.ts")).sessionIdentityScope(other));
    assert.equal(getSessionGeneration(), before, "the same current B identity does not advance again");
    assert.deepEqual(calls, ["/api/session/login", "/api/session/me"]);
  `);
});

test("RSC verification outages stay withheld and a manual retry rechecks the live identity", () => {
  run(`${setup}
    const other = { ...identity, userId: 8, fullName: "Grace Manager", email: "grace@example.test", role: "MANAGER", dataScope: "TEAM", teamId: 3 };
    let available = false;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      if (path === "/api/session/login") return Response.json(other);
      if (path === "/api/session/me") return available ? Response.json(other) : error("unavailable", 503);
      throw new Error("unexpected path " + path);
    };
    const { getSessionLifecycle, reconcileRscSession } = await import("./src/features/auth/session-client.ts");
    assert.equal((await loginSession("grace@example.test", "password")).ok, true);
    const failed = await reconcileRscSession(identity);
    assert.equal(failed, "unavailable");
    assert.equal(getSessionLifecycle().identityScope, (await import("./src/lib/session-types.ts")).sessionIdentityScope(other));
    available = true;
    const retried = await reconcileRscSession(identity);
    assert.equal(retried, "mismatch", "a successful /me for B keeps stale RSC A withheld so the caller can refresh");
    assert.equal(getSessionLifecycle().identityScope, (await import("./src/lib/session-types.ts")).sessionIdentityScope(other));
  `);
});

test("direct session me authentication errors do not recurse into refresh", () => {
  run(`${setup}
    const calls = [];
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success();
      if (path === "/api/session/me") return error("unauthenticated", 401);
      throw new Error("unexpected path " + path);
    };
    await loginSession("ada@example.test", "password");
    const result = await sessionMe();
    assert.equal(result.ok, false);
    assert.equal(result.error.kind, "unauthenticated");
    assert.deepEqual(calls, ["/api/session/login", "/api/session/me"]);
  `);
});

test("user subject, email, team, role, scope, and status identity changes invalidate resource replay", () => {
  run(`${setup}
    const calls = [];
    let nextIdentity = identity;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.push(path);
      if (path === "/api/session/login") return success(identity);
      if (path === "/api/backend/deals/1") return error("unauthenticated", 401);
      if (path === "/api/session/me") return error("unauthenticated", 401);
      if (path === "/api/session/refresh") return success(nextIdentity);
      if (path === "/api/session/logout") return new Response(null, { status: 204 });
      throw new Error("unexpected path " + path);
    };
    const { bffJson } = await import("./src/lib/api/transport.ts");
    const { getSessionGeneration } = await import("./src/features/auth/session-client.ts");
    const cases = [
      ["user", { userId: 8 }],
      ["email", { email: "ada+new@example.test" }],
      ["team", { teamId: 4 }],
      ["role", { role: "MANAGER" }],
      ["scope", { dataScope: "TEAM" }],
      ["status", { status: "DEACTIVATED" }],
      ["must-change-password", { mustChangePassword: true }],
    ];
    for (const [label, change] of cases) {
      calls.length = 0;
      nextIdentity = { ...identity, ...change };
      const login = await loginSession("ada@example.test", "password");
      assert.equal(login.ok, true, label + " setup");
      const before = getSessionGeneration();
      const result = await runResourceRequest(() => bffJson("/api/backend/deals/1"));
      assert.equal(result.ok, false, label);
      assert.equal(result.error.kind, "cancelled", label);
      assert.ok(getSessionGeneration() > before, label + " advances generation");
      assert.equal(calls.filter((path) => path === "/api/backend/deals/1").length, 1, label + " does not replay");
      assert.equal(calls.filter((path) => path === "/api/session/refresh").length, 1, label);
      if (change.status === "DEACTIVATED") assert.equal(calls.at(-1), "/api/session/logout");
    }
  `);
});

test("an active RSC confirmation resets one recovery attempt; repeated recovery markup does not loop", () => {
  run(`${setup}
    let refreshCalls = 0;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      if (path === "/api/session/refresh") {
        refreshCalls += 1;
        return success();
      }
      throw new Error("unexpected path " + path);
    };
    const { recoverRscSession, confirmRscSession } = await import("./src/features/auth/session-client.ts");
    const first = await recoverRscSession();
    assert.equal(first.refreshed, true);
    const repeated = await recoverRscSession();
    assert.equal(repeated.refreshed, false);
    assert.equal(refreshCalls, 1, "recover markup cannot automatically retry itself");
    confirmRscSession(identity);
    const afterActiveConfirmation = await recoverRscSession();
    assert.equal(afterActiveConfirmation.refreshed, true);
    assert.equal(refreshCalls, 2, "a confirmed active RSC render opens one attempt for a later expiry");
  `);
});

test("an unsuccessful RSC recovery makes no automatic second POST without active confirmation", () => {
  run(`${setup}
    let refreshCalls = 0;
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      if (path === "/api/session/refresh") {
        refreshCalls += 1;
        return error("unavailable", 503, "BACKEND_UNAVAILABLE");
      }
      throw new Error("unexpected path " + path);
    };
    const { recoverRscSession } = await import("./src/features/auth/session-client.ts");
    const first = await recoverRscSession();
    assert.equal(first.refreshed, false);
    const repeated = await recoverRscSession();
    assert.equal(repeated.refreshed, false);
    assert.equal(refreshCalls, 1);
  `);
});

test("terminal RSC refresh failure requires sign-in and offers no retry; transient failure remains retryable", () => {
  run(`${setup}
    const { sessionRecoveryPresentation } = await import("./src/features/auth/session-recovery-state.ts");
    const expired = sessionRecoveryPresentation("recover", true);
    assert.equal(expired.canRetry, false);
    assert.match(expired.message, /sign in is required/i);
    const checking = sessionRecoveryPresentation("recover", false, false);
    assert.equal(checking.canRetry, false);
    assert.match(checking.message, /checking your session/i);
    const transient = sessionRecoveryPresentation("recover", false, true);
    assert.equal(transient.canRetry, true);
    assert.match(transient.message, /could not verify your session/i);
  `);
});
