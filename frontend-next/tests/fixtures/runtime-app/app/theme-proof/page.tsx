"use client";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useTheme } from "@/components/theme-client";

export default function ThemeProofPage() {
  const { theme, setTheme } = useTheme();

  return (
    <main style={{ maxWidth: 640, margin: "0 auto", padding: 24 }}>
      <h1 className="ui-page-title">B06 theme and primitive proof</h1>
      <output aria-live="polite" data-mode={theme} data-testid="theme-mode">{theme}</output>
      <p data-testid="font-sample" className="tabular-nums">
        Inter Variable — Русский — Қазақша — Әділет — Ғимарат — 0123456789
      </p>
      <Card data-testid="primitive-card">
        <h2 className="ui-card-title">Text styles</h2>
        <p className="ui-metadata">Metadata at 12 pixels</p>
        <p className="ui-secondary">Secondary text at 13 pixels</p>
        <label htmlFor="theme-proof-input">Accessible input</label>
        <Input id="theme-proof-input" data-testid="theme-proof-input" />
        <Button size="sm" data-testid="small-hit-target">Small hit target</Button>
        <Button size="lg" data-testid="large-hit-target">Large hit target</Button>
        <Button size="icon" aria-label="Icon action" data-testid="icon-hit-target">+</Button>
        <Button disabled data-testid="disabled-button">Disabled</Button>
        <Button data-testid="set-theme-light" onClick={() => setTheme("light")}>Light</Button>
        <Button data-testid="set-theme-dark" onClick={() => setTheme("dark")}>Dark</Button>
        <Button data-testid="set-theme-system" onClick={() => setTheme("system")}>System</Button>
      </Card>
      <section className="auth-visual-placeholder" data-testid="auth-visual">
        <h2 className="ui-card-title">Auth visual baseline</h2>
        <div className="auth-panel" data-testid="auth-panel">
          <Input
            aria-label="Auth input sample"
            data-testid="auth-input"
            placeholder="Auth input sample"
          />
          <Button className="auth-action" data-testid="auth-action">Auth action sample</Button>
        </div>
      </section>
    </main>
  );
}
