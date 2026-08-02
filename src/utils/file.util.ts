import fs from "fs";
import path from "path";
import crypto from "crypto";

const SCREENSHOT_DIRECTORY = path.join(process.cwd(), "screenshots");

// Create screenshots directory if it doesn't exist
if (!fs.existsSync(SCREENSHOT_DIRECTORY)) {
  fs.mkdirSync(SCREENSHOT_DIRECTORY, { recursive: true });
}

/**
 * Generates a unique screenshot file path.
 */
export function getScreenshotPath(): {
  fileName: string;
  filePath: string;
  createdAt: Date;
} {
  const timestamp = new Date()
    .toISOString()
    .replace(/[:.]/g, "-");

  const uniqueId = crypto.randomUUID();

  const fileName = `${timestamp}-${uniqueId}.png`;

  const filePath = path.join(
    SCREENSHOT_DIRECTORY,
    fileName
  );

  return {
    fileName,
    filePath,
    createdAt: new Date(),
  };
}