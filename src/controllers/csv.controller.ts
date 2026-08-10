import { Request, Response } from 'express';
import fs from 'fs';
import { parseCsvFile } from '../services/csv.service';
import { runDemoFormBot } from '../automation/bots/demoFormBot';
import { AutomationRequest } from '../types/automation.types';

export async function uploadCsv(
    req: Request,
    res: Response
): Promise<void> {
    try {
        if (!req.file) {
            res.status(400).json({
                success: false,
                message: 'CSV file is required',
            });

            return;
        }

        const filePath = req.file.path;

        const records = parseCsvFile(filePath);

        // Remove uploaded CSV after parsing
        fs.unlinkSync(filePath);

        if (records.length === 0) {
            res.status(400).json({
                success: false,
                message: 'CSV file contains no records',
            });

            return;
        }

        console.log(
            `CSV contains ${records.length} records.`
        );

        const results = [];

        for (const record of records) {
            console.log(
                `Starting automation for ${record.firstName} ${record.lastName}`
            );

            try {
                const screenshot = await runDemoFormBot(
                    record as AutomationRequest
                );

                results.push({
                    firstName: record.firstName,
                    lastName: record.lastName,
                    email: record.email,
                    status: 'SUCCESS',
                    screenshot,
                });

                console.log(
                    `Automation completed for ${record.firstName} ${record.lastName}`
                );

            } catch (error) {
                console.error(
                    `Automation failed for ${record.firstName} ${record.lastName}:`,
                    error
                );

                results.push({
                    firstName: record.firstName,
                    lastName: record.lastName,
                    email: record.email,
                    status: 'FAILED',
                    error: 'Automation failed',
                });
            }
        }

        const successfulRecords = results.filter(
            (result) => result.status === 'SUCCESS'
        ).length;

        const failedRecords = results.filter(
            (result) => result.status === 'FAILED'
        ).length;

        res.status(200).json({
            success: failedRecords === 0,
            message:
                failedRecords === 0
                    ? 'CSV processed successfully'
                    : 'CSV processing completed with some failures',
            totalRecords: records.length,
            successfulRecords,
            failedRecords,
            results,
        });

    } catch (error) {
        console.error('CSV processing error:', error);

        // Clean up uploaded file if it still exists
        if (req.file?.path && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }

        res.status(500).json({
            success: false,
            message: 'Failed to process CSV file',
        });
    }
}