import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { readdir, readFile } from "node:fs/promises";
import { createServer } from "node:net";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const fixture = join(root, "tests/fixtures/runtime-app");
const nextBin = join(root, "node_modules/next/dist/bin/next");
const backendSentinel = "http://private-backend-sentinel.invalid/api";

function getAvailablePort() {
  return new Promise((resolve, reject) => {
    const server = createServer();
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      if (!address || typeof address === "string") {
        server.close();
        reject(new Error("Could not reserve a local port"));
        return;
      }
      server.close((error) => error ? reject(error) : resolve(address.port));
    });
  });
}

function runNext(args, env) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [nextBin, ...args], {
      cwd: fixture,
      env,
      stdio: "inherit",
    });
    child.once("error", reject);
    child.once("exit", (code, signal) => {
      if (code === 0) resolve();
      else reject(new Error(`Next ${args[0]} exited with ${code ?? signal}`));
    });
  });
}

async function waitForServer(baseUrl, child) {
  const deadline = Date.now() + 20_000;
  while (Date.now() < deadline && child.exitCode === null) {
    try {
      const response = await fetch(`${baseUrl}/api/proof/binary`, { signal: AbortSignal.timeout(2_000) });
      if (response.ok) {
        await response.arrayBuffer();
        return;
      }
      await response.arrayBuffer();
      await delay(250);
    } catch {
      await delay(250);
    }
  }
  throw new Error("Next runtime fixture did not become ready within 20 seconds");
}

async function readChunks(response) {
  assert.equal(response.ok, true, `unexpected HTTP ${response.status}`);
  assert.ok(response.body, "response should stream a body");
  const reader = response.body.getReader();
  const chunks = [];
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) return chunks;
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
}

async function listFiles(directory) {
  let entries;
  try {
    entries = await readdir(directory, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") return [];
    throw error;
  }
  const nested = await Promise.all(entries.map((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? listFiles(path) : [path];
  }));
  return nested.flat();
}

async function assertNoBackendSentinelInStaticAssets() {
  const files = await listFiles(join(fixture, ".next/static"));
  let jsCount = 0;
  for (const file of files) {
    if (file.endsWith(".js")) jsCount += 1;
    const bytes = await readFile(file);
    assert.equal(bytes.includes(Buffer.from(backendSentinel)), false, "private backend URL must not appear in generated browser assets");
  }
  if (jsCount > 0) {
    console.log(`PASS no private backend URL in ${jsCount} generated browser JavaScript assets`);
  } else {
    console.log("NOT RUN browser bundle scan: the API-only fixture emitted no JavaScript assets");
  }
}

const port = await getAvailablePort();
const baseUrl = `http://127.0.0.1:${port}`;
const env = {
  PATH: process.env.PATH ?? "",
  ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
  ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
  BACKEND_API_URL: backendSentinel,
  WEB_ORIGIN: baseUrl,
  NEXT_TELEMETRY_DISABLED: "1",
};

await runNext(["build"], env);
await assertNoBackendSentinelInStaticAssets();

const server = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(port)], {
  cwd: fixture,
  env,
  stdio: "inherit",
});

try {
  await waitForServer(baseUrl, server);

  const fileBytes = 20 * 1024 * 1024;
  const file = new Blob([Buffer.alloc(fileBytes, 0x5a)], { type: "application/octet-stream" });
  const form = new FormData();
  form.append("file", file, "proof.bin");
  const encoded = new Request(`${baseUrl}/api/proof/upload`, { method: "POST", body: form });
  const uploadBody = Buffer.from(await encoded.arrayBuffer());
  const multipartContentType = encoded.headers.get("content-type");
  assert.match(multipartContentType ?? "", /^multipart\/form-data; boundary=/);
  const upload = await fetch(`${baseUrl}/api/proof/upload`, {
    method: "POST",
    headers: { "Content-Type": multipartContentType },
    body: uploadBody,
    signal: AbortSignal.timeout(30_000),
  });
  assert.equal(upload.status, 200);
  const uploadResult = await upload.json();
  assert.deepEqual(uploadResult, {
    fileName: "proof.bin",
    fileBytes,
    requestBytes: uploadBody.byteLength,
  });
  assert.ok(uploadResult.requestBytes > fileBytes, "multipart framing should add bytes around the file");
  assert.ok(uploadResult.requestBytes <= 25 * 1024 * 1024, "whole multipart request should remain under 25 MiB");
  console.log("PASS synthetic multipart request with a 20 MiB file under the 25 MiB request cap");

  const binary = await fetch(`${baseUrl}/api/proof/binary`, { signal: AbortSignal.timeout(10_000) });
  assert.equal(binary.headers.get("content-type"), "application/octet-stream");
  assert.equal(binary.headers.get("cache-control"), "no-store");
  const binaryChunks = await readChunks(binary);
  assert.ok(binaryChunks.length >= 2, "binary response should arrive in multiple chunks");
  assert.deepEqual(Buffer.concat(binaryChunks.map((chunk) => Buffer.from(chunk))), Buffer.from([0, 255, 16, 128, 1, 0]));
  console.log("PASS synthetic binary response stream");

  const csv = await fetch(`${baseUrl}/api/proof/csv`, { signal: AbortSignal.timeout(10_000) });
  assert.match(csv.headers.get("content-disposition") ?? "", /attachment; filename="proof\.csv"/);
  assert.match(csv.headers.get("content-type") ?? "", /^text\/csv; charset=utf-8/);
  assert.equal(csv.headers.get("cache-control"), "no-store");
  const csvChunks = await readChunks(csv);
  assert.ok(csvChunks.length >= 2, "CSV response should arrive in multiple chunks");
  assert.equal(Buffer.concat(csvChunks.map((chunk) => Buffer.from(chunk))).toString("utf8"), "id,name\n1,Alpha\n2,Beta\n");
  console.log("PASS synthetic CSV download stream");

  const missing = await fetch(`${baseUrl}/api/proof/not-found`, { signal: AbortSignal.timeout(10_000) });
  assert.equal(missing.status, 404);
  assert.deepEqual(await missing.json(), { error: "Not found" });
  console.log("PASS unsupported fixture path returns 404");

  const started = Date.now();
  const slow = await fetch(`${baseUrl}/api/proof/slow`, { signal: AbortSignal.timeout(110_000) });
  assert.equal(slow.status, 200);
  assert.equal(await slow.text(), "synthetic 90-second response");
  assert.ok(Date.now() - started >= 89_000, "response should remain pending for approximately 90 seconds");
  console.log("PASS synthetic 90-second server response");
} finally {
  server.kill("SIGTERM");
  await Promise.race([
    new Promise((resolve) => server.once("exit", resolve)),
    delay(5_000).then(() => {
      if (server.exitCode === null) server.kill("SIGKILL");
    }),
  ]);
}
