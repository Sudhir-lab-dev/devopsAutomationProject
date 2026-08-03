import { Router } from "express";
import { runAutomationController } from "../controllers/automation.controller";

const router = Router();

router.post("/run", runAutomationController);

export default router;
