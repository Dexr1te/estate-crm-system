"use client";

import { createContext, useContext, useEffect, useSyncExternalStore, type ReactNode } from "react";
import {
  applyThemePreference,
  LEGACY_THEME_STORAGE_KEY,
  parseThemePreference,
  THEME_STORAGE_KEY,
  type ThemePreference,
  watchThemePreference,
} from "@/lib/theme";

type ThemeContextValue = {
  theme: ThemePreference;
  setTheme: (theme: ThemePreference) => void;
};

const ThemeContext = createContext<ThemeContextValue | null>(null);
const themeListeners = new Set<() => void>();

function subscribeTheme(listener: () => void) {
  themeListeners.add(listener);
  return () => {
    themeListeners.delete(listener);
  };
}

function getThemeSnapshot(): ThemePreference {
  return parseThemePreference(document.documentElement.dataset.themePreference) ?? "dark";
}

function getServerThemeSnapshot(): ThemePreference {
  return "dark";
}

function publishTheme() {
  for (const listener of themeListeners) listener();
}

export function ThemeClient({ children }: { children: ReactNode }) {
  const theme = useSyncExternalStore(subscribeTheme, getThemeSnapshot, getServerThemeSnapshot);

  useEffect(() => {
    const preference = parseThemePreference(document.documentElement.dataset.themePreference) ?? theme;
    return watchThemePreference(document.documentElement, preference);
  }, [theme]);

  const setTheme = (nextTheme: ThemePreference) => {
    let systemIsDark = false;
    if (nextTheme === "system") {
      try {
        systemIsDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      } catch {
        // Use the light system fallback if matchMedia is unavailable.
      }
    }
    applyThemePreference(document.documentElement, nextTheme, systemIsDark);
    try {
      const storage = window.localStorage;
      storage.setItem(THEME_STORAGE_KEY, nextTheme);
      storage.removeItem(LEGACY_THEME_STORAGE_KEY);
    } catch {
      // Keep the selected theme in this tab if storage is blocked.
    }
    publishTheme();
  };

  return <ThemeContext.Provider value={{ theme, setTheme }}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("useTheme must be used within ThemeClient");
  return context;
}
