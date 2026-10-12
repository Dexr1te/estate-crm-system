"use client";

import { useEffect, type ReactNode } from "react";
import { useRouter } from "next/navigation";

type Props = { canonicalHref: string; staleIdentityHref: string; logoutRaceHref: string; children: ReactNode };

export function ProofRouteActions({ canonicalHref, staleIdentityHref, logoutRaceHref, children }: Props) {
  const router = useRouter();

  useEffect(() => {
    const canonical = () => router.push(canonicalHref);
    const staleIdentity = () => router.push(staleIdentityHref);
    const logoutRace = () => router.push(logoutRaceHref);
    window.addEventListener("b08-proof-canonical", canonical);
    window.addEventListener("b08-proof-stale-identity", staleIdentity);
    window.addEventListener("b08-proof-logout-race", logoutRace);
    return () => {
      window.removeEventListener("b08-proof-canonical", canonical);
      window.removeEventListener("b08-proof-stale-identity", staleIdentity);
      window.removeEventListener("b08-proof-logout-race", logoutRace);
    };
  }, [canonicalHref, logoutRaceHref, router, staleIdentityHref]);

  return children;
}
