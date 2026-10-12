import assert from "node:assert/strict";
import { readFile, stat } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import vm from "node:vm";
import test from "node:test";
import {
  applyThemePreference,
  LEGACY_THEME_STORAGE_KEY,
  parseThemePreference,
  resolveColorScheme,
  THEME_BOOTSTRAP_SCRIPT,
  THEME_STORAGE_KEY,
  watchThemePreference,
} from "../../src/lib/theme.ts";

const root = fileURLToPath(new URL("../..", import.meta.url));

function fakeRoot(initialDark = false) {
  const classes = new Set(initialDark ? ["dark"] : []);
  return {
    dataset: {},
    classList: {
      toggle(name, enabled) {
        if (enabled) classes.add(name);
        else classes.delete(name);
      },
      contains(name) { return classes.has(name); },
    },
  };
}

function runBootstrap({ values = {}, systemIsDark = false, failGet = false, failSet = false } = {}) {
  const stored = new Map(Object.entries(values));
  const storage = {
    getItem(key) {
      if (failGet) throw new Error("storage denied");
      return stored.get(key) ?? null;
    },
    setItem(key, value) {
      if (failSet) throw new Error("storage is read-only");
      stored.set(key, value);
    },
    removeItem(key) { stored.delete(key); },
  };
  const rootElement = fakeRoot();
  vm.runInNewContext(THEME_BOOTSTRAP_SCRIPT, {
    document: { documentElement: rootElement },
    window: {
      localStorage: storage,
      matchMedia: () => ({ matches: systemIsDark }),
    },
  });
  return { rootElement, stored };
}

test("theme bootstrap defaults to dark and applies a stored preference before hydration", () => {
  const fallback = runBootstrap();
  assert.equal(fallback.rootElement.dataset.themePreference, "dark");
  assert.equal(fallback.rootElement.classList.contains("dark"), true);

  const light = runBootstrap({ values: { [THEME_STORAGE_KEY]: "light" } });
  assert.equal(light.rootElement.dataset.themePreference, "light");
  assert.equal(light.rootElement.classList.contains("dark"), false);
});

test("theme bootstrap migrates the old same-origin preference once and new values win", () => {
  const migrated = runBootstrap({ values: { [LEGACY_THEME_STORAGE_KEY]: "light" } });
  assert.equal(migrated.rootElement.dataset.themePreference, "light");
  assert.equal(migrated.stored.get(THEME_STORAGE_KEY), "light");
  assert.equal(migrated.stored.has(LEGACY_THEME_STORAGE_KEY), false);

  const currentWins = runBootstrap({ values: {
    [THEME_STORAGE_KEY]: "dark",
    [LEGACY_THEME_STORAGE_KEY]: "light",
  } });
  assert.equal(currentWins.rootElement.dataset.themePreference, "dark");
  assert.equal(currentWins.stored.get(LEGACY_THEME_STORAGE_KEY), "light");
});

test("blocked storage falls back to dark; failed migration writes still use the readable legacy value", () => {
  const blocked = runBootstrap({ failGet: true });
  assert.equal(blocked.rootElement.dataset.themePreference, "dark");
  assert.equal(blocked.rootElement.classList.contains("dark"), true);

  const readOnly = runBootstrap({ values: { [LEGACY_THEME_STORAGE_KEY]: "light" }, failSet: true });
  assert.equal(readOnly.rootElement.dataset.themePreference, "light");
  assert.equal(readOnly.stored.has(LEGACY_THEME_STORAGE_KEY), true);
});

test("system preference resolves at bootstrap and follows later media changes", () => {
  const darkAtStart = runBootstrap({ values: { [THEME_STORAGE_KEY]: "system" }, systemIsDark: true });
  assert.equal(darkAtStart.rootElement.classList.contains("dark"), true);
  assert.equal(resolveColorScheme("system", false), "light");
  assert.equal(resolveColorScheme("system", true), "dark");
  assert.equal(parseThemePreference("system"), "system");
  assert.equal(parseThemePreference("unknown"), null);

  let matches = false;
  const listeners = new Set();
  const previousWindow = globalThis.window;
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: {
      matchMedia: () => ({
        get matches() { return matches; },
        addEventListener(_type, listener) { listeners.add(listener); },
        removeEventListener(_type, listener) { listeners.delete(listener); },
      }),
    },
  });
  const rootElement = fakeRoot(true);
  let stop;
  try {
    stop = watchThemePreference(rootElement, "system");
    assert.equal(rootElement.classList.contains("dark"), false);
    matches = true;
    for (const listener of listeners) listener();
    assert.equal(rootElement.classList.contains("dark"), true);
    stop();
    assert.equal(listeners.size, 0);
  } finally {
    stop?.();
    if (previousWindow === undefined) delete globalThis.window;
    else Object.defineProperty(globalThis, "window", { configurable: true, value: previousWindow });
  }
});

test("B06 stylesheet preserves palette, radii, font features, focus, and phone control targets", async () => {
  const css = await readFile(join(root, "src/app/globals.css"), "utf8");
  for (const token of [
    "--background: oklch(1 0 0)",
    "--foreground: oklch(0.145 0 0)",
    "--primary: oklch(0.508 0.118 165.612)",
    "--background: oklch(0.145 0 0)",
    "--primary: oklch(0.432 0.095 166.913)",
    "--radius-2xl: 18px",
    "--radius-4xl: 26px",
    "--auth-accent: oklch(76.9% 0.188 70.08)",
    "--auth-accent-hover: oklch(82.8% 0.189 84.429)",
    "--auth-surface: oklch(14.1% 0.005 285.823)",
    "--auth-panel: oklch(21% 0.006 285.885)",
    "--auth-input-border: oklch(37% 0.013 285.805)",
    "--auth-muted: oklch(70.5% 0.015 286.067)",
    "font-weight: 100 900",
    "unicode-range: U+0460-052F,U+1C80-1C8A,U+20B4",
    'font-variant-numeric: tabular-nums',
    ".ui-button:focus-visible",
    ".ui-input:focus-visible",
    ".ui-input { min-height: 44px; }",
    ".ui-button[data-size=\"lg\"]",
    ".ui-button[data-size=\"icon\"] { width: 44px; }",
    ".ui-page-title { margin: 0; font-size: 20px; font-weight: 600;",
    ".ui-card-title { margin: 0; font-size: 16px; font-weight: 500;",
    ".ui-metadata { color: var(--muted-foreground); font-size: 12px;",
    ".ui-secondary { color: var(--muted-foreground); font-size: 13px;",
    ".auth-panel .ui-input { border-color: var(--auth-input-border); background: var(--auth-input); color: var(--auth-foreground); }",
    ".auth-panel .ui-input:focus-visible",
  ]) assert.ok(css.includes(token), `missing CSS contract: ${token}`);
  assert.equal(css.includes("overflow-x: hidden"), false, "global overflow clipping is not allowed");

  for (const font of [
    "inter-latin-wght-normal.woff2",
    "inter-latin-ext-wght-normal.woff2",
    "inter-cyrillic-wght-normal.woff2",
    "inter-cyrillic-ext-wght-normal.woff2",
    "LICENSE-Inter.txt",
  ]) await stat(join(root, "src/app/fonts", font));
  assert.equal(resolveColorScheme("dark", false), "dark");
  assert.equal(THEME_BOOTSTRAP_SCRIPT.includes(THEME_STORAGE_KEY), true);
});

test("theme application updates only the root theme preference and dark class", () => {
  const rootElement = fakeRoot();
  applyThemePreference(rootElement, "dark", false);
  assert.equal(rootElement.dataset.themePreference, "dark");
  assert.equal(rootElement.classList.contains("dark"), true);
  applyThemePreference(rootElement, "light", false);
  assert.equal(rootElement.classList.contains("dark"), false);
});
