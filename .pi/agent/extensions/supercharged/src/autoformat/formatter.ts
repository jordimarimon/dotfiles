import {existsSync, statSync, accessSync, constants} from 'node:fs';
import {join, delimiter, resolve} from 'node:path';

export interface FormatterResult {
    success: boolean;
    error?: unknown;
}

export const FORMAT_TIMEOUT = 10_000;

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

    protected which(command: string): string | null {
        if (command.includes('/')) {
            return this.check(command);
        }

        const paths = (process.env['PATH'] || '').split(delimiter);

        for (const p of paths) {
            const fullPath = join(p, command);
            const result = this.check(fullPath);

            if (result) {
                return result;
            }
        }

        return null;
    }

    protected check(path: string): string | null {
        try {
            const stats = statSync(path);

            if (!stats.isFile()) {
                return null;
            }

            accessSync(path, constants.X_OK);

            return resolve(path);
        } catch {
            // Ignore
        }

        return null;
    }
}
