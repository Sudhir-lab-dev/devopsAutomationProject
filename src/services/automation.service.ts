import { runDemoFormBot } from "../automation/bots/demoFormBot";
import { AutomationRequest } from "../types/automation.types";
import logger from "../utils/logger";

export async function runAutomation(request: AutomationRequest) {
    logger.info("Automation started.");
    const screenshot = await runDemoFormBot(request);
    logger.info("Automation completed successfully.");

    return {
        success: true,
        message: "Automation completed successfully",
        screenshot,
    };
}