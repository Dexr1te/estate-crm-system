import { spawn, type ChildProcess } from "node:child_process";
import { createServer } from "node:net";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { test, type TestInfo } from "@playwright/test";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const chrome = process.env.B09_BROWSER_EXECUTABLE || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const proofTimeout = 270_000;

function signalProof(child: ChildProcess, signal: NodeJS.Signals): void {
  if (!child.pid) return;
  try {
    if (process.platform === "win32") child.kill(signal);
    else process.kill(-child.pid, signal);
  } catch {
    child.kill(signal);
  }
}

function processGroupExists(pid: number): boolean {
  try {
    process.kill(-pid, 0);
    return true;
  } catch (error) {
    return (error as NodeJS.ErrnoException).code === "EPERM";
  }
}

async function stopProof(child: ChildProcess): Promise<void> {
  if (!child.pid || child.exitCode !== null || child.signalCode !== null) return;
  const pid = child.pid;
  const closed = new Promise<void>((resolvePromise) => child.once("close", () => resolvePromise()));
  signalProof(child, "SIGTERM");
  let graceTimer: NodeJS.Timeout | undefined;
  const closedGracefully = await Promise.race([
    closed.then(() => true),
    new Promise<boolean>((resolvePromise) => { graceTimer = setTimeout(() => resolvePromise(false), 5_000); }),
  ]);
  if (graceTimer) clearTimeout(graceTimer);
  if (!closedGracefully) signalProof(child, "SIGKILL");
  const deadline = Date.now() + 5_000;
  while (processGroupExists(pid) && Date.now() < deadline) {
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
  }
  if (processGroupExists(pid)) signalProof(child, "SIGKILL");
}

async function stopFailedGroup(child: ChildProcess): Promise<void> {
  if (process.platform === "win32" || !child.pid) return;
  const pid = child.pid;
  if (!processGroupExists(pid)) return;
  try {
    process.kill(-pid, "SIGTERM");
  } catch {
    return;
  }
  const deadline = Date.now() + 3_000;
  while (processGroupExists(pid) && Date.now() < deadline) {
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
  }
  if (processGroupExists(pid)) {
    try { process.kill(-pid, "SIGKILL"); } catch { /* The group may have exited. */ }
    const killDeadline = Date.now() + 3_000;
    while (processGroupExists(pid) && Date.now() < killDeadline) {
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
    }
  }
}

function runCommand(label: string, cwd: string, args: string[], env: NodeJS.ProcessEnv, timeoutMs = proofTimeout): Promise<void> {
  const child = spawn(process.execPath, args, {
    cwd,
    env,
    detached: process.platform !== "win32",
    stdio: ["ignore", "pipe", "pipe"],
  });

  return new Promise((resolvePromise, rejectPromise) => {
    let stdout = "";
    let stderr = "";
    let timedOut = false;
    let interrupted: NodeJS.Signals | undefined;
    let spawnError: Error | undefined;
    let forceKill: NodeJS.Timeout | undefined;
    const append = (current: string, chunk: string) => `${current}${chunk}`.slice(-100_000);
    const interrupt = (signal: NodeJS.Signals) => {
      interrupted = signal;
      signalProof(child, "SIGTERM");
      forceKill = setTimeout(() => signalProof(child, "SIGKILL"), 5_000);
    };
    const onInterrupt = () => interrupt("SIGINT");
    const onTerminate = () => interrupt("SIGTERM");
    const timeout = setTimeout(() => {
      timedOut = true;
      signalProof(child, "SIGTERM");
      forceKill = setTimeout(() => signalProof(child, "SIGKILL"), 5_000);
    }, timeoutMs);

    child.stdout?.setEncoding("utf8").on("data", (chunk: string) => { stdout = append(stdout, chunk); });
    child.stderr?.setEncoding("utf8").on("data", (chunk: string) => { stderr = append(stderr, chunk); });
    child.once("error", (error) => { spawnError = error; });
    process.once("SIGINT", onInterrupt);
    process.once("SIGTERM", onTerminate);
    child.once("close", async (code, signal) => {
      clearTimeout(timeout);
      if (forceKill) clearTimeout(forceKill);
      process.off("SIGINT", onInterrupt);
      process.off("SIGTERM", onTerminate);
      const failed = Boolean(spawnError || timedOut || interrupted || code !== 0);
      if (failed) await stopFailedGroup(child);
      const output = `stdout:\n${stdout || "(empty)"}\nstderr:\n${stderr || "(empty)"}`;
      if (spawnError) rejectPromise(new Error(`Could not start ${label}: ${spawnError.message}\n${output}`));
      else if (timedOut) rejectPromise(new Error(`${label} exceeded ${timeoutMs} ms and was terminated.\n${output}`));
      else if (interrupted) rejectPromise(new Error(`${label} was cancelled by ${interrupted}.\n${output}`));
      else if (code !== 0) rejectPromise(new Error(`${label} exited with ${code ?? signal}.\n${output}`));
      else {
        if (stdout) process.stdout.write(stdout.endsWith("\n") ? stdout : `${stdout}\n`);
        if (stderr) process.stderr.write(stderr.endsWith("\n") ? stderr : `${stderr}\n`);
        resolvePromise();
      }
    });
  });
}

function proofEnv(testInfo: TestInfo, outputVariable?: string, extra: NodeJS.ProcessEnv = {}): NodeJS.ProcessEnv {
  return {
    PATH: process.env.PATH ?? "",
    ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
    ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
    NEXT_TELEMETRY_DISABLED: "1",
    B06_BROWSER_EXECUTABLE: chrome,
    B07_BROWSER_EXECUTABLE: chrome,
    B08_BROWSER_EXECUTABLE: chrome,
    ...(outputVariable ? { [outputVariable]: testInfo.outputPath("proof-artifacts") } : {}),
    ...extra,
  };
}

function runProof(testInfo: TestInfo, script: string, outputVariable?: string, extraEnv: NodeJS.ProcessEnv = {}): Promise<void> {
  return runCommand(
    script,
    projectRoot,
    [join(projectRoot, "scripts", script)],
    proofEnv(testInfo, outputVariable, extraEnv),
  );
}

async function availablePort(): Promise<number> {
  const reserve = createServer();
  await new Promise<void>((resolvePromise, rejectPromise) => {
    reserve.once("error", rejectPromise);
    reserve.listen(0, "127.0.0.1", resolvePromise);
  });
  const address = reserve.address();
  if (!address || typeof address === "string") throw new Error("Could not reserve a loopback port for the theme proof.");
  await new Promise<void>((resolvePromise, rejectPromise) => reserve.close((error) => error ? rejectPromise(error) : resolvePromise()));
  return address.port;
}

async function themeBrowserProof(testInfo: TestInfo): Promise<void> {
  const fixture = join(projectRoot, "tests/fixtures/runtime-app");
  const nextBin = join(projectRoot, "node_modules/next/dist/bin/next");
  const port = await availablePort();
  const origin = `http://127.0.0.1:${port}`;
  const env: NodeJS.ProcessEnv = {
    PATH: process.env.PATH ?? "",
    ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
    ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
    BACKEND_API_URL: "http://private-backend-sentinel.invalid/api",
    WEB_ORIGIN: origin,
    NEXT_TELEMETRY_DISABLED: "1",
  };
  await runCommand("theme fixture build", fixture, [nextBin, "build"], env);

  const next = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(port)], {
    cwd: fixture,
    env,
    detached: process.platform !== "win32",
    stdio: ["ignore", "pipe", "pipe"],
  });
  let logs = "";
  let spawnError: Error | undefined;
  next.once("error", (error) => { spawnError = error; });
  for (const stream of [next.stdout, next.stderr]) {
    stream?.setEncoding("utf8").on("data", (chunk: string) => { logs = `${logs}${chunk}`.slice(-32_000); });
  }
  try {
    const deadline = Date.now() + 30_000;
    let ready = false;
    while (Date.now() < deadline && next.exitCode === null && !spawnError) {
      try {
        const response = await fetch(`${origin}/theme-proof`, { signal: AbortSignal.timeout(1_000) });
        await response.arrayBuffer();
        if (response.status === 200) {
          ready = true;
          break;
        }
      } catch {
        await new Promise((resolvePromise) => setTimeout(resolvePromise, 200));
      }
    }
    if (spawnError) throw new Error(`Could not start theme fixture server: ${spawnError.message}\n${logs}`);
    if (next.exitCode !== null) throw new Error(`Theme fixture server exited early.\n${logs}`);
    if (!ready) throw new Error(`Theme fixture server did not become ready within 30 seconds.\n${logs}`);
    await runProof(testInfo, "theme-browser-proof.mjs", "B06_PROOF_OUTPUT_DIR", { B06_PROOF_URL: `${origin}/theme-proof` });
  } finally {
    await stopProof(next);
  }
}

test.describe("existing real Next runtime proofs", () => {
  test("BFF allowlist, CSRF, private streams, upload, CSV, and cancellation", async ({}, testInfo) => {
    await runProof(testInfo, "bff-runtime-proof.mjs");
  });

  test("session login, refresh, and local logout routes", async ({}, testInfo) => {
    await runProof(testInfo, "session-runtime-proof.mjs");
  });

  test("session RSC verification and refresh", async ({}, testInfo) => {
    await runProof(testInfo, "session-rsc-proof.mjs");
  });

  test("theme bootstrap, keyboard, contrast, and responsive browser proof", async ({}, testInfo) => {
    await themeBrowserProof(testInfo);
  });

  test("role shell keyboard and responsive browser proof", async ({}, testInfo) => {
    await runProof(testInfo, "entry-shell-proof.mjs", "B07_PROOF_OUTPUT_DIR");
  });

  test("private query hydration, identity changes, Back/Forward, and cancellation", async ({}, testInfo) => {
    await runProof(testInfo, "query-cache-browser-proof.mjs", "B08_PROOF_OUTPUT_DIR");
  });
});
