import {logger, LogGroup} from '../utils/logger.ts';
import {dirname, join, relative} from 'node:path';
import {existsSync, readFileSync} from 'node:fs';
import {ToolIntent} from '#src/utils/intent.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolResultEvent,
    AgentToolResult,
} from '@earendil-works/pi-coding-agent';

export class ScopedContext {
    readonly #files = new Set<string>();

    static register(pi: ExtensionAPI): void {
        const context = new ScopedContext();

        pi.on('tool_result', (event: ToolResultEvent, ctx: ExtensionContext) => {
            return context.#handle(event, ctx);
        });
    }

    #handle(event: ToolResultEvent, ctx: ExtensionContext): AgentToolResult<unknown> {
        if (event.isError) {
            return event;
        }

        const intent = ToolIntent.get(event.toolCallId);

        if (!intent?.paths.length) {
            return event;
        }

        const newContent: ToolResultEvent['content'] = [];

        for (const path of intent.paths) {
            const newContextFiles = this.#search(path, ctx.cwd);

            if (!newContextFiles.length) {
                return event;
            }

            logger.info(
                LogGroup.ScopedContext,
                `Found ${newContextFiles.length} new AGENTS.md files for ${path}`,
            );

            const contextBlocks = newContextFiles.map(f => {
                const content = readFileSync(f, 'utf8');
                const relativePath = relative(ctx.cwd, f);
                return `[Context from ${relativePath}]\n${content}`;
            });

            newContent.push({
                type: 'text' as const,
                text: `### Hierarchical Context Discovery\n\nNew context rules found for this path:\n\n${contextBlocks.join('\n\n')}`,
            });
        }

        newContent.push(...event.content);

        return {content: newContent, details: event.details};
    }

    #search(target: string, root: string): string[] {
        const found: string[] = [];

        let currentDir = dirname(target);

        while (true) {
            const next = dirname(currentDir);
            const agentsPath = join(currentDir, 'AGENTS.md');
            const isRoot = currentDir === root;

            if (!isRoot && !this.#files.has(agentsPath) && existsSync(agentsPath)) {
                found.push(agentsPath);
                this.#files.add(agentsPath);
            }

            if (isRoot || currentDir === next) {
                break;
            }

            currentDir = next;
        }

        return found.reverse();
    }
}
