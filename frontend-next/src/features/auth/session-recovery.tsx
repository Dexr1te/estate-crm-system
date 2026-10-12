"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  claimRscSignoutRefresh,
  claimRscRefresh,
  logoutSession,
  recoverRscSession,
  resetRscRecoveryAttempt,
} from "./session-client.ts";
import { sessionRecoveryPresentation, type SessionRecoveryReason } from "./session-recovery-state.ts";

export type { SessionRecoveryReason } from "./session-recovery-state.ts";

type Props = { reason: SessionRecoveryReason };

export function SessionRecovery({ reason }: Props) {
  const router = useRouter();
  const [busy, setBusy] = useState(reason === "recover" || reason === "signout");
  const [message, setMessage] = useState("");
  const [terminal, setTerminal] = useState(false);
  const [recoveryComplete, setRecoveryComplete] = useState(false);

  useEffect(() => {
    let mounted = true;
    const refreshRoute = () => {
      if (mounted && claimRscRefresh()) router.refresh();
    };

    if (reason === "signout") {
      void logoutSession().then((result) => {
        if (!mounted) return;
        if (result.ok) {
          setBusy(false);
          if (claimRscSignoutRefresh()) router.refresh();
        }
        else {
          setBusy(false);
          setMessage("The session could not be closed. Try again.");
        }
      });
    } else if (reason === "recover") {
      void recoverRscSession().then((result) => {
        if (!mounted) return;
        if (result.refreshed) refreshRoute();
        else {
          setTerminal(Boolean(result.terminal));
          setRecoveryComplete(true);
          setBusy(false);
          setMessage("");
        }
      });
    }

    return () => {
      mounted = false;
    };
  }, [reason, router]);

  async function retry() {
    setBusy(true);
    setMessage("");
    if (reason === "recover") {
      setRecoveryComplete(false);
      resetRscRecoveryAttempt();
      const result = await recoverRscSession();
      if (result.refreshed) {
        if (claimRscRefresh()) router.refresh();
      } else {
        setTerminal(Boolean(result.terminal));
        setRecoveryComplete(true);
        setBusy(false);
        setMessage("");
      }
      return;
    }
    if (reason === "signout") {
      const result = await logoutSession();
      if (result.ok) {
        setBusy(false);
        if (claimRscSignoutRefresh()) router.refresh();
      }
      else {
        setBusy(false);
        setMessage("The session could not be closed. Try again.");
      }
      return;
    }
    setBusy(false);
    router.refresh();
  }

  const presentation = sessionRecoveryPresentation(reason, terminal, recoveryComplete);

  return (
    <main aria-live="polite" aria-busy={busy}>
      <p>{message || presentation.message}</p>
      {presentation.canRetry && !busy ? (
        <button type="button" onClick={() => void retry()}>Try again</button>
      ) : null}
    </main>
  );
}
