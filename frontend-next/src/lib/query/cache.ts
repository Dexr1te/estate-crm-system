import { QueryClient, type DehydratedState } from "@tanstack/react-query";
import type { ApiError } from "../api/transport.ts";
import type { SessionIdentity } from "../session-types.ts";
import { sessionIdentityScope } from "../session-types.ts";
import type { SessionLifecycle } from "../../features/auth/session-client.ts";

export class ApiQueryError extends Error {
  readonly apiError: ApiError;

  constructor(apiError: ApiError) {
    super(apiError.message);
    this.apiError = apiError;
    this.name = "ApiQueryError";
  }
}

export type PrivateQueryKey = readonly [number, number | null, string, string, string, ...unknown[]];

export function privateQueryKey(identity: SessionIdentity, domain: string, ...filters: unknown[]): PrivateQueryKey {
  return [identity.userId, identity.teamId, identity.dataScope, sessionIdentityScope(identity), domain, ...filters];
}

export function privateHydrationState(
  identityScope: string,
  lifecycle: SessionLifecycle,
  state: DehydratedState | undefined,
): DehydratedState | undefined {
  return !lifecycle.closing && lifecycle.identityScope === identityScope ? state : undefined;
}

export function shouldRetryPrivateRead(failureCount: number, error: unknown): boolean {
  if (failureCount >= 1 || !(error instanceof ApiQueryError)) return false;
  return ["network", "timeout", "unavailable"].includes(error.apiError.kind);
}

export function createPrivateQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: { staleTime: 30_000, retry: shouldRetryPrivateRead },
      mutations: { retry: false },
    },
  });
}
