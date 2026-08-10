import { Request, Response } from 'express';
import fs from 'fs';
import { parseCsvFile } from '../services/csv.service';

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

        fs.unlinkSync(filePath);

        res.status(200).json({
            success: true,
            message: 'CSV uploaded and parsed successfully',
            totalRecords: records.length,
            records,
        });

    } catch (error) {

        console.error('CSV processing error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to process CSV file',
        });
    }
}