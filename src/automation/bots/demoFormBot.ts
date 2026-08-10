import { launchBrowser } from "../browser";
import { AutomationRequest } from "../../types/automation.types";
import { getScreenshotPath } from "../../utils/file.util";

export async function runDemoFormBot(
    request: AutomationRequest
): Promise<{
    fileName: string;
    filePath: string;
    createdAt: Date;
}> {
    const browser = await launchBrowser();

    try {
        const page = await browser.newPage();

        await page.goto(
            "https://www.selenium.dev/selenium/web/web-form.html",
            {
                waitUntil: "load",
            }
        );

        // Fill first name
        await page.locator("#my-text-id").fill(request.firstName);

        // Fill last name
        const lastNameInput: any = page.locator('input[name="my-password"]');

        if (await lastNameInput.count()) {
            await lastNameInput.fill(request.lastName);
        }

        // Fill email
        const emailInput: any = page.locator('textarea[name="my-textarea"]');

        if (await emailInput.count()) {
            await emailInput.fill(request.email);
        }

        const screenshot = getScreenshotPath();

        await page.screenshot({
            path: screenshot.filePath,
            fullPage: true,
        });

        return screenshot;
    } finally {
        await browser.close();
    }
}