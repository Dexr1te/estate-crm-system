"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useMemo, useRef } from "react";
import { clientListApiPath, clientListHref, clientListQueryKey, parseClientListUrl } from "@/features/clients/client-list-url.ts";
import { bffQueryFn } from "@/lib/query/browser.ts";
import { privateQueryKey } from "@/lib/query/cache.ts";
import type { SessionIdentity } from "@/lib/session-types.ts";
import type { ApiQueryError } from "@/lib/query/cache.ts";
import type { ClientListProofDTO } from "./client-page";
import { decodeClientListProof } from "./client-page";
import type { Page } from "@/lib/api/page.ts";
import { getSessionGeneration, loginSession, logoutSession, sessionMe } from "@/features/auth/session-client.ts";

export function ClientListProof({ identity }: { identity: SessionIdentity }) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const queryClient = useQueryClient();
  const queryString = searchParams.toString();
  const closeAfterHydration = searchParams.get("proof-close-after-hydration") === "1";
  const closeStarted = useRef(false);
  const state = useMemo(() => {
    const params = new URLSearchParams(queryString);
    params.delete("proof-stale-identity");
    params.delete("proof-close-after-hydration");
    return parseClientListUrl(params);
  }, [queryString]);
  const key = clientListQueryKey(identity, state);
  const query = useQuery<Page<ClientListProofDTO>, ApiQueryError>({
    queryKey: key,
    queryFn: bffQueryFn(clientListApiPath(state), decodeClientListProof),
  });

  useEffect(() => {
    Object.assign(window as Window & { __b08SessionActions?: unknown }, {
      __b08SessionActions: {
        login: () => loginSession("ada@example.test", "proof-password"),
        logout: () => logoutSession(),
        startDelayedRead: () => { void queryClient.fetchQuery({
          queryKey: privateQueryKey(identity, "clients", { delayProof: true }),
          queryFn: bffQueryFn("/api/backend/clients?page=0&size=20&search=slow-proof", decodeClientListProof),
          staleTime: 0,
        }).catch(() => undefined); },
        verifySession: () => sessionMe(),
        refresh: () => router.refresh(),
        generation: () => getSessionGeneration(),
        cachedNames: () => queryClient.getQueryCache().getAll().flatMap((entry) => {
          const data = entry.state.data as Page<ClientListProofDTO> | undefined;
          return data?.content.map((client) => client.fullName) ?? [];
        }),
      },
    });
  }, [identity, pathname, queryClient, router, state]);

  useEffect(() => {
    if (!closeAfterHydration || closeStarted.current) return;
    closeStarted.current = true;
    const pending = logoutSession();
    Object.assign(window as Window & { __b08HydrationClose?: Promise<unknown> }, { __b08HydrationClose: pending });
  }, [closeAfterHydration]);

  const status = query.isPending ? "loading" : query.isError ? "error" : query.data.content.length === 0 ? "empty" : "ready";
  const next = { ...state, page: state.page + 1 };

  return (
    <main data-private-client-list="true" data-session-scope={identity.dataScope}>
      <h1>B08 API028 client list proof</h1>
      <output data-testid="query-status" data-state={status}>{status}</output>
      <output data-testid="url-state">{JSON.stringify(state)}</output>
      {query.isError ? <output data-testid="query-error" data-kind={query.error.apiError.kind} data-code={query.error.apiError.code ?? ""}>{query.error.message}</output> : null}
      <ul data-testid="client-rows">
        {query.data?.content.map((client) => <li key={client.id} data-client-id={client.id}>{client.fullName}</li>)}
      </ul>
      <button type="button" data-testid="apply-search" onClick={() => router.push(clientListHref({ ...state, search: "ada", page: 0 }, pathname))}>
        Apply search
      </button>
      <button type="button" data-testid="next-page" disabled={query.data?.last ?? false} onClick={() => router.push(clientListHref(next, pathname))}>
        Next page
      </button>
      <button type="button" data-testid="refresh-list" onClick={() => router.refresh()}>Refresh URL state</button>
      <button type="button" data-testid="request-error" onClick={() => router.push(clientListHref({ ...state, search: "structured-error", page: 0 }, pathname))}>
        Request fixture error
      </button>
    </main>
  );
}
