import express from "express";
import healthRoutes from "./routes/health.routes";
import automationRoutes from "./routes/automation.routes";
import csvRoutes from './routes/csv.routes';

const app = express();

app.use(express.json());

app.use("/api/health", healthRoutes);
app.use("/api/automation", automationRoutes);
app.use('/api/csv', csvRoutes);

export default app;
