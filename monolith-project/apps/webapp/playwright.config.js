import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/ui",
  retries: process.env.CI ? 1 : 0,
  use: {
    baseURL: process.env.BASE_URL || "http://127.0.0.1:3000"
  },
  webServer: {
    command: "npm start",
    url: "http://127.0.0.1:3000/health",
    reuseExistingServer: false,
    timeout: 120000,
  }
});
