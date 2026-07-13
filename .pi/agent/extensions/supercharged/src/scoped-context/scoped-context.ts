import {dirname, join, relative, resolve} from 'node:path';
import {logger, LogGroup} from '../utils/logger.ts';
import {existsSync, readFileSync} from 'node:fs';
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
        if (
            event.isError ||
            (event.toolName !== 'read' && event.toolName !== 'write' && event.toolName !== 'edit')
        ) {
            return event;
        }

        const filePath = event.input['path'];

        if (typeof filePath !== 'string') {
            return event;
        }

        const absoluteFilePath = resolve(ctx.cwd, filePath);
        const newContextFiles = this.#search(absoluteFilePath, ctx.cwd);

        if (!newContextFiles.length) {
            return event;
        }

        logger.info(
            LogGroup.ScopedContext,
            `Found ${newContextFiles.length} new AGENTS.md files for ${filePath}`,
        );

        const contextBlocks = newContextFiles.map(f => {
            const content = readFileSync(f, 'utf8');
            const relativePath = relative(ctx.cwd, f);
            return `[Context from ${relativePath}]\n${content}`;
        });

        const newContent = [
            {
                type: 'text' as const,
                text: `### Hierarchical Context Discovery\n\nNew context rules found for this path:\n\n${contextBlocks.join('\n\n')}`,
            },
            ...event.content,
        ];

        return {content: newContent, details: event.details};
    }

    #search(target: string, root: string): string[] {
        const found: string[] = [];

        let currentDir = dirname(target);

        while (true) {
            const next = dirname(currentDir);
            const agentsPath = join(currentDir, 'AGENTS.md');
            const isRoot = currentDir === root;

            if (!isRoot && existsSync(agentsPath) && !this.#files.has(agentsPath)) {
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
