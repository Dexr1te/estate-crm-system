"use client";

import type { QueryFunction, QueryKey } from "@tanstack/react-query";
import { bffJson } from "../api/transport.ts";
import { runResourceRequest } from "../../features/auth/session-client.ts";
import { ApiQueryError } from "./cache.ts";

function project<T>(value: unknown, decode: (value: unknown) => T): T {
  try {
    return decode(value);
  } catch {
    throw new ApiQueryError({ kind: "malformed", status: 502, format: "json", message: "The API response was invalid." });
  }
}

export function bffQueryFn<T>(path: string, decode: (value: unknown) => T): QueryFunction<T, QueryKey> {
  return async ({ signal }) => {
    const result = await runResourceRequest(() => bffJson<unknown>(path, { signal }));
    if (!result.ok) throw new ApiQueryError(result.error);
    if (result.data === undefined) {
      throw new ApiQueryError({ kind: "malformed", status: 502, format: "empty", message: "The API response was empty." });
    }
    return project(result.data, decode);
  };
}

export async function bffMutation<T>(path: string, init: RequestInit, decode: (value: unknown) => T): Promise<T> {
  const result = await runResourceRequest(() => bffJson<unknown>(path, init));
  if (!result.ok) throw new ApiQueryError(result.error);
  return project(result.data, decode);
}
