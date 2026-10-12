import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { parseServerRuntimeConfig } from "../../src/lib/server/backend-config.ts";

test("normalizes the private API path and browser origin", () => {
  assert.deepEqual(
    parseServerRuntimeConfig({
      BACKEND_API_URL: "https://api.example.test/api/",
      WEB_ORIGIN: "https://crm.example.test/",
    }),
    {
      backendApiUrl: "https://api.example.test/api",
      webOrigin: "https://crm.example.test",
    },
  );
});

test("rejects missing values, wrong API paths, and non-origin web URLs", () => {
  assert.throws(() => parseServerRuntimeConfig({ WEB_ORIGIN: "https://crm.test" }), /BACKEND_API_URL is required/);
  assert.throws(
    () => parseServerRuntimeConfig({ BACKEND_API_URL: "https://api.test/v1", WEB_ORIGIN: "https://crm.test" }),
    /BACKEND_API_URL must use the \/api path/,
  );
  assert.throws(
    () => parseServerRuntimeConfig({ BACKEND_API_URL: "https://api.test/api", WEB_ORIGIN: "https://crm.test/team" }),
    /WEB_ORIGIN must contain only an origin/,
  );
});

test("rejects URL credentials, query strings, and fragments without echoing values", () => {
  const secretUrl = "https://alice:do-not-leak@api.test/api?token=do-not-leak#private";
  assert.throws(
    () => parseServerRuntimeConfig({ BACKEND_API_URL: secretUrl, WEB_ORIGIN: "https://crm.test" }),
    (error) => {
      assert.match(error.message, /must not contain credentials, query, or fragment/);
      assert.equal(error.message.includes("do-not-leak"), false);
      assert.equal(error.message.includes("alice"), false);
      return true;
    },
  );
});

test("allows plain HTTP origins only for loopback development", () => {
  assert.equal(parseServerRuntimeConfig({
    BACKEND_API_URL: "http://127.0.0.1:8080/api",
    WEB_ORIGIN: "http://localhost:3000",
  }).webOrigin, "http://localhost:3000");
  assert.throws(() => parseServerRuntimeConfig({
    BACKEND_API_URL: "http://127.0.0.1:8080/api",
    WEB_ORIGIN: "http://crm.example.test",
  }), /WEB_ORIGIN must use HTTPS except for loopback development/);
});

test("server-only package rejects a default/client-condition import", () => {
  const root = fileURLToPath(new URL("../..", import.meta.url));
  const result = spawnSync(
    process.execPath,
    ["--experimental-strip-types", "--input-type=module", "-e", 'await import("./src/lib/server/env.ts")'],
    {
      cwd: root,
      encoding: "utf8",
      env: {
        PATH: process.env.PATH,
        BACKEND_API_URL: "https://do-not-leak.invalid/api",
        WEB_ORIGIN: "https://crm.invalid",
      },
    },
  );

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /cannot be imported from a Client Component/);
  assert.equal(result.stderr.includes("do-not-leak"), false);
});
