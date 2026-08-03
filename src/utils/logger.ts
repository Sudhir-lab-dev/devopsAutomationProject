import winston from "winston";
import fs from "fs";
import path from "path";

const LOG_DIRECTORY = path.join(process.cwd(), "logs");

// Create logs directory if it doesn't exist
if (!fs.existsSync(LOG_DIRECTORY)) {
  fs.mkdirSync(LOG_DIRECTORY, { recursive: true });
}

const logger = winston.createLogger({
  level: "info",

  format: winston.format.combine(
    winston.format.timestamp({
      format: "YYYY-MM-DD HH:mm:ss",
    }),
    winston.format.printf(({ timestamp, level, message }) => {
      return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    }),
  ),

  transports: [
    new winston.transports.Console(),

    new winston.transports.File({
      filename: path.join(LOG_DIRECTORY, "application.log"),
    }),
  ],
});

export default logger;
