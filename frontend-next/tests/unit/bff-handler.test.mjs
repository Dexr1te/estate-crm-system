import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = fileURLToPath(new URL("../..", import.meta.url));

test("BFF retains timeout, cancellation, and network kinds when a JSON body fails after headers", () => {
  const source = `
    import assert from "node:assert/strict";
    import { NextRequest } from "next/server.js";
    import { handlePrivateBff } from "./src/lib/server/bff-handler.ts";
    import { accessCookieName, readAccessBearer } from "./src/lib/server/session.ts";
    import { safeAttachment } from "./src/lib/server/bff-response.ts";
    process.env.BACKEND_API_URL = "http://127.0.0.1:8080/api";
    process.env.WEB_ORIGIN = "http://127.0.0.1:3000";
    assert.equal(accessCookieName("https://crm.example"), "__Host-estate-access");
    assert.equal(accessCookieName("http://localhost:3000"), "estate-dev-access");
    assert.equal(accessCookieName("http://127.0.0.1:3000"), "estate-dev-access");
    assert.throws(() => accessCookieName("http://crm.example"), /must use HTTPS/);
    const secureRequest = new NextRequest("https://crm.example/api/backend/deals/1/documents", {
      headers: { cookie: "__Host-estate-access=secure-token" },
    });
    assert.equal(readAccessBearer(secureRequest, "https://crm.example"), "secure-token");
    const emojiName = "a".repeat(254) + "😀x";
    const emojiDisposition = safeAttachment("attachment; filename*=UTF-8''" + encodeURIComponent(emojiName), "fallback");
    assert.ok(emojiDisposition.endsWith("%F0%9F%98%80"), "truncation keeps a complete final Unicode code point");
    const backendMaxName = "a".repeat(251) + ".pdf";
    const maxDisposition = safeAttachment("attachment; filename*=UTF-8''" + encodeURIComponent(backendMaxName), "fallback");
    assert.equal(maxDisposition, "attachment; filename*=UTF-8''" + encodeURIComponent(backendMaxName));
    assert.equal(safeAttachment("attachment; filename*=UTF-8''%Q1", "fallback"), "attachment; filename*=UTF-8''fallback");
    const cases = [
      [new DOMException("upstream timeout", "TimeoutError"), 504, "timeout"],
      [new DOMException("upstream cancelled", "AbortError"), 503, "cancelled"],
      [new TypeError("upstream socket closed"), 503, "network"],
    ];
    for (const [reason, status, kind] of cases) {
      globalThis.fetch = async () => new Response(new ReadableStream({
        pull(controller) { controller.error(reason); },
      }), { status: 200, headers: { "content-type": "application/json" } });
      const request = new NextRequest("http://127.0.0.1:3000/api/backend/deals/1/documents", {
        headers: { cookie: "estate-dev-access=opaque-test-token" },
      });
      const response = await handlePrivateBff(request, ["deals", "1", "documents"]);
      assert.equal(response.status, status);
      assert.equal(response.headers.get("x-crm-bff-error"), "1");
      const wire = await response.json();
      assert.equal(wire.error.status, response.status);
      assert.equal(wire.error.kind, kind);
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
        BACKEND_API_URL: "http://127.0.0.1:8080/api",
        WEB_ORIGIN: "http://127.0.0.1:3000",
      },
    },
  );
  assert.equal(result.status, 0, result.stderr);
});

test("API028 BFF allowlist requires an explicit bounded Page query and preserves supported URL filters", () => {
  const source = `
    import assert from "node:assert/strict";
    import { matchPrivateOperation, operationApiPath } from "./src/lib/server/allowlist.ts";
    const parsed = new URL("http://127.0.0.1:3000/api/backend/clients?type=BUYER&agentId=9007199254740993&search=ada&createdFrom=2024-02-29&tags=VIP&tags=Repeat&leadSource=WEBSITE&page=2&size=50&sort=createdAt%2Cdesc&sort=id%2Casc");
    const operation = matchPrivateOperation(["clients"], parsed, "GET");
    assert.equal(operation?.id, "API028");
    assert.equal(operation?.method, "GET");
    assert.equal(operation?.kind, "json");
    assert.equal(operationApiPath(operation, parsed), "/clients" + parsed.search);
    const invalid = [
      [new URL("http://127.0.0.1:3000/api/backend/clients"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=20&extra=x"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&page=1&size=20"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=20&agentId=9223372036854775808"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=20&createdFrom=2023-02-29"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=20&sort=password,asc"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=20&sort=createdAt,sideways"), "GET"],
      [new URL("http://127.0.0.1:3000/api/backend/clients?page=0&size=101"), "GET"],
      [parsed, "POST"],
    ];
    for (const [url, method] of invalid) assert.equal(matchPrivateOperation(["clients"], url, method), null);
  `;
  const result = spawnSync(
    process.execPath,
    ["--conditions=react-server", "--experimental-strip-types", "--input-type=module", "-e", source],
    {
      cwd: root,
      encoding: "utf8",
      timeout: 10_000,
      env: { PATH: process.env.PATH, BACKEND_API_URL: "http://127.0.0.1:8080/api", WEB_ORIGIN: "http://127.0.0.1:3000" },
    },
  );
  assert.equal(result.status, 0, result.stderr);
});

test("JSON PUT requires a non-empty bounded body before proxying", () => {
  const source = `
    import assert from "node:assert/strict";
    import { NextRequest } from "next/server.js";
    import { handlePrivateBff } from "./src/lib/server/bff-handler.ts";
    process.env.BACKEND_API_URL = "http://127.0.0.1:8080/api";
    process.env.WEB_ORIGIN = "http://127.0.0.1:3000";
    let backendCalls = 0;
    globalThis.fetch = async () => {
      backendCalls += 1;
      return Response.json({ photoIds: [] });
    };
    const cases = [
      [undefined, 400, "REQUEST_BODY_REQUIRED"],
      ["", 400, "REQUEST_BODY_REQUIRED"],
      [" ".repeat(1024 * 1024 + 1), 413, "REQUEST_BODY_TOO_LARGE"],
    ];
    for (const [body, status, code] of cases) {
      const request = new NextRequest("http://127.0.0.1:3000/api/backend/properties/1/photos/order", {
        method: "PUT",
        headers: {
          cookie: "estate-dev-access=opaque-test-token",
          origin: "http://127.0.0.1:3000",
          "content-type": "application/json",
        },
        ...(body === undefined ? {} : { body }),
      });
      const response = await handlePrivateBff(request, ["properties", "1", "photos", "order"]);
      const wire = await response.json();
      assert.equal(response.status, status);
      assert.equal(wire.error.code, code);
    }
    assert.equal(backendCalls, 0);
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
        BACKEND_API_URL: "http://127.0.0.1:8080/api",
        WEB_ORIGIN: "http://127.0.0.1:3000",
      },
    },
  );
  assert.equal(result.status, 0, result.stderr);
});

test("BFF cancels no-length upstream bodies that exceed the JSON and private resource caps", () => {
  const source = `
    import assert from "node:assert/strict";
    import { NextRequest } from "next/server.js";
    import { handlePrivateBff } from "./src/lib/server/bff-handler.ts";
    process.env.BACKEND_API_URL = "http://127.0.0.1:8080/api";
    process.env.WEB_ORIGIN = "http://127.0.0.1:3000";
    const calls = new Map();
    const cancelled = { json: 0, image: 0, document: 0 };
    const resourceBody = (kind) => {
      const chunk = new Uint8Array(5 * 1024 * 1024);
      return new ReadableStream({
        pull(controller) {
          controller.enqueue(chunk);
        },
        cancel() { cancelled[kind] += 1; },
      });
    };
    globalThis.fetch = async (input) => {
      const path = new URL(input).pathname;
      calls.set(path, (calls.get(path) ?? 0) + 1);
      if (path === "/api/deals/1/documents") {
        const upstream = new Response(new ReadableStream({
          pull(controller) {
            controller.enqueue(new Uint8Array(1024 * 1024 + 1));
          },
          cancel() { cancelled.json += 1; },
        }), { status: 200, headers: { "content-type": "application/json" } });
        assert.equal(upstream.headers.get("content-length"), null);
        return upstream;
      }
      if (path === "/api/properties/1/photos/3/content") {
        const upstream = new Response(resourceBody("image"), {
          status: 200,
          headers: { "content-type": "image/jpeg" },
        });
        assert.equal(upstream.headers.get("content-length"), null);
        return upstream;
      }
      if (path === "/api/deals/1/documents/2/content") {
        const upstream = new Response(resourceBody("document"), {
          status: 200,
          headers: {
            "content-type": "application/pdf",
            "content-disposition": "attachment; filename=plan.pdf",
          },
        });
        assert.equal(upstream.headers.get("content-length"), null);
        return upstream;
      }
      throw new Error("Unexpected upstream path");
    };
    const request = (path) => new NextRequest("http://127.0.0.1:3000/api/backend/" + path, {
      headers: { cookie: "estate-dev-access=opaque-test-token" },
    });
    const json = await handlePrivateBff(request("deals/1/documents"), ["deals", "1", "documents"]);
    assert.equal(json.status, 502);
    assert.equal((await json.json()).error.code, "UPSTREAM_JSON_TOO_LARGE");
    assert.equal(cancelled.json, 1);
    for (const [path, parts, kind] of [
      ["properties/1/photos/3/content", ["properties", "1", "photos", "3", "content"], "image"],
      ["deals/1/documents/2/content", ["deals", "1", "documents", "2", "content"], "document"],
    ]) {
      const response = await handlePrivateBff(request(path), parts);
      assert.equal(response.status, 200, "stream status cannot change after headers are returned");
      assert.equal(response.headers.get("content-length"), null);
      const reader = response.body.getReader();
      let bytes = 0;
      let failed = false;
      try {
        while (true) {
          const part = await reader.read();
          if (part.done) break;
          bytes += part.value.byteLength;
        }
      } catch {
        failed = true;
      }
      assert.equal(failed, true);
      assert.equal(bytes, 20 * 1024 * 1024);
      assert.equal(cancelled[kind], 1, kind + " upstream body should be cancelled");
    }
    assert.equal([...calls.values()].reduce((sum, count) => sum + count, 0), 3);
    assert.deepEqual([...calls.values()], [1, 1, 1]);
  `;
  const result = spawnSync(
    process.execPath,
    ["--conditions=react-server", "--experimental-strip-types", "--input-type=module", "-e", source],
    {
      cwd: root,
      encoding: "utf8",
      timeout: 15_000,
      env: {
        PATH: process.env.PATH,
        BACKEND_API_URL: "http://127.0.0.1:8080/api",
        WEB_ORIGIN: "http://127.0.0.1:3000",
      },
    },
  );
  assert.equal(result.status, 0, result.stderr);
});
