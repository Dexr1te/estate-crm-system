import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { once } from "node:events";
import { gzipSync } from "node:zlib";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const nextBin = join(root, "node_modules/next/dist/bin/next");
const nodeBin = process.execPath;
const accessToken = "local-access-token";
const uploadBytes = 20 * 1024 * 1024;
const requestLimitBytes = 25 * 1024 * 1024;
const csvBytes = 20 * 1024 * 1024 + 1;
const backendCalls = [];
const counters = { photoCancelled: 0, htmlCancelled: 0, uploadCompleted: 0, uploadAborted: 0 };
const nativeFetch = globalThis.fetch;
globalThis.fetch = (input, init = {}) => nativeFetch(input, {
  ...init,
  signal: init.signal ?? AbortSignal.timeout(15_000),
});

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      if (!address || typeof address === "string") return reject(new Error("Local test server did not bind"));
      resolve(address.port);
    });
  });
}

function close(server) {
  return server.listening
    ? new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()))
    : Promise.resolve();
}

function json(response, status, value, extra = {}) {
  response.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "set-cookie": "backend-cookie=must-not-leak; Path=/",
    ...extra,
  });
  response.end(JSON.stringify(value));
}

async function writeLargeCsv(response) {
  response.writeHead(200, {
    "content-type": "text/csv; charset=UTF-8",
    "content-disposition": 'attachment; filename="clients.csv"',
    "x-export-rows": "1",
    "content-length": String(csvBytes),
    "set-cookie": "backend-cookie=must-not-leak; Path=/",
  });
  const first = Buffer.from("id\n");
  response.write(first);
  const chunk = Buffer.alloc(64 * 1024, 0x78);
  let left = csvBytes - first.byteLength;
  while (left > 0) {
    const part = left >= chunk.byteLength ? chunk : chunk.subarray(0, left);
    if (!response.write(part)) await once(response, "drain");
    left -= part.byteLength;
  }
  response.end();
}

const backend = createServer((request, response) => {
  const url = new URL(request.url ?? "/", "http://backend.test");
  const path = url.pathname;
  const call = {
    method: request.method,
    path,
    query: url.search,
    authorization: request.headers.authorization,
    cookie: request.headers.cookie,
    contentLength: request.headers["content-length"],
    contentType: request.headers["content-type"],
  };
  backendCalls.push(call);

  if (path === "/api/deals/1/documents" && request.method === "GET") {
    json(response, 200, [{ id: 2, fileName: "plan.pdf" }], { location: "https://private.invalid/redirect" });
    return;
  }
  if (path === "/api/deals/2/documents" && request.method === "GET") {
    json(response, 200, { accessToken: "backend-secret-token" });
    return;
  }
  if (path === "/api/deals/1/documents" && request.method === "POST" || path === "/api/properties/1/photos" && request.method === "POST") {
    let bytes = 0;
    request.on("data", (part) => { bytes += part.byteLength; });
    request.on("aborted", () => { counters.uploadAborted += 1; });
    request.on("end", () => {
      counters.uploadCompleted += 1;
      call.bodyBytes = bytes;
      json(response, 201, { id: counters.uploadCompleted, fileBytes: bytes });
    });
    return;
  }
  if (path === "/api/properties/1/photos/order" && request.method === "PUT") {
    const chunks = [];
    request.on("data", (part) => chunks.push(part));
    request.on("end", () => {
      call.body = Buffer.concat(chunks).toString("utf8");
      json(response, 200, [{ id: 3, order: 0 }, { id: 2, order: 1 }]);
    });
    return;
  }
  if (path === "/api/deals/1/documents/2/content") {
    const bytes = gzipSync(Buffer.from("compressed private document"));
    response.writeHead(200, {
      "content-type": "application/pdf",
      "content-disposition": "attachment; filename*=UTF-8''plan%20%CE%B1.pdf",
      "content-encoding": "gzip",
      "content-length": String(bytes.byteLength),
      "set-cookie": "backend-cookie=must-not-leak; Path=/",
    });
    response.end(bytes);
    return;
  }
  if (path === "/api/deals/1/documents/9/content") {
    json(response, 500, { status: 500, error: "Internal Server Error", message: "private database stack", path });
    return;
  }
  if (path === "/api/deals/1/documents/10/content") {
    json(response, 503, { status: 503, error: "Service Unavailable", message: "private proxy stack", path });
    return;
  }
  if (path === "/api/properties/1/cover") {
    response.writeHead(200, { "content-type": "text/html; charset=utf-8", "set-cookie": "backend-cookie=must-not-leak; Path=/" });
    response.end("<!doctype html><html><body>private backend error page</body></html>");
    return;
  }
  if (path === "/api/properties/2/cover") {
    response.writeHead(200, { "content-type": "image/bmp", "set-cookie": "backend-cookie=must-not-leak; Path=/" });
    response.end(Buffer.from([0x42, 0x4d, 0, 0, 0, 0]));
    return;
  }
  if (path === "/api/properties/1/photos/3/content") {
    response.writeHead(200, { "content-type": "image/jpeg", "set-cookie": "backend-cookie=must-not-leak; Path=/" });
    let index = 0;
    const interval = setInterval(() => {
      if (response.destroyed) {
        clearInterval(interval);
        return;
      }
      if (index === 100) {
        clearInterval(interval);
        response.end();
        return;
      }
      response.write(Buffer.alloc(16 * 1024, index % 255));
      index += 1;
    }, 25);
    response.on("close", () => {
      clearInterval(interval);
      if (!response.writableEnded) counters.photoCancelled += 1;
    });
    return;
  }
  if (path === "/api/export/deals") {
    response.writeHead(200, {
      "content-type": "text/csv; charset=UTF-8",
      "content-disposition": 'attachment; filename="deals.csv"',
      "x-export-rows": "2",
      "set-cookie": "backend-cookie=must-not-leak; Path=/",
    });
    response.end("id\n1\n2\n");
    return;
  }
  if (path === "/api/export/clients" && url.searchParams.get("search") === "large") {
    void writeLargeCsv(response);
    return;
  }
  if (path === "/api/export/clients" && url.searchParams.get("status") === "plain") {
    response.writeHead(400, { "content-type": "text/plain; charset=utf-8", "set-cookie": "backend-cookie=must-not-leak; Path=/" });
    response.end("Invalid delimiter");
    return;
  }
  if (path === "/api/export/clients") {
    response.writeHead(403, { "content-type": "text/plain; charset=utf-8", "set-cookie": "backend-cookie=must-not-leak; Path=/" });
    response.end("private authorization diagnostic");
    return;
  }
  if (path === "/api/export/properties") {
    json(response, 403, { status: 403, error: "Forbidden", code: "TEAM_REQUIRED", message: "private membership detail", path });
    return;
  }
  json(response, 404, { status: 404, error: "Not Found", message: "not found", path });
});

const backendPort = await listen(backend);
const webPort = await (async () => {
  const server = createServer();
  const port = await listen(server);
  await close(server);
  return port;
})();
const baseUrl = `http://127.0.0.1:${webPort}`;
const webOrigin = baseUrl;
const env = {
  PATH: process.env.PATH ?? "",
  ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
  ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
  BACKEND_API_URL: `http://127.0.0.1:${backendPort}/api`,
  WEB_ORIGIN: webOrigin,
  NODE_ENV: "production",
  NEXT_TELEMETRY_DISABLED: "1",
};
const next = spawn(nodeBin, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(webPort)], {
  cwd: root,
  env,
  stdio: ["ignore", "pipe", "pipe"],
});
const watchdog = setTimeout(() => {
  console.error("FAIL BFF runtime proof exceeded its three-minute watchdog");
  next.kill("SIGKILL");
  process.exit(1);
}, 180_000);
watchdog.unref();
let startupLog = "";
for (const stream of [next.stdout, next.stderr]) {
  stream.setEncoding("utf8");
  stream.on("data", (part) => { startupLog = `${startupLog}${part}`.slice(-12_000); });
}

async function waitForNext() {
  const deadline = Date.now() + 30_000;
  while (Date.now() < deadline && next.exitCode === null) {
    try {
      const response = await fetch(`${baseUrl}/api/backend/deals/1/documents`, { signal: AbortSignal.timeout(1_500) });
      await response.arrayBuffer();
      if (response.status === 401) return;
    } catch {
      await delay(200);
    }
  }
  throw new Error(`Next server was not ready: ${startupLog}`);
}

function headers(extra = {}) {
  return { cookie: `estate-dev-access=${accessToken}; unrelated=keep-private`, ...extra };
}

async function errorJson(response) {
  assert.equal(response.headers.get("x-crm-bff-error"), "1");
  assert.equal(response.headers.get("cache-control"), "private, no-store");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  return response.json();
}

async function waitUntil(predicate, message) {
  const deadline = Date.now() + 5_000;
  while (Date.now() < deadline) {
    if (predicate()) return;
    await delay(25);
  }
  assert.fail(message);
}

try {
  await waitForNext();

  const missingCookie = await fetch(`${baseUrl}/api/backend/deals/1/documents`);
  assert.equal(missingCookie.status, 401);
  assert.equal((await errorJson(missingCookie)).error.kind, "unauthenticated");
  const duplicateCookie = await fetch(`${baseUrl}/api/backend/deals/1/documents`, {
    headers: { cookie: `estate-dev-access=${accessToken}; estate-dev-access=other` },
  });
  assert.equal(duplicateCookie.status, 401);
  assert.equal((await errorJson(duplicateCookie)).error.code, "ACCESS_COOKIE_REQUIRED");

  const listed = await fetch(`${baseUrl}/api/backend/deals/1/documents`, {
    headers: headers({ authorization: "Bearer browser-controlled", "x-forwarded-host": "attacker.invalid" }),
  });
  assert.equal(listed.status, 200);
  assert.deepEqual(await listed.json(), [{ id: 2, fileName: "plan.pdf" }]);
  assert.equal(listed.headers.get("cache-control"), "private, no-store");
  assert.equal(listed.headers.get("x-content-type-options"), "nosniff");
  assert.equal(listed.headers.get("set-cookie"), null);
  assert.equal(listed.headers.get("location"), null);
  const listCall = backendCalls.find((call) => call.path === "/api/deals/1/documents" && call.method === "GET");
  assert.equal(listCall.authorization, `Bearer ${accessToken}`);
  assert.equal(listCall.cookie, undefined);
  assert.equal(listCall.path, "/api/deals/1/documents");
  console.log("PASS cookie-only bearer, incoming Authorization/host/cookies filtered, private JSON headers");

  const unknown = await fetch(`${baseUrl}/api/backend/auth/me`, { headers: headers() });
  assert.equal(unknown.status, 404);
  const wrongMethod = await fetch(`${baseUrl}/api/backend/deals/1/documents`, { method: "DELETE", headers: headers() });
  assert.equal(wrongMethod.status, 405);
  const unknownQuery = await fetch(`${baseUrl}/api/backend/export/deals?unexpected=1`, { headers: headers() });
  assert.equal(unknownQuery.status, 404);
  const maxLong = await fetch(`${baseUrl}/api/backend/deals/9223372036854775808/documents`, { headers: headers() });
  assert.equal(maxLong.status, 404);
  const documentQuery = await fetch(`${baseUrl}/api/backend/deals/1/documents?unexpected=1`, { headers: headers() });
  assert.equal(documentQuery.status, 404);
  const encodedTraversal = await fetch(`${baseUrl}/api/backend/deals/1%2F..%2Fexport%2Fdeals`, { headers: headers() });
  assert.equal(encodedTraversal.status, 404);
  assert.equal(backendCalls.length, 1, "unsupported paths, methods, queries and IDs never reach Spring");
  console.log("PASS exact allowlist rejects auth paths, unsupported methods, and unlisted query keys");

  const writeUrl = `${baseUrl}/api/backend/properties/1/photos/order`;
  const backendCallsBeforeDeniedWrites = backendCalls.length;
  for (const origin of [undefined, "null", "https://attacker.invalid"]) {
    const response = await fetch(writeUrl, {
      method: "PUT",
      headers: headers({ ...(origin === undefined ? {} : { origin }), "content-type": "application/json" }),
      body: JSON.stringify({ photoIds: [3, 2] }),
    });
    assert.equal(response.status, 403);
    assert.equal((await errorJson(response)).error.code, "ORIGIN_REJECTED");
  }
  const crossSite = await fetch(writeUrl, {
    method: "PUT",
    headers: headers({ origin: webOrigin, "sec-fetch-site": "cross-site", "content-type": "application/json" }),
    body: JSON.stringify({ photoIds: [3, 2] }),
  });
  assert.equal(crossSite.status, 403);
  assert.equal((await errorJson(crossSite)).error.code, "FETCH_SITE_REJECTED");
  const wrongContentType = await fetch(writeUrl, {
    method: "PUT",
    headers: headers({ origin: webOrigin, "content-type": "text/plain" }),
    body: "{}",
  });
  assert.equal(wrongContentType.status, 415);
  const credentialWrite = await fetch(writeUrl, {
    method: "PUT",
    headers: headers({ origin: webOrigin, "content-type": "application/json" }),
    body: JSON.stringify({ photoIds: [3, 2], password: "must-not-leave" }),
  });
  assert.equal(credentialWrite.status, 400);
  for (const body of [undefined, ""]) {
    const init = {
      method: "PUT",
      headers: headers({ origin: webOrigin, "content-type": "application/json" }),
    };
    if (body !== undefined) init.body = body;
    const missingBody = await fetch(writeUrl, init);
    assert.equal(missingBody.status, 400);
    assert.equal((await errorJson(missingBody)).error.code, "REQUEST_BODY_REQUIRED");
  }
  assert.equal(backendCalls.length, backendCallsBeforeDeniedWrites, "CSRF, content-type and credential failures never reach Spring");
  const validOrder = await fetch(writeUrl, {
    method: "PUT",
    headers: headers({ origin: webOrigin, "sec-fetch-site": "same-origin", "content-type": "application/json" }),
    body: JSON.stringify({ photoIds: [3, 2] }),
  });
  assert.equal(validOrder.status, 200);
  assert.deepEqual(await validOrder.json(), [{ id: 3, order: 0 }, { id: 2, order: 1 }]);
  const orderCall = backendCalls.find((call) => call.path === "/api/properties/1/photos/order");
  assert.deepEqual(JSON.parse(orderCall.body), { photoIds: [3, 2] });
  console.log("PASS write Origin/Fetch Metadata/content-type/body and credential JSON guards");

  const htmlImage = await fetch(`${baseUrl}/api/backend/properties/1/cover`, { headers: headers() });
  assert.equal(htmlImage.status, 502);
  const htmlError = await errorJson(htmlImage);
  assert.equal(htmlError.error.kind, "malformed");
  assert.equal(htmlError.error.message.includes("backend error page"), false);
  const bmpImage = await fetch(`${baseUrl}/api/backend/properties/2/cover`, { headers: headers() });
  assert.equal(bmpImage.status, 200);
  assert.equal(bmpImage.headers.get("content-type"), "image/bmp");
  assert.equal(bmpImage.headers.get("cache-control"), "private, no-store");
  assert.deepEqual([...new Uint8Array(await bmpImage.arrayBuffer())], [0x42, 0x4d, 0, 0, 0, 0]);
  console.log("PASS private image stream rejects upstream HTML and accepts the backend BMP MIME");

  const document = await fetch(`${baseUrl}/api/backend/deals/1/documents/2/content`, { headers: headers() });
  assert.equal(document.status, 200);
  assert.equal(document.headers.get("content-type"), "application/pdf");
  assert.match(document.headers.get("content-disposition") ?? "", /^attachment; filename\*=UTF-8''plan%20%CE%B1\.pdf$/);
  assert.equal(document.headers.get("content-length"), null, "compressed upstream length is not copied after fetch decoding");
  assert.equal(document.headers.get("set-cookie"), null);
  assert.equal(await document.text(), "compressed private document");
  console.log("PASS document download remains an attachment and omits compressed upstream length");

  const exportResponse = await fetch(`${baseUrl}/api/backend/export/deals?lang=en&tags=a&tags=b`, { headers: headers() });
  assert.equal(exportResponse.status, 200);
  assert.match(exportResponse.headers.get("content-disposition") ?? "", /^attachment; filename\*=UTF-8''deals\.csv$/);
  assert.equal(exportResponse.headers.get("x-export-rows"), "2");
  assert.equal(exportResponse.headers.get("content-type"), "text/csv; charset=utf-8");
  assert.equal(exportResponse.headers.get("cache-control"), "private, no-store");
  assert.equal(exportResponse.headers.get("set-cookie"), null);
  assert.equal(await exportResponse.text(), "id\n1\n2\n");
  const largeCsv = await fetch(`${baseUrl}/api/backend/export/clients?search=large`, { headers: headers(), signal: AbortSignal.timeout(60_000) });
  assert.equal(largeCsv.status, 200);
  assert.equal(largeCsv.headers.get("x-export-rows"), "1");
  let receivedCsvBytes = 0;
  const csvReader = largeCsv.body.getReader();
  try {
    while (true) {
      const part = await csvReader.read();
      if (part.done) break;
      receivedCsvBytes += part.value.byteLength;
    }
  } finally {
    csvReader.releaseLock();
  }
  assert.equal(receivedCsvBytes, csvBytes, "CSV larger than 20 MiB is streamed without a byte cap");
  console.log("PASS CSV export headers and streaming of a response larger than 20 MiB");

  const unknown403 = await fetch(`${baseUrl}/api/backend/export/clients`, { headers: headers() });
  assert.equal(unknown403.status, 403);
  const unknown403Body = await errorJson(unknown403);
  assert.equal(unknown403Body.error.kind, "verification-needed");
  assert.equal(unknown403Body.error.message.includes("authorization diagnostic"), false);
  const structured403 = await fetch(`${baseUrl}/api/backend/export/properties`, { headers: headers() });
  assert.equal(structured403.status, 403);
  const structured403Body = await errorJson(structured403);
  assert.equal(structured403Body.error.kind, "forbidden");
  assert.equal(structured403Body.error.code, "TEAM_REQUIRED");
  assert.equal(structured403Body.error.message.includes("membership detail"), false);
  const plain400 = await fetch(`${baseUrl}/api/backend/export/clients?status=plain`, { headers: headers() });
  assert.equal(plain400.status, 400);
  const plain400Body = await errorJson(plain400);
  assert.equal(plain400Body.error.message, "Invalid delimiter");
  for (const [id, status] of [[9, 500], [10, 503]]) {
    const upstream5xx = await fetch(`${baseUrl}/api/backend/deals/1/documents/${id}/content`, { headers: headers() });
    assert.equal(upstream5xx.status, status);
    const body = await errorJson(upstream5xx);
    assert.equal(body.error.status, status);
    assert.equal(body.error.kind, "unavailable");
    assert.equal(body.error.message.includes("private"), false);
  }
  const credentialOutput = await fetch(`${baseUrl}/api/backend/deals/2/documents`, { headers: headers() });
  assert.equal(credentialOutput.status, 502);
  assert.equal((await credentialOutput.text()).includes("backend-secret-token"), false);
  console.log("PASS BFF wire preserves unknown/structured 403, safe plain-text 400, and actual upstream 5xx status");

  for (const [path, file] of [["deals/1/documents", "document.txt"], ["properties/1/photos", "photo.bin"]]) {
    const form = new FormData();
    const size = path.startsWith("properties/") ? uploadBytes : 7;
    form.append("file", new Blob([new Uint8Array(size).fill(0x61)], { type: "application/octet-stream" }), file);
    const uploaded = await fetch(`${baseUrl}/api/backend/${path}`, {
      method: "POST",
      headers: headers({ origin: webOrigin, "sec-fetch-site": "same-origin" }),
      body: form,
      signal: AbortSignal.timeout(60_000),
    });
    assert.equal(uploaded.status, 201);
    const result = await uploaded.json();
    assert.equal(result.fileBytes > size, true, "the backend received multipart framing plus file bytes");
  }
  assert.equal(counters.uploadCompleted, 2);
  assert.equal(backendCalls.filter((call) => call.method === "POST" && (call.path === "/api/deals/1/documents" || call.path === "/api/properties/1/photos")).length, 2);
  console.log("PASS streamed multipart document and 20 MiB photo uploads complete once with no replay");

  let chunksSent = 0;
  const tooLargeBody = new ReadableStream({
    pull(controller) {
      if (chunksSent * 256 * 1024 >= requestLimitBytes + 1) {
        controller.close();
        return;
      }
      const remaining = requestLimitBytes + 1 - chunksSent * 256 * 1024;
      const bytes = Math.min(256 * 1024, remaining);
      controller.enqueue(new Uint8Array(bytes).fill(0x61));
      chunksSent += 1;
    },
  });
  const rejectedUpload = await fetch(`${baseUrl}/api/backend/properties/1/photos`, {
    method: "POST",
    headers: headers({ origin: webOrigin, "content-type": "multipart/form-data; boundary=proof-boundary" }),
    body: tooLargeBody,
    duplex: "half",
    signal: AbortSignal.timeout(60_000),
  });
  assert.equal(rejectedUpload.status, 413);
  assert.equal((await errorJson(rejectedUpload)).error.code, "UPLOAD_TOO_LARGE");
  assert.equal(backendCalls.filter((call) => call.method === "POST" && call.path === "/api/properties/1/photos").length, 2,
    "one accepted and one rejected photo upload each make a single backend attempt");
  await waitUntil(() => counters.uploadAborted > 0, "the oversized chunked upload should be cancelled before backend completion");
  assert.equal(counters.uploadCompleted, 2, "oversized upload must not commit at the backend");
  console.log("PASS chunked upload with no Content-Length is stopped at the 25 MiB BFF limit");

  const image = await fetch(`${baseUrl}/api/backend/properties/1/photos/3/content`, { headers: headers() });
  assert.equal(image.status, 200);
  const imageReader = image.body.getReader();
  const firstImageChunk = await imageReader.read();
  assert.equal(firstImageChunk.done, false);
  await imageReader.cancel("proof downstream cancellation");
  await waitUntil(() => counters.photoCancelled === 1, "downstream cancellation should close the upstream image stream");
  assert.equal(backendCalls.filter((call) => call.path === "/api/properties/1/photos/3/content").length, 1);
  console.log("PASS downstream cancellation reaches the private image stream with one backend request");
} finally {
  clearTimeout(watchdog);
  next.kill("SIGTERM");
  await Promise.race([
    new Promise((resolve) => next.once("exit", resolve)),
    delay(5_000).then(() => { if (next.exitCode === null) next.kill("SIGKILL"); }),
  ]);
  await close(backend);
}

console.log("PASS real Next production server BFF boundary proof completed");
