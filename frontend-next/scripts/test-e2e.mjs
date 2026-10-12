import { randomUUID } from "node:crypto";
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const cli = join(root, "node_modules/@playwright/test/cli.js");
const runId = randomUUID();
const child = spawn(process.execPath, [cli, "test", "--config=playwright.config.ts", ...process.argv.slice(2)], {
  cwd: root,
  env: { ...process.env, B09_RUN_ID: runId },
  stdio: "inherit",
});

const forward = (signal) => child.kill(signal);
process.once("SIGINT", () => forward("SIGINT"));
process.once("SIGTERM", () => forward("SIGTERM"));
child.once("error", (error) => {
  process.stderr.write(`Could not start Playwright: ${error.message}\n`);
  process.exitCode = 1;
});
child.once("exit", (code, signal) => {
  process.exitCode = code ?? (signal ? 1 : 0);
});
