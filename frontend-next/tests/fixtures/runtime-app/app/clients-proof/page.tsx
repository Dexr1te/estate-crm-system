import { dehydrate } from "@tanstack/react-query";
import { headers } from "next/headers";
import { Suspense } from "react";
import { SessionVerified } from "@/features/auth/session-verified.tsx";
import { parseClientListUrl, serializeClientListUrl, clientListQueryKey } from "@/features/clients/client-list-url.ts";
import { backendJson } from "@/lib/server/backend.ts";
import { getServerRuntimeConfig } from "@/lib/server/env.ts";
import { readRscRouteAccess, RouteAccessFallback } from "@/lib/server/route-access.tsx";
import { accessCookieName, readSessionBearer } from "@/lib/server/session.ts";
import { createPrivateQueryClient } from "@/lib/query/cache.ts";
import { ClientListProof } from "./client-list-proof";
import { decodeClientListProof } from "./client-page";
import { ProofRouteActions } from "./proof-route-actions";
import type { SessionIdentity } from "@/lib/session-types.ts";

export const dynamic = "force-dynamic";

type SearchParams = Record<string, string | string[] | undefined>;

const staleProofIdentity: SessionIdentity = {
  userId: 71,
  fullName: "Ada Agent",
  email: "ada@example.test",
  role: "AGENT",
  dataScope: "OWN",
  status: "ACTIVE",
  teamId: null,
  teamName: null,
  teamCurrency: null,
  mustChangePassword: false,
};

function toUrlSearchParams(search: SearchParams): URLSearchParams {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(search)) {
    if (Array.isArray(value)) for (const item of value) params.append(key, item);
    else if (value !== undefined) params.set(key, value);
  }
  return params;
}

export default async function ClientsProofPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const access = await readRscRouteAccess("authenticated");
  if (access.status !== "allowed") return <RouteAccessFallback access={access} />;

  const params = toUrlSearchParams(await searchParams);
  const staleIdentityProof = params.get("proof-stale-identity") === "1";
  const closeAfterHydrationProof = params.get("proof-close-after-hydration") === "1";
  params.delete("proof-stale-identity");
  params.delete("proof-close-after-hydration");
  const state = parseClientListUrl(params);
  const identity = staleIdentityProof ? staleProofIdentity : access.identity;
  const requestHeaders = await headers();
  const config = getServerRuntimeConfig();
  const bearerToken = readSessionBearer(requestHeaders.get("cookie"), accessCookieName(config.webOrigin));
  const result = staleIdentityProof
    ? { ok: true as const, data: { content: [{ id: 771, fullName: "A_STALE_RSC" }], totalElements: 1, totalPages: 1, number: 0, size: 20, first: true, last: true } }
    : bearerToken
      ? await backendJson<unknown>(`/clients?${serializeClientListUrl(state)}`, { bearerToken })
      : { ok: false as const, error: { kind: "unauthenticated" as const, format: "none" as const, message: "Sign in to continue." } };
  const queryClient = createPrivateQueryClient();
  if (result.ok && result.data !== undefined) {
    try {
      const value = closeAfterHydrationProof
        ? { content: [{ id: 779, fullName: "A_QUEUED_AFTER_CLOSE" }], totalElements: 1, totalPages: 1, number: 0, size: 20, first: true, last: true }
        : decodeClientListProof(result.data);
      queryClient.setQueryData(clientListQueryKey(identity, state), value, closeAfterHydrationProof ? { updatedAt: 4_102_444_800_000 } : undefined);
    } catch {
      // An invalid Page or unsafe numeric ID is left uncached; the query boundary renders its own typed error.
    }
  }

  const proofQuery = serializeClientListUrl({ tags: ["VIP", "Repeat"], page: 0, size: 20, sort: [] });
  return (
    <ProofRouteActions
      canonicalHref={`/clients-proof?${proofQuery}`}
      staleIdentityHref={`/clients-proof?proof-stale-identity=1&${proofQuery}`}
      logoutRaceHref={`/clients-proof?proof-close-after-hydration=1&${proofQuery}`}
    >
      <SessionVerified identity={identity} dehydratedState={dehydrate(queryClient)}>
        <Suspense fallback={<main data-testid="query-status" data-state="loading">loading</main>}>
          <ClientListProof identity={identity} />
        </Suspense>
      </SessionVerified>
    </ProofRouteActions>
  );
}
