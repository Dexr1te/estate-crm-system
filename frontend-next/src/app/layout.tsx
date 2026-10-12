import type { ReactNode } from "react";
import { ThemeClient } from "@/components/theme-client";
import { THEME_BOOTSTRAP_SCRIPT } from "@/lib/theme";
import "./globals.css";

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" className="dark" data-theme-preference="dark" suppressHydrationWarning>
      <head>
        <script id="estate-theme-bootstrap" dangerouslySetInnerHTML={{ __html: THEME_BOOTSTRAP_SCRIPT }} />
      </head>
      <body>
        <ThemeClient>{children}</ThemeClient>
      </body>
    </html>
  );
}
