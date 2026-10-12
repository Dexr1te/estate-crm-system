import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { chromium } from 'playwright-core';

const chromePath = process.env.B06_BROWSER_EXECUTABLE;
const outputDir = process.env.B06_PROOF_OUTPUT_DIR || join(tmpdir(), 'estate-crm-b06-browser-proof');
const requestedUrl = process.env.B06_PROOF_URL;

if (!chromePath || !requestedUrl) {
  throw new Error('Set B06_BROWSER_EXECUTABLE and B06_PROOF_URL before running the browser proof.');
}

const proofUrl = new URL(requestedUrl);
if (proofUrl.protocol !== 'http:' || !['127.0.0.1', 'localhost', '[::1]'].includes(proofUrl.hostname)) {
  throw new Error('B06_PROOF_URL must use loopback HTTP.');
}
if (proofUrl.pathname !== '/theme-proof') {
  throw new Error('B06_PROOF_URL must target the test-only /theme-proof route.');
}
await mkdir(outputDir, { recursive: true });
const sameOrigin = proofUrl.origin;
const report = {
  status: 'RUNNING',
  url: proofUrl.href,
  runtime: {
    node: process.version,
    playwrightCore: '1.64.0',
    chromePath,
  },
  firstPaintNote: 'FCP is recorded from PerformanceObserver while same-origin /_next JavaScript requests are held. Root state is sampled by that observer and compared after script release/hydration; no screenshot alone is treated as first-paint evidence.',
  zoomNote: 'The 640 CSS-pixel viewport is the practical 200% desktop zoom equivalent for a 1280 CSS-pixel baseline; this is not native Chrome zoom.',
  cases: [],
};

const initProbe = ({ seed, blockStorage }) => {
  const readState = () => {
    const root = document.documentElement;
    const body = document.body;
    const mode = document.querySelector('[data-testid="theme-mode"]');
    const rootStyle = root ? getComputedStyle(root) : null;
    const style = body ? getComputedStyle(body) : null;
    return {
      rootClass: root?.className ?? null,
      themePreference: root?.getAttribute('data-theme-preference') ?? null,
      darkClass: root?.classList.contains('dark') ?? false,
      modeText: mode?.textContent?.trim() ?? null,
      modeData: mode?.getAttribute('data-mode') ?? null,
      rootBackground: rootStyle?.backgroundColor ?? null,
      rootColor: rootStyle?.color ?? null,
      backgroundToken: rootStyle?.getPropertyValue('--background').trim() ?? null,
      foregroundToken: rootStyle?.getPropertyValue('--foreground').trim() ?? null,
      bodyBackground: style?.backgroundColor ?? null,
      bodyColor: style?.color ?? null,
    };
  };

  window.__b06Probe = {
    firstContentfulPaint: null,
    mutations: [],
    storageSetupError: null,
  };

  try {
    if (blockStorage) {
      Object.defineProperty(window, 'localStorage', {
        configurable: true,
        get() {
          throw new DOMException('Blocked by B06 browser proof', 'SecurityError');
        },
      });
    } else {
      const storage = window.localStorage;
      storage.clear();
      for (const [key, value] of Object.entries(seed)) storage.setItem(key, value);
    }
  } catch (error) {
    window.__b06Probe.storageSetupError = String(error);
  }

  const observeRoot = () => {
    const root = document.documentElement;
    if (!root || window.__b06Probe.observedRoot === root) return;
    window.__b06Probe.observedRoot = root;
    const observer = new MutationObserver((records) => {
      const changed = records.some((record) =>
        record.attributeName === 'class' || record.attributeName === 'data-theme-preference',
      );
      if (changed) {
        window.__b06Probe.mutations.push({ at: performance.now(), ...readState() });
      }
    });
    observer.observe(root, {
      attributes: true,
      attributeFilter: ['class', 'data-theme-preference'],
    });
  };

  observeRoot();
  new MutationObserver(observeRoot).observe(document, { childList: true });

  try {
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.name === 'first-contentful-paint' && !window.__b06Probe.firstContentfulPaint) {
          window.__b06Probe.firstContentfulPaint = {
            startTime: entry.startTime,
            observerTime: performance.now(),
            ...readState(),
          };
        }
      }
    }).observe({ type: 'paint', buffered: true });
  } catch (error) {
    window.__b06Probe.paintObserverError = String(error);
  }
};

const getDomSnapshot = async (page) => page.evaluate(() => {
  const root = document.documentElement;
  const body = document.body;
  const mode = document.querySelector('[data-testid="theme-mode"]');
  const rootStyle = getComputedStyle(root);
  const style = body ? getComputedStyle(body) : null;
  return {
    rootClass: root.className,
    themePreference: root.getAttribute('data-theme-preference'),
    darkClass: root.classList.contains('dark'),
    modeText: mode?.textContent?.trim() ?? null,
    modeData: mode?.getAttribute('data-mode') ?? null,
    rootBackground: rootStyle.backgroundColor,
    rootColor: rootStyle.color,
    backgroundToken: rootStyle.getPropertyValue('--background').trim(),
    foregroundToken: rootStyle.getPropertyValue('--foreground').trim(),
    bodyBackground: style?.backgroundColor ?? null,
    bodyColor: style?.color ?? null,
    document: {
      readyState: document.readyState,
      innerWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
      bodyWidth: document.body.scrollWidth,
      stylesheetCount: document.styleSheets.length,
      linkedStylesheets: [...document.querySelectorAll('link[rel="stylesheet"]')].map((link) => link.href),
      inlineStylesheetCount: [...document.styleSheets].filter((sheet) => !sheet.href).length,
    },
    probe: window.__b06Probe,
  };
});

const assertRoot = (snapshot, expectedPreference, expectedResolved, checkMode = true) => {
  assert.equal(snapshot.themePreference, expectedPreference, 'root data-theme-preference');
  assert.equal(snapshot.darkClass, expectedResolved === 'dark', 'root .dark class');
  if (checkMode && snapshot.modeData !== null) {
    assert.equal(snapshot.modeData, expectedPreference, 'visible saved theme preference');
  }
};

const waitForPreference = async (page, expected) => {
  await page.waitForFunction(
    (preference) => document.querySelector('[data-testid="theme-mode"]')?.getAttribute('data-mode') === preference,
    expected,
    { timeout: 10_000 },
  );
};

const buttonSelectors = {
  default: '[data-testid="set-theme-light"]',
  sm: '[data-testid="small-hit-target"]',
  lg: '[data-testid="large-hit-target"]',
  icon: '[data-testid="icon-hit-target"]',
  input: '#theme-proof-input',
};

const measureTargets = async (page) => page.evaluate((selectors) => {
  return Object.fromEntries(Object.entries(selectors).map(([name, selector]) => {
    const element = document.querySelector(selector);
    if (!element) return [name, null];
    const rect = element.getBoundingClientRect();
    return [name, {
      tagName: element.tagName,
      width: rect.width,
      height: rect.height,
      disabled: 'disabled' in element ? element.disabled : null,
      left: rect.left,
      right: rect.right,
      top: rect.top,
      bottom: rect.bottom,
    }];
  }));
}, buttonSelectors);

const readAuthVisuals = async (page) => page.evaluate(() => {
  const canvas = document.createElement('canvas');
  canvas.width = 1;
  canvas.height = 1;
  const context = canvas.getContext('2d', { colorSpace: 'srgb' });
  const toRgba = (color) => {
    context.clearRect(0, 0, 1, 1);
    context.fillStyle = color;
    context.fillRect(0, 0, 1, 1);
    const [red, green, blue, alpha] = context.getImageData(0, 0, 1, 1).data;
    return [red, green, blue, alpha / 255];
  };
  const over = (foreground, background) => {
    const alpha = foreground[3] + background[3] * (1 - foreground[3]);
    if (!alpha) return [0, 0, 0, 0];
    return [0, 1, 2].map((index) =>
      (foreground[index] * foreground[3] + background[index] * background[3] * (1 - foreground[3])) / alpha,
    ).concat(alpha);
  };
  const luminance = ([red, green, blue]) => {
    const linear = [red, green, blue].map((value) => {
      const channel = value / 255;
      return channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4;
    });
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2];
  };
  const contrast = (foreground, background) => {
    const a = luminance(foreground);
    const b = luminance(background);
    return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
  };
  const selectors = {
    visual: '[data-testid="auth-visual"]',
    panel: '[data-testid="auth-panel"]',
    input: '[data-testid="auth-input"]',
    action: '[data-testid="auth-action"]',
  };
  return Object.fromEntries(Object.entries(selectors).map(([name, selector]) => {
    const element = document.querySelector(selector);
    if (!element) return [name, null];
    const style = getComputedStyle(element);
    const rect = element.getBoundingClientRect();
    const backgrounds = [];
    for (let ancestor = element; ancestor; ancestor = ancestor.parentElement) {
      const color = getComputedStyle(ancestor).backgroundColor;
      const rgba = toRgba(color);
      if (rgba[3] > 0) backgrounds.unshift(rgba);
      if (ancestor === document.documentElement) break;
    }
    let compositeBackground = [255, 255, 255, 1];
    for (const background of backgrounds) compositeBackground = over(background, compositeBackground);
    const foreground = toRgba(style.color);
    const compositeForeground = over(foreground, compositeBackground);
    const placeholderStyle = name === 'input' ? getComputedStyle(element, '::placeholder') : null;
    const placeholderForeground = placeholderStyle
      ? (() => {
          const rgba = toRgba(placeholderStyle.color);
          rgba[3] *= Number(placeholderStyle.opacity || 1);
          return over(rgba, compositeBackground);
        })()
      : null;
    return [name, {
      backgroundColor: style.backgroundColor,
      color: style.color,
      borderColor: style.borderColor,
      borderStyle: style.borderStyle,
      borderWidth: style.borderWidth,
      boxShadow: style.boxShadow,
      outlineColor: style.outlineColor,
      authAccent: style.getPropertyValue('--auth-accent').trim(),
      authSurface: style.getPropertyValue('--auth-surface').trim(),
      authPanelToken: style.getPropertyValue('--auth-panel').trim(),
      contrast: contrast(compositeForeground, compositeBackground),
      placeholderColor: placeholderStyle?.color ?? null,
      placeholderOpacity: placeholderStyle?.opacity ?? null,
      placeholderContrast: placeholderForeground ? contrast(placeholderForeground, compositeBackground) : null,
      width: rect.width,
      height: rect.height,
    }];
  }));
});

const focusByTab = async (page, testId) => {
  await page.evaluate(() => document.activeElement?.blur());
  let activeTestId = null;
  for (let index = 0; index < 40; index += 1) {
    await page.keyboard.press('Tab');
    activeTestId = await page.evaluate(() => document.activeElement?.getAttribute('data-testid') ?? null);
    if (activeTestId === testId) break;
  }
  assert.equal(activeTestId, testId, `Tab reaches ${testId}`);
  await page.waitForFunction((id) => {
    const element = [...document.querySelectorAll('[data-testid]')]
      .find((candidate) => candidate.getAttribute('data-testid') === id);
    if (!element || !element.matches('.auth-panel .ui-input:focus-visible')) return false;
    const style = getComputedStyle(element);
    const readRgba = (color) => {
      const canvas = document.createElement('canvas');
      canvas.width = 1;
      canvas.height = 1;
      const context = canvas.getContext('2d', { colorSpace: 'srgb' });
      context.fillStyle = color;
      context.fillRect(0, 0, 1, 1);
      const [red, green, blue, alpha] = context.getImageData(0, 0, 1, 1).data;
      return [red, green, blue, alpha];
    };
    const accent = readRgba(style.getPropertyValue('--auth-accent').trim());
    const border = readRgba(style.borderColor);
    const borderMatchesAccent = border.slice(0, 3).every((value, index) => Math.abs(value - accent[index]) <= 1);
    const shadowColors = style.boxShadow.match(/(?:rgba?|oklch|oklab)\([^)]*\)/gi) ?? [];
    const visibleAmberShadow = shadowColors.some((color) => {
      const [red, green, blue, alpha] = readRgba(color);
      if (alpha === 0) return false;
      const maximum = Math.max(red, green, blue) / 255;
      const minimum = Math.min(red, green, blue) / 255;
      const delta = maximum - minimum;
      if (delta < 0.12) return false;
      let hue;
      if (maximum === red / 255) hue = ((green - blue) / 255 / delta) % 6;
      else if (maximum === green / 255) hue = (blue - red) / 255 / delta + 2;
      else hue = (red - green) / 255 / delta + 4;
      hue *= 60;
      if (hue < 0) hue += 360;
      return hue >= 20 && hue <= 90;
    });
    return borderMatchesAccent && visibleAmberShadow;
  }, testId, { timeout: 5_000 });
  const focusState = await page.getByTestId(testId).evaluate((element) => {
    const style = getComputedStyle(element);
    return {
      focusVisible: element.matches(':focus-visible'),
      outlineStyle: style.outlineStyle,
      outlineWidth: style.outlineWidth,
      outlineColor: style.outlineColor,
      borderColor: style.borderColor,
      boxShadow: style.boxShadow,
      authAccent: style.getPropertyValue('--auth-accent').trim(),
    };
  });
  return { ...focusState, amberRingConfirmed: true };
};

const waitForKeyboardIndicator = async (page, testId) => {
  await page.waitForFunction((id) => {
    const element = [...document.querySelectorAll('[data-testid]')]
      .find((candidate) => candidate.getAttribute('data-testid') === id);
    if (!element?.matches(':focus-visible')) return false;
    const style = getComputedStyle(element);
    const outlineVisible = style.outlineStyle !== 'none' && style.outlineWidth !== '0px';
    const shadowVisible = style.boxShadow !== 'none' && !/rgba?\([^)]*,\s*0(?:\.0+)?\s*\)/.test(style.boxShadow);
    return outlineVisible || shadowVisible;
  }, testId, { timeout: 5_000 });
};

const browser = await chromium.launch({
  executablePath: chromePath,
  headless: true,
  args: [
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-background-networking',
  ],
});

report.runtime.chromeVersion = browser.version();

const runCase = async ({
  name,
  seed = {},
  blockStorage = false,
  colorScheme = 'dark',
  isMobile = false,
  hasTouch = false,
  expectedPreference,
  expectedResolved,
}) => {
  const item = {
    name,
    colorScheme,
    isMobile,
    hasTouch,
    expectedPreference,
    expectedResolved,
    heldScripts: [],
    cssResponses: [],
    fontRequests: [],
    fontResponses: [],
    consoleErrors: [],
    pageErrors: [],
    deniedExternalRequests: [],
  };
  report.cases.push(item);

  const context = await browser.newContext({
    viewport: { width: 1280, height: 900 },
    colorScheme,
    isMobile,
    hasTouch,
    deviceScaleFactor: isMobile ? 2 : 1,
    reducedMotion: 'reduce',
  });
  await context.addInitScript(initProbe, { seed, blockStorage });
  const page = await context.newPage();
  let releaseGate;
  let gateReleased = false;
  const nextScriptGate = new Promise((resolve) => { releaseGate = resolve; });

  page.on('console', (message) => {
    if (message.type() === 'error') item.consoleErrors.push(message.text());
  });
  page.on('pageerror', (error) => item.pageErrors.push(error.stack ?? String(error)));
  page.on('response', (response) => {
    const request = response.request();
    let url;
    try { url = new URL(response.url()); } catch { return; }
    if (url.origin !== sameOrigin) return;
    if (request.resourceType() === 'stylesheet') {
      item.cssResponses.push({ url: url.pathname, status: response.status() });
    }
    if (request.resourceType() === 'font' || /\.(?:woff2?|ttf|otf)(?:$|\?)/i.test(response.url())) {
      item.fontResponses.push({ url: url.pathname, status: response.status() });
    }
  });
  page.on('request', (request) => {
    let url;
    try { url = new URL(request.url()); } catch { return; }
    if (url.origin === sameOrigin && (request.resourceType() === 'font' || /\.(?:woff2?|ttf|otf)(?:$|\?)/i.test(request.url()))) {
      item.fontRequests.push({ url: url.pathname, resourceType: request.resourceType() });
    }
  });

  await page.route('**/*', async (route) => {
    const request = route.request();
    let url;
    try { url = new URL(request.url()); } catch {
      await route.continue();
      return;
    }
    if (url.origin !== sameOrigin) {
      item.deniedExternalRequests.push(url.href);
      await route.abort();
      return;
    }
    if (request.resourceType() === 'script' && url.pathname.startsWith('/_next/')) {
      item.heldScripts.push({ url: url.pathname, atFcpPending: false });
      await nextScriptGate;
      if (!page.isClosed()) await route.continue();
      return;
    }
    await route.continue();
  });

  try {
    const response = await page.goto(proofUrl.href, { waitUntil: 'commit', timeout: 20_000 });
    assert(response && response.status() < 400, `HTTP response for ${name}`);
    await page.waitForFunction(() => Boolean(window.__b06Probe?.firstContentfulPaint), null, { timeout: 15_000 });

    const preHydration = await getDomSnapshot(page);
    item.preHydration = preHydration;
    item.heldScriptsAtFcp = item.heldScripts.length;
    item.heldScripts = item.heldScripts.map((entry) => ({ ...entry, atFcpPending: true }));

    assert(item.heldScriptsAtFcp > 0, 'at least one same-origin Next JavaScript request is held at FCP');
    assertRoot(preHydration.probe.firstContentfulPaint, expectedPreference, expectedResolved, false);
    assertRoot(preHydration, expectedPreference, expectedResolved, false);
    assert.equal(preHydration.probe.storageSetupError, null, 'storage setup before app scripts');
    assert(
      item.cssResponses.some((entry) => entry.status >= 200 && entry.status < 300) ||
        preHydration.document.inlineStylesheetCount > 0,
      'CSS is available before FCP while JavaScript is held',
    );

    gateReleased = true;
    releaseGate();
    await page.waitForLoadState('load', { timeout: 20_000 });
    await page.locator('[data-testid="theme-mode"]').waitFor({ state: 'visible', timeout: 10_000 });
    await waitForPreference(page, expectedPreference);
    await page.waitForTimeout(200);

    const postHydration = await getDomSnapshot(page);
    item.postHydration = postHydration;
    assertRoot(postHydration, expectedPreference, expectedResolved);
    const postFcpMutations = postHydration.probe.mutations.filter((mutation) =>
      mutation.at >= postHydration.probe.firstContentfulPaint.startTime,
    );
    item.postFcpRootMutations = postFcpMutations;
    for (const mutation of postFcpMutations) {
      assertRoot(mutation, expectedPreference, expectedResolved, false);
    }
    assert.equal(
      postHydration.bodyBackground,
      preHydration.bodyBackground,
      'body background does not change across JavaScript release/hydration',
    );
    assert.equal(postHydration.rootBackground, preHydration.rootBackground, 'root background does not change across hydration');
    assert.equal(postHydration.rootColor, preHydration.rootColor, 'root text color does not change across hydration');
    assert.equal(postHydration.backgroundToken, preHydration.backgroundToken, 'background token does not change across hydration');
    assert.equal(postHydration.foregroundToken, preHydration.foregroundToken, 'foreground token does not change across hydration');
    assert.equal(postHydration.bodyColor, preHydration.bodyColor, 'body text color does not change across hydration');
    assert.deepEqual(item.deniedExternalRequests, [], 'no external network requests');
    assert.deepEqual(item.pageErrors, [], 'no uncaught page errors');
    assert.deepEqual(item.consoleErrors, [], 'no browser console errors during bootstrap/hydration');

    return { item, context, page, releaseGate, setGateReleased: (value) => { gateReleased = value; }, isGateReleased: () => gateReleased };
  } catch (error) {
    item.error = error.stack ?? String(error);
    if (!gateReleased) {
      gateReleased = true;
      releaseGate();
    }
    await context.close().catch(() => {});
    throw error;
  }
};

const active = [];

try {
  const defaultCase = await runCase({
    name: 'default-dark',
    colorScheme: 'dark',
    expectedPreference: 'dark',
    expectedResolved: 'dark',
  });
  active.push(defaultCase);

  const newLight = await runCase({
    name: 'stored-light-held-js',
    seed: { 'estate-crm-theme': 'light' },
    colorScheme: 'dark',
    expectedPreference: 'light',
    expectedResolved: 'light',
  });
  active.push(newLight);

  const legacyLight = await runCase({
    name: 'legacy-light-migration',
    seed: { 'vite-ui-theme': 'light' },
    colorScheme: 'dark',
    expectedPreference: 'light',
    expectedResolved: 'light',
  });
  active.push(legacyLight);

  const invalidWithLegacy = await runCase({
    name: 'invalid-new-key-falls-back-to-legacy',
    seed: { 'estate-crm-theme': 'invalid-value', 'vite-ui-theme': 'light' },
    colorScheme: 'dark',
    expectedPreference: 'light',
    expectedResolved: 'light',
  });
  active.push(invalidWithLegacy);

  const blocked = await runCase({
    name: 'blocked-storage-default-dark',
    blockStorage: true,
    colorScheme: 'light',
    expectedPreference: 'dark',
    expectedResolved: 'dark',
  });
  active.push(blocked);

  const system = await runCase({
    name: 'stored-system-light-first',
    seed: { 'estate-crm-theme': 'system' },
    colorScheme: 'light',
    expectedPreference: 'system',
    expectedResolved: 'light',
  });
  active.push(system);

  const storageAfterMigration = await legacyLight.page.evaluate(() => ({
    current: localStorage.getItem('estate-crm-theme'),
    legacy: localStorage.getItem('vite-ui-theme'),
  }));
  legacyLight.item.storageAfterMigration = storageAfterMigration;
  assert.deepEqual(storageAfterMigration, { current: 'light', legacy: null }, 'legacy preference migrates and old key is removed');

  const fallbackStorage = await invalidWithLegacy.page.evaluate(() => ({
    current: localStorage.getItem('estate-crm-theme'),
    legacy: localStorage.getItem('vite-ui-theme'),
  }));
  invalidWithLegacy.item.storageAfterMigration = fallbackStorage;
  assert.deepEqual(fallbackStorage, { current: 'light', legacy: null }, 'invalid new preference falls back to legacy and migrates');

  const newLightStoredValue = await newLight.page.evaluate(() => localStorage.getItem('estate-crm-theme'));
  newLight.item.storageAfterHydration = newLightStoredValue;
  assert.equal(newLightStoredValue, 'light', 'new stored light preference survives hydration');

  const storageAfterSystem = await system.page.evaluate(() => localStorage.getItem('estate-crm-theme'));
  system.item.storageAfterHydration = storageAfterSystem;
  assert.equal(storageAfterSystem, 'system', 'stored system preference survives hydration');

  const authLight = await readAuthVisuals(newLight.page);
  const authDark = await readAuthVisuals(defaultCase.page);
  newLight.item.authVisuals = authLight;
  defaultCase.item.authVisuals = authDark;
  for (const [name, lightStyles] of Object.entries(authLight)) {
    const darkStyles = authDark[name];
    assert(lightStyles && darkStyles, `auth ${name} exists in light and dark modes`);
    for (const property of ['backgroundColor', 'color', 'borderColor']) {
      assert.notEqual(lightStyles[property], '', `auth ${name} ${property} resolves in light mode`);
      assert.notEqual(darkStyles[property], '', `auth ${name} ${property} resolves in dark mode`);
    }
  }
  for (const name of Object.keys(authLight)) {
    for (const property of ['backgroundColor', 'color', 'boxShadow', 'authAccent', 'authSurface', 'authPanelToken']) {
      assert.equal(authLight[name][property], authDark[name][property], `fixed auth ${name} ${property} is unchanged between CRM themes`);
    }
    if (authLight[name].borderStyle !== 'none' && authLight[name].borderWidth !== '0px') {
      assert.equal(authLight[name].borderColor, authDark[name].borderColor, `visible auth ${name} border is unchanged between CRM themes`);
    }
  }
  for (const name of ['panel', 'input', 'action']) {
    assert(authLight[name].contrast >= 4.5, `auth ${name} text contrast is at least 4.5:1 in light CRM theme`);
    assert(authDark[name].contrast >= 4.5, `auth ${name} text contrast is at least 4.5:1 in dark CRM theme`);
  }
  for (const [theme, styles] of [['light', authLight], ['dark', authDark]]) {
    assert(styles.input.placeholderColor, `${theme} auth placeholder color is computed`);
    assert(
      styles.input.placeholderContrast >= 4.5,
      `${theme} auth placeholder contrast is at least 4.5:1 over the input background`,
    );
  }

  const lightAuthFocus = await focusByTab(newLight.page, 'auth-input');
  const darkAuthFocus = await focusByTab(defaultCase.page, 'auth-input');
  newLight.item.authInputKeyboardFocus = lightAuthFocus;
  defaultCase.item.authInputKeyboardFocus = darkAuthFocus;
  for (const [theme, focus] of [['light', lightAuthFocus], ['dark', darkAuthFocus]]) {
    assert.equal(focus.focusVisible, true, `${theme} auth input shows keyboard focus-visible state`);
    assert(
      (focus.outlineStyle !== 'none' && focus.outlineWidth !== '0px') || focus.boxShadow !== 'none',
      `${theme} auth input has a visible focus indicator`,
    );
    assert.equal(focus.amberRingConfirmed, true, `${theme} auth input border and keyboard ring use the amber accent`);
  }

  await system.page.emulateMedia({ colorScheme: 'dark' });
  await system.page.waitForFunction(() => document.documentElement.classList.contains('dark'), null, { timeout: 10_000 });
  const systemDark = await getDomSnapshot(system.page);
  assert.equal(systemDark.themePreference, 'system');
  assert.equal(systemDark.darkClass, true, 'system preference follows dark media change');
  assert.equal(systemDark.modeData, 'system', 'visible mode continues to show the saved system preference');
  system.item.systemDarkChange = systemDark;
  await system.page.emulateMedia({ colorScheme: 'light' });
  await system.page.waitForFunction(() => !document.documentElement.classList.contains('dark'), null, { timeout: 10_000 });
  const systemLight = await getDomSnapshot(system.page);
  assert.equal(systemLight.themePreference, 'system');
  assert.equal(systemLight.darkClass, false, 'system preference follows light media change');
  assert.equal(systemLight.modeData, 'system', 'visible mode continues to show the saved system preference');
  system.item.systemLightChange = systemLight;

  const blockedBefore = blocked.item.postHydration;
  await blocked.page.getByTestId('set-theme-light').click();
  await waitForPreference(blocked.page, 'light');
  blocked.item.afterThemeChange = await getDomSnapshot(blocked.page);
  assert.equal(blocked.item.afterThemeChange.darkClass, false, 'theme setter works in current tab when storage is blocked');
  assert.deepEqual(blocked.item.pageErrors, [], 'blocked storage produces no uncaught errors');
  assert.ok(blockedBefore, 'blocked case reached post-hydration state');

  const keyboardPage = newLight.page;
  let focusedTestId = null;
  for (let index = 0; index < 20; index += 1) {
    await keyboardPage.keyboard.press('Tab');
    focusedTestId = await keyboardPage.evaluate(() => document.activeElement?.getAttribute('data-testid') ?? null);
    if (focusedTestId === 'set-theme-light') break;
  }
  assert.equal(focusedTestId, 'set-theme-light', 'Tab reaches the light theme button');
  await waitForKeyboardIndicator(keyboardPage, 'set-theme-light');
  const focusState = await keyboardPage.getByTestId('set-theme-light').evaluate((element) => {
    const style = getComputedStyle(element);
    return {
      focusVisible: element.matches(':focus-visible'),
      outlineStyle: style.outlineStyle,
      outlineWidth: style.outlineWidth,
      boxShadow: style.boxShadow,
    };
  });
  newLight.item.keyboardFocus = focusState;
  assert.equal(focusState.focusVisible, true, 'keyboard focus matches :focus-visible');
  assert(
    (focusState.outlineStyle !== 'none' && focusState.outlineWidth !== '0px') || focusState.boxShadow !== 'none',
    'keyboard focus has a visible outline or ring',
  );
  await keyboardPage.keyboard.press('Enter');
  await waitForPreference(keyboardPage, 'light');

  const disabled = await defaultCase.page.getByTestId('disabled-button').evaluate((element) => {
    let clickCount = 0;
    const countClick = () => { clickCount += 1; };
    element.addEventListener('click', countClick);
    element.click();
    element.removeEventListener('click', countClick);
    element.focus();
    return {
      disabled: element.disabled,
      clickCount,
      canReceiveFocus: document.activeElement === element,
      tabIndex: element.tabIndex,
    };
  });
  defaultCase.item.nativeDisabled = disabled;
  assert.equal(disabled.disabled, true, 'disabled control is disabled');
  assert.equal(disabled.clickCount, 0, 'native disabled button does not dispatch click');
  assert.equal(disabled.canReceiveFocus, false, 'native disabled button cannot receive focus');

  const fontReport = await newLight.page.evaluate(async () => {
    await document.fonts.ready;
    const sample = document.querySelector('[data-testid="font-sample"]');
    const style = getComputedStyle(sample);
    const familyStack = style.fontFamily;
    const family = (familyStack.match(/^\s*(['"])(.*?)\1/)?.[2] ?? familyStack.split(',')[0]).trim();
    const faceQuery = `${style.fontWeight} ${style.fontSize} "${family}"`;
    const samples = {
      english: 'Inter Variable 0123456789',
      russian: 'Русский язык',
      kazakh: 'Қазақша Әділет Ғимарат Ұұ Ґґ',
      kazakhSpecial: 'ҰұҐґ',
    };
    const checks = {};
    for (const [name, text] of Object.entries(samples)) {
      const loaded = await document.fonts.load(faceQuery, text);
      checks[name] = {
        text,
        check: document.fonts.check(faceQuery, text),
        matchingFaces: loaded.map((face) => ({
          family: face.family,
          status: face.status,
          weight: face.weight,
          unicodeRange: face.unicodeRange,
        })),
      };
    }
    return {
      computedFontFamily: familyStack,
      selectedFamily: family,
      fontWeight: style.fontWeight,
      fontSize: style.fontSize,
      tabularDigitFeature: style.fontVariantNumeric,
      checks,
      registeredFaces: [...document.fonts].map((face) => ({
        family: face.family,
        status: face.status,
        weight: face.weight,
        unicodeRange: face.unicodeRange,
      })),
    };
  });
  await newLight.page.waitForTimeout(100);
  newLight.item.fonts = fontReport;
  assert.match(fontReport.selectedFamily, /inter/i, 'font sample uses Inter family');
  for (const [name, check] of Object.entries(fontReport.checks)) {
    assert.equal(check.check, true, `${name} glyphs report loaded through CSS font loading API`);
    assert(
      check.matchingFaces.some((face) => /inter/i.test(face.family) && face.status === 'loaded'),
      `${name} resolves to a loaded Inter face`,
    );
  }
  assert.equal(fontReport.tabularDigitFeature, 'tabular-nums', 'sample uses tabular digits');
  assert(newLight.item.fontRequests.length > 0, 'same-origin local font requests captured');
  assert(
    newLight.item.fontResponses.length > 0 && newLight.item.fontResponses.every((entry) => entry.status >= 200 && entry.status < 300),
    'same-origin font responses succeed',
  );

  const desktopExpectations = { default: 36, sm: 32, lg: 40, icon: 36, input: 36 };
  const responsiveScreenshots = [];
  for (const width of [320, 640, 768, 1280]) {
    await newLight.page.setViewportSize({ width, height: 900 });
    await newLight.page.waitForTimeout(50);
    const measurements = await measureTargets(newLight.page);
    const viewport = await newLight.page.evaluate(() => ({
      width: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
      bodyWidth: document.body.scrollWidth,
      pointerCoarse: matchMedia('(pointer: coarse)').matches,
    }));
    newLight.item.desktopWidths ??= [];
    newLight.item.desktopWidths.push({ width, viewport, measurements });
    assert(viewport.documentWidth <= width, `no horizontal document overflow at desktop viewport ${width}`);
    assert(viewport.bodyWidth <= width, `no horizontal body overflow at desktop viewport ${width}`);
    for (const [name, expectedHeight] of Object.entries(desktopExpectations)) {
      assert(measurements[name], `${name} target exists at desktop viewport ${width}`);
      assert(measurements[name].height > 0, `${name} target has positive height at ${width}px`);
      if (width === 1280) {
        assert.equal(Math.round(measurements[name].height), expectedHeight, `${name} desktop height at ${width}px`);
      }
      assert(measurements[name].left >= -0.5 && measurements[name].right <= width + 0.5, `${name} stays in viewport at ${width}px`);
    }
    const screenshot = join(outputDir, `b06-light-desktop-${width}.png`);
    await newLight.page.screenshot({ path: screenshot, fullPage: true, animations: 'disabled' });
    responsiveScreenshots.push(screenshot);
  }
  newLight.item.screenshots = responsiveScreenshots;

  const mobileContext = await browser.newContext({
    viewport: { width: 320, height: 900 },
    colorScheme: 'light',
    isMobile: true,
    hasTouch: true,
    deviceScaleFactor: 2,
    reducedMotion: 'reduce',
  });
  await mobileContext.addInitScript(initProbe, { seed: { 'estate-crm-theme': 'light' }, blockStorage: false });
  const mobilePage = await mobileContext.newPage();
  const mobileErrors = [];
  mobilePage.on('pageerror', (error) => mobileErrors.push(error.stack ?? String(error)));
  await mobilePage.goto(proofUrl.href, { waitUntil: 'domcontentloaded', timeout: 20_000 });
  await mobilePage.locator('[data-testid="theme-mode"]').waitFor({ state: 'visible', timeout: 10_000 });
  await waitForPreference(mobilePage, 'light');
  const mobileSizes = [];
  for (const width of [320, 768]) {
    await mobilePage.setViewportSize({ width, height: 900 });
    await mobilePage.waitForTimeout(50);
    const measurements = await measureTargets(mobilePage);
    const viewport = await mobilePage.evaluate(() => ({
      width: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
      bodyWidth: document.body.scrollWidth,
      pointerCoarse: matchMedia('(pointer: coarse)').matches,
    }));
    mobileSizes.push({ width, viewport, measurements });
    assert.equal(viewport.pointerCoarse, true, 'mobile context has a coarse pointer');
    assert(viewport.documentWidth <= width, `no horizontal document overflow at coarse viewport ${width}`);
    assert(viewport.bodyWidth <= width, `no horizontal body overflow at coarse viewport ${width}`);
    for (const [name, measured] of Object.entries(measurements)) {
      assert(measured, `${name} target exists at coarse viewport ${width}`);
      assert(measured.height >= 44, `${name} target is at least 44px high at coarse viewport ${width}`);
      if (name !== 'input') assert(measured.width >= 44, `${name} button is at least 44px wide at coarse viewport ${width}`);
      assert(measured.left >= -0.5 && measured.right <= width + 0.5, `${name} stays in coarse viewport ${width}`);
    }
    if (width === 320) {
      const screenshot = join(outputDir, 'b06-light-coarse-320.png');
      await mobilePage.screenshot({ path: screenshot, fullPage: true, animations: 'disabled' });
      report.cases.push({ name: 'coarse-targets', screenshots: [screenshot], measurements: mobileSizes });
    }
  }
  report.cases.find((entry) => entry.name === 'coarse-targets').measurements = mobileSizes;
  assert.deepEqual(mobileErrors, [], 'no uncaught errors in coarse/mobile context');
  await mobileContext.close();

  report.status = 'PASS';
} catch (error) {
  report.status = 'FAIL';
  report.error = error.stack ?? String(error);
} finally {
  for (const entry of active) {
    if (!entry.isGateReleased()) {
      entry.setGateReleased(true);
      entry.releaseGate();
    }
    await entry.context.close().catch(() => {});
  }
  await browser.close().catch(() => {});
  await writeFile(join(outputDir, 'b06-proof-report.json'), `${JSON.stringify(report, null, 2)}\n`);
  console.log(JSON.stringify(report, null, 2));
}

if (report.status !== 'PASS') process.exitCode = 1;
