import type { Page } from "@/lib/api/page.ts";
import { requireSafeApiId } from "@/lib/api/wire-values.ts";
import { decodeClientListPage } from "@/features/clients/client-list-contract.ts";

export type ClientListProofDTO = { id: number; fullName: string };

export function decodeClientListProof(value: unknown): Page<ClientListProofDTO> {
  return decodeClientListPage(value, (item) => {
    if (typeof item !== "object" || item === null || Array.isArray(item)) {
      throw new TypeError("The client list response was invalid.");
    }
    const row = item as Record<string, unknown>;
    if (typeof row.fullName !== "string") throw new TypeError("The client list response was invalid.");
    return { id: requireSafeApiId(row.id), fullName: row.fullName };
  });
}
