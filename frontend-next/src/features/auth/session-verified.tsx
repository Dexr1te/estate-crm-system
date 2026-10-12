"use client";

import { useEffect, type ReactNode } from "react";
import { useCallback, useMemo, useRef, useState, useSyncExternalStore } from "react";
import { useRouter } from "next/navigation";
import type { DehydratedState } from "@tanstack/react-query";
import { sessionIdentityScope, type SessionIdentity } from "../../lib/session-types.ts";
import { PrivateQueryProvider } from "./private-query-provider.tsx";
import { getSessionLifecycle, reconcileRscSession, subscribeSessionLifecycle } from "./session-client.ts";

type Props = { identity: SessionIdentity; dehydratedState?: DehydratedState; children: ReactNode };

export function SessionVerified({ identity, dehydratedState, children }: Props) {
  const router = useRouter();
  const scope = sessionIdentityScope(identity);
  const serverSnapshot = useMemo(() => ({ generation: 0, closing: false, identityScope: scope }), [scope]);
  const getServerSnapshot = useCallback(() => serverSnapshot, [serverSnapshot]);
  const lifecycle = useSyncExternalStore(subscribeSessionLifecycle, getSessionLifecycle, getServerSnapshot);
  const refreshFor = useRef<string | null>(null);
  const [verificationFailed, setVerificationFailed] = useState(false);
  const [retryAttempt, setRetryAttempt] = useState(0);
  const retryVerification = useCallback(() => {
    refreshFor.current = null;
    setVerificationFailed(false);
    setRetryAttempt((current) => current + 1);
  }, []);

  useEffect(() => {
    if (lifecycle.closing) return;
    let active = true;
    void reconcileRscSession(identity).then((result) => {
      if (!active || getSessionLifecycle().closing) return;
      setVerificationFailed(result === "unavailable");
      if (result === "verified" || result === "unavailable") return;
      const key = `${getSessionLifecycle().generation}:${scope}`;
      if (refreshFor.current === key) return;
      refreshFor.current = key;
      router.refresh();
    }).catch(() => {
      if (active && !getSessionLifecycle().closing) setVerificationFailed(true);
    });
    return () => { active = false; };
  }, [identity, lifecycle.closing, lifecycle.generation, retryAttempt, router, scope]);

  return (
    <PrivateQueryProvider
      key={scope}
      identity={identity}
      dehydratedState={dehydratedState}
      verificationFailed={verificationFailed}
      onRetryVerification={retryVerification}
    >
      {children}
    </PrivateQueryProvider>
  );
}
