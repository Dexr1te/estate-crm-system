import { SessionRecovery } from "@/features/auth/session-recovery.tsx";
import { SessionVerified } from "@/features/auth/session-verified.tsx";
import { readRscSession } from "@/lib/server/rsc-session.ts";

export const dynamic = "force-dynamic";

export default async function SessionProofPage() {
  const [session, repeatedSession] = await Promise.all([readRscSession(), readRscSession()]);
  if (session !== repeatedSession) throw new Error("RSC session reads were not memoized for this render");
  if (session.status === "active") {
    return (
      <SessionVerified identity={session.identity}>
        <main data-session="active">
          <p>{session.identity.fullName}</p>
          <p>PRIVATE_RSC_CONTENT</p>
        </main>
      </SessionVerified>
    );
  }
  if (session.status === "anonymous") return <main data-session="anonymous">Sign in required.</main>;

  return (
    <main data-session={session.status}>
      <SessionRecovery reason={session.status} />
    </main>
  );
}
