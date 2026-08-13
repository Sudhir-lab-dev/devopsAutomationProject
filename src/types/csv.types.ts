export interface CsvAutomationRow {
    firstName: string;
    lastName: string;
    email: string;
}

export interface CsvValidationResult {
    valid: boolean;
    errors: string[];
}