import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { mkdir, writeFile } from "node:fs/promises";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { chromium } from "playwright-core";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const fixture = join(root, "tests/fixtures/runtime-app");
const nextBin = join(root, "node_modules/next/dist/bin/next");
const chromePath = process.env.B08_BROWSER_EXECUTABLE || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const outputDir = process.env.B08_PROOF_OUTPUT_DIR || "/private/tmp/estate-crm-next-b08-evidence/query-browser";
const backendRequests = [];
const privateResponses = [];
const report = {
  status: "RUNNING",
  runtime: { node: process.version, playwrightCore: "1.64.0", chromePath },
  cases: [],
  backend: [],
};

function tokenFor(nonce) {
  const payload = Buffer.from(JSON.stringify({ exp: Math.floor(Date.now() / 1000) + 3600, nonce })).toString("base64url");
  return `a.${payload}.s`;
}

const tokenA = "agent-A";
const tokenB = "agent-B";
const tokenAAfterLogin = tokenFor("same-user-new-login");
const refreshAAfterLogin = tokenFor("same-user-new-refresh");
const identities = {
  [tokenA]: { userId: 71, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE", teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false },
  [tokenB]: { userId: 82, fullName: "Morgan Manager", email: "morgan@example.test", role: "MANAGER", dataScope: "TEAM", status: "ACTIVE", teamId: 9, teamName: "Cedar Realty", teamCurrency: "KZT", mustChangePassword: false },
  [tokenAAfterLogin]: { userId: 71, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE", teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false },
};
const signals = [];

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      if (!address || typeof address === "string") return reject(new Error("Could not bind B08 proof server"));
      resolve(address.port);
    });
  });
}

function close(server) {
  return server.listening
    ? new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()))
    : Promise.resolve();
}

function json(response, status, value) {
  response.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
    "set-cookie": "backend-cookie=must-not-leak; Path=/",
  });
  response.end(JSON.stringify(value));
}

async function requestBody(request) {
  const parts = [];
  for await (const part of request) parts.push(part);
  return Buffer.concat(parts).toString("utf8");
}

function pageResponse(row, pageNumber = 0) {
  return {
    content: [{
      id: pageNumber + 1,
      fullName: row,
      email: "private@example.test",
      phone: "+15555550123",
      notes: "PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE",
      budgetMin: 123.450000000000000000000,
    }],
    totalElements: 41,
    totalPages: 3,
    number: pageNumber,
    size: 20,
    first: pageNumber === 0,
    last: pageNumber === 2,
    pageable: { implementation: "discarded" },
    sort: { implementation: "discarded" },
  };
}

const backend = createServer(async (request, response) => {
  const url = new URL(request.url || "/", "http://backend.test");
  const bearer = (request.headers.authorization || "").replace(/^Bearer /, "");
  const identity = identities[bearer];
  const entry = {
    path: url.pathname,
    search: url.search,
    method: request.method,
    principal: bearer === tokenA ? "A-old" : bearer === tokenAAfterLogin ? "A-new" : bearer === tokenB ? "B" : "unknown",
    cookieForwarded: request.headers.cookie !== undefined,
  };
  backendRequests.push(entry);

  if (url.pathname === "/api/auth/login") {
    entry.body = await requestBody(request);
    if (entry.body !== JSON.stringify({ email: "ada@example.test", password: "proof-password" })) {
      json(response, 401, { message: "bad credentials" });
      return;
    }
    json(response, 200, {
      ...identities[tokenAAfterLogin],
      accessToken: tokenAAfterLogin,
      refreshToken: refreshAAfterLogin,
      tokenType: "Bearer",
    });
    return;
  }

  if (url.pathname === "/api/auth/me") {
    if (!identity) {
      json(response, 401, { status: 401, error: "Unauthorized", message: "unauthenticated", path: url.pathname });
      return;
    }
    json(response, 200, { ...identity, accessToken: null, refreshToken: null, tokenType: "Bearer" });
    return;
  }

  if (url.pathname !== "/api/clients") {
    json(response, 404, { status: 404, error: "Not Found", message: "not found", path: url.pathname });
    return;
  }
  if (!identity) {
    json(response, 401, { status: 401, error: "Unauthorized", message: "unauthenticated", path: url.pathname });
    return;
  }

  const search = url.searchParams.get("search") || "";
  if (search === "plain-error") {
    response.writeHead(400, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
    response.end("Client filters are invalid.");
    return;
  }
  if (search === "structured-error") {
    json(response, 403, { status: 403, error: "Forbidden", message: "TEAM_REQUIRED", code: "TEAM_REQUIRED", path: url.pathname });
    return;
  }
  if (search === "generic-error") {
    json(response, 403, { message: "denied" });
    return;
  }

  const page = Number(url.searchParams.get("page") || 0);
  let row;
  if (search === "slow-proof") {
    const startedAt = Date.now();
    await delay(1_500);
    row = bearer === tokenA ? "A_DELAYED_OLD_RESPONSE" : "B_DELAYED_RESPONSE";
    signals.push({ kind: "delayed-backend-response", principal: entry.principal, elapsedMs: Date.now() - startedAt, responseClosed: response.destroyed });
  } else if (bearer === tokenA) {
    row = search ? `A_FILTERED_PAGE_${page}` : `A_PRELOGOUT_PAGE_${page}`;
  } else if (bearer === tokenAAfterLogin) {
    row = `A_POSTLOGIN_PAGE_${page}`;
  } else {
    row = `B_SENTINEL_PAGE_${page}`;
  }
  json(response, 200, pageResponse(row, page));
});

function runNext(args, env, logs) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [nextBin, ...args], { cwd: fixture, env, stdio: ["ignore", "pipe", "pipe"] });
    for (const stream of [child.stdout, child.stderr]) {
      stream.setEncoding("utf8");
      stream.on("data", (part) => { logs.value = (logs.value + part).slice(-20_000); });
    }
    child.once("error", reject);
    child.once("exit", (code, signal) => code === 0
      ? resolve()
      : reject(new Error(`Next ${args[0]} exited with ${code ?? signal}:\n${logs.value}`)));
  });
}

async function stopNext(child) {
  if (!child || child.exitCode !== null) return;
  child.kill("SIGTERM");
  await Promise.race([new Promise((resolve) => child.once("exit", resolve)), delay(5_000)]);
  if (child.exitCode === null) child.kill("SIGKILL");
}

async function waitFor(predicate, message, timeoutMs = 12_000) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (predicate()) return;
    await delay(40);
  }
  throw new Error(message);
}

function eventCount(predicate) {
  return backendRequests.filter(predicate).length;
}

await mkdir(outputDir, { recursive: true });
let next;
let browser;
let watchdog;
let nextLogs = { value: "" };
let lastReadiness;
try {
  const backendPort = await listen(backend);
  const reserve = createServer();
  const webPort = await listen(reserve);
  await close(reserve);
  const baseUrl = `http://127.0.0.1:${webPort}`;
  const env = {
    PATH: process.env.PATH || "",
    ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
    ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
    BACKEND_API_URL: `http://127.0.0.1:${backendPort}/api`,
    WEB_ORIGIN: baseUrl,
    NODE_ENV: "production",
    NEXT_TELEMETRY_DISABLED: "1",
  };
  const buildLogs = { value: "" };
  await runNext(["build"], env, buildLogs);
  await writeFile(join(outputDir, "next-build.log"), buildLogs.value);

  next = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(webPort)], {
    cwd: fixture, env, stdio: ["ignore", "pipe", "pipe"],
  });
  nextLogs = { value: "" };
  for (const stream of [next.stdout, next.stderr]) {
    stream.setEncoding("utf8");
    stream.on("data", (part) => { nextLogs.value = (nextLogs.value + part).slice(-20_000); });
  }
  watchdog = setTimeout(() => {
    console.error("FAIL B08 Query/SSR browser proof exceeded its two-minute watchdog");
    next.kill("SIGKILL");
    process.exit(1);
  }, 120_000);
  watchdog.unref();

  let ready = false;
  const readyDeadline = Date.now() + 30_000;
  while (!ready && Date.now() < readyDeadline && next.exitCode === null) {
    try {
      const response = await fetch(`${baseUrl}/clients-proof?page=0&size=20`, {
        redirect: "manual",
        signal: AbortSignal.timeout(1_000),
      });
      await response.arrayBuffer();
      lastReadiness = { status: response.status, location: response.headers.get("location") };
      ready = response.status === 307 && response.headers.get("location") === "/login";
    } catch {
      await delay(100);
    }
  }
  assert.equal(ready, true, `Next fixture should start with the expected unauthenticated route gate (${JSON.stringify(lastReadiness)}):\n${nextLogs.value}`);

  browser = await chromium.launch({ headless: true, executablePath: chromePath, args: ["--no-sandbox", "--disable-dev-shm-usage"] });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();
  const cdp = await context.newCDPSession(page);
  await cdp.send("Fetch.enable", {
    patterns: [{ urlPattern: `${baseUrl}/clients-proof*`, requestStage: "Response" }],
  });
  const clientBffRequests = [];
  const documentRequests = [];
  const failedSlowRequests = [];
  cdp.on("Fetch.requestPaused", (event) => {
    void (async () => {
      const url = new URL(event.request.url);
      if (url.pathname !== "/clients-proof" || event.responseStatusCode === undefined) {
        await cdp.send("Fetch.continueRequest", { requestId: event.requestId });
        return;
      }
      const headers = Object.fromEntries((event.responseHeaders ?? []).map(({ name, value }) => [name.toLowerCase(), String(value)]));
      const requestHeaders = Object.fromEntries(Object.entries(event.request.headers).map(([name, value]) => [name.toLowerCase(), String(value)]));
      const responseStatus = event.responseStatusCode;
    const record = {
      url: url.href,
      kind: requestHeaders.rsc === "1" || url.searchParams.has("_rsc") ? "flight" : "document",
      status: responseStatus,
      cacheControl: headers["cache-control"] ?? "",
      contentType: headers["content-type"] ?? "",
      contentLength: headers["content-length"] ?? "",
      body: "",
      bodyReadError: "",
    };
    privateResponses.push(record);
      try {
        const responseBody = await cdp.send("Fetch.getResponseBody", { requestId: event.requestId });
        record.body = responseBody.base64Encoded ? Buffer.from(responseBody.body, "base64").toString("utf8") : responseBody.body;
      } catch (error) {
        record.bodyReadError = String(error);
      } finally {
        await cdp.send("Fetch.continueRequest", { requestId: event.requestId });
      }
    })().catch(() => undefined);
  });
  page.on("request", (request) => {
    const url = new URL(request.url());
    if (url.pathname === "/api/backend/clients") clientBffRequests.push(url.search);
    if (request.resourceType() === "document" && url.pathname === "/clients-proof") documentRequests.push(url.href);
  });
  page.on("requestfailed", (request) => {
    if (request.url().includes("slow-proof")) failedSlowRequests.push(request.failure()?.errorText || "unknown");
  });

  await context.addCookies([{ name: "estate-dev-access", value: tokenA, url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
  const initialUrl = `${baseUrl}/clients-proof?page=0&size=20&tags=VIP&tags=Repeat`;
  const initialRequestCount = eventCount((entry) => entry.path === "/api/clients");
  const initialResponse = await page.goto(initialUrl, { waitUntil: "networkidle", timeout: 15_000 });
  assert.equal(initialResponse?.status(), 200);
  const initialRaw = await initialResponse.text();
  assert.match(initialResponse.headers()["cache-control"] ?? "", /no-store/i, "private HTML is not cached");
  await page.waitForFunction(() => document.querySelector('[data-testid="query-status"]')?.getAttribute("data-state") === "ready");
  await page.waitForFunction(() => typeof window.__b08SessionActions?.generation === "function");
  assert.match(await page.locator("[data-testid=client-rows]").innerText(), /A_PRELOGOUT_PAGE_0/);
  const initialHtml = await page.content();
  assert.doesNotMatch(initialHtml, /agent-A|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  assert.match(initialRaw, /A_PRELOGOUT_PAGE_0/);
  assert.doesNotMatch(initialRaw, /B_SENTINEL|agent-A|agent-B|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  assert.equal(clientBffRequests.length, 0, "the first RSC Page hydrates the same browser key without a BFF duplicate");
  assert.equal(eventCount((entry) => entry.path === "/api/clients") - initialRequestCount, 1);
  const firstPageRequest = backendRequests.find((entry, index) => index >= 0 && entry.path === "/api/clients" && entry.principal === "A-old");
  assert.ok(firstPageRequest?.search.includes("page=0") && firstPageRequest.search.includes("size=20"));
  assert.equal(firstPageRequest?.cookieForwarded, false);
  assert.equal(await page.evaluate(() => window.__b08SessionActions.generation()), 1, "initial RSC confirmation sets a nonzero browser generation");
  report.cases.push({ name: "initial-hydration", pageFetches: 1, browserClientFetches: clientBffRequests.length, browserGeneration: 1, privateDtoOnly: true });

  await page.getByTestId("apply-search").click();
  await page.waitForFunction(() => new URL(location.href).searchParams.get("search") === "ada");
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("A_FILTERED_PAGE_0"));
  await waitFor(() => privateResponses.some((entry) => entry.kind === "flight" && entry.body.includes("A_FILTERED_PAGE_0")), "A RSC response should be captured");
  const aFlight = privateResponses.find((entry) => entry.kind === "flight" && entry.body.includes("A_FILTERED_PAGE_0"));
  assert.match(aFlight?.cacheControl ?? "", /no-store/i);
  assert.doesNotMatch(aFlight?.body ?? "", /B_SENTINEL|agent-A|agent-B|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  assert.equal(await page.evaluate(() => window.__b08SessionActions.generation()), 1, "later RSC navigation hydrates while the browser generation is nonzero");
  assert.equal(clientBffRequests.length, 0, "later RSC hydration also avoids an immediate duplicate BFF request");
  await page.getByTestId("next-page").click();
  await page.waitForFunction(() => new URL(location.href).searchParams.get("page") === "1");
  await page.waitForFunction(() => document.querySelector('[data-testid="url-state"]')?.textContent?.includes('"page":1'));
  await page.goBack({ waitUntil: "domcontentloaded" });
  await page.waitForFunction(() => new URL(location.href).searchParams.get("page") === "0" && new URL(location.href).searchParams.get("search") === "ada");
  await page.waitForFunction(() => document.querySelector('[data-testid="url-state"]')?.textContent?.includes('"page":0'));
  await page.goForward({ waitUntil: "domcontentloaded" });
  await page.waitForFunction(() => new URL(location.href).searchParams.get("page") === "1" && new URL(location.href).searchParams.get("search") === "ada");
  await page.goBack({ waitUntil: "domcontentloaded" });
  await page.waitForFunction(() => new URL(location.href).searchParams.get("page") === "0" && new URL(location.href).searchParams.get("search") === "ada");
  const beforeBackRefresh = eventCount((entry) => entry.path === "/api/clients");
  await page.getByTestId("refresh-list").click();
  await waitFor(() => eventCount((entry) => entry.path === "/api/clients") > beforeBackRefresh, "Back-restored filters should be sent by the next RSC read");
  const backRead = backendRequests.filter((entry) => entry.path === "/api/clients").at(-1);
  const backQuery = new URLSearchParams(backRead?.search);
  assert.equal(backQuery.get("page"), "0");
  assert.equal(backQuery.get("search"), "ada");
  assert.deepEqual(backQuery.getAll("tags"), ["VIP", "Repeat"]);
  assert.equal(clientBffRequests.length, 0);
  report.cases.push({ name: "url-back-and-hydration", restoredPage: 0, restoredSearch: "ada", repeatedTags: backQuery.getAll("tags"), browserGeneration: 1, duplicateClientFetches: 0 });

  const plainError = await page.evaluate(async () => {
    const response = await fetch("/api/backend/clients?page=0&size=20&search=plain-error");
    return { status: response.status, body: await response.json() };
  });
  assert.equal(plainError.status, 400);
  assert.equal(plainError.body.ok, false);
  assert.equal(plainError.body.error.format, "plain-text");
  const structuredError = await page.evaluate(async () => {
    const response = await fetch("/api/backend/clients?page=0&size=20&search=structured-error");
    return { status: response.status, body: await response.json() };
  });
  assert.equal(structuredError.status, 403);
  assert.equal(structuredError.body.ok, false);
  assert.equal(structuredError.body.error.kind, "forbidden");
  assert.equal(structuredError.body.error.code, "TEAM_REQUIRED");
  const genericError = await page.evaluate(async () => {
    const response = await fetch("/api/backend/clients?page=0&size=20&search=generic-error");
    return { status: response.status, body: await response.json() };
  });
  assert.equal(genericError.status, 403);
  assert.equal(genericError.body.ok, false);
  assert.equal(genericError.body.error.kind, "verification-needed");
  await page.getByTestId("request-error").click();
  await page.waitForFunction(() => document.querySelector('[data-testid="query-error"]')?.getAttribute("data-code") === "TEAM_REQUIRED");
  assert.equal(await page.locator('[data-testid="query-error"]').getAttribute("data-kind"), "forbidden");
  report.cases.push({ name: "typed-api-errors", plainStatus: plainError.status, plainFormat: plainError.body.error.format, teamRequiredCode: structuredError.body.error.code, generic403: genericError.body.error.kind });

  const slowCountBeforeScopeChange = clientBffRequests.filter((search) => search.includes("slow-proof")).length;
  const cancelledBeforeScopeChange = failedSlowRequests.length;
  await page.evaluate(() => window.__b08SessionActions.startDelayedRead());
  await waitFor(() => clientBffRequests.filter((search) => search.includes("slow-proof")).length > slowCountBeforeScopeChange, "delayed BFF read should start");
  await page.evaluate(() => {
    const proof = { knownB: false, leaks: [] };
    const observer = new MutationObserver((records) => {
      if (!proof.knownB) return;
      for (const record of records) {
        const nodes = record.type === "characterData" ? [record.target] : [...record.addedNodes];
        for (const node of nodes) {
          const text = node.textContent ?? "";
          if (/A_STALE_RSC|A_DELAYED_OLD_RESPONSE|A_PRELOGOUT/.test(text)) proof.leaks.push(text.slice(0, 160));
        }
      }
    });
    observer.observe(document.body, { childList: true, subtree: true, characterData: true });
    window.__b08MutationProof = proof;
  });
  await context.addCookies([{ name: "estate-dev-access", value: tokenB, url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
  await page.evaluate(() => { window.__b08MutationProof.knownB = true; });
  const verifiedB = await page.evaluate(async () => {
    const result = await window.__b08SessionActions.verifySession();
    return { ok: result.ok, generation: window.__b08SessionActions.generation() };
  });
  assert.equal(verifiedB.ok, true);
  assert.equal(verifiedB.generation, 2);
  await waitFor(() => failedSlowRequests.length > cancelledBeforeScopeChange, "A's pending private request is canceled on the scope change");
  const scopeChangeCancellationCount = failedSlowRequests.length - cancelledBeforeScopeChange;
  assert.equal(scopeChangeCancellationCount, 1, "the scope-change phase aborts exactly one delayed private read");
  assert.equal(await page.evaluate(() => window.__b08SessionActions.generation()), 2);
  const bffCountBeforeHydration = clientBffRequests.length;
  const bFlightStart = privateResponses.length;
  await page.evaluate(() => window.dispatchEvent(new Event("b08-proof-canonical")));
  await page.waitForFunction(() => document.querySelector('[data-private-client-list]')?.getAttribute("data-session-scope") === "TEAM");
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("B_SENTINEL_PAGE_0"));
  await waitFor(() => privateResponses.slice(bFlightStart).some((entry) => entry.kind === "flight" && entry.body.includes("B_SENTINEL_PAGE_0")), "generation-2 B RSC response should be captured");
  const bStableFlight = privateResponses.slice(bFlightStart).find((entry) => entry.kind === "flight" && entry.body.includes("B_SENTINEL_PAGE_0"));
  assert.match(bStableFlight?.cacheControl ?? "", /no-store/i);
  assert.doesNotMatch(bStableFlight?.body ?? "", /A_PRELOGOUT|A_POSTLOGIN|A_STALE_RSC|agent-A|agent-B|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  assert.equal(clientBffRequests.length, bffCountBeforeHydration, "generation-2 B data hydrates without an immediate BFF duplicate");
  const bCacheNames = await page.evaluate(() => window.__b08SessionActions.cachedNames());
  assert.ok(bCacheNames.length > 0 && bCacheNames.every((name) => name.startsWith("B_")), JSON.stringify(bCacheNames));

  await page.evaluate(() => {
    const original = window.fetch.bind(window);
    let failNextMe = true;
    window.fetch = (input, init) => {
      const href = input instanceof Request ? input.url : String(input);
      if (failNextMe && new URL(href, location.href).pathname === "/api/session/me") {
        failNextMe = false;
        return Promise.resolve(Response.json({ ok: false, error: { kind: "unavailable", status: 503, format: "none", message: "The service is temporarily unavailable." } }, {
          status: 503,
          headers: { "x-crm-bff-error": "1" },
        }));
      }
      return original(input, init);
    };
  });
  const staleCandidateStart = privateResponses.length;
  await page.evaluate(() => window.dispatchEvent(new Event("b08-proof-stale-identity")));
  await waitFor(() => privateResponses.slice(staleCandidateStart).some((entry) => entry.kind === "flight" && entry.body.includes("A_STALE_RSC")), "the fixture stale-A RSC candidate should be delivered");
  const staleCandidate = privateResponses.slice(staleCandidateStart).find((entry) => entry.kind === "flight" && entry.body.includes("A_STALE_RSC"));
  assert.match(staleCandidate?.cacheControl ?? "", /no-store/i);
  assert.doesNotMatch(staleCandidate?.body ?? "", /agent-A|agent-B|accessToken|refreshToken|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  await page.waitForFunction(() => document.querySelector('[data-testid="retry-session"]') !== null, null, { timeout: 15_000 });
  assert.doesNotMatch(await page.locator("body").innerText(), /A_STALE_RSC|A_DELAYED_OLD_RESPONSE|A_PRELOGOUT/);
  const bAuthReadsBeforeRetry = eventCount((entry) => entry.path === "/api/auth/me" && entry.principal === "B");
  await page.evaluate(() => document.querySelector('[data-testid="retry-session"]')?.click());
  await waitFor(() => eventCount((entry) => entry.path === "/api/auth/me" && entry.principal === "B") > bAuthReadsBeforeRetry, "manual verification retry should check the live B identity");
  await page.waitForFunction(() => !document.querySelector('[data-private-client-list]'));
  await delay(100);
  const transientLeaks = await page.evaluate(() => window.__b08MutationProof.leaks);
  assert.deepEqual(transientLeaks, [], "stale A rows never commit while B is known or its provider is closed");
  assert.equal(await page.evaluate(() => window.__b08SessionActions.generation()), 2, "stale A RSC props cannot roll the verified B scope back");
  assert.ok((await page.locator("body").innerText()).includes("Verifying session"));
  report.cases.push({ name: "stale-rsc-candidate-withheld", fixtureOnlyCandidate: true, deliveredFlight: true, scope: "B/TEAM", generation: 2, oldNamesVisible: false, transientLeaks, unavailableVerificationRetry: true, scopeChangeCancellationCount });

  const bffCountBeforeStaleRecovery = clientBffRequests.length;
  const bRecoveryStart = privateResponses.length;
  await page.evaluate(() => window.dispatchEvent(new Event("b08-proof-canonical")));
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("B_SENTINEL_PAGE_0"));
  await waitFor(() => privateResponses.slice(bRecoveryStart).some((entry) => entry.kind === "flight" && entry.body.includes("B_SENTINEL_PAGE_0")), "fresh B RSC should restore the verified private tree");
  assert.equal(clientBffRequests.length, bffCountBeforeStaleRecovery, "fresh B RSC hydrates after stale props without a duplicate BFF read");
  assert.equal(await page.evaluate(() => window.__b08SessionActions.generation()), 2);
  report.cases.push({ name: "generation-2-hydration", scope: "B/TEAM", generation: 2, duplicateBffFetches: clientBffRequests.length - bffCountBeforeHydration, cachedNames: bCacheNames });
  await waitFor(() => signals.filter((event) => event.kind === "delayed-backend-response").length >= 1, "the canceled A scope-switch read should finish at the backend", 4_000);
  assert.ok(signals[0].responseClosed, JSON.stringify(signals[0]));
  const transientLeaksAfterDelayedResponse = await page.evaluate(() => window.__b08MutationProof.leaks);
  assert.deepEqual(transientLeaksAfterDelayedResponse, [], "the delayed A response never committed after the scope switch");

  const bDocumentResponse = await page.goto(initialUrl, { waitUntil: "networkidle", timeout: 15_000 });
  assert.equal(bDocumentResponse?.status(), 200);
  const bDocumentRaw = await bDocumentResponse.text();
  assert.match(bDocumentResponse.headers()["cache-control"] ?? "", /no-store/i);
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("B_SENTINEL_PAGE_0"));
  assert.match(bDocumentRaw, /B_SENTINEL_PAGE_0/);
  assert.doesNotMatch(bDocumentRaw, /A_PRELOGOUT|A_POSTLOGIN|A_STALE_RSC|agent-A|agent-B|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);

  await context.addCookies([{ name: "estate-dev-access", value: tokenA, url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
  const secondAResponse = await page.goto(initialUrl, { waitUntil: "networkidle", timeout: 15_000 });
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("A_PRELOGOUT_PAGE_0"));
  const secondARaw = await secondAResponse.text();
  assert.match(secondAResponse.headers()["cache-control"] ?? "", /no-store/i);
  assert.match(secondARaw, /A_PRELOGOUT_PAGE_0/);
  assert.doesNotMatch(secondARaw, /A_POSTLOGIN|B_SENTINEL|agent-A|agent-B|must-not-leak|PRIVATE_NOTE_SHOULD_NOT_CROSS_RSC_CACHE/);
  const slowCountBeforeRelogin = clientBffRequests.filter((search) => search.includes("slow-proof")).length;
  const cancelledBeforeRelogin = failedSlowRequests.length;
  await page.evaluate(() => {
    window.__b08RealmMarker = "prelogout";
    window.__b08SavedLogin = window.__b08SessionActions.login;
    window.__b08SessionActions.startDelayedRead();
    const proof = { leaks: [] };
    const observer = new MutationObserver((records) => {
      for (const record of records) {
        const nodes = record.type === "characterData" ? [record.target] : [...record.addedNodes];
        for (const node of nodes) {
          const text = node.textContent ?? "";
          if (text.includes("A_QUEUED_AFTER_CLOSE")) proof.leaks.push(text.slice(0, 160));
        }
      }
    });
    observer.observe(document.body, { childList: true, subtree: true, characterData: true });
    window.__b08QueuedHydrationProof = proof;
  });
  await waitFor(() => clientBffRequests.filter((search) => search.includes("slow-proof")).length > slowCountBeforeRelogin, "same-scope pending read should start");
  const completedBffReadsBeforeLogin = clientBffRequests.filter((search) => !search.includes("slow-proof")).length;
  const documentCountBeforeLogin = documentRequests.length;
  const closeFlightStart = privateResponses.length;
  await page.evaluate(() => window.dispatchEvent(new Event("b08-proof-logout-race")));
  await waitFor(() => privateResponses.slice(closeFlightStart).some((entry) => entry.kind === "flight" && entry.body.includes("A_QUEUED_AFTER_CLOSE")), "the newer same-key hydration payload should be delivered before the child closes the session");
  const queuedHydrationFlight = privateResponses.slice(closeFlightStart).find((entry) => entry.kind === "flight" && entry.body.includes("A_QUEUED_AFTER_CLOSE"));
  assert.match(queuedHydrationFlight?.cacheControl ?? "", /no-store/i);
  const logoutResult = await page.evaluate(async () => {
    const result = await window.__b08HydrationClose;
    return { ok: result.ok, kind: result.ok ? "ok" : result.error.kind };
  });
  assert.equal(logoutResult.ok, true, JSON.stringify(logoutResult));
  await page.waitForFunction(() => !document.querySelector("[data-private-client-list]"));
  await delay(80);
  const namesAfterQueuedHydrationClose = await page.evaluate(() => window.__b08SessionActions.cachedNames());
  assert.deepEqual(namesAfterQueuedHydrationClose, [], "a queued HydrationBoundary update cannot repopulate the cache after logout closes the provider");
  const queuedHydrationLeaks = await page.evaluate(() => window.__b08QueuedHydrationProof.leaks);
  assert.deepEqual(queuedHydrationLeaks, [], "the queued same-key sentinel never becomes visible during closure");
  await waitFor(() => failedSlowRequests.length > cancelledBeforeRelogin, "logout should abort the same-scope delayed read");
  const scopeCloseCancellationCount = failedSlowRequests.length - cancelledBeforeRelogin;
  assert.equal(scopeCloseCancellationCount, 1, "logout closes and cancels the same-scope in-flight query exactly once");
  report.cases.push({ name: "queued-hydration-cleared-on-close", deliveredHydrationCandidate: true, hiddenCacheNames: namesAfterQueuedHydrationClose, transientLeaks: queuedHydrationLeaks, delayedCancellationCount: scopeCloseCancellationCount });
  await page.evaluate((href) => history.replaceState(null, "", href), new URL(initialUrl).pathname + new URL(initialUrl).search);
  await page.evaluate(() => { void window.__b08SavedLogin(); });
  await waitFor(() => documentRequests.length > documentCountBeforeLogin, "successful login should replace the current document", 15_000);
  await page.waitForFunction(() => document.querySelector('[data-testid="client-rows"]')?.textContent?.includes("A_POSTLOGIN_PAGE_0"), null, { timeout: 15_000 });
  await delay(1_700);
  const postLoginText = await page.locator("body").innerText();
  assert.doesNotMatch(postLoginText, /A_PRELOGOUT|A_STALE_RSC|A_DELAYED_OLD_RESPONSE/);
  assert.equal(await page.evaluate(() => window.__b08RealmMarker), undefined, "login replaces the pre-auth JavaScript realm");
  const sameScopeCancellationCount = failedSlowRequests.length - cancelledBeforeRelogin;
  assert.equal(sameScopeCancellationCount, 1, "the same-scope phase aborts exactly one delayed private read");
  assert.equal(sameScopeCancellationCount, scopeCloseCancellationCount);
  assert.equal(clientBffRequests.filter((search) => !search.includes("slow-proof")).length, completedBffReadsBeforeLogin, "fresh server data hydrates after the document replacement without a duplicate BFF read");
  assert.ok(eventCount((entry) => entry.path === "/api/clients" && entry.principal === "A-new") > 0);
  assert.equal(failedSlowRequests.length - cancelledBeforeScopeChange, 2, "the two independently measured lifecycle phases account for both aborts");
  await waitFor(() => signals.filter((event) => event.kind === "delayed-backend-response").length >= 2, "both backend delayed reads should finish or observe cancellation", 4_000);
  assert.ok(signals.filter((event) => event.kind === "delayed-backend-response").every((event) => event.responseClosed), JSON.stringify(signals));
  assert.ok(backendRequests.filter((entry) => entry.path.startsWith("/api/")).every((entry) => !entry.cookieForwarded), "backend requests receive bearer auth, never browser cookies");
  const output = {
    ...report,
    status: "PASS",
    urls: { initial: initialUrl, final: page.url() },
    loginDocumentNavigations: documentRequests.length - documentCountBeforeLogin,
    scopeChangeCancellationCount,
    sameScopeCancellationCount,
    queuedHydrationFlight: { status: queuedHydrationFlight?.status, cacheControl: queuedHydrationFlight?.cacheControl, body: queuedHydrationFlight?.body },
    delayedQueryAbortEvents: failedSlowRequests,
    delayedBackendSignals: signals,
    privatePageResponses: privateResponses.map(({ url, kind, status, cacheControl, contentType, contentLength, body, bodyReadError }) => ({ url, kind, status, cacheControl, contentType, contentLength, bodyReadError, bodyLength: body.length, containsA: body.includes("A_"), containsB: body.includes("B_") })),
    rawPrivateCaptures: [
      { name: "A-document", status: initialResponse.status(), cacheControl: initialResponse.headers()["cache-control"], body: initialRaw },
      { name: "A-flight", status: aFlight?.status, cacheControl: aFlight?.cacheControl, contentType: aFlight?.contentType, body: aFlight?.body },
      { name: "B-document", status: bDocumentResponse.status(), cacheControl: bDocumentResponse.headers()["cache-control"], body: bDocumentRaw },
      { name: "B-flight", status: bStableFlight?.status, cacheControl: bStableFlight?.cacheControl, contentType: bStableFlight?.contentType, body: bStableFlight?.body },
      { name: "fixture-stale-A-candidate", status: staleCandidate?.status, cacheControl: staleCandidate?.cacheControl, contentType: staleCandidate?.contentType, body: staleCandidate?.body },
      { name: "A-document-before-relogin", status: secondAResponse.status(), cacheControl: secondAResponse.headers()["cache-control"], body: secondARaw },
    ],
    backend: backendRequests.map(({ path, search, method, principal, cookieForwarded }) => ({ path, search, method, principal, cookieForwarded })),
    notes: [
      "The stale-A Flight is a controlled runtime-fixture candidate emitted only after the authenticated B request; it is recorded separately from normal A/B backend responses.",
      "API028 role/scope enforcement remains backend-authoritative; the loopback mock proves only the bearer and Page transport boundary.",
      "No real Spring database, native phone, or screen reader was exercised.",
    ],
  };
  await page.screenshot({ path: join(outputDir, "clients-proof-final.png"), fullPage: true });
  await writeFile(join(outputDir, "query-browser.json"), JSON.stringify(output, null, 2));
  await writeFile(join(outputDir, "next-server.log"), nextLogs.value);
  console.log("PASS per-render SSR isolation, same-key and later-generation hydration, URL Back, API028 errors, signal cancellation, stale-RSC suppression, queued-hydration cache clearing, identity change, and same-user login document reset");
} catch (error) {
  report.status = "FAIL";
  report.failure = error instanceof Error ? error.stack : String(error);
  report.readiness = lastReadiness;
  report.privatePageResponses = privateResponses.map(({ url, kind, status, cacheControl, contentType, contentLength, body, bodyReadError }) => ({ url, kind, status, cacheControl, contentType, contentLength, bodyReadError, bodyLength: body.length, bodySample: body.slice(0, 500) }));
  report.backend = backendRequests.map(({ path, search, method, principal, cookieForwarded }) => ({ path, search, method, principal, cookieForwarded }));
  await writeFile(join(outputDir, "query-browser-failure.json"), JSON.stringify(report, null, 2));
  await writeFile(join(outputDir, "next-server.log"), nextLogs.value);
  throw error;
} finally {
  if (watchdog) clearTimeout(watchdog);
  if (browser) await browser.close();
  await stopNext(next);
  await close(backend);
}
