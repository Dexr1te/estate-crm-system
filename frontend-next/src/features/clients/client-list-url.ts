import { isLocalDate, isLongIdString } from "../../lib/api/wire-values.ts";
import { privateQueryKey } from "../../lib/query/cache.ts";
import type { SessionIdentity } from "../../lib/session-types.ts";
import { isClientListSort } from "./client-list-contract.ts";

export type ClientListState = {
  type?: string;
  agentId?: string;
  search?: string;
  createdFrom?: string;
  createdTo?: string;
  tags: string[];
  leadSource?: string;
  page: number;
  size: number;
  sort: string[];
};

const scalarKeys = ["type", "agentId", "search", "createdFrom", "createdTo", "leadSource", "page", "size"] as const;
const queryKeys = new Set([...scalarKeys, "tags", "sort"]);

function scalar(params: URLSearchParams, key: typeof scalarKeys[number]): string | undefined {
  const values = params.getAll(key);
  if (values.length > 1) throw new TypeError(`Duplicate ${key} parameter.`);
  return values[0];
}

function pageNumber(value: string | undefined, fallback: number, max: number): number {
  if (value === undefined) return fallback;
  if (!/^(0|[1-9]\d*)$/.test(value)) throw new TypeError("Invalid pagination parameter.");
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed > max) throw new TypeError("Invalid pagination parameter.");
  return parsed;
}

export function parseClientListUrl(params: URLSearchParams): ClientListState {
  for (const key of params.keys()) if (!queryKeys.has(key)) throw new TypeError(`Unsupported client filter: ${key}.`);
  const type = scalar(params, "type");
  const agentId = scalar(params, "agentId");
  const search = scalar(params, "search");
  const createdFrom = scalar(params, "createdFrom");
  const createdTo = scalar(params, "createdTo");
  const leadSource = scalar(params, "leadSource");
  if (agentId !== undefined && !isLongIdString(agentId)) throw new TypeError("Invalid agentId parameter.");
  if (createdFrom !== undefined && !isLocalDate(createdFrom)) throw new TypeError("Invalid createdFrom parameter.");
  if (createdTo !== undefined && !isLocalDate(createdTo)) throw new TypeError("Invalid createdTo parameter.");
  const sort = params.getAll("sort");
  if (sort.length > 3 || sort.some((value) => !isClientListSort(value)) || new Set(sort.map((value) => value.split(",", 1)[0])).size !== sort.length) {
    throw new TypeError("Invalid sort parameter.");
  }
  const page = pageNumber(scalar(params, "page"), 0, 2_147_483_647);
  const size = pageNumber(scalar(params, "size"), 20, 100);
  if (size === 0) throw new TypeError("Invalid size parameter.");
  return {
    ...(type === undefined ? {} : { type }),
    ...(agentId === undefined ? {} : { agentId }),
    ...(search === undefined ? {} : { search }),
    ...(createdFrom === undefined ? {} : { createdFrom }),
    ...(createdTo === undefined ? {} : { createdTo }),
    tags: params.getAll("tags"),
    ...(leadSource === undefined ? {} : { leadSource }),
    page,
    size,
    sort,
  };
}

export function serializeClientListUrl(state: ClientListState): string {
  if (state.sort.length > 3 || state.sort.some((value) => !isClientListSort(value)) || new Set(state.sort.map((value) => value.split(",", 1)[0])).size !== state.sort.length) {
    throw new TypeError("Invalid sort parameter.");
  }
  const params = new URLSearchParams();
  if (state.type !== undefined) params.set("type", state.type);
  if (state.agentId !== undefined) params.set("agentId", state.agentId);
  if (state.search !== undefined && state.search !== "") params.set("search", state.search);
  if (state.createdFrom !== undefined) params.set("createdFrom", state.createdFrom);
  if (state.createdTo !== undefined) params.set("createdTo", state.createdTo);
  for (const tag of state.tags) params.append("tags", tag);
  if (state.leadSource !== undefined) params.set("leadSource", state.leadSource);
  params.set("page", String(state.page));
  params.set("size", String(state.size));
  for (const sort of state.sort) params.append("sort", sort);
  return params.toString();
}

export function clientListApiPath(state: ClientListState): string {
  return `/api/backend/clients?${serializeClientListUrl(state)}`;
}

export function clientListQueryKey(identity: SessionIdentity, state: ClientListState) {
  return privateQueryKey(identity, "clients", {
    type: state.type ?? null,
    agentId: state.agentId ?? null,
    search: state.search || null,
    createdFrom: state.createdFrom ?? null,
    createdTo: state.createdTo ?? null,
    tags: [...state.tags],
    leadSource: state.leadSource ?? null,
    page: state.page,
    size: state.size,
    sort: [...state.sort],
  });
}

export function clientListHref(state: ClientListState, pathname = "/clients"): string {
  return `${pathname}?${serializeClientListUrl(state)}`;
}
