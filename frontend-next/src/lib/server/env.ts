import "server-only";

import { parseServerRuntimeConfig } from "./backend-config.ts";

export function getServerRuntimeConfig() {
  return parseServerRuntimeConfig({
    BACKEND_API_URL: process.env.BACKEND_API_URL,
    WEB_ORIGIN: process.env.WEB_ORIGIN,
  });
}
