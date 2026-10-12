import "server-only";
import { isLocalDate } from "../api/wire-values.ts";
import { isClientListSort } from "../../features/clients/client-list-contract.ts";

export type PrivateOperation = {
  id: "API028" | "API074" | "API075" | "API076" | "API078" | "API152" | "API153" | "API161" | "API164";
  method: "GET" | "POST" | "PUT";
  kind: "json" | "image" | "document" | "upload" | "export";
  path: string;
};

const maxLong = 9_223_372_036_854_775_807n;
const exportKinds = new Set(["clients", "properties", "deals"]);
const exportQueryKeys = new Set([
  "lang", "delimiter", "type", "status", "source", "city", "agentId", "search", "minPrice", "maxPrice",
  "rooms", "createdFrom", "createdTo", "closedFrom", "closedTo", "tags", "leadSource",
]);
const clientQueryKeys = new Set([
  "type", "agentId", "search", "createdFrom", "createdTo", "tags", "leadSource", "page", "size", "sort",
]);

function isId(value: string | undefined): value is string {
  if (!value || !/^[1-9]\d{0,18}$/.test(value)) return false;
  try {
    return BigInt(value) <= maxLong;
  } catch {
    return false;
  }
}

function noQuery(requestUrl: URL): boolean {
  return requestUrl.search === "";
}

function validClientPageQuery(requestUrl: URL): boolean {
  const seen = new Set<string>();
  for (const key of requestUrl.searchParams.keys()) {
    if (!clientQueryKeys.has(key) || (key !== "tags" && key !== "sort" && seen.has(key))) return false;
    seen.add(key);
  }
  const page = requestUrl.searchParams.get("page");
  const size = requestUrl.searchParams.get("size");
  if (page === null || size === null || !/^(0|[1-9]\d*)$/.test(page) || !/^[1-9]\d*$/.test(size)) return false;
  const pageNumber = Number(page);
  const pageSize = Number(size);
  if (!Number.isSafeInteger(pageNumber) || pageNumber > 2_147_483_647 || !Number.isSafeInteger(pageSize) || pageSize > 100) return false;
  const agentId = requestUrl.searchParams.get("agentId");
  if (agentId !== null && !isId(agentId)) return false;
  for (const key of ["createdFrom", "createdTo"]) {
    const value = requestUrl.searchParams.get(key);
    if (value !== null && !isLocalDate(value)) return false;
  }
  const sorts = requestUrl.searchParams.getAll("sort");
  if (sorts.length > 3 || sorts.some((value) => !isClientListSort(value)) || new Set(sorts.map((value) => value.split(",", 1)[0])).size !== sorts.length) return false;
  return true;
}

export function matchPrivateOperation(path: string[], requestUrl: URL, requestMethod: string): PrivateOperation | null {
  if (path.some((part) => !/^[A-Za-z0-9_-]+$/.test(part))) return null;
  const [a, b, c, d, e] = path;
  if (a === "clients" && path.length === 1 && requestMethod.toUpperCase() === "GET" && validClientPageQuery(requestUrl)) {
    return { id: "API028", method: "GET", kind: "json", path: "/clients" };
  }
  if (a === "deals" && isId(b) && c === "documents" && path.length === 3 && noQuery(requestUrl)) {
    return requestMethod.toUpperCase() === "POST"
      ? { id: "API076", method: "POST", kind: "upload", path: `/deals/${b}/documents` }
      : { id: "API074", method: "GET", kind: "json", path: `/deals/${b}/documents` };
  }
  if (a === "deals" && isId(b) && c === "documents" && isId(d) && e === "content" && path.length === 5 && noQuery(requestUrl)) {
    return { id: "API075", method: "GET", kind: "document", path: `/deals/${b}/documents/${d}/content` };
  }
  if (a === "properties" && isId(b) && c === "photos" && d === "order" && path.length === 4 && noQuery(requestUrl)) {
    return { id: "API164", method: "PUT", kind: "json", path: `/properties/${b}/photos/order` };
  }
  if (a === "properties" && isId(b) && c === "cover" && path.length === 3 && noQuery(requestUrl)) {
    return { id: "API152", method: "GET", kind: "image", path: `/properties/${b}/cover` };
  }
  if (a === "properties" && isId(b) && c === "photos" && isId(d) && e === "content" && path.length === 5 && noQuery(requestUrl)) {
    return { id: "API153", method: "GET", kind: "image", path: `/properties/${b}/photos/${d}/content` };
  }
  if (a === "properties" && isId(b) && c === "photos" && path.length === 3 && noQuery(requestUrl)) {
    return { id: "API161", method: "POST", kind: "upload", path: `/properties/${b}/photos` };
  }
  if (a === "export" && exportKinds.has(b ?? "") && path.length === 2) {
    const seen = new Set<string>();
    for (const key of requestUrl.searchParams.keys()) {
      if (!exportQueryKeys.has(key) || (key !== "tags" && seen.has(key))) return null;
      seen.add(key);
    }
    return { id: "API078", method: "GET", kind: "export", path: `/export/${b}` };
  }
  return null;
}

export function operationApiPath(operation: PrivateOperation, requestUrl: URL): string {
  return operation.id === "API028" || operation.kind === "export" ? `${operation.path}${requestUrl.search}` : operation.path;
}

