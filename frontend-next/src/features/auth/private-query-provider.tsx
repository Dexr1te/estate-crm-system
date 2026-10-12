"use client";

import { HydrationBoundary, QueryClientProvider, type DehydratedState } from "@tanstack/react-query";
import { useCallback, useEffect, useMemo, useRef, useState, useSyncExternalStore, type ReactNode } from "react";
import { createPrivateQueryClient, privateHydrationState } from "../../lib/query/cache.ts";
import { sessionIdentityScope, type SessionIdentity } from "../../lib/session-types.ts";
import { getSessionLifecycle, subscribeSessionLifecycle } from "./session-client.ts";

type Props = {
  identity: SessionIdentity;
  dehydratedState?: DehydratedState;
  verificationFailed?: boolean;
  onRetryVerification?: () => void;
  children: ReactNode;
};

export function PrivateQueryProvider({ identity, dehydratedState, verificationFailed = false, onRetryVerification, children }: Props) {
  const scope = sessionIdentityScope(identity);
  const [client] = useState(createPrivateQueryClient);
  const serverSnapshot = useMemo(() => ({ generation: 0, closing: false, identityScope: scope }), [scope]);
  const getServerSnapshot = useCallback(() => serverSnapshot, [serverSnapshot]);
  const lifecycle = useSyncExternalStore(subscribeSessionLifecycle, getSessionLifecycle, getServerSnapshot);
  const hadMatchingScope = useRef(false);
  const visible = !lifecycle.closing && lifecycle.identityScope === scope;
  const allowedState = privateHydrationState(scope, lifecycle, dehydratedState);

  useEffect(() => {
    const current = getSessionLifecycle();
    if (current.closing) {
      void client.cancelQueries();
      client.clear();
    } else if (current.identityScope === scope) {
      hadMatchingScope.current = true;
    }
    return subscribeSessionLifecycle(() => {
      const next = getSessionLifecycle();
      if (next.closing || (hadMatchingScope.current && next.identityScope !== scope)) {
        void client.cancelQueries();
        client.clear();
        hadMatchingScope.current = false;
      } else if (next.identityScope === scope) {
        hadMatchingScope.current = true;
      }
    });
  }, [client, scope]);

  // HydrationBoundary may apply newer dehydrated data in a passive effect after
  // a child closes the session. Recheck live lifecycle state after that effect
  // and clear again so queued hydration cannot repopulate a closed cache.
  useEffect(() => {
    const current = getSessionLifecycle();
    if (current.closing || (current.identityScope !== null && current.identityScope !== scope)) {
      void client.cancelQueries();
      client.clear();
    }
  }, [client, lifecycle.generation, lifecycle.closing, lifecycle.identityScope, scope]);

  useEffect(() => () => {
    void client.cancelQueries();
    client.clear();
  }, [client]);

  return (
    <QueryClientProvider client={client}>
      <HydrationBoundary state={allowedState}>
        {visible ? children : (
          <div role="status">
            {verificationFailed && !lifecycle.closing ? (
              <>
                <p>We could not verify the current session.</p>
                <button type="button" data-testid="retry-session" onClick={onRetryVerification}>Retry</button>
              </>
            ) : "Verifying session…"}
          </div>
        )}
      </HydrationBoundary>
    </QueryClientProvider>
  );
}
