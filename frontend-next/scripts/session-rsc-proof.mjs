import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const fixture = join(root, "tests/fixtures/runtime-app");
const nextBin = join(root, "node_modules/next/dist/bin/next");
const backendRequests = [];
const refreshedAccess = `a.${Buffer.from(JSON.stringify({ exp: Math.floor(Date.now() / 1000) + 600 })).toString("base64url")}.s`;
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

function runNext(args, env, logs) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [nextBin, ...args], {
      cwd: fixture,
      env,
      stdio: ["ignore", "pipe", "pipe"],
    });
    for (const stream of [child.stdout, child.stderr]) {
      stream.setEncoding("utf8");
      stream.on("data", (part) => { logs.value = `${logs.value}${part}`.slice(-12_000); });
    }
    child.once("error", reject);
    child.once("exit", (code, signal) => code === 0
      ? resolve()
      : reject(new Error(`Next ${args[0]} exited with ${code ?? signal}:\n${logs.value}`)));
  });
}

function json(response, status, value) {
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
  backendRequests.push({
    path,
    method: request.method,
    authorization: request.headers.authorization,
    cookie: request.headers.cookie,
    contentLength: request.headers["content-length"],
  });
  if (path === "/api/auth/refresh") {
    const body = await requestBody(request);
    backendRequests.at(-1).body = body;
    json(response, 200, { ...identity, accessToken: refreshedAccess, refreshToken: null, tokenType: "Bearer" });
    return;
  }
  if (path !== "/api/auth/me") {
    json(response, 404, { status: 404, error: "Not Found", message: "not found", path });
    return;
  }
  const bearer = request.headers.authorization ?? "";
  if (bearer === "Bearer expired-access") {
    json(response, 401, { message: "expired" });
  } else if (bearer === "Bearer outage-access") {
    json(response, 503, { message: "temporarily unavailable" });
  } else if (bearer === "Bearer inactive-access") {
    json(response, 200, { ...identity, status: "DEACTIVATED", accessToken: null, refreshToken: null });
  } else if (bearer === "Bearer active-access" || bearer === `Bearer ${refreshedAccess}`) {
    json(response, 200, { ...identity, accessToken: null, refreshToken: null });
  } else {
    json(response, 401, { message: "missing" });
  }
});

const backendPort = await listen(backend);
const webPort = await (async () => {
  const server = createServer();
  const port = await listen(server);
  await close(server);
  return port;
})();
const baseUrl = `http://127.0.0.1:${webPort}`;
const env = {
  PATH: process.env.PATH ?? "",
  ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
  ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
  BACKEND_API_URL: `http://127.0.0.1:${backendPort}/api`,
  WEB_ORIGIN: baseUrl,
  NODE_ENV: "production",
  NEXT_TELEMETRY_DISABLED: "1",
};
const buildLogs = { value: "" };
await runNext(["build"], env, buildLogs);

const next = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(webPort)], {
  cwd: fixture,
  env,
  stdio: ["ignore", "pipe", "pipe"],
});
const logs = { value: "" };
for (const stream of [next.stdout, next.stderr]) {
  stream.setEncoding("utf8");
  stream.on("data", (part) => { logs.value = `${logs.value}${part}`.slice(-12_000); });
}
const watchdog = setTimeout(() => {
  console.error("FAIL RSC session proof exceeded its two-minute watchdog");
  next.kill("SIGKILL");
  process.exit(1);
}, 120_000);
watchdog.unref();

async function waitForNext() {
  const deadline = Date.now() + 30_000;
  while (Date.now() < deadline && next.exitCode === null) {
    try {
      const response = await fetch(`${baseUrl}/session-proof`, { signal: AbortSignal.timeout(1_500) });
      if (response.status === 200) {
        await response.arrayBuffer();
        return;
      }
      await response.arrayBuffer();
    } catch {
      await delay(200);
    }
  }
  throw new Error(`Next fixture was not ready: ${logs.value}`);
}

async function page(cookie) {
  return fetch(`${baseUrl}/session-proof`, {
    headers: cookie ? { cookie } : {},
    signal: AbortSignal.timeout(8_000),
  });
}

try {
  await waitForNext();

  const anonymous = await page();
  const anonymousHtml = await anonymous.text();
  assert.equal(anonymous.status, 200);
  assert.match(anonymousHtml, /data-session="anonymous"/);
  assert.equal(backendRequests.length, 0, "anonymous RSC does not call the backend");

  const beforeDuplicateAccess = backendRequests.length;
  const duplicateAccess = await page("estate-dev-access=expired-access; estate-dev-access=active-access; estate-dev-refresh=refresh-sentinel");
  const duplicateAccessHtml = await duplicateAccess.text();
  assert.equal(duplicateAccess.status, 200);
  assert.match(duplicateAccessHtml, /data-session="recover"/);
  assert.doesNotMatch(duplicateAccessHtml, /PRIVATE_RSC_CONTENT|expired-access|active-access|refresh-sentinel/);
  assert.equal(backendRequests.length, beforeDuplicateAccess, "RSC rejects duplicate raw access-cookie names before forwarding a bearer");

  const beforeDuplicateRefresh = backendRequests.length;
  const duplicateRefresh = await page("estate-dev-access=expired-access; estate-dev-refresh=refresh-one; estate-dev-refresh=refresh-two");
  const duplicateRefreshHtml = await duplicateRefresh.text();
  assert.equal(duplicateRefresh.status, 200);
  assert.match(duplicateRefreshHtml, /data-session="anonymous"/);
  assert.doesNotMatch(duplicateRefreshHtml, /PRIVATE_RSC_CONTENT|expired-access|refresh-one|refresh-two/);
  assert.deepEqual(backendRequests.slice(beforeDuplicateRefresh).map(({ path, authorization }) => ({ path, authorization })), [
    { path: "/api/auth/me", authorization: "Bearer expired-access" },
  ], "duplicate raw refresh-cookie names cannot authorize RSC recovery");

  const beforeExpired = backendRequests.length;
  const recovering = await page("estate-dev-access=expired-access; estate-dev-refresh=refresh-sentinel");
  const recoveringHtml = await recovering.text();
  assert.equal(recovering.status, 200);
  assert.match(recoveringHtml, /data-session="recover"/);
  assert.doesNotMatch(recoveringHtml, /PRIVATE_RSC_CONTENT|expired-access|refresh-sentinel/);
  assert.equal(recovering.headers.getSetCookie().length, 0, "RSC verification never writes cookies");
  assert.deepEqual(backendRequests.slice(beforeExpired).map(({ path, authorization, cookie }) => ({ path, authorization, cookie })), [
    { path: "/api/auth/me", authorization: "Bearer expired-access", cookie: undefined },
  ]);

  const refresh = await fetch(`${baseUrl}/api/session/refresh`, {
    method: "POST",
    headers: { origin: baseUrl, cookie: "estate-dev-refresh=refresh-sentinel" },
    signal: AbortSignal.timeout(8_000),
  });
  assert.equal(refresh.status, 200);
  const refreshBody = await refresh.json();
  assert.deepEqual(refreshBody, identity, "refresh returns only the sanitized identity");
  const refreshCookies = refresh.headers.getSetCookie();
  assert.equal(refreshCookies.length, 1, "a null upstream refresh token leaves the old refresh cookie untouched");
  assert.match(refreshCookies[0], /^estate-dev-access=/);
  assert.match(refreshCookies[0], /HttpOnly/i);
  assert.match(refreshCookies[0], /SameSite=Lax/i);
  assert.doesNotMatch(refreshCookies[0], /backend-cookie|Secure|Domain=/i);
  assert.equal(JSON.stringify(refreshBody).includes(refreshedAccess), false);
  const refreshCall = backendRequests.find(({ path }) => path === "/api/auth/refresh");
  assert.equal(refreshCall?.method, "POST");
  assert.equal(refreshCall?.authorization, "Bearer refresh-sentinel");
  assert.equal(refreshCall?.cookie, undefined);
  assert.ok(refreshCall?.contentLength === undefined || refreshCall.contentLength === "0");
  assert.equal(refreshCall?.body, "", "refresh has no upstream body");

  const beforeActive = backendRequests.length;
  const active = await page(`estate-dev-access=${refreshedAccess}; estate-dev-refresh=refresh-sentinel`);
  const activeHtml = await active.text();
  assert.equal(active.status, 200);
  assert.match(activeHtml, /data-session="active"/);
  assert.match(activeHtml, /Ada Agent/);
  assert.match(activeHtml, /PRIVATE_RSC_CONTENT/);
  assert.doesNotMatch(activeHtml, /refresh-sentinel/);
  assert.equal(activeHtml.includes(refreshedAccess), false);
  assert.equal(active.headers.getSetCookie().length, 0);
  assert.equal(backendRequests.slice(beforeActive).length, 1);

  const beforeOutage = backendRequests.length;
  const outage = await page("estate-dev-access=outage-access; estate-dev-refresh=refresh-sentinel");
  const outageHtml = await outage.text();
  assert.equal(outage.status, 200);
  assert.match(outageHtml, /data-session="unavailable"/);
  assert.doesNotMatch(outageHtml, /PRIVATE_RSC_CONTENT|outage-access|refresh-sentinel/);
  assert.equal(outage.headers.getSetCookie().length, 0);
  assert.equal(backendRequests.slice(beforeOutage).length, 1, "an outage does not trigger refresh or retry");

  const inactive = await page("estate-dev-access=inactive-access; estate-dev-refresh=refresh-sentinel");
  const inactiveHtml = await inactive.text();
  assert.equal(inactive.status, 200);
  assert.match(inactiveHtml, /data-session="signout"/);
  assert.doesNotMatch(inactiveHtml, /PRIVATE_RSC_CONTENT|inactive-access|refresh-sentinel/);
  assert.equal(inactive.headers.getSetCookie().length, 0, "non-active RSC state asks the client boundary to POST logout");

  assert.ok(backendRequests.every(({ path }) => path === "/api/auth/me" || path === "/api/auth/refresh"), "fixture uses only the fixed session upstream operations");
  console.log("PASS real Next server RSC output excludes private content/tokens before verification; two same-render reads coalesce, separate cookie states stay isolated, verification is read-only, and explicit refresh updates the access cookie");
  console.log("NOT RUN browser proof: Safari Remote Automation is disabled; this fixture verifies server RSC output only");
} finally {
  clearTimeout(watchdog);
  next.kill("SIGTERM");
  await Promise.race([
    new Promise((resolve) => next.once("exit", resolve)),
    delay(5_000).then(() => { if (next.exitCode === null) next.kill("SIGKILL"); }),
  ]);
  await close(backend);
}
