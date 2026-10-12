import type { ReactNode } from "react";
import RootLayout from "@/app/layout";

export default function RuntimeProofLayout({ children }: Readonly<{ children: ReactNode }>) {
  return <RootLayout>{children}</RootLayout>;
}
