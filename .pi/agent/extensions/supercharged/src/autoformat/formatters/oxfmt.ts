import {BaseFormatter, type FormatterResult, FORMAT_TIMEOUT} from '../formatter.ts';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {join} from 'node:path';

const execFileAsync = promisify(execFile);

export class OxfmtFormatter extends BaseFormatter {
    readonly #configFiles: string[] = [
        '.oxfmtrc.json',
        '.oxfmtrc.jsonc',
        'oxfmt.config.ts',
        'oxfmt.config.mts',
    ];

    #execPath: string | null = '';

    hasBinary(cwd: string): boolean {
        if (this.#execPath) {
            return true;
        }

        if (!this.hasConfig(cwd, this.#configFiles)) {
            return false;
        }

        const localPath: string | null = join(cwd, 'node_modules', '.bin', 'oxfmt');
        this.#execPath = this.check(localPath);

        if (this.#execPath) {
            return true;
        }

        this.#execPath = this.which('oxfmt');

        return !!this.#execPath;
    }

    async format(paths: string[], cwd: string): Promise<FormatterResult> {
        if (!this.#execPath) {
            return {success: false, error: 'No binary available'};
        }

        try {
            await execFileAsync(this.#execPath, paths, {cwd, timeout: FORMAT_TIMEOUT});
            return {success: true};
        } catch (error: unknown) {
            return {success: false, error};
        }
    }
}
