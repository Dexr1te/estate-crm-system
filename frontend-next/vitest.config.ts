import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["tests/vitest/**/*.test.{ts,tsx}"],
    environment: "jsdom",
    environmentOptions: { jsdom: { url: "http://127.0.0.1:3000" } },
    setupFiles: ["./tests/vitest/setup.ts"],
  },
});
