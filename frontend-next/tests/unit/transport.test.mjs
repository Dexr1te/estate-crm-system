import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { readJson, readStream, bffJson, bffStream } from "../../src/lib/api/transport.ts";
import { resolveBackendApiUrl } from "../../src/lib/server/backend-config.ts";

const root = fileURLToPath(new URL("../..", import.meta.url));
const jsonHeaders = { "content-type": "application/json" };

function errorResponse(status, extra = {}) {
  return {
    status,
    error: status === 403 ? "Forbidden" : "Bad Request",
    message: "Request failed",
    path: "/api/clients",
    timestamp: "2026-10-11T12:00:00",
    ...extra,
  };
}

function response(body, status, headers = jsonHeaders) {
  return new Response(typeof body === "string" ? body : JSON.stringify(body), { status, headers });
}

test("backend URL resolution stays on the configured /api origin", () => {
  assert.equal(
    resolveBackendApiUrl("https://backend.test/api", "/clients?page=2").toString(),
    "https://backend.test/api/clients?page=2",
  );
  for (const path of [
    "https://attacker.test/api/clients",
    "//attacker.test/api/clients",
    "/../admin/users",
    "/clients/%2e%2e/admin",
    "/clients/%2fadmin",
    "/clients\\..\\admin",
    "/clients#fragment",
  ]) {
    assert.throws(() => resolveBackendApiUrl("https://backend.test/api", path));
  }
  assert.throws(() => resolveBackendApiUrl("https://backend.test/other", "/clients"));
});

test("JSON transport accepts 204 without parsing a body and preserves ErrorResponse fields", async () => {
  const noContent = await readJson(new Response(null, { status: 204 }));
  assert.deepEqual(noContent, { ok: true, data: undefined });
  const resetContent = await readJson(new Response(null, { status: 205 }));
  assert.deepEqual(resetContent, { ok: true, data: undefined });

  const validation = await readJson(response(errorResponse(400, {
    validationErrors: { email: "Invalid email", phone: "Required" },
  }), 400));
  assert.equal(validation.ok, false);
  if (!validation.ok) {
    assert.equal(validation.error.kind, "validation");
    assert.equal(validation.error.status, 400);
    assert.deepEqual(validation.error.validationErrors, { email: "Invalid email", phone: "Required" });
  }

  const unknown400 = await readJson(response(errorResponse(400), 400));
  assert.equal(unknown400.ok, false);
  if (!unknown400.ok) {
    assert.equal(unknown400.error.kind, "http");
    assert.notEqual(unknown400.error.message, "Request failed");
  }
});

test("HTTP status stays authoritative and 403 is denied only for a structured ErrorResponse", async () => {
  const cases = [
    [401, new Response(null, { status: 401 }), "unauthenticated"],
    [403, response(errorResponse(403, { code: "TEAM_REQUIRED" }), 403), "forbidden"],
    [403, new Response(null, { status: 403 }), "verification-needed"],
    [404, new Response(null, { status: 404 }), "not-found"],
    [409, new Response(null, { status: 409 }), "conflict"],
    [429, new Response(null, { status: 429 }), "rate-limited"],
    [503, response(errorResponse(400, { code: "BAD_INPUT" }), 503), "unavailable"],
  ];

  for (const [status, reply, kind] of cases) {
    const result = await readJson(Promise.resolve(reply));
    assert.equal(result.ok, false);
    if (!result.ok) {
      assert.equal(result.error.status, status);
      assert.equal(result.error.kind, kind);
    }
  }

  const codedForbidden = await readJson(response(errorResponse(403, { code: "TEAM_REQUIRED" }), 403));
  assert.equal(codedForbidden.ok, false);
  if (!codedForbidden.ok) assert.equal(codedForbidden.error.code, "TEAM_REQUIRED");

  const markupErrors = await readJson(response(errorResponse(400, {
    message: "Field rejected: <script>alert(1)</script>",
    validationErrors: { name: "Must not contain <script> tags" },
  }), 400));
  assert.equal(markupErrors.ok, false);
  if (!markupErrors.ok) {
    assert.equal(markupErrors.error.kind, "validation");
    assert.deepEqual(markupErrors.error.validationErrors, { name: "Must not contain <script> tags" });
    assert.equal(markupErrors.error.message.includes("<script>"), false);
  }

  const structuredMarkupForbidden = await readJson(response(errorResponse(403, {
    code: "TEAM_REQUIRED",
    message: "<script>private diagnostic</script>",
    validationErrors: { teamId: "<script>private</script>" },
  }), 403));
  assert.equal(structuredMarkupForbidden.ok, false);
  if (!structuredMarkupForbidden.ok) {
    assert.equal(structuredMarkupForbidden.error.kind, "forbidden");
    assert.equal(structuredMarkupForbidden.error.code, "TEAM_REQUIRED");
    assert.deepEqual(structuredMarkupForbidden.error.validationErrors, { teamId: "<script>private</script>" });
    assert.equal(structuredMarkupForbidden.error.message.includes("private diagnostic"), false);
  }
});

test("plain text is bounded; HTML, malformed JSON and unreadable error bodies stay safe", async () => {
  const plain = await readJson(response("Invalid date", 400, { "content-type": "text/plain" }));
  assert.equal(plain.ok, false);
  if (!plain.ok) {
    assert.equal(plain.error.format, "plain-text");
    assert.equal(plain.error.message, "Invalid date");
  }

  const forbiddenPlain = await readJson(response("private authorization diagnostic", 403, { "content-type": "text/plain" }));
  assert.equal(forbiddenPlain.ok, false);
  if (!forbiddenPlain.ok) {
    assert.equal(forbiddenPlain.error.kind, "verification-needed");
    assert.equal(forbiddenPlain.error.message.includes("private authorization"), false);
  }

  const html = await readJson(response("<!doctype html><html><body>secret stack</body></html>", 502, { "content-type": "text/html" }));
  assert.equal(html.ok, false);
  if (!html.ok) {
    assert.equal(html.error.kind, "unavailable");
    assert.equal(html.error.format, "html");
    assert.equal(html.error.message.includes("secret stack"), false);
  }

  const mislabeledHtml = await readJson(response("<p>database stack</p>", 400, { "content-type": "text/plain" }));
  assert.equal(mislabeledHtml.ok, false);
  if (!mislabeledHtml.ok) {
    assert.equal(mislabeledHtml.error.format, "html");
    assert.equal(mislabeledHtml.error.message.includes("<p>"), false);
  }

  const diagnostic = await readJson(response("SQLException: private gateway details", 502, { "content-type": "text/plain" }));
  assert.equal(diagnostic.ok, false);
  if (!diagnostic.ok) {
    assert.equal(diagnostic.error.kind, "unavailable");
    assert.equal(diagnostic.error.message.includes("SQLException"), false);
  }

  const malformed = await readJson(response('{"status":', 502));
  assert.equal(malformed.ok, false);
  if (!malformed.ok) {
    assert.equal(malformed.error.status, 502);
    assert.equal(malformed.error.kind, "unavailable");
    assert.equal(malformed.error.format, "malformed-json");
  }

  const mislabeledJsonHtml = await readJson(response("<html><body>proxy error</body></html>", 502));
  assert.equal(mislabeledJsonHtml.ok, false);
  if (!mislabeledJsonHtml.ok) assert.equal(mislabeledJsonHtml.error.format, "html");

  const truncated = await readJson(response(`{"status":502,"message":"${"x".repeat(20_000)}`, 502));
  assert.equal(truncated.ok, false);
  if (!truncated.ok) assert.equal(truncated.error.format, "malformed-json");

  const brokenBody = new ReadableStream({
    start(controller) {
      controller.error(new Error("database stack must not escape"));
    },
  });
  const unreadable = await readJson(Promise.resolve(new Response(brokenBody, {
    status: 502,
    headers: jsonHeaders,
  })));
  assert.equal(unreadable.ok, false);
  if (!unreadable.ok) {
    assert.equal(unreadable.error.kind, "unavailable");
    assert.equal(unreadable.error.format, "unreadable");
    assert.equal(unreadable.error.message.includes("database stack"), false);
  }
});

test("body cancellation and timeout after headers keep their transport result", async () => {
  const cancelledReason = new DOMException("cancelled", "AbortError");
  const cancelController = new AbortController();
  cancelController.abort(cancelledReason);
  const cancelledBody = new ReadableStream({
    start(controller) {
      controller.error(cancelledReason);
    },
  });
  const cancelled = await readJson(Promise.resolve(new Response(cancelledBody, {
    status: 200,
    headers: jsonHeaders,
  })), cancelController.signal);
  assert.equal(cancelled.ok, false);
  if (!cancelled.ok) {
    assert.equal(cancelled.error.kind, "cancelled");
    assert.equal(cancelled.error.status, 200);
    assert.equal(cancelled.error.format, "unreadable");
  }

  const timeoutReason = new DOMException("timeout", "TimeoutError");
  const timeoutController = new AbortController();
  timeoutController.abort(timeoutReason);
  const timeoutBody = new ReadableStream({
    start(controller) {
      controller.error(timeoutReason);
    },
  });
  const timedOut = await readJson(Promise.resolve(new Response(timeoutBody, {
    status: 503,
    headers: jsonHeaders,
  })), timeoutController.signal);
  assert.equal(timedOut.ok, false);
  if (!timedOut.ok) {
    assert.equal(timedOut.error.kind, "timeout");
    assert.equal(timedOut.error.status, 503);
    assert.equal(timedOut.error.format, "unreadable");
  }

  const errorController = new AbortController();
  errorController.abort(cancelledReason);
  const errorBody = new ReadableStream({
    start(controller) {
      controller.error(cancelledReason);
    },
  });
  const forbidden = await readJson(Promise.resolve(new Response(errorBody, {
    status: 403,
    headers: jsonHeaders,
  })), errorController.signal);
  assert.equal(forbidden.ok, false);
  if (!forbidden.ok) {
    assert.equal(forbidden.error.kind, "cancelled");
    assert.equal(forbidden.error.status, 403);
  }

  const pendingController = new AbortController();
  let bodyReadPending = false;
  const pendingBody = new ReadableStream({
    start(controller) {
      pendingController.signal.addEventListener("abort", () => controller.error(pendingController.signal.reason), { once: true });
    },
    pull() {
      bodyReadPending = true;
      return new Promise(() => {});
    },
  });
  const pendingResultPromise = readJson(Promise.resolve(new Response(pendingBody, {
    status: 200,
    headers: jsonHeaders,
  })), pendingController.signal);
  await new Promise((resolve) => setImmediate(resolve));
  assert.equal(bodyReadPending, true, "the response body read is pending before abort");
  pendingController.abort(cancelledReason);
  const pendingResult = await pendingResultPromise;
  assert.equal(pendingResult.ok, false);
  if (!pendingResult.ok) {
    assert.equal(pendingResult.error.kind, "cancelled");
    assert.equal(pendingResult.error.status, 200);
    assert.equal(pendingResult.error.format, "unreadable");
  }

  const pendingErrorController = new AbortController();
  let errorBodyReadPending = false;
  const pendingErrorBody = new ReadableStream({
    start(controller) {
      pendingErrorController.signal.addEventListener("abort", () => controller.error(pendingErrorController.signal.reason), { once: true });
    },
    pull() {
      errorBodyReadPending = true;
      return new Promise(() => {});
    },
  });
  const pendingErrorResultPromise = readJson(Promise.resolve(new Response(pendingErrorBody, {
    status: 503,
    headers: jsonHeaders,
  })), pendingErrorController.signal);
  await new Promise((resolve) => setImmediate(resolve));
  assert.equal(errorBodyReadPending, true, "the upstream error body read is pending before abort");
  pendingErrorController.abort(timeoutReason);
  const pendingErrorResult = await pendingErrorResultPromise;
  assert.equal(pendingErrorResult.ok, false);
  if (!pendingErrorResult.ok) {
    assert.equal(pendingErrorResult.error.kind, "timeout");
    assert.equal(pendingErrorResult.error.status, 503);
    assert.equal(pendingErrorResult.error.format, "unreadable");
  }
});

test("rejecting a successful non-JSON body cancels its unread stream", async () => {
  let cancelled = false;
  const body = new ReadableStream({
    cancel() {
      cancelled = true;
    },
  });
  const result = await readJson(Promise.resolve(new Response(body, {
    status: 200,
    headers: { "content-type": "text/html" },
  })));
  assert.equal(result.ok, false);
  assert.equal(cancelled, true);
});

test("browser transport is limited to documented same-origin BFF prefixes", async () => {
  const originalWindow = globalThis.window;
  const originalFetch = globalThis.fetch;
  globalThis.window = { location: { origin: "https://crm.test" } };
  let calls = 0;
  let seen;
  globalThis.fetch = async (url, init) => {
    calls += 1;
    seen = { url: new URL(url), init };
    return response({ ok: true }, 200);
  };

  try {
    for (const path of [
      "https://attacker.test/api/backend/clients",
      "//attacker.test/api/backend/clients",
      "/api/other/clients",
      "/api/backend/../session/refresh",
    ]) {
      const result = await bffJson(path);
      assert.equal(result.ok, false);
    }
    assert.equal(calls, 0);

    const result = await bffJson("/api/backend/clients?page=1", {
      method: "POST",
      headers: { authorization: "Bearer browser-secret", "content-type": "application/json" },
      body: "{}",
    });
    assert.deepEqual(result, { ok: true, data: { ok: true } });
    assert.equal(calls, 1);
    assert.equal(seen.url.origin, "https://crm.test");
    assert.equal(seen.url.pathname, "/api/backend/clients");
    assert.equal(seen.init.headers.get("authorization"), null);
    assert.equal(seen.init.cache, "no-store");
    assert.equal(seen.init.credentials, "same-origin");
    assert.equal(seen.init.redirect, "error");

    const form = new FormData();
    form.append("document", new Blob([new Uint8Array([0, 255, 1])]), "scan.bin");
    const upload = await bffJson("/api/backend/documents", { method: "POST", body: form });
    assert.equal(upload.ok, true);
    assert.equal(seen.init.body, form);
    assert.equal(seen.init.headers.get("content-type"), null, "fetch can add the multipart boundary");
  } finally {
    globalThis.fetch = originalFetch;
    if (originalWindow === undefined) delete globalThis.window;
    else globalThis.window = originalWindow;
  }
});

test("browser POST is sent once on network failure and distinguishes cancellation from timeout", async () => {
  const originalWindow = globalThis.window;
  const originalFetch = globalThis.fetch;
  globalThis.window = { location: { origin: "https://crm.test" } };
  let calls = 0;
  globalThis.fetch = async (_url, init) => {
    calls += 1;
    assert.equal(init.method, "POST");
    throw new TypeError("private request details must not escape");
  };

  try {
    const network = await bffJson("/api/backend/clients", { method: "POST", body: "{}" });
    assert.equal(network.ok, false);
    if (!network.ok) {
      assert.equal(network.error.kind, "network");
      assert.equal(network.error.message.includes("private request"), false);
    }
    assert.equal(calls, 1, "a failed POST is never replayed");

    const cancelledController = new AbortController();
    cancelledController.abort(new DOMException("cancel", "AbortError"));
    const cancelled = await readJson(Promise.reject(cancelledController.signal.reason), cancelledController.signal);
    assert.equal(cancelled.ok, false);
    if (!cancelled.ok) assert.equal(cancelled.error.kind, "cancelled");

    const timeoutController = new AbortController();
    timeoutController.abort(new DOMException("timeout", "TimeoutError"));
    const timedOut = await readJson(Promise.reject(timeoutController.signal.reason), timeoutController.signal);
    assert.equal(timedOut.ok, false);
    if (!timedOut.ok) assert.equal(timedOut.error.kind, "timeout");
  } finally {
    globalThis.fetch = originalFetch;
    if (originalWindow === undefined) delete globalThis.window;
    else globalThis.window = originalWindow;
  }
});

test("binary success remains an unconsumed Response stream", async () => {
  const originalWindow = globalThis.window;
  const originalFetch = globalThis.fetch;
  globalThis.window = { location: { origin: "https://crm.test" } };
  const body = new ReadableStream({
    start(controller) {
      controller.enqueue(new Uint8Array([0, 255, 16]));
      controller.enqueue(new Uint8Array([128, 1, 0]));
      controller.close();
    },
  });
  const upstream = new Response(body, { status: 200, headers: { "content-type": "application/octet-stream" } });
  let calls = 0;
  globalThis.fetch = async () => {
    calls += 1;
    return upstream;
  };

  try {
    const result = await bffStream("/api/backend/documents/1");
    assert.equal(result.ok, true);
    if (result.ok) {
      assert.equal(result.data, upstream);
      assert.equal(result.data.bodyUsed, false);
      assert.equal(result.data.body, body);
      const bytes = new Uint8Array(await result.data.arrayBuffer());
      assert.deepEqual([...bytes], [0, 255, 16, 128, 1, 0]);
    }
    assert.equal(calls, 1);
  } finally {
    globalThis.fetch = originalFetch;
    if (originalWindow === undefined) delete globalThis.window;
    else globalThis.window = originalWindow;
  }
});

test("server transport scopes bearer, disables caching and follows no redirects", () => {
  const source = `
    import assert from "node:assert/strict";
    import { createServer } from "node:http";
    import { backendJson } from "./src/lib/server/backend.ts";
    const nativeFetch = globalThis.fetch;
    const calls = [];
    globalThis.fetch = async (url, init) => {
      calls.push({ url: String(url), init });
      return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { "content-type": "application/json" } });
    };
    const result = await backendJson("/clients", {
      bearerToken: "explicit-token",
      headers: { authorization: "caller-token", cookie: "browser-cookie", accept: "application/json" },
    });
    assert.deepEqual(result, { ok: true, data: { ok: true } });
    assert.equal(calls[0].url, "http://backend.internal/api/clients");
    assert.equal(calls[0].init.cache, "no-store");
    assert.equal(calls[0].init.credentials, "omit");
    assert.equal(calls[0].init.redirect, "manual");
    assert.equal(calls[0].init.headers.get("authorization"), "Bearer explicit-token");
    assert.equal(calls[0].init.headers.get("cookie"), null);

    let redirectCalls = 0;
    globalThis.fetch = async (_url, init) => {
      redirectCalls += 1;
      assert.equal(init.redirect, "manual");
      return new Response("", { status: 302, headers: { location: "https://attacker.test/collect" } });
    };
    const redirect = await backendJson("/auth/me", { bearerToken: "explicit-token" });
    assert.equal(redirect.ok, false);
    if (!redirect.ok) assert.equal(redirect.error.status, 302);
    assert.equal(redirectCalls, 1);

    let invalidCalls = 0;
    globalThis.fetch = async () => { invalidCalls += 1; return new Response("{}"); };
    const invalid = await backendJson("https://attacker.test/api", { bearerToken: "explicit-token" });
    assert.equal(invalid.ok, false);
    if (!invalid.ok) assert.equal(invalid.error.kind, "malformed");
    assert.equal(invalidCalls, 0);

    const start = async (server) => {
      server.listen(0, "127.0.0.1");
      await new Promise((resolve, reject) => {
        server.once("error", reject);
        server.once("listening", resolve);
      });
      return server.address().port;
    };
    const close = (server) => server.listening
      ? new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()))
      : Promise.resolve();
    const redirectedRequests = [];
    const redirectTarget = createServer((request, response) => {
      redirectedRequests.push({ path: request.url, authorization: request.headers.authorization });
      response.writeHead(200, { "content-type": "text/plain" }).end("unexpected redirect follow");
    });
    let redirectPort;
    const backendRequests = [];
    const localBackend = createServer(async (request, response) => {
      const chunks = [];
      for await (const chunk of request) chunks.push(chunk);
      const captured = {
        path: request.url,
        host: request.headers.host,
        authorization: request.headers.authorization,
        cookie: request.headers.cookie,
        contentType: request.headers["content-type"],
      };
      if (request.url === "/api/upload") captured.body = Buffer.concat(chunks).toString("latin1");
      backendRequests.push(captured);
      if (request.url === "/api/redirect") {
        response.writeHead(302, {
          location: "http://127.0.0.1:" + redirectPort + "/collect",
          "content-type": "text/plain",
        }).end("redirect");
        return;
      }
      response.writeHead(200, { "content-type": "application/json" })
        .end(JSON.stringify({ ok: true, path: request.url }));
    });

    try {
      redirectPort = await start(redirectTarget);
      const backendPort = await start(localBackend);
      globalThis.fetch = nativeFetch;
      process.env.BACKEND_API_URL = "http://127.0.0.1:" + backendPort + "/api";
      const actual = await backendJson("/clients", {
        bearerToken: "request-local-token",
        headers: { authorization: "caller-token", cookie: "caller-cookie", accept: "application/json" },
      });
      assert.deepEqual(actual, { ok: true, data: { ok: true, path: "/api/clients" } });
      assert.deepEqual(backendRequests[0], {
        path: "/api/clients",
        host: "127.0.0.1:" + backendPort,
        authorization: "Bearer request-local-token",
        cookie: undefined,
        contentType: undefined,
      });

      const form = new FormData();
      form.append("document", new Blob([new Uint8Array([0, 255, 1])]), "scan.bin");
      const upload = await backendJson("/upload", { method: "POST", bearerToken: "request-local-token", body: form });
      assert.deepEqual(upload, { ok: true, data: { ok: true, path: "/api/upload" } });
      const multipart = backendRequests[1];
      assert.ok(multipart.contentType.startsWith("multipart/form-data; boundary="));
      const boundary = multipart.contentType.split("boundary=")[1];
      assert.ok(multipart.body.includes("--" + boundary));
      assert.ok(multipart.body.includes('filename="scan.bin"'));

      const redirect = await backendJson("/redirect", { bearerToken: "request-local-token" });
      assert.equal(redirect.ok, false);
      if (!redirect.ok) assert.equal(redirect.error.status, 302);
      assert.equal(backendRequests.length, 3);
      assert.equal(backendRequests[2].path, "/api/redirect");
      assert.equal(backendRequests[2].authorization, "Bearer request-local-token");
      assert.deepEqual(redirectedRequests, [], "manual redirect handling must not contact the second local origin");
    } finally {
      await Promise.all([close(localBackend), close(redirectTarget)]);
    }
  `;
  const result = spawnSync(
    process.execPath,
    ["--conditions=react-server", "--experimental-strip-types", "--input-type=module", "-e", source],
    {
      cwd: root,
      encoding: "utf8",
      timeout: 10_000,
      env: {
        PATH: process.env.PATH,
        BACKEND_API_URL: "http://backend.internal/api",
        WEB_ORIGIN: "http://127.0.0.1",
      },
    },
  );
  assert.equal(result.status, 0, result.stderr);
});

test("only same-origin BFF readers trust the versioned typed error wire", async () => {
  const originalWindow = globalThis.window;
  const originalFetch = globalThis.fetch;
  globalThis.window = { location: { origin: "https://crm.test" } };
  const wire = (kind, status, code) => new Response(JSON.stringify({
    ok: false,
    error: { kind, status, format: "error-response", message: "Safe BFF message", code },
  }), { status, headers: { ...jsonHeaders, "x-crm-bff-error": "1" } });
  try {
    const untrusted = await readJson(Promise.resolve(wire("forbidden", 403, "TEAM_REQUIRED")));
    assert.equal(untrusted.ok, false);
    if (!untrusted.ok) {
      assert.equal(untrusted.error.kind, "verification-needed");
      assert.equal(untrusted.error.code, undefined);
    }
    const untrustedStream = await readStream(Promise.resolve(wire("forbidden", 403, "TEAM_REQUIRED")));
    assert.equal(untrustedStream.ok, false);
    if (!untrustedStream.ok) {
      assert.equal(untrustedStream.error.kind, "verification-needed");
      assert.equal(untrustedStream.error.code, undefined);
    }

    globalThis.fetch = async () => wire("verification-needed", 403, "AUTH_UNVERIFIED");
    const verification = await bffJson("/api/backend/deals/1/documents");
    assert.equal(verification.ok, false);
    if (!verification.ok) {
      assert.equal(verification.error.kind, "verification-needed");
      assert.equal(verification.error.status, 403);
      assert.equal(verification.error.code, "AUTH_UNVERIFIED");
    }

    globalThis.fetch = async () => wire("forbidden", 403, "TEAM_REQUIRED");
    const forbidden = await bffStream("/api/backend/export/deals");
    assert.equal(forbidden.ok, false);
    if (!forbidden.ok) assert.equal(forbidden.error.kind, "forbidden");

    globalThis.fetch = async () => wire("forbidden", 401, "TEAM_REQUIRED");
    const mismatch = await bffJson("/api/backend/deals/1/documents");
    assert.equal(mismatch.ok, false);
    if (!mismatch.ok) {
      assert.equal(mismatch.error.kind, "malformed");
      assert.equal(mismatch.error.status, 401);
    }

    for (const status of [500, 502, 503]) {
      globalThis.fetch = async () => wire("unavailable", status, "BACKEND_ERROR");
      const upstream5xx = await bffJson("/api/backend/deals/1/documents");
      assert.equal(upstream5xx.ok, false);
      if (!upstream5xx.ok) assert.equal(upstream5xx.error.status, status);
    }
    for (const [status, code] of [[413, "UPLOAD_TOO_LARGE"], [415, "CONTENT_TYPE_REJECTED"]]) {
      globalThis.fetch = async () => wire("validation", status, code);
      const boundaryError = await bffJson("/api/backend/deals/1/documents");
      assert.equal(boundaryError.ok, false);
      if (!boundaryError.ok) {
        assert.equal(boundaryError.error.kind, "validation");
        assert.equal(boundaryError.error.status, status);
        assert.equal(boundaryError.error.code, code);
      }
    }

    let cancelled = false;
    globalThis.fetch = async () => new Response(new ReadableStream({
      start(controller) {
        controller.enqueue(new TextEncoder().encode(`{"ok":false,"error":{"kind":"forbidden","status":403,"format":"json","message":"${"x".repeat(20_000)}"}}`));
      },
      cancel() {
        cancelled = true;
      },
    }), { status: 403, headers: { ...jsonHeaders, "x-crm-bff-error": "1" } });
    const oversizedWire = await bffJson("/api/backend/deals/1/documents");
    assert.equal(oversizedWire.ok, false);
    if (!oversizedWire.ok) assert.equal(oversizedWire.error.kind, "malformed");
    assert.equal(cancelled, true, "the oversized marked error stream is cancelled to a bounded sample");
  } finally {
    globalThis.fetch = originalFetch;
    if (originalWindow === undefined) delete globalThis.window;
    else globalThis.window = originalWindow;
  }
});

test("aborted or timed out marked BFF error bodies keep their transport classification", async () => {
  const originalWindow = globalThis.window;
  const originalFetch = globalThis.fetch;
  globalThis.window = { location: { origin: "https://crm.test" } };
  try {
    for (const [name, kind] of [["AbortError", "cancelled"], ["TimeoutError", "timeout"]]) {
      globalThis.fetch = async () => new Response(new ReadableStream({
        pull(controller) {
          controller.error(new DOMException("private body read detail", name));
        },
      }), { status: 403, headers: { ...jsonHeaders, "x-crm-bff-error": "1" } });
      const result = await bffJson("/api/backend/deals/1/documents");
      assert.equal(result.ok, false);
      if (!result.ok) {
        assert.equal(result.error.kind, kind);
        assert.equal(result.error.status, 403);
        assert.equal(result.error.format, "unreadable");
        assert.equal(result.error.message.includes("private body"), false);
      }
    }
  } finally {
    globalThis.fetch = originalFetch;
    if (originalWindow === undefined) delete globalThis.window;
    else globalThis.window = originalWindow;
  }
});
