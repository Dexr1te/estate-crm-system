import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = fileURLToPath(new URL("../..", import.meta.url));

test("session cookie selection rejects duplicates and preserves B04 bearer compatibility", () => {
  const source = `
    import assert from "node:assert/strict";
    import { NextRequest } from "next/server.js";
    import { accessCookieName, readAccessBearer, readRefreshBearer, refreshCookieName } from "./src/lib/server/session.ts";
    process.env.BACKEND_API_URL = "http://127.0.0.1:8080/api";
    process.env.WEB_ORIGIN = "http://localhost:3000";
    assert.equal(accessCookieName("https://crm.example"), "__Host-estate-access");
    assert.equal(refreshCookieName("https://crm.example"), "__Host-estate-refresh");
    assert.equal(accessCookieName("http://localhost:3000"), "estate-dev-access");
    assert.equal(refreshCookieName("http://127.0.0.1:3000"), "estate-dev-refresh");
    assert.equal(accessCookieName("http://[::1]:3000"), "estate-dev-access");
    assert.throws(() => accessCookieName("http://crm.example"), /must use HTTPS/);
    const one = new NextRequest("http://localhost:3000/", { headers: { cookie: "estate-dev-access=opaque-test-token" } });
    assert.equal(readAccessBearer(one, "http://localhost:3000"), "opaque-test-token");
    assert.equal(readRefreshBearer(one, "http://localhost:3000"), null);
    const duplicate = new NextRequest("http://localhost:3000/", {
      headers: { cookie: "estate-dev-access=first; estate-dev-access=second" },
    });
    assert.equal(readAccessBearer(duplicate, "http://localhost:3000"), null);
    const malformed = new NextRequest("http://localhost:3000/", { headers: { cookie: "estate-dev-access=bad%value" } });
    assert.equal(readAccessBearer(malformed, "http://localhost:3000"), null);
  `;
  const result = spawnSync(process.execPath, ["--conditions=react-server", "--experimental-strip-types", "--input-type=module", "-e", source], {
    cwd: root,
    encoding: "utf8",
    timeout: 10_000,
    env: { ...process.env, BACKEND_API_URL: "http://127.0.0.1:8080/api", WEB_ORIGIN: "http://localhost:3000" },
  });
  assert.equal(result.status, 0, result.stderr);
});

test("session cookie writes use bounded JWT expiry hints and keep null refresh tokens untouched", () => {
  const source = `
    import assert from "node:assert/strict";
    import { NextResponse } from "next/server.js";
    import { clearSessionCookies, cookieMaxAge, parseAuthResponse, setRefreshedSessionCookies, setSessionCookies } from "./src/lib/server/session.ts";
    const token = (exp) => "header." + Buffer.from(JSON.stringify({ exp })).toString("base64url") + ".signature";
    const now = Date.now();
    const access = token(Math.floor(now / 1000) + 300);
    const refresh = token(Math.floor(now / 1000) + 1200);
    assert.equal(cookieMaxAge(access, now), 299);
    assert.equal(cookieMaxAge("malformed", now), null);
    const response = NextResponse.json({ ok: true });
    assert.equal(setSessionCookies(response, access, refresh, "https://crm.example"), true);
    const cookies = response.headers.getSetCookie();
    assert.equal(cookies.length, 2);
    for (const item of cookies) {
      assert.match(item, /HttpOnly/i);
      assert.match(item, /Secure/i);
      assert.match(item, /SameSite=Lax/i);
      assert.match(item, /Path=\\//i);
      assert.doesNotMatch(item, /Domain=/i);
    }
    assert.match(cookies[0], /^__Host-estate-access=/);
    assert.match(cookies[1], /^__Host-estate-refresh=/);
    const refreshOnly = NextResponse.json({ ok: true });
    assert.equal(setRefreshedSessionCookies(refreshOnly, access, null, "https://crm.example"), true);
    assert.equal(refreshOnly.headers.getSetCookie().length, 1, "null refresh must not rewrite or extend the refresh cookie");
    assert.match(refreshOnly.headers.getSetCookie()[0], /^__Host-estate-access=/);
    const invalidPair = NextResponse.json({ ok: true });
    assert.equal(setSessionCookies(invalidPair, "invalid", refresh, "https://crm.example"), false);
    assert.equal(invalidPair.headers.getSetCookie().length, 0, "validate both tokens before writing either cookie");
    const unsignedPair = NextResponse.json({ ok: true });
    assert.equal(setSessionCookies(unsignedPair, access, "header.payload", "https://crm.example"), false);
    assert.equal(unsignedPair.headers.getSetCookie().length, 0, "a JWT-shaped token needs all three non-empty segments");
    const cleared = NextResponse.json({ ok: true });
    clearSessionCookies(cleared, "https://crm.example");
    assert.equal(cleared.headers.getSetCookie().length, 2);
    assert.ok(cleared.headers.getSetCookie().every((item) => /Max-Age=0/i.test(item)));
    const identity = {
      userId: 7, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE",
      teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false,
      accessToken: access, refreshToken: refresh, tokenType: "Bearer", isActive: true,
    };
    const auth = parseAuthResponse(identity);
    assert.ok(auth);
    assert.equal(auth.identity.teamId, null);
    assert.equal(Object.hasOwn(auth.identity, "accessToken"), false);
    assert.equal(Object.hasOwn(auth.identity, "isActive"), false);
    assert.equal(JSON.stringify(auth.identity).includes(access), false);
    assert.equal(JSON.stringify(auth.identity).includes(refresh), false);
  `;
  const result = spawnSync(process.execPath, ["--conditions=react-server", "--experimental-strip-types", "--input-type=module", "-e", source], {
    cwd: root,
    encoding: "utf8",
    timeout: 10_000,
    env: { ...process.env, BACKEND_API_URL: "http://127.0.0.1:8080/api", WEB_ORIGIN: "https://crm.example" },
  });
  assert.equal(result.status, 0, result.stderr);
});
