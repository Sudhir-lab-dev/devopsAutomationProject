import express from "express";
import healthRoutes from "./routes/health.routes";
import automationRoutes from "./routes/automation.routes";

const app = express();

app.use(express.json());

app.use("/api", healthRoutes);
app.use("/api/automation", automationRoutes);

export default app;