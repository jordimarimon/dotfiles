import {existsSync} from 'node:fs';
import {join} from 'node:path';

export interface FormatterResult {
    success: boolean;
    error?: unknown;
}

export abstract class BaseFormatter {
    /**
     * Discovery logic: returns the absolute path to the binary if available or the command name
     * and only if a config file is present in the project.
     */
    abstract getBinary(cwd: string): string | null;

    /**
     * The actual formatting execution. Supports multiple files for batching.
     */
    abstract format(filePaths: string[], binaryPath: string, cwd: string): Promise<FormatterResult>;

    /**
     * Helper to check if any of the config files exist in the cwd.
     */
    protected hasConfig(cwd: string, configFiles: string[]): boolean {
        return configFiles.some(file => existsSync(join(cwd, file)));
    }
}
