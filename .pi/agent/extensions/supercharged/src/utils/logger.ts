import {appendFileSync, existsSync, mkdirSync, readdirSync, unlinkSync} from 'node:fs';
import {join} from 'node:path';

export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';

export const LogGroup = {AutoFormat: 'AutoFormat', Permission: 'Permission'} as const;

export class Logger {
    readonly #dir: string = join(import.meta.dirname, '..', '..', '.logs');

    #file: string;

    constructor() {
        if (!existsSync(this.#dir)) {
            mkdirSync(this.#dir, {recursive: true});
        }

        const today = new Date().toISOString().split('T')[0];
        this.#file = join(this.#dir, `${today}.log`);

        const files = readdirSync(this.#dir);

        for (const file of files) {
            if (file !== this.#file) {
                try {
                    unlinkSync(join(this.#dir, file));
                } catch (_err: unknown) {
                    // Silently fail if we can't delete
                }
            }
        }
    }

    debug(group: string, msg: string, data?: unknown): void {
        this.#log(group, 'DEBUG', msg, data);
    }

    info(group: string, msg: string, data?: unknown): void {
        this.#log(group, 'INFO', msg, data);
    }

    warn(group: string, msg: string, data?: unknown): void {
        this.#log(group, 'WARN', msg, data);
    }

    error(group: string, msg: string, data?: unknown): void {
        this.#log(group, 'ERROR', msg, data);
    }

    #log(group: string, level: LogLevel, message: string, data?: unknown): void {
        let logMessage = `[${new Date().toISOString()}] [${group.toUpperCase()}] [${level}] ${message}`;

        try {
            if (data) {
                if (data instanceof Error) {
                    logMessage += ` - ${data.message}\n${data.stack}`;
                } else {
                    logMessage += ` - ${JSON.stringify(data)}`;
                }
            }

            appendFileSync(this.#file, logMessage + '\n');
        } catch (err: unknown) {
            console.error('Failed to write to log file', err);
        }
    }
}

export const logger: Logger = new Logger();
