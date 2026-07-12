import {BaseFormatter, type FormatterResult} from '../formatter.ts';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {existsSync} from 'node:fs';
import {join} from 'node:path';

const execFileAsync = promisify(execFile);

export class PhpCodeStandardFixerFormatter extends BaseFormatter {
    readonly #configFiles = ['.php-cs-fixer.php', '.php-cs-fixer.dist.php'];

    getBinary(cwd: string): string | null {
        if (!this.hasConfig(cwd, this.#configFiles)) {
            return null;
        }

        const localPath = join(cwd, 'vendor', 'bin', 'php-cs-fixer');

        if (existsSync(localPath)) {
            return localPath;
        }

        return 'php-cs-fixer';
    }

    async format(filePaths: string[], binaryPath: string, cwd: string): Promise<FormatterResult> {
        try {
            await execFileAsync(binaryPath, ['fix', ...filePaths], {cwd});
            return {success: true};
        } catch (_error: unknown) {
            return {
                success: false,
                error: '',
                stderr: '',
            };
        }
    }
}
