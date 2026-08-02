import { Request, Response } from "express";
import { runAutomation } from "../services/automation.service";
import { AutomationRequest } from "../types/automation.types";
import logger from "../utils/logger";

export async function runAutomationController(
    req: Request,
    res: Response
) {
    try {
        const request: AutomationRequest = req.body;

        const result = await runAutomation(request);

        res.status(200).json(result);
    } catch (error) {
        logger.error(
            error instanceof Error ? error.message : "Unknown error"
        );

        res.status(500).json({
            success: false,
            message: "Automation failed",
        });
    }
}