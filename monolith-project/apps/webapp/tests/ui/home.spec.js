import { expect, test } from "@playwright/test";

test("home page renders app details", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByTestId("title")).toHaveText("Project 1 Webapp");
  await expect(page.getByTestId("status")).toContainText("CI/CD");
  await expect(page.getByTestId("message-form")).toBeVisible();
  await expect(page.getByTestId("message-input")).toBeVisible();
  await expect(page.getByTestId("message-submit")).toBeVisible();
});
