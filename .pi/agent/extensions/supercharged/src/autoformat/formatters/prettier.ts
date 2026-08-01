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

    #execPath: string | null = '';

    hasBinary(cwd: string): boolean {
        if (this.#execPath) {
            return true;
        }

        if (!this.hasConfig(cwd, this.#configFiles)) {
            return false;
        }

        const localPath: string | null = join(cwd, 'node_modules', '.bin', 'prettier');
        this.#execPath = this.check(localPath);

        if (this.#execPath) {
            return true;
        }

        this.#execPath = this.which('prettier');

        return !!this.#execPath;
    }

    async format(paths: string[], cwd: string): Promise<FormatterResult> {
        if (!this.#execPath) {
            return {success: false, error: 'No binary available'};
        }

        try {
            await execFileAsync(this.#execPath, ['--write', ...paths], {
                cwd,
                timeout: FORMAT_TIMEOUT,
            });
            return {success: true};
        } catch (error: unknown) {
            return {success: false, error};
        }
    }
}
