import fs from 'fs';
import { parse } from 'csv-parse/sync';
import { CsvAutomationRow } from '../types/csv.types';

export function parseCsvFile(
    filePath: string
): CsvAutomationRow[] {

    const fileContent = fs.readFileSync(filePath, 'utf-8');

    const records = parse(fileContent, {
        columns: true,
        skip_empty_lines: true,
        trim: true,
    });

    return records as CsvAutomationRow[];
}