import { mkdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { defineConfig } from "@playwright/test";

const evidenceBase = "/private/tmp/estate-crm-next-b09-evidence";
const runId = process.env.B09_RUN_ID ?? "";
if (!/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(runId)) {
  throw new Error("B09_RUN_ID must be a UUID created by npm run test:e2e.");
}
const runDir = join(evidenceBase, runId);
const evidenceDir = join(runDir, "test-results");
mkdirSync(runDir, { recursive: true });

export default defineConfig({
  testDir: "./tests/e2e",
  testMatch: "**/*.spec.ts",
  fullyParallel: false,
  workers: 1,
  retries: 0,
  timeout: 300_000,
  outputDir: evidenceDir,
  reporter: [["list"], ["json", { outputFile: resolve(runDir, "results.json") }]],
});
