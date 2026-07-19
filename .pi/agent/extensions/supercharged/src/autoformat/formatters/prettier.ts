import {BaseFormatter, type FormatterResult, FORMAT_TIMEOUT} from '../formatter.ts';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
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

        let localPath: string | null = join(cwd, 'node_modules', '.bin', 'prettier');
        localPath = this.check(localPath);

        if (localPath) {
            return localPath;
        }

        return this.which('prettier');
    }

    async format(filePaths: string[], binaryPath: string, cwd: string): Promise<FormatterResult> {
        try {
            await execFileAsync(binaryPath, ['--write', ...filePaths], {
                cwd,
                timeout: FORMAT_TIMEOUT,
            });
            return {success: true};
        } catch (error: unknown) {
            return {success: false, error};
        }
    }
}
