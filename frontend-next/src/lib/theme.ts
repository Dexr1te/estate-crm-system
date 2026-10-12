export const THEME_STORAGE_KEY = "estate-crm-theme";
export const LEGACY_THEME_STORAGE_KEY = "vite-ui-theme";

export type ThemePreference = "light" | "dark" | "system";
export type ColorScheme = "light" | "dark";

export function parseThemePreference(value: string | undefined): ThemePreference | null {
  return value === "light" || value === "dark" || value === "system" ? value : null;
}

export function resolveColorScheme(preference: ThemePreference, systemIsDark: boolean): ColorScheme {
  return preference === "system" ? (systemIsDark ? "dark" : "light") : preference;
}

export function applyThemePreference(
  root: Pick<HTMLHtmlElement, "dataset" | "classList">,
  preference: ThemePreference,
  systemIsDark: boolean,
) {
  const scheme = resolveColorScheme(preference, systemIsDark);
  root.dataset.themePreference = preference;
  root.classList.toggle("dark", scheme === "dark");
}

export function watchThemePreference(root: HTMLElement, preference: ThemePreference) {
  let media: MediaQueryList | undefined;
  try {
    if (preference === "system") media = window.matchMedia("(prefers-color-scheme: dark)");
  } catch {
    // A missing matchMedia implementation uses the light system fallback.
  }

  const update = () => applyThemePreference(root, preference, media?.matches ?? false);
  media?.addEventListener("change", update);
  update();
  return () => media?.removeEventListener("change", update);
}

export function bootstrapTheme(storageKey: string, legacyStorageKey: string) {
  let preference = "dark";
  try {
    const storage = window.localStorage;
    const saved = storage.getItem(storageKey);
    if (saved === "light" || saved === "dark" || saved === "system") {
      preference = saved;
    } else {
      const legacy = storage.getItem(legacyStorageKey);
      if (legacy === "light" || legacy === "dark" || legacy === "system") {
        preference = legacy;
        try {
          storage.setItem(storageKey, legacy);
          storage.removeItem(legacyStorageKey);
        } catch {
          // Keep the migrated preference for this page when storage is read-only.
        }
      }
    }
  } catch {
    // A blocked storage API falls back to the first-run dark theme.
  }

  let systemIsDark = false;
  if (preference === "system") {
    try {
      systemIsDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    } catch {
      // Keep the light system fallback if the media query is unavailable.
    }
  }

  const root = document.documentElement;
  root.dataset.themePreference = preference;
  root.classList.toggle("dark", preference === "dark" || (preference === "system" && systemIsDark));
}

export const THEME_BOOTSTRAP_SCRIPT = `(${bootstrapTheme.toString()})(${JSON.stringify(THEME_STORAGE_KEY)},${JSON.stringify(LEGACY_THEME_STORAGE_KEY)});`;
