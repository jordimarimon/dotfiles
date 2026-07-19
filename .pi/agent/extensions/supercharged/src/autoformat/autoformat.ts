import {EXTENSION_TO_FILETYPE, FORMATTERS, FORMATTERS_BY_FILETYPE} from './registry.ts';
import {logger, LogGroup} from '../utils/logger.ts';
import {ToolIntent} from '#src/utils/intent.ts';
import {readFile} from 'node:fs/promises';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolResultEvent,
    TurnEndEvent,
} from '@earendil-works/pi-coding-agent';
import {createHash} from 'node:crypto';
import {existsSync} from 'node:fs';
import {extname} from 'node:path';

export class AutoFormat {
    readonly #files = new Set<string>();

    static register(pi: ExtensionAPI): void {
        const autoFormat = new AutoFormat();

        // Collect modified files
        pi.on('tool_result', (event: ToolResultEvent) => {
            autoFormat.#handle(event);
        });

        // Format at the end (this way if the LLM modifies multiple times
        // the same file, we only format once)
        pi.on('turn_end', async (_event: TurnEndEvent, ctx: ExtensionContext) => {
            const files = Array.from(autoFormat.#files);
            autoFormat.#files.clear();

            if (files.length === 0) {
                return;
            }

            logger.debug(LogGroup.AutoFormat, 'Checking files: ', {files});

            const result = await autoFormat.#format(ctx.cwd, files);

            if (!result.length) {
                return;
            }

            logger.info(LogGroup.AutoFormat, `Successfully formatted ${result.length} files`);

            ctx.ui.notify(`Autoformatted ${result.length} file(s)`, 'info');

            pi.sendMessage({
                display: true,
                customType: 'format',
                content: `The following files were automatically formatted:\n- ${result.join('\n- ')}`,
            });
        });
    }

    #handle(event: ToolResultEvent): void {
        // If the tool was blocked by the permission system
        if (event.isError) {
            return;
        }

        const intent = ToolIntent.get(event.toolCallId);

        if (!intent) {
            return;
        }

        for (const path of intent.paths) {
            if (existsSync(path)) {
                this.#files.add(path);
            }
        }
    }

    async #format(cwd: string, files: string[]): Promise<string[]> {
        const filesByType: Record<string, string[]> = {};

        for (const file of files) {
            const ext = extname(file).slice(1);
            const fileType = EXTENSION_TO_FILETYPE[ext];

            if (fileType) {
                filesByType[fileType] ??= [];
                filesByType[fileType].push(file);
            }
        }

        const results: string[] = [];

        for (const [fileType, batch] of Object.entries(filesByType)) {
            const formatterNames = FORMATTERS_BY_FILETYPE[fileType];

            if (!formatterNames?.length) {
                continue;
            }

            const initialHashes: Record<string, string | null> = {};
            for (const file of batch) {
                initialHashes[file] = await this.#getHash(file);
            }

            const successfulTools: string[] = [];

            for (const formatterName of formatterNames) {
                const formatter = FORMATTERS[formatterName];
                if (!formatter) {
                    continue;
                }

                const binary = formatter.getBinary(cwd);
                if (!binary) {
                    logger.debug(
                        LogGroup.AutoFormat,
                        `Formatter ${formatterName} not available for cwd: ${cwd}`,
                    );
                    continue;
                }

                logger.info(LogGroup.AutoFormat, `Running ${formatterName}`, {files: batch});

                const result = await formatter.format(batch, binary, cwd);

                if (result.success) {
                    successfulTools.push(formatterName);
                } else {
                    logger.error(LogGroup.AutoFormat, `Formatter ${formatterName} failed`, {
                        result,
                        cwd,
                    });
                }
            }

            if (successfulTools.length > 0) {
                for (const file of batch) {
                    const postHash = await this.#getHash(file);

                    if (postHash !== initialHashes[file]) {
                        results.push(`${file} (${successfulTools.join(', ')})`);
                    }
                }
            }
        }

        return results;
    }

    async #getHash(filePath: string): Promise<string | null> {
        try {
            // After "digest(...)", we can't reuse the Hash object,
            // we need to create a new hash object every time.
            const content = await readFile(filePath);
            return createHash('sha256').update(content).digest('hex');
        } catch {
            return null;
        }
    }
}
