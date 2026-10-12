export type SessionIdentity = {
  userId: number;
  fullName: string;
  email: string;
  role: "AGENT" | "MANAGER" | "ADMIN";
  dataScope: "OWN" | "TEAM" | "ALL";
  status: "PENDING_INVITE" | "ACTIVE" | "DEACTIVATED";
  teamId: number | null;
  teamName: string | null;
  teamCurrency: string | null;
  mustChangePassword: boolean;
};

export function sessionIdentityScope(identity: SessionIdentity): string {
  return JSON.stringify([
    identity.userId,
    identity.email,
    identity.teamId,
    identity.role,
    identity.dataScope,
    identity.status,
    identity.mustChangePassword,
  ]);
}
