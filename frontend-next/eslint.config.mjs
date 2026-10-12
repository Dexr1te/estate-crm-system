import { defineConfig, globalIgnores } from "eslint/config";
import nextCoreWebVitals from "eslint-config-next/core-web-vitals";
import nextTypeScript from "eslint-config-next/typescript";

export default defineConfig([
  ...nextCoreWebVitals,
  ...nextTypeScript,
  {
    files: ["tests/fixtures/runtime-app/app/**/*.{ts,tsx}"],
    rules: { "@next/next/no-html-link-for-pages": "off" },
  },
  globalIgnores(["**/.next/**", "**/node_modules/**", "**/next-env.d.ts"]),
]);
