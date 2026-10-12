import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const nextBin = join(root, "node_modules/next/dist/bin/next");
const backendCalls = [];
const identity = {
  userId: 7,
  fullName: "Ada Agent",
  email: "ada@example.test",
  role: "AGENT",
  dataScope: "OWN",
  status: "ACTIVE",
  teamId: null,
  teamName: null,
  teamCurrency: null,
  mustChangePassword: false,
};

function jwt(exp) {
  return `a.${Buffer.from(JSON.stringify({ exp })).toString("base64url")}.s`;
}

const successAccess = jwt(Math.floor(Date.now() / 1000) + 900);
const successRefresh = jwt(Math.floor(Date.now() / 1000) + 3600);
const refreshedAccess = jwt(Math.floor(Date.now() / 1000) + 1200);

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      if (!address || typeof address === "string") return reject(new Error("Could not bind proof server"));
      resolve(address.port);
    });
  });
}

function close(server) {
  return server.listening
    ? new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()))
    : Promise.resolve();
}

function sendJson(response, status, value) {
  response.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "set-cookie": "backend-cookie=must-not-leak; Path=/",
  });
  response.end(JSON.stringify(value));
}

async function requestBody(request) {
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  return Buffer.concat(chunks).toString("utf8");
}

const backend = createServer(async (request, response) => {
  const path = new URL(request.url ?? "/", "http://backend.test").pathname;
  const call = {
    path,
    method: request.method,
    authorization: request.headers.authorization,
    cookie: request.headers.cookie,
    contentLength: request.headers["content-length"],
    contentType: request.headers["content-type"],
  };
  backendCalls.push(call);
  if (path === "/api/auth/login" && request.method === "POST") {
    call.body = await requestBody(request);
    const body = JSON.parse(call.body);
    if (body.email === "fail@example.test") {
      sendJson(response, 401, { message: "wrong credentials" });
    } else if (body.email === "malformed@example.test") {
      sendJson(response, 200, { ...identity, accessToken: successAccess, refreshToken: "bad-token" });
    } else {
      sendJson(response, 200, { ...identity, accessToken: successAccess, refreshToken: successRefresh, tokenType: "Bearer", isActive: true });
    }
    return;
  }
  if (path === "/api/auth/me" && request.method === "GET") {
    if (call.authorization === `Bearer ${successAccess}` || call.authorization === `Bearer ${refreshedAccess}`) {
      sendJson(response, 200, { ...identity, accessToken: null, refreshToken: null, tokenType: "Bearer" });
    } else {
      sendJson(response, 401, { message: "expired access" });
    }
    return;
  }
  if (path === "/api/auth/refresh" && request.method === "POST") {
    call.body = await requestBody(request);
    const token = (call.authorization ?? "").replace(/^Bearer /, "");
    if (token === "refresh-400") sendJson(response, 400, { message: "invalid refresh" });
    else if (token === "refresh-401") sendJson(response, 401, { message: "invalid refresh" });
    else if (token === "refresh-403") sendJson(response, 403, { message: "invalid refresh" });
    else if (token === "refresh-408") sendJson(response, 408, { message: "temporarily timed out" });
    else if (token === "refresh-429") sendJson(response, 429, { message: "too many attempts" });
    else if (token === "refresh-503") sendJson(response, 503, { message: "temporarily unavailable" });
    else if (token === "refresh-malformed") sendJson(response, 200, { ...identity, accessToken: "bad-access", refreshToken: null });
    else sendJson(response, 200, { ...identity, accessToken: refreshedAccess, refreshToken: null, tokenType: "Bearer" });
    return;
  }
  sendJson(response, 404, { status: 404, error: "Not Found", message: "not found", path });
});

const backendPort = await listen(backend);
const webPort = await (async () => {
  const server = createServer();
  const port = await listen(server);
  await close(server);
  return port;
})();
const baseUrl = `http://127.0.0.1:${webPort}`;
const configuredOrigin = "https://crm.example.test";
const accessCookie = "__Host-estate-access";
const refreshCookie = "__Host-estate-refresh";
const env = {
  PATH: process.env.PATH ?? "",
  ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
  ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
  BACKEND_API_URL: `http://127.0.0.1:${backendPort}/api`,
  WEB_ORIGIN: configuredOrigin,
  NODE_ENV: "production",
  NEXT_TELEMETRY_DISABLED: "1",
};
const next = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(webPort)], {
  cwd: root,
  env,
  stdio: ["ignore", "pipe", "pipe"],
});
const logs = { value: "" };
for (const stream of [next.stdout, next.stderr]) {
  stream.setEncoding("utf8");
  stream.on("data", (part) => { logs.value = `${logs.value}${part}`.slice(-12_000); });
}
const watchdog = setTimeout(() => {
  console.error("FAIL session runtime proof exceeded its two-minute watchdog");
  next.kill("SIGKILL");
  process.exit(1);
}, 120_000);
watchdog.unref();

async function waitForNext() {
  const deadline = Date.now() + 30_000;
  while (Date.now() < deadline && next.exitCode === null) {
    try {
      const response = await fetch(`${baseUrl}/api/session/me`, { signal: AbortSignal.timeout(1_500) });
      if (response.status === 401) return;
      await response.arrayBuffer();
    } catch {
      await delay(200);
    }
  }
  throw new Error(`Next server was not ready: ${logs.value}`);
}

function originHeaders(cookie, extra = {}) {
  return { origin: configuredOrigin, ...(cookie ? { cookie } : {}), ...extra };
}

async function errorBody(response, status) {
  assert.equal(response.status, status);
  assert.equal(response.headers.get("x-crm-bff-error"), "1");
  assert.equal(response.headers.get("cache-control"), "private, no-store");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  return response.json();
}

try {
  await waitForNext();

  const callsBeforeRejectedWrites = backendCalls.length;
  const missingOrigin = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ email: "ada@example.test", password: "secret" }),
  });
  assert.equal((await errorBody(missingOrigin, 403)).error.code, "ORIGIN_REJECTED");
  const nullOrigin = await fetch(`${baseUrl}/api/session/logout`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=old`, { origin: "null" }),
  });
  assert.equal((await errorBody(nullOrigin, 403)).error.code, "ORIGIN_REJECTED");
  const crossSite = await fetch(`${baseUrl}/api/session/logout`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=old`, { "sec-fetch-site": "cross-site" }),
  });
  assert.equal((await errorBody(crossSite, 403)).error.code, "FETCH_SITE_REJECTED");
  assert.equal(backendCalls.length, callsBeforeRejectedWrites, "CSRF rejections never reach the backend");

  const badType = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "text/plain" }),
    body: "{}",
  });
  assert.equal((await errorBody(badType, 415)).error.code, "CONTENT_TYPE_REJECTED");
  const badBody = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "application/json" }),
    body: "[]",
  });
  assert.equal((await errorBody(badBody, 400)).error.code, "REQUEST_BODY_INVALID");
  const largeLogin = JSON.stringify({ email: "ada@example.test", password: "x".repeat(1024 * 1024) });
  const oversizedBody = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "application/json" }),
    body: largeLogin,
  });
  assert.equal((await errorBody(oversizedBody, 413)).error.code, "REQUEST_BODY_TOO_LARGE");
  const callsBeforeBodyRejections = backendCalls.length;
  const nonemptyRefresh = await fetch(`${baseUrl}/api/session/refresh`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${successRefresh}`, { "content-type": "application/json" }),
    body: "{}",
  });
  assert.equal((await errorBody(nonemptyRefresh, 400)).error.code, "REQUEST_BODY_NOT_ALLOWED");
  assert.equal(nonemptyRefresh.headers.getSetCookie().length, 0);
  const nonemptyLogout = await fetch(`${baseUrl}/api/session/logout`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${successRefresh}`, { "content-type": "application/json" }),
    body: "{}",
  });
  assert.equal((await errorBody(nonemptyLogout, 400)).error.code, "REQUEST_BODY_NOT_ALLOWED");
  assert.equal(nonemptyLogout.headers.getSetCookie().length, 0);
  assert.equal(backendCalls.length, callsBeforeBodyRejections, "oversized login and no-body route payloads never reach the backend");
  assert.equal(backendCalls.length, callsBeforeRejectedWrites, "invalid JSON/schema never reaches the backend");
  console.log("PASS session POST origin, Fetch Metadata, content type, schema, 1 MiB cap, and no-body route checks");

  const badLogin = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=old-access; ${refreshCookie}=old-refresh`, { "content-type": "application/json" }),
    body: JSON.stringify({ email: "fail@example.test", password: "wrong" }),
  });
  const badLoginWire = await errorBody(badLogin, 401);
  assert.equal(badLoginWire.error.kind, "unauthenticated");
  assert.equal(badLogin.headers.getSetCookie().length, 0, "failed login does not replace or expose the existing pair");
  const malformedLogin = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "application/json" }),
    body: JSON.stringify({ email: "malformed@example.test", password: "secret" }),
  });
  assert.equal((await errorBody(malformedLogin, 502)).error.code, "UPSTREAM_SESSION_INVALID");
  assert.equal(malformedLogin.headers.getSetCookie().length, 0, "malformed login pair writes neither cookie");

  const login = await fetch(`${baseUrl}/api/session/login`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "application/json" }),
    body: JSON.stringify({ email: "ada@example.test", password: "secret" }),
  });
  assert.equal(login.status, 200);
  const loginBody = await login.json();
  assert.deepEqual(loginBody, identity);
  assert.equal(JSON.stringify(loginBody).includes(successAccess), false);
  assert.equal(JSON.stringify(loginBody).includes(successRefresh), false);
  assert.equal(Object.hasOwn(loginBody, "isActive"), false);
  assert.equal(Object.hasOwn(loginBody, "tokenType"), false);
  const loginCookies = login.headers.getSetCookie();
  assert.equal(loginCookies.length, 2);
  assert.match(loginCookies[0], /^__Host-estate-access=/);
  assert.match(loginCookies[1], /^__Host-estate-refresh=/);
  for (const cookie of loginCookies) {
    assert.match(cookie, /HttpOnly/i);
    assert.match(cookie, /SameSite=Lax/i);
    assert.match(cookie, /Path=\//i);
    assert.match(cookie, /Secure/i, "HTTPS origin uses Secure cookies");
    assert.doesNotMatch(cookie, /Domain=/i, "__Host cookies omit Domain");
    assert.match(cookie, /Max-Age=[1-9]\d*/i);
    assert.doesNotMatch(cookie, /backend-cookie|tokenType/i);
  }
  const loginCall = backendCalls.findLast(({ path, method }) => path === "/api/auth/login" && method === "POST");
  assert.deepEqual(JSON.parse(loginCall.body), { email: "ada@example.test", password: "secret" });
  assert.equal(loginCall.cookie, undefined, "browser cookies do not reach the backend login route");
  console.log("PASS login validates and atomically sets an exp-bounded HttpOnly pair while returning only allow-listed identity");

  const callsBeforeDuplicateMe = backendCalls.length;
  const duplicateMe = await fetch(`${baseUrl}/api/session/me`, {
    headers: { cookie: `${accessCookie}=${successAccess}; ${accessCookie}=other` },
  });
  assert.equal((await errorBody(duplicateMe, 401)).error.code, "SESSION_REQUIRED");
  assert.equal(backendCalls.length, callsBeforeDuplicateMe, "duplicate access cookies are rejected locally");

  const me = await fetch(`${baseUrl}/api/session/me`, {
    headers: { cookie: `${accessCookie}=${successAccess}; ${refreshCookie}=${successRefresh}` },
  });
  assert.equal(me.status, 200);
  assert.deepEqual(await me.json(), identity);
  assert.equal(me.headers.getSetCookie().length, 0, "/me never writes or clears cookies");
  const meCall = backendCalls.findLast(({ path, method }) => path === "/api/auth/me" && method === "GET");
  assert.equal(meCall.authorization, `Bearer ${successAccess}`);
  assert.equal(meCall.cookie, undefined);
  console.log("PASS /me uses only the access bearer, rejects duplicate cookies, and is read-only");

  const refresh = await fetch(`${baseUrl}/api/session/refresh`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${successRefresh}`),
  });
  assert.equal(refresh.status, 200);
  const refreshBody = await refresh.json();
  assert.deepEqual(refreshBody, identity);
  assert.equal(JSON.stringify(refreshBody).includes(refreshedAccess), false);
  const refreshCookies = refresh.headers.getSetCookie();
  assert.equal(refreshCookies.length, 1, "null upstream refresh token retains the old refresh cookie without resetting its Max-Age");
  assert.match(refreshCookies[0], /^__Host-estate-access=/);
  assert.match(refreshCookies[0], /Secure/i);
  assert.doesNotMatch(refreshCookies[0], /Domain=/i);
  const refreshCall = backendCalls.findLast(({ path, method }) => path === "/api/auth/refresh" && method === "POST");
  assert.equal(refreshCall.authorization, `Bearer ${successRefresh}`);
  assert.equal(refreshCall.cookie, undefined);
  assert.ok(refreshCall.contentLength === undefined || refreshCall.contentLength === "0");
  assert.equal(refreshCall.contentType, undefined);
  assert.equal(refreshCall.body, "", "refresh sends no upstream body");

  for (const [token, status] of [["refresh-400", 400], ["refresh-401", 401], ["refresh-403", 403]]) {
    const invalid = await fetch(`${baseUrl}/api/session/refresh`, {
      method: "POST",
      headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${token}`),
    });
    const wire = await errorBody(invalid, status);
    assert.equal(wire.error.status, status, "preserve the backend HTTP status");
    assert.equal(invalid.headers.getSetCookie().length, 2, "invalid refresh clears both session cookies");
    assert.ok(invalid.headers.getSetCookie().every((cookie) => /Max-Age=0/i.test(cookie)));
    assert.ok(invalid.headers.getSetCookie().every((cookie) => /Secure/i.test(cookie) && /Path=\//i.test(cookie)));
  }

  for (const [token, status] of [["refresh-408", 408], ["refresh-429", 429], ["refresh-503", 503]]) {
    const transient = await fetch(`${baseUrl}/api/session/refresh`, {
      method: "POST",
      headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${token}`),
    });
    const wire = await errorBody(transient, status);
    assert.equal(wire.error.status, status);
    assert.equal(transient.headers.getSetCookie().length, 0, "transient failures retain both cookies");
  }

  const malformedRefresh = await fetch(`${baseUrl}/api/session/refresh`, {
    method: "POST",
    headers: originHeaders(`${refreshCookie}=refresh-malformed`),
  });
  assert.equal((await errorBody(malformedRefresh, 502)).error.code, "UPSTREAM_SESSION_INVALID");
  assert.equal(malformedRefresh.headers.getSetCookie().length, 0, "malformed upstream pair keeps existing cookies");
  console.log("PASS refresh sends only the refresh bearer, retains null refresh cookies, clears invalid credentials, and preserves transient cookies/status");

  const postMe = await fetch(`${baseUrl}/api/session/me`, {
    method: "POST",
    headers: originHeaders(null, { "content-type": "application/json" }),
    body: "{}",
  });
  assert.equal(postMe.status, 405);
  assert.equal(postMe.headers.get("allow"), "GET");
  const getLogin = await fetch(`${baseUrl}/api/session/login`);
  assert.equal(getLogin.status, 405);
  assert.equal(getLogin.headers.get("allow"), "POST");
  const unknown = await fetch(`${baseUrl}/api/session/not-a-session-operation`);
  assert.equal(unknown.status, 404);

  const logout = await fetch(`${baseUrl}/api/session/logout`, {
    method: "POST",
    headers: originHeaders(`${accessCookie}=${successAccess}; ${refreshCookie}=${successRefresh}`),
  });
  assert.equal(logout.status, 204);
  assert.equal(logout.headers.getSetCookie().length, 2);
  assert.ok(logout.headers.getSetCookie().every((cookie) => /Max-Age=0/i.test(cookie)));
  assert.ok(logout.headers.getSetCookie().every((cookie) => /^__Host-estate-(?:access|refresh)=/.test(cookie) && /Secure/i.test(cookie)));
  assert.equal(backendCalls.filter(({ path }) => path === "/api/auth/logout").length, 0, "logout is a local cookie clear only");
  console.log("PASS fixed routes return 405/Allow for wrong methods and HTTPS-configured logout clears __Host cookies locally without backend logout");
} finally {
  clearTimeout(watchdog);
  next.kill("SIGTERM");
  await Promise.race([
    new Promise((resolve) => next.once("exit", resolve)),
    delay(5_000).then(() => { if (next.exitCode === null) next.kill("SIGKILL"); }),
  ]);
  await close(backend);
}
