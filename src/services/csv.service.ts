import fs from 'fs';
import { parse } from 'csv-parse/sync';
import {
    CsvAutomationRow,
    CsvValidationResult,
} from '../types/csv.types';

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

export function validateCsvRecord(
    record: CsvAutomationRow
): CsvValidationResult {

    const errors: string[] = [];

    if (!record.firstName?.trim()) {
        errors.push('firstName is required');
    }

    if (!record.lastName?.trim()) {
        errors.push('lastName is required');
    }

    if (!record.email?.trim()) {
        errors.push('email is required');
    } else if (!isValidEmail(record.email)) {
        errors.push('email is invalid');
    }

    return {
        valid: errors.length === 0,
        errors,
    };
}

function isValidEmail(email: string): boolean {

    const emailRegex =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    return emailRegex.test(email.trim());
}