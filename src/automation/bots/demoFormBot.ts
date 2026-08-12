import { launchBrowser } from "../browser";
import { AutomationRequest } from "../../types/automation.types";
import { getScreenshotPath } from "../../utils/file.util";
import { uploadScreenshotToS3 } from "../../services/s3.service";
import logger from "../../utils/logger";

export async function runDemoFormBot(
    request: AutomationRequest
): Promise<{
    fileName: string;
    filePath: string;
    s3Key: string;
    s3Uri: string;
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

        /*
         * Add the correct selectors for last name and email
         * when we finalize the form automation.
         */

        // Generate screenshot path
        const screenshot = getScreenshotPath();

        // Take screenshot
        await page.screenshot({
            path: screenshot.filePath,
            fullPage: true,
        });

        logger.info(
            `Screenshot created locally: ${screenshot.filePath}`
        );

        // Upload screenshot to S3
        const s3Result = await uploadScreenshotToS3(
            screenshot.filePath,
            screenshot.fileName
        );

        logger.info(
            `Screenshot stored in S3: ${s3Result.s3Uri}`
        );

        return {
            fileName: screenshot.fileName,
            filePath: screenshot.filePath,
            s3Key: s3Result.s3Key,
            s3Uri: s3Result.s3Uri,
            createdAt: screenshot.createdAt,
        };
    } finally {
        await browser.close();
    }
}