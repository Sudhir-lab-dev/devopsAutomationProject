import {
    S3Client,
    PutObjectCommand,
} from "@aws-sdk/client-s3";
import fs from "fs";
import logger from "../utils/logger";

const AWS_REGION = process.env.AWS_REGION || "us-east-1";

const S3_BUCKET =
    process.env.S3_SCREENSHOT_BUCKET ||
    "automation-devops-project-screenshots-218589468002";

const s3Client = new S3Client({
    region: AWS_REGION,
});

export async function uploadScreenshotToS3(
    filePath: string,
    fileName: string
): Promise<{
    s3Key: string;
    s3Uri: string;
}> {
    const s3Key = `screenshots/${fileName}`;

    try {
        logger.info(`Uploading screenshot to S3: ${s3Key}`);

        const fileStream = fs.createReadStream(filePath);

        await s3Client.send(
            new PutObjectCommand({
                Bucket: S3_BUCKET,
                Key: s3Key,
                Body: fileStream,
                ContentType: "image/png",
            })
        );

        const s3Uri = `s3://${S3_BUCKET}/${s3Key}`;

        logger.info(`Screenshot uploaded successfully: ${s3Uri}`);

        return {
            s3Key,
            s3Uri,
        };
    } catch (error) {
        logger.error(`S3 screenshot upload failed: ${error}`);

        throw error;
    }
}