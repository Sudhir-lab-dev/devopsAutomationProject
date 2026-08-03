import { launchBrowser } from "../browser";
import { AutomationRequest } from "../../types/automation.types";
import { getScreenshotPath } from "../../utils/file.util";

export async function runDemoFormBot(request: AutomationRequest): Promise<{
  fileName: string;
  filePath: string;
  createdAt: Date;
}> {
  const browser = await launchBrowser();

  try {
    const page = await browser.newPage();

    await page.goto("https://www.selenium.dev/selenium/web/web-form.html", {
      waitUntil: "load",
    });

    await page.locator("#my-text-id").fill(request.firstName);

    const screenshot = getScreenshotPath();

    await page.screenshot({
      path: screenshot.filePath,
    });

    return screenshot;
  } finally {
    await browser.close();
  }
}
