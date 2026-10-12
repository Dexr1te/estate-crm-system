import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { once } from "node:events";
import { createServer } from "node:http";
import { mkdir, writeFile } from "node:fs/promises";
import { setTimeout as delay } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { chromium } from "playwright-core";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const fixture = join(root, "tests/fixtures/runtime-app");
const nextBin = join(root, "node_modules/next/dist/bin/next");
const chromePath = process.env.B07_BROWSER_EXECUTABLE || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const outputDir = process.env.B07_PROOF_OUTPUT_DIR || "/private/tmp/estate-crm-next-b07-evidence";
const requests = [];
const report = {
  status: "RUNNING",
  node: process.version,
  playwrightCore: "1.64.0",
  chromePath,
  cases: [],
};

const identities = {
  "agent-team": { userId: 11, fullName: "Ada Agent", email: "ada@example.test", role: "AGENT", dataScope: "TEAM", status: "ACTIVE", teamId: 2, teamName: "Northstar Realty", teamCurrency: "USD", mustChangePassword: false },
  "agent-empty": { userId: 12, fullName: "Alex Agent", email: "alex@example.test", role: "AGENT", dataScope: "OWN", status: "ACTIVE", teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false },
  "manager-team": { userId: 13, fullName: "Morgan Manager", email: "morgan@example.test", role: "MANAGER", dataScope: "TEAM", status: "ACTIVE", teamId: 3, teamName: "Cedar Realty", teamCurrency: "KZT", mustChangePassword: false },
  "manager-empty": { userId: 14, fullName: "Mina Manager", email: "mina@example.test", role: "MANAGER", dataScope: "OWN", status: "ACTIVE", teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false },
  admin: { userId: 15, fullName: "Ari Admin", email: "ari@example.test", role: "ADMIN", dataScope: "ALL", status: "ACTIVE", teamId: null, teamName: null, teamCurrency: null, mustChangePassword: false },
};

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      if (!address || typeof address === "string") return reject(new Error("Could not bind proof server"));
      resolve(address.port);
    });
  });
}

function close(server) {
  return server.listening
    ? new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()))
    : Promise.resolve();
}

function json(response, status, value) {
  response.writeHead(status, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
  response.end(JSON.stringify(value));
}

function accessToken(request) {
  return (request.headers.authorization || "").replace(/^Bearer /, "");
}

const backend = createServer((request, response) => {
  const path = new URL(request.url || "/", "http://backend.test").pathname;
  requests.push({ path, method: request.method, authorization: request.headers.authorization, cookie: request.headers.cookie });
  if (path !== "/api/auth/me") {
    json(response, 404, { status: 404, error: "Not Found", message: "not found", path });
    return;
  }
  const token = accessToken(request);
  if (token === "rsc-forbidden") {
    json(response, 403, { status: 403, error: "Forbidden", message: "denied", path });
    return;
  }
  if (token === "rsc-unavailable") {
    json(response, 503, { status: 503, error: "Service Unavailable", message: "offline", path });
    return;
  }
  if (token === "rsc-expired") {
    json(response, 401, { message: "expired" });
    return;
  }
  const identity = identities[token];
  if (!identity) {
    json(response, 401, { message: "missing" });
    return;
  }
  json(response, 200, { ...identity, accessToken: null, refreshToken: null, tokenType: "Bearer" });
});

function runNext(args, env, logs) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [nextBin, ...args], {
      cwd: fixture,
      env,
      stdio: ["ignore", "pipe", "pipe"],
    });
    for (const stream of [child.stdout, child.stderr]) {
      stream.setEncoding("utf8");
      stream.on("data", (part) => { logs.value = (logs.value + part).slice(-16_000); });
    }
    child.once("error", reject);
    child.once("exit", (code, signal) => code === 0
      ? resolve()
      : reject(new Error("Next " + args[0] + " exited with " + (code ?? signal) + ":\n" + logs.value)));
  });
}

async function stopNext(child) {
  if (!child || child.exitCode !== null) return;
  child.kill("SIGTERM");
  await Promise.race([once(child, "exit"), delay(5_000)]);
  if (child.exitCode === null) child.kill("SIGKILL");
}

function cookie(token, includeRefresh = true) {
  return "estate-dev-access=" + token + (includeRefresh ? "; estate-dev-refresh=refresh-sentinel" : "");
}

async function getPage(baseUrl, path, token, options = {}) {
  const headers = new Headers(options.headers);
  if (token) headers.set("cookie", cookie(token, options.includeRefresh !== false));
  const response = await fetch(baseUrl + path, {
    headers,
    redirect: options.redirect || "manual",
    signal: AbortSignal.timeout(8_000),
  });
  return { response, body: await response.text() };
}

async function assertRedirect(baseUrl, path, token, destination) {
  const result = await getPage(baseUrl, path, token);
  assert.ok(result.response.status >= 300 && result.response.status < 400, path + " should redirect");
  assert.equal(new URL(result.response.headers.get("location"), baseUrl).pathname, destination);
  assert.doesNotMatch(result.body, /PRIVATE_B07_/);
  report.cases.push({ kind: "redirect", path, token, status: result.response.status, destination });
}

await mkdir(outputDir, { recursive: true });
let next;
let browser;
let watchdog;
try {
  const backendPort = await listen(backend);
  const reserve = createServer();
  const webPort = await listen(reserve);
  await close(reserve);
  const baseUrl = "http://127.0.0.1:" + webPort;
  const env = {
    PATH: process.env.PATH || "",
    ...(process.env.HOME ? { HOME: process.env.HOME } : {}),
    ...(process.env.TMPDIR ? { TMPDIR: process.env.TMPDIR } : {}),
    BACKEND_API_URL: "http://127.0.0.1:" + backendPort + "/api",
    WEB_ORIGIN: baseUrl,
    NODE_ENV: "production",
    NEXT_TELEMETRY_DISABLED: "1",
  };
  const buildLogs = { value: "" };
  await runNext(["build"], env, buildLogs);
  next = spawn(process.execPath, [nextBin, "start", "--hostname", "127.0.0.1", "--port", String(webPort)], {
    cwd: fixture,
    env,
    stdio: ["ignore", "pipe", "pipe"],
  });
  const logs = { value: "" };
  for (const stream of [next.stdout, next.stderr]) {
    stream.setEncoding("utf8");
    stream.on("data", (part) => { logs.value = (logs.value + part).slice(-16_000); });
  }
  watchdog = setTimeout(() => {
    console.error("FAIL B07 entry/shell proof exceeded its two-minute watchdog");
    next.kill("SIGKILL");
    process.exit(1);
  }, 120_000);
  watchdog.unref();

  let ready = false;
  const deadline = Date.now() + 30_000;
  while (Date.now() < deadline && next.exitCode === null) {
    try {
      const response = await fetch(baseUrl + "/proof/shell", {
        headers: { cookie: cookie("agent-team") },
        redirect: "manual",
        signal: AbortSignal.timeout(1_500),
      });
      await response.arrayBuffer();
      if (response.status === 200) {
        ready = true;
        break;
      }
    } catch {
      await delay(200);
    }
  }
  assert.equal(ready, true, "Next fixture should start: " + logs.value);

  const allowed = await getPage(baseUrl, "/proof/team", "agent-team");
  assert.equal(allowed.response.status, 200);
  assert.match(allowed.body, /PRIVATE_B07_TEAM/);
  assert.match(allowed.body, /Northstar Realty/);
  assert.doesNotMatch(allowed.body, /agent-team|refresh-sentinel/);
  report.cases.push({ kind: "team-member", status: allowed.response.status, marker: "PRIVATE_B07_TEAM" });

  await assertRedirect(baseUrl, "/proof/team", "manager-empty", "/onboarding/team");
  await assertRedirect(baseUrl, "/proof/team", "agent-empty", "/onboarding/waiting");

  const adminTeamBypass = await getPage(baseUrl, "/proof/team", "admin");
  assert.equal(adminTeamBypass.response.status, 200);
  assert.match(adminTeamBypass.body, /PRIVATE_B07_TEAM/);
  report.cases.push({ kind: "admin-team-exemption", status: adminTeamBypass.response.status });

  const adminAllowed = await getPage(baseUrl, "/proof/admin", "admin");
  assert.equal(adminAllowed.response.status, 200);
  assert.match(adminAllowed.body, /PRIVATE_B07_ADMIN/);
  const agentAdminDenied = await getPage(baseUrl, "/proof/admin", "agent-team");
  assert.ok(agentAdminDenied.response.status >= 300 && agentAdminDenied.response.status < 400);
  assert.equal(new URL(agentAdminDenied.response.headers.get("location"), baseUrl).pathname, "/dashboard");
  assert.doesNotMatch(agentAdminDenied.body, /PRIVATE_B07_ADMIN/);
  report.cases.push({ kind: "admin-role-gate", destination: "/dashboard", deniedMarkerAbsent: true });

  for (const [token, expected] of [
    ["rsc-forbidden", "You do not have permission to view this page."],
    ["rsc-unavailable", "The service is temporarily unavailable."],
    ["rsc-expired", "Checking your session."],
  ]) {
    const result = await getPage(baseUrl, "/proof/shell", token);
    assert.equal(result.response.status, 200);
    assert.ok(result.body.includes(expected), token + " renders its session state");
    assert.doesNotMatch(result.body, /PRIVATE_B07_SHELL|rsc-forbidden|rsc-unavailable|rsc-expired|refresh-sentinel/);
    report.cases.push({ kind: "session-gate", token, privateMarkerAbsent: true });
  }
  const anonymous = await getPage(baseUrl, "/proof/shell", null);
  assert.ok(anonymous.response.status >= 300 && anonymous.response.status < 400);
  assert.equal(new URL(anonymous.response.headers.get("location"), baseUrl).pathname, "/login");
  assert.doesNotMatch(anonymous.body, /PRIVATE_B07_SHELL/);
  report.cases.push({ kind: "anonymous-gate", destination: "/login", privateMarkerAbsent: true });

  browser = await chromium.launch({
    executablePath: chromePath,
    headless: true,
    args: ["--no-first-run", "--no-default-browser-check", "--disable-background-networking"],
  });
  report.chromeVersion = browser.version();
  const desktopContext = await browser.newContext({ viewport: { width: 1280, height: 900 }, reducedMotion: "reduce" });
  await desktopContext.addInitScript((theme) => {
    try { localStorage.setItem("estate-crm-theme", theme); } catch {}
  }, "dark");
  await desktopContext.addCookies([{ name: "estate-dev-access", value: "agent-team", url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
  const desktop = await desktopContext.newPage();
  await desktop.goto(baseUrl + "/proof/shell", { waitUntil: "networkidle" });
  await desktop.locator('[data-private-marker="PRIVATE_B07_SHELL"]').waitFor();
  const teamFlightRequest = desktop.waitForRequest((request) => request.headers().rsc === "1" && request.url().includes("/proof/team"));
  await desktop.getByRole("link", { name: "Team gate" }).click();
  const observedFlightRequest = await teamFlightRequest;
  const observedHeaders = await observedFlightRequest.allHeaders();
  const deniedFlight = await desktop.evaluate(async ({ path, headers }) => {
    const response = await fetch(path, { headers });
    return {
      status: response.status,
      contentType: response.headers.get("content-type"),
      url: response.url,
      body: await response.text(),
    };
  }, {
    path: new URL(observedFlightRequest.url()).pathname.replace("/proof/team", "/proof/admin") + new URL(observedFlightRequest.url()).search,
    headers: {
      accept: observedHeaders.accept,
      rsc: observedHeaders.rsc,
      "next-url": observedHeaders["next-url"],
      "next-router-state-tree": observedHeaders["next-router-state-tree"],
    },
  });
  assert.equal(deniedFlight.status, 200, "Denied Flight response: " + deniedFlight.status + " " + deniedFlight.url + " " + deniedFlight.body.slice(0, 800));
  assert.match(deniedFlight.contentType || "", /text\/x-component/i);
  assert.doesNotMatch(deniedFlight.body, /PRIVATE_B07_ADMIN/);
  report.cases.push({ kind: "denied-flight", status: deniedFlight.status, privateMarkerAbsent: true });
  assert.equal(await desktop.locator('.crm-sidebar-desktop .crm-nav-link[aria-label="Team gate"]').getAttribute("aria-current"), "page");
  const parentCrumb = desktop.getByRole("link", { name: "Proof", exact: true });
  await parentCrumb.click();
  await desktop.waitForURL((url) => url.pathname === "/proof/shell");
  report.cases.push({ kind: "parent-breadcrumb", destination: new URL(desktop.url()).pathname });
  const desktopMetrics = await desktop.evaluate(() => ({
    sidebarWidth: document.querySelector(".crm-sidebar-desktop").getBoundingClientRect().width,
    dark: document.documentElement.classList.contains("dark"),
    themePreference: document.documentElement.dataset.themePreference,
    shellBackground: getComputedStyle(document.querySelector(".crm-shell")).backgroundColor,
    documentWidth: document.documentElement.scrollWidth,
  }));
  assert.equal(desktopMetrics.sidebarWidth, 256);
  assert.equal(desktopMetrics.dark, true);
  assert.equal(desktopMetrics.themePreference, "dark");
  assert.equal(desktopMetrics.documentWidth, 1280);
  assert.notEqual(desktopMetrics.shellBackground, "rgba(0, 0, 0, 0)");
  report.cases.push({ kind: "desktop-dark", ...desktopMetrics });

  async function assertNavigation(token, expected) {
    await desktopContext.addCookies([{ name: "estate-dev-access", value: token, url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
    await desktop.goto(baseUrl + "/proof/shell", { waitUntil: "networkidle" });
    const labels = await desktop.locator(".crm-sidebar-desktop .crm-nav-link").evaluateAll((links) => links.map((link) => link.getAttribute("aria-label")));
    assert.deepEqual(labels, expected, token + " navigation");
    report.cases.push({ kind: "navigation-matrix", token, labels: expected });
  }
  await assertNavigation("agent-empty", ["Shell proof"]);
  await assertNavigation("manager-empty", ["Shell proof"]);
  await assertNavigation("manager-team", ["Shell proof", "Team gate"]);
  await assertNavigation("admin", ["Shell proof", "Team gate", "Admin gate"]);
  await assertNavigation("agent-team", ["Shell proof", "Team gate"]);

  await desktop.getByRole("button", { name: "Collapse sidebar" }).click();
  assert.equal(await desktop.locator(".crm-shell").getAttribute("data-sidebar-collapsed"), "true");
  const collapsedLink = desktop.getByRole("link", { name: "Team gate" });
  assert.equal(await collapsedLink.getAttribute("title"), "Team gate");
  await desktop.getByRole("button", { name: "Expand sidebar" }).focus();
  await desktop.keyboard.press("Shift+Tab");
  await desktop.keyboard.press("Shift+Tab");
  const tooltipState = await collapsedLink.evaluate((link) => ({
    focused: document.activeElement === link,
    focusVisible: link.matches(":focus-visible"),
    tooltipOpen: link.querySelector(".crm-nav-tooltip").matches(":popover-open"),
    tooltipRect: (() => {
      const rect = link.querySelector(".crm-nav-tooltip").getBoundingClientRect();
      return { left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom };
    })(),
    sidebarRight: document.querySelector(".crm-sidebar-desktop").getBoundingClientRect().right,
    tooltipText: link.querySelector(".crm-nav-tooltip").textContent,
  }));
  assert.equal(tooltipState.focused, true);
  assert.equal(tooltipState.focusVisible, true);
  assert.equal(tooltipState.tooltipOpen, true);
  assert.ok(tooltipState.tooltipRect.left >= tooltipState.sidebarRight, JSON.stringify(tooltipState));
  assert.ok(tooltipState.tooltipRect.right <= 1280, JSON.stringify(tooltipState));
  assert.equal(tooltipState.tooltipText, "Team gate");
  report.cases.push({ kind: "collapsed-keyboard-tooltip", ...tooltipState });
  await desktop.screenshot({ path: join(outputDir, "collapsed-keyboard-tooltip.png"), fullPage: false });
  await desktop.keyboard.press("Escape");
  const escapedTooltip = await collapsedLink.evaluate((link) => ({
    focused: document.activeElement === link,
    tooltipOpen: link.querySelector(".crm-nav-tooltip").matches(":popover-open"),
  }));
  assert.equal(escapedTooltip.focused, true);
  assert.equal(escapedTooltip.tooltipOpen, false);
  report.cases.push({ kind: "tooltip-escape", ...escapedTooltip });
  await desktop.getByRole("button", { name: "Expand sidebar" }).click();

  await desktop.evaluate(() => {
    const fixtures = [
      ["input", false],
      ["textarea", false],
      ["select", false],
      ["div", true],
    ];
    for (const [tag, editable] of fixtures) {
      const element = document.createElement(tag);
      element.dataset.shortcutProbe = tag;
      if (editable) {
        element.contentEditable = "true";
        element.tabIndex = 0;
      }
      if (tag === "select") element.innerHTML = "<option>One</option>";
      document.body.append(element);
    }
    const parent = document.createElement("div");
    parent.contentEditable = "true";
    const child = document.createElement("button");
    child.dataset.shortcutProbe = "inherited-editable";
    child.textContent = "Editable child";
    parent.append(child);
    document.body.append(parent);
  });
  for (const probe of ["input", "textarea", "select", "div", "inherited-editable"]) {
    const editable = desktop.locator('[data-shortcut-probe="' + probe + '"]');
    await editable.focus();
    if (probe === "inherited-editable") {
      assert.equal(await editable.evaluate((node) => node.isContentEditable), true);
    }
    const before = await desktop.locator(".crm-shell").getAttribute("data-sidebar-collapsed");
    await desktop.keyboard.press("Control+b");
    await desktop.keyboard.press("Meta+b");
    assert.equal(await desktop.locator(".crm-shell").getAttribute("data-sidebar-collapsed"), before, probe + " must ignore Ctrl/Cmd+B");
  }
  report.cases.push({ kind: "editable-shortcut-exclusions", targets: ["input", "textarea", "select", "contenteditable", "inherited contenteditable child"] });
  await desktop.locator('[data-shortcut-probe="input"]').evaluate((node) => node.remove());
  await desktop.locator('[data-shortcut-probe="textarea"]').evaluate((node) => node.remove());
  await desktop.locator('[data-shortcut-probe="select"]').evaluate((node) => node.remove());
  await desktop.locator('[data-shortcut-probe="div"]').evaluate((node) => node.remove());
  await desktop.locator('[data-shortcut-probe="inherited-editable"]').evaluate((node) => node.parentElement.remove());

  await desktop.getByRole("button", { name: "Collapse sidebar" }).focus();
  await desktop.keyboard.press("Control+b");
  assert.equal(await desktop.locator(".crm-shell").getAttribute("data-sidebar-collapsed"), "true");
  await desktop.keyboard.press("Meta+b");
  assert.equal(await desktop.locator(".crm-shell").getAttribute("data-sidebar-collapsed"), "false");
  report.cases.push({ kind: "keyboard-shortcut", controlB: "passed", metaB: "passed" });
  await desktop.screenshot({ path: join(outputDir, "desktop-dark.png"), fullPage: true });
  await desktopContext.close();

  const phoneContext = await browser.newContext({
    viewport: { width: 320, height: 800 },
    isMobile: true,
    hasTouch: true,
    deviceScaleFactor: 2,
    reducedMotion: "reduce",
  });
  await phoneContext.addInitScript((theme) => {
    try { localStorage.setItem("estate-crm-theme", theme); } catch {}
  }, "light");
  await phoneContext.addCookies([{ name: "estate-dev-access", value: "agent-team", url: baseUrl, httpOnly: true, sameSite: "Lax" }]);
  const phone = await phoneContext.newPage();
  await phone.goto(baseUrl + "/proof/shell", { waitUntil: "networkidle" });
  await phone.locator('[data-private-marker="PRIVATE_B07_SHELL"]').waitFor();
  const phoneMetrics = await phone.evaluate(() => ({
    width: window.innerWidth,
    documentWidth: document.documentElement.scrollWidth,
    topbarHeight: document.querySelector(".crm-topbar").getBoundingClientRect().height,
    dark: document.documentElement.classList.contains("dark"),
    themePreference: document.documentElement.dataset.themePreference,
    coarsePointer: window.matchMedia("(pointer: coarse)").matches,
  }));
  assert.equal(phoneMetrics.width, 320);
  assert.equal(phoneMetrics.documentWidth, 320);
  assert.equal(phoneMetrics.topbarHeight, 56);
  assert.equal(phoneMetrics.dark, false);
  assert.equal(phoneMetrics.themePreference, "light");
  assert.equal(phoneMetrics.coarsePointer, true);
  await phone.getByRole("button", { name: "Open navigation" }).click();
  const dialog = phone.getByRole("dialog", { name: "Navigation" });
  await dialog.waitFor({ state: "visible" });
  const drawer = await dialog.evaluate((element) => ({
    open: element.open,
    width: element.getBoundingClientRect().width,
    height: element.getBoundingClientRect().height,
    activeLabel: document.activeElement.getAttribute("aria-label"),
    links: [...element.querySelectorAll(".crm-nav-link")].map((link) => ({
      label: link.getAttribute("aria-label"),
      width: link.getBoundingClientRect().width,
      height: link.getBoundingClientRect().height,
    })),
  }));
  assert.equal(drawer.open, true);
  assert.equal(drawer.width, 288);
  assert.equal(drawer.height, 800);
  assert.equal(drawer.activeLabel, "Close navigation");
  assert.ok(drawer.links.every((link) => link.width >= 44 && link.height >= 44));
  await phone.screenshot({ path: join(outputDir, "phone-drawer.png"), fullPage: true });
  await phone.getByRole("link", { name: "Team gate" }).focus();
  await phone.keyboard.press("Tab");
  assert.equal(await phone.evaluate(() => document.activeElement.getAttribute("aria-label")), "Close navigation");
  await phone.keyboard.press("Escape");
  await phone.waitForFunction(() => !document.querySelector(".crm-mobile-dialog").open);
  assert.equal(await phone.evaluate(() => document.activeElement.getAttribute("aria-label")), "Open navigation");
  await phone.screenshot({ path: join(outputDir, "phone-light.png"), fullPage: true });
  await phone.getByRole("button", { name: "Open navigation" }).click();
  await phone.setViewportSize({ width: 1280, height: 900 });
  await phone.waitForFunction(() => !document.querySelector(".crm-mobile-dialog").open);
  await phone.getByRole("button", { name: "Collapse sidebar" }).waitFor({ state: "visible" });
  await phone.waitForFunction(() => document.activeElement?.getAttribute("aria-label") === "Collapse sidebar");
  assert.equal(await phone.evaluate(() => document.activeElement.getAttribute("aria-label")), "Collapse sidebar");
  await phone.getByRole("button", { name: "Collapse sidebar" }).click();
  const coarseCollapsedLink = await phone.locator(".crm-sidebar-desktop .crm-nav-link").first().evaluate((link) => ({
    width: link.getBoundingClientRect().width,
    height: link.getBoundingClientRect().height,
    coarsePointer: window.matchMedia("(pointer: coarse)").matches,
  }));
  assert.equal(coarseCollapsedLink.coarsePointer, true);
  assert.ok(coarseCollapsedLink.width >= 44 && coarseCollapsedLink.height >= 44);
  report.cases.push({ kind: "coarse-collapsed-nav-target", ...coarseCollapsedLink });

  const collapsedDesktopLink = phone.getByRole("link", { name: "Team gate" });
  await collapsedDesktopLink.focus();
  assert.equal(await collapsedDesktopLink.locator(".crm-nav-tooltip").evaluate((tooltip) => tooltip.matches(":popover-open")), true);
  await phone.setViewportSize({ width: 320, height: 800 });
  await phone.waitForFunction(() => document.querySelectorAll(".crm-nav-tooltip:popover-open").length === 0);
  await phone.getByRole("button", { name: "Open navigation" }).click();
  const reverseDrawer = await phone.getByRole("dialog", { name: "Navigation" }).evaluate((element) => ({
    open: element.open,
    teamName: (() => {
      const name = element.querySelector(".crm-sidebar-mobile .crm-workspace-context strong");
      return { text: name.textContent.trim(), display: getComputedStyle(name).display, width: name.getBoundingClientRect().width };
    })(),
    labels: [...element.querySelectorAll(".crm-sidebar-mobile .crm-nav-label")].map((label) => ({
      text: label.textContent.trim(),
      position: getComputedStyle(label).position,
      width: label.getBoundingClientRect().width,
    })),
    links: [...element.querySelectorAll(".crm-sidebar-mobile .crm-nav-link")].map((link) => ({
      width: link.getBoundingClientRect().width,
      height: link.getBoundingClientRect().height,
    })),
    openTooltips: document.querySelectorAll(".crm-nav-tooltip:popover-open").length,
  }));
  assert.equal(reverseDrawer.open, true);
  assert.deepEqual(reverseDrawer.labels.map((label) => label.text), ["Shell proof", "Team gate"]);
  assert.ok(reverseDrawer.labels.every((label) => label.position !== "absolute" && label.width > 0));
  assert.equal(reverseDrawer.teamName.text, "Northstar Realty");
  assert.notEqual(reverseDrawer.teamName.display, "none");
  assert.ok(reverseDrawer.teamName.width > 0);
  assert.ok(reverseDrawer.links.every((link) => link.width >= 44 && link.height >= 44));
  assert.equal(reverseDrawer.openTooltips, 0);
  report.cases.push({ kind: "reverse-breakpoint-mobile-drawer", ...reverseDrawer });
  await phone.screenshot({ path: join(outputDir, "reverse-breakpoint-mobile-drawer.png"), fullPage: true });
  report.cases.push({ kind: "phone-light", ...phoneMetrics, drawer });
  await phoneContext.close();

  assert.ok(requests.every((request) => request.cookie === undefined), "backend never receives browser cookies");
  assert.ok(requests.some((request) => request.path === "/api/auth/me" && request.authorization === "Bearer agent-team"));
  report.backendRequestCount = requests.length;
  report.backendCookiesForwarded = 0;
  report.status = "PASS";
  console.log("PASS production Next fixture route gates: team members pass; teamless manager/agent route to their canonical onboarding entries; ADMIN bypasses the non-admin team gate; non-admin role denial renders no private marker.");
  console.log("PASS denied HTML and streamed Flight exclude the private admin marker; anonymous, expired, forbidden, and unavailable session states render no private shell marker.");
  console.log("PASS Chrome " + report.chromeVersion + " 1280px desktop/320px coarse phone: 256px sidebar, 56px topbar, 288px modal drawer, 44px nav targets, keyboard collapse, focus trap/Escape/return focus, resize close, light/dark shell.");
  console.log("PASS fixture navigation matrix is filtered by verified role/team access; backend receives no browser Cookie header.");
} catch (error) {
  report.status = "FAIL";
  report.error = String(error);
  throw error;
} finally {
  if (watchdog) clearTimeout(watchdog);
  await browser?.close();
  await stopNext(next);
  await close(backend);
  await writeFile(join(outputDir, "entry-shell.json"), JSON.stringify(report, null, 2) + "\n");
}
