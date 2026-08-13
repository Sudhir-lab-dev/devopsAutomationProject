import { Request, Response } from 'express';
import fs from 'fs';

import {
    parseCsvFile,
    validateCsvRecord,
} from '../services/csv.service';

import { runDemoFormBot } from '../automation/bots/demoFormBot';

import { AutomationRequest } from '../types/automation.types';

export async function uploadCsv(
    req: Request,
    res: Response
): Promise<void> {

    try {

        // --------------------------------------------------
        // 1. Check whether CSV file was uploaded
        // --------------------------------------------------

        if (!req.file) {

            res.status(400).json({
                success: false,
                message: 'CSV file is required',
            });

            return;
        }


        // --------------------------------------------------
        // 2. Get uploaded CSV file path
        // --------------------------------------------------

        const filePath = req.file.path;


        // --------------------------------------------------
        // 3. Parse CSV file
        // --------------------------------------------------

        const records = parseCsvFile(filePath);


        // --------------------------------------------------
        // 4. Remove uploaded CSV after parsing
        // --------------------------------------------------

        fs.unlinkSync(filePath);


        // --------------------------------------------------
        // 5. Check whether CSV contains records
        // --------------------------------------------------

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


        // --------------------------------------------------
        // 6. Process each CSV record
        // --------------------------------------------------

        const results = [];


        for (const record of records) {

            console.log(
                `Starting validation for ${record.firstName} ${record.lastName}`
            );


            // --------------------------------------------------
            // 7. Validate CSV record BEFORE Puppeteer
            // --------------------------------------------------

            const validation = validateCsvRecord(record);


            // --------------------------------------------------
            // 8. Handle invalid CSV record
            // --------------------------------------------------

            if (!validation.valid) {

                console.log(
                    `Validation failed for ${record.firstName} ${record.lastName}`
                );

                console.log(
                    `Validation errors: ${validation.errors.join(', ')}`
                );


                results.push({
                    firstName: record.firstName,
                    lastName: record.lastName,
                    email: record.email,
                    status: 'FAILED',
                    errorType: 'VALIDATION_ERROR',
                    errors: validation.errors,
                });


                // Important:
                // Do NOT stop the complete CSV processing.
                // Continue with the next record.

                continue;
            }


            console.log(
                `Validation passed for ${record.firstName} ${record.lastName}`
            );


            // --------------------------------------------------
            // 9. Run Puppeteer automation
            // --------------------------------------------------

            try {

                const screenshot = await runDemoFormBot(
                    record as AutomationRequest
                );


                // --------------------------------------------------
                // 10. Automation successful
                // --------------------------------------------------

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


                // --------------------------------------------------
                // 11. Automation failed
                // --------------------------------------------------

                console.error(
                    `Automation failed for ${record.firstName} ${record.lastName}:`,
                    error
                );


                results.push({
                    firstName: record.firstName,
                    lastName: record.lastName,
                    email: record.email,
                    status: 'FAILED',
                    errorType: 'AUTOMATION_ERROR',
                    error: 'Automation failed',
                });

            }

        }


        // --------------------------------------------------
        // 12. Calculate processing summary
        // --------------------------------------------------

        const successfulRecords = results.filter(
            (result) => result.status === 'SUCCESS'
        ).length;


        const failedRecords = results.filter(
            (result) => result.status === 'FAILED'
        ).length;


        // --------------------------------------------------
        // 13. Return final response
        // --------------------------------------------------

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


        // --------------------------------------------------
        // 14. Handle unexpected CSV processing errors
        // --------------------------------------------------

        console.error(
            'CSV processing error:',
            error
        );


        // --------------------------------------------------
        // 15. Cleanup uploaded CSV if it still exists
        // --------------------------------------------------

        if (
            req.file?.path &&
            fs.existsSync(req.file.path)
        ) {

            fs.unlinkSync(req.file.path);

        }


        // --------------------------------------------------
        // 16. Return server error
        // --------------------------------------------------

        res.status(500).json({

            success: false,

            message: 'Failed to process CSV file',

        });

    }

}