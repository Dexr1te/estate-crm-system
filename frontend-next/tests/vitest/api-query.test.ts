import { http, HttpResponse } from "msw";
import { expect, it } from "vitest";
import { QueryClient, type QueryFunctionContext } from "@tanstack/react-query";
import { decodeClientListPage } from "../../src/features/clients/client-list-contract.ts";
import { bffJson } from "../../src/lib/api/transport.ts";
import { bffQueryFn } from "../../src/lib/query/browser.ts";
import { server } from "./msw-server.ts";

const clientsPath = "/api/backend/clients?page=0&size=20";
const clientsUrl = "http://127.0.0.1:3000/api/backend/clients";
const clientsRequestUrl = `${clientsUrl}?page=0&size=20`;
const bffHeaders = { "x-crm-bff-error": "1", "cache-control": "private, no-store" };
const springPage = {
  content: [{ id: 7, fullName: "Ada Agent", email: "ada@example.test", type: "BUYER", tags: [] }],
  totalElements: 1,
  totalPages: 1,
  number: 0,
  size: 20,
  first: true,
  last: true,
};

function context(signal: AbortSignal): QueryFunctionContext {
  return { client: new QueryClient(), meta: undefined, signal, queryKey: ["clients"] };
}

function queryClients() {
  return bffQueryFn(clientsPath, (value) => decodeClientListPage(value, (client) => client));
}

it("uses the API028 same-origin BFF path, strips caller auth, and returns the Spring page", async () => {
  const requests: Request[] = [];
  server.use(http.get(clientsUrl, ({ request }) => {
    requests.push(request);
    return HttpResponse.json(springPage);
  }));

  const result = await bffJson(clientsPath, { headers: { authorization: "Bearer must-not-reach-BFF" } });
  const page = await queryClients()(context(new AbortController().signal));

  expect(result).toEqual({ ok: true, data: springPage });
  expect(page).toMatchObject({ content: [{ id: 7, fullName: "Ada Agent" }], number: 0, size: 20 });
  expect(requests).toHaveLength(2);
  for (const request of requests) {
    expect(request.url).toBe(clientsRequestUrl);
    expect(request.headers.has("authorization")).toBe(false);
    expect(request.cache).toBe("no-store");
    expect(request.credentials).toBe("same-origin");
    expect(request.redirect).toBe("error");
  }
});

it.each([
  [400, "validation", { code: "INVALID_FILTER", validationErrors: { search: "Too long." } }],
  [403, "forbidden", { code: "ACCESS_DENIED" }],
  [503, "unavailable", {}],
] as const)("preserves the typed BFF %i result through the query adapter", async (status, kind, fields) => {
  server.use(http.get(clientsUrl, () => HttpResponse.json({
    ok: false,
    error: {
      kind,
      status,
      format: status === 503 ? "none" : "error-response",
      message: kind === "forbidden"
        ? "You do not have permission to do this."
        : kind === "unavailable"
          ? "The service is temporarily unavailable."
          : "Check the request and try again.",
      ...fields,
    },
  }, { status, headers: bffHeaders })));

  await expect(queryClients()(context(new AbortController().signal))).rejects.toMatchObject({
    name: "ApiQueryError",
    apiError: { kind, status },
  });
});

it("classifies a successful HTTP response with an invalid DTO as malformed", async () => {
  server.use(http.get(clientsUrl, () => HttpResponse.json({ content: "not-an-array" })));

  await expect(queryClients()(context(new AbortController().signal))).rejects.toMatchObject({
    name: "ApiQueryError",
    apiError: { kind: "malformed", status: 502 },
  });
});

it("passes query cancellation through bffJson and reports a cancelled typed error", async () => {
  let started!: () => void;
  let observedAbort = false;
  const requestStarted = new Promise<void>((resolve) => { started = resolve; });
  server.use(http.get(clientsUrl, ({ request }) => new Promise<Response>((resolve) => {
    request.signal.addEventListener("abort", () => {
      observedAbort = request.signal.aborted;
      resolve(HttpResponse.json(springPage));
    }, { once: true });
    started();
  })));

  const controller = new AbortController();
  const pending = queryClients()(context(controller.signal));
  await requestStarted;
  controller.abort(new DOMException("cancelled", "AbortError"));

  await expect(pending).rejects.toMatchObject({ name: "ApiQueryError", apiError: { kind: "cancelled" } });
  expect(observedAbort).toBe(true);
});
