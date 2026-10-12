import assert from "node:assert/strict";
import test from "node:test";
import { dehydrate, hydrate } from "@tanstack/react-query";
import { projectSpringPage } from "../../src/lib/api/page.ts";
import { decodeClientListPage } from "../../src/features/clients/client-list-contract.ts";
import {
  decimalDraftToWireNumber,
  isLocalDate,
  isLocalDateTime,
  isLongIdString,
  isYearMonth,
  requireSafeApiId,
} from "../../src/lib/api/wire-values.ts";
import { parseClientListUrl, serializeClientListUrl, clientListQueryKey } from "../../src/features/clients/client-list-url.ts";
import { bffMutation, bffQueryFn } from "../../src/lib/query/browser.ts";
import { ApiQueryError, createPrivateQueryClient, privateHydrationState, privateQueryKey, shouldRetryPrivateRead } from "../../src/lib/query/cache.ts";
import { sessionIdentityScope } from "../../src/lib/session-types.ts";

const identity = (userId, overrides = {}) => ({
  userId,
  fullName: `Agent ${userId}`,
  email: `agent-${userId}@example.test`,
  role: "AGENT",
  dataScope: "OWN",
  status: "ACTIVE",
  teamId: null,
  teamName: null,
  teamCurrency: null,
  mustChangePassword: false,
  ...overrides,
});

test("Page projection retains stable fields and rejects legacy arrays or error-shaped bodies", () => {
  const decodeRow = (item) => {
    assert.equal(typeof item, "object");
    requireSafeApiId(item.id);
    return { id: item.id };
  };
  const page = projectSpringPage({
    content: [{ id: 1 }], totalElements: 1, totalPages: 1, number: 0, size: 20, first: true, last: true,
    pageable: { implementation: "ignored" }, sort: { implementation: "ignored" },
  }, decodeRow);
  assert.deepEqual(page, { content: [{ id: 1 }], totalElements: 1, totalPages: 1, number: 0, size: 20, first: true, last: true });
  assert.throws(() => projectSpringPage([{ id: 1 }], decodeRow), /paged response/);
  assert.throws(() => projectSpringPage({ ok: false, error: { status: 400 } }, decodeRow), /paged response/);
  assert.throws(() => projectSpringPage({ ...page, number: -1 }, decodeRow), /paged response/);
  assert.throws(() => projectSpringPage({ ...page, content: [{ id: 9_007_199_254_740_992 }] }, decodeRow), /unsafe identifier/);
  assert.throws(() => decodeClientListPage({ ...page, size: 0 }, decodeRow), /API028 page size/);
  assert.throws(() => decodeClientListPage({ ...page, size: 101 }, decodeRow), /API028 page size/);
});

test("URL state preserves real API028 filters and normalizes the same query key", () => {
  const params = new URLSearchParams("type=BUYER&agentId=9007199254740993&search=ada&createdFrom=2024-02-29&tags=VIP&tags=Repeat&leadSource=WEBSITE&page=2&size=50&sort=createdAt,desc&sort=id,asc");
  const state = parseClientListUrl(params);
  const query = serializeClientListUrl(state);
  assert.deepEqual(new URLSearchParams(query).getAll("tags"), ["VIP", "Repeat"]);
  assert.deepEqual(new URLSearchParams(query).getAll("sort"), ["createdAt,desc", "id,asc"]);
  assert.equal(parseClientListUrl(new URLSearchParams(query)).agentId, "9007199254740993");
  assert.deepEqual(clientListQueryKey(identity(7), state), clientListQueryKey(identity(7), parseClientListUrl(new URLSearchParams(query))));
  assert.notDeepEqual(clientListQueryKey(identity(7), state), clientListQueryKey(identity(8), state));
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=20&unknown=x")), /Unsupported/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&page=1&size=20")), /Duplicate/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=101")), /pagination/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=20&createdFrom=2023-02-29")), /createdFrom/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=20&sort=password,asc")), /sort/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=20&sort=createdAt,sideways")), /sort/);
  assert.throws(() => parseClientListUrl(new URLSearchParams("page=0&size=20&sort=id,asc&sort=id,desc")), /sort/);
});

test("local wire values preserve ISO strings and reject invalid, offset, or unsafe values", () => {
  assert.equal(isLocalDate("2024-02-29"), true);
  assert.equal(isLocalDate("2023-02-29"), false);
  assert.equal(isYearMonth("2024-12"), true);
  assert.equal(isYearMonth("2024-13"), false);
  assert.equal(isLocalDateTime("2024-02-29T23:59:59.123456"), true);
  assert.equal(isLocalDateTime("2024-02-29T23:59Z"), false);
  assert.equal(isLocalDateTime("2024-02-30T12:00"), false);
  assert.equal(isLongIdString("9007199254740993"), true);
  assert.equal(isLongIdString("9223372036854775808"), false);
  assert.throws(() => requireSafeApiId(9_007_199_254_740_992), /unsafe identifier/);
  assert.equal(decimalDraftToWireNumber("12.50"), 12.5);
  assert.equal(decimalDraftToWireNumber("1.230"), 1.23, "value conversion does not impose endpoint lexical scale");
  assert.equal(decimalDraftToWireNumber("1e3"), 1000);
  assert.throws(() => decimalDraftToWireNumber("0.123456789012345678"), /precision/);
  assert.throws(() => decimalDraftToWireNumber(""), /precision/);
  assert.throws(() => decimalDraftToWireNumber("1e-324"), /precision/);
  assert.throws(() => decimalDraftToWireNumber("Infinity"), /precision/);
});

test("server query clients are per render and hydrated data prevents an immediate duplicate read", async () => {
  const a = createPrivateQueryClient();
  const b = createPrivateQueryClient();
  const keyA = privateQueryKey(identity(7), "clients", { page: 0 });
  const keyB = privateQueryKey(identity(8), "clients", { page: 0 });
  a.setQueryData(keyA, { sentinel: "A" });
  b.setQueryData(keyB, { sentinel: "B" });
  assert.notEqual(a, b);
  assert.deepEqual(b.getQueryData(keyA), undefined);
  const browser = createPrivateQueryClient();
  hydrate(browser, dehydrate(a));
  let requests = 0;
  const data = await browser.fetchQuery({ queryKey: keyA, queryFn: async () => { requests += 1; return { sentinel: "fresh" }; } });
  assert.deepEqual(data, { sentinel: "A" });
  assert.equal(requests, 0);

  const state = dehydrate(a);
  const scope = sessionIdentityScope(identity(7));
  const otherScope = sessionIdentityScope(identity(8));
  const closedState = privateHydrationState(scope, { generation: 3, closing: true, identityScope: scope }, state);
  const mismatchedState = privateHydrationState(otherScope, { generation: 3, closing: false, identityScope: scope }, state);
  const withheld = createPrivateQueryClient();
  assert.equal(closedState, undefined);
  assert.equal(mismatchedState, undefined);
  if (closedState) hydrate(withheld, closedState);
  if (mismatchedState) hydrate(withheld, mismatchedState);
  assert.equal(withheld.getQueryData(keyA), undefined, "closed or mismatched RSC state cannot repopulate a cleared private cache");

  const delayedKey = privateQueryKey(identity(7), "delayed");
  let resolveDelayed;
  const pending = browser.fetchQuery({ queryKey: delayedKey, retry: false, queryFn: () => new Promise((resolve) => { resolveDelayed = resolve; }) });
  await new Promise((resolve) => setImmediate(resolve));
  await browser.cancelQueries({ queryKey: delayedKey });
  resolveDelayed({ sentinel: "late" });
  await assert.rejects(pending);
  assert.equal(browser.getQueryData(delayedKey), undefined, "a cancelled late result cannot repopulate the query cache");

  a.clear();
  b.clear();
  browser.clear();
  withheld.clear();
});

test("typed query errors, signal propagation, retry policy, and uncertain writes stay bounded", async () => {
  const previousFetch = globalThis.fetch;
  const previousWindow = globalThis.window;
  globalThis.window = { location: { origin: "http://127.0.0.1:3000" } };
  try {
    const controller = new AbortController();
    let capturedSignal;
    globalThis.fetch = async (_input, init) => {
      capturedSignal = init.signal;
      return Response.json({ value: 4 });
    };
    const read = bffQueryFn("/api/backend/clients?page=0&size=20", (value) => value);
    assert.deepEqual(await read({ signal: controller.signal, queryKey: ["clients"] }), { value: 4 });
    assert.equal(capturedSignal, controller.signal);

    globalThis.fetch = async () => new Response(JSON.stringify({
      ok: false, error: { kind: "forbidden", status: 403, format: "error-response", message: "No access." },
    }), { status: 403, headers: { "content-type": "application/json", "x-crm-bff-error": "1" } });
    await assert.rejects(read({ signal: new AbortController().signal, queryKey: ["clients"] }), (error) => {
      assert.ok(error instanceof ApiQueryError);
      assert.equal(error.apiError.kind, "forbidden");
      return true;
    });
    assert.equal(shouldRetryPrivateRead(0, new ApiQueryError({ kind: "forbidden", status: 403, format: "none", message: "denied" })), false);
    assert.equal(shouldRetryPrivateRead(0, new ApiQueryError({ kind: "network", format: "none", message: "offline" })), true);
    assert.equal(shouldRetryPrivateRead(1, new ApiQueryError({ kind: "network", format: "none", message: "offline" })), false);

    let writes = 0;
    globalThis.fetch = async () => { writes += 1; throw new TypeError("connection closed after request send"); };
    await assert.rejects(bffMutation("/api/backend/clients", { method: "POST", body: "{}" }, (value) => value), ApiQueryError);
    assert.equal(writes, 1, "an uncertain write is never replayed by the resource wrapper");

    let deletes = 0;
    globalThis.fetch = async () => { deletes += 1; return new Response(null, { status: 204 }); };
    assert.equal(await bffMutation("/api/backend/clients/7", { method: "DELETE" }, (value) => value === undefined ? undefined : value), undefined);
    assert.equal(deletes, 1, "a successful void mutation accepts 204 exactly once");

    await assert.rejects(
      bffMutation("/api/backend/clients/7", { method: "DELETE" }, (value) => { if (value === undefined) throw new TypeError("JSON body required"); return value; }),
      ApiQueryError,
    );
  } finally {
    globalThis.fetch = previousFetch;
    if (previousWindow === undefined) delete globalThis.window;
    else globalThis.window = previousWindow;
  }
});
