import { notFound } from "next/navigation";
import { AppShell } from "@/components/layout/app-shell.tsx";
import { SessionVerified } from "@/features/auth/session-verified.tsx";
import { canEnterRoute } from "@/lib/navigation/entry.ts";
import { readRscRouteAccess, RouteAccessFallback } from "@/lib/server/route-access.tsx";

export const dynamic = "force-dynamic";

const proofRoutes = {
  shell: { requirement: "authenticated", label: "Shell" },
  team: { requirement: "team", label: "Team gate" },
  admin: { requirement: "admin", label: "Admin gate" },
} as const;
const proofNavigation = [
  { label: "Shell proof", href: "/proof/shell", requirement: "authenticated" },
  { label: "Team gate", href: "/proof/team", requirement: "team" },
  { label: "Admin gate", href: "/proof/admin", requirement: "admin" },
] as const;

export default async function EntryShellProofPage({ params }: { params: Promise<{ kind: string }> }) {
  const { kind } = await params;
  if (!Object.hasOwn(proofRoutes, kind)) notFound();
  const route = proofRoutes[kind as keyof typeof proofRoutes];
  const access = await readRscRouteAccess(route.requirement);
  if (access.status !== "allowed") return <RouteAccessFallback access={access} />;

  return (
    <SessionVerified identity={access.identity}>
      <AppShell
        breadcrumbs={[{ label: "Proof", href: "/proof/shell" }, { label: route.label }]}
        identity={{
          fullName: access.identity.fullName,
          role: access.identity.role,
          teamName: access.identity.teamName,
        }}
        navigation={proofNavigation.filter((item) => canEnterRoute(access.identity, item.requirement))}
      >
        <section data-private-marker={"PRIVATE_B07_" + kind.toUpperCase()}>
          <h1>{route.label}</h1>
          <p>PRIVATE_B07_{kind.toUpperCase()}</p>
        </section>
      </AppShell>
    </SessionVerified>
  );
}
