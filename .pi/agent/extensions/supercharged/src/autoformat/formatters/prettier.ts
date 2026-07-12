import {BaseFormatter, type FormatterResult} from '../formatter.ts';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {existsSync} from 'node:fs';
import {join} from 'node:path';

const execFileAsync = promisify(execFile);

export class PrettierFormatter extends BaseFormatter {
    readonly #configFiles: string[] = [
        '.prettierrc',
        '.prettierrc.js',
        'prettier.config.js',
        'prettier.config.cjs',
        'prettier.config.mjs',
    ];

    getBinary(cwd: string): string | null {
        if (!this.hasConfig(cwd, this.#configFiles)) {
            return null;
        }

        const localPath = join(cwd, 'node_modules', '.bin', 'prettier');

        if (existsSync(localPath)) {
            return localPath;
        }

        // Fallback to global
        return 'prettier';
    }

    async format(filePaths: string[], binaryPath: string, cwd: string): Promise<FormatterResult> {
        try {
            await execFileAsync(binaryPath, ['--write', ...filePaths], {cwd});
            return {success: true};
        } catch (error: unknown) {
            return {success: false, error};
        }
    }
}
