import {BashParser, type BashCommand} from './bash-parser.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolCallEvent,
    ToolResultEvent,
} from '@earendil-works/pi-coding-agent';
import {normalizePath} from './fs.ts';

export interface AccessIntent {
    agentName?: string | undefined;
    toolName?: string | undefined;
    input: unknown;
    paths: string[];
    bashCommand?: BashCommand | undefined;
}

export class ToolIntent {
    static #intents = new Map<string, AccessIntent>();

    static #parser = new BashParser();

    static async get(toolCallId: string): Promise<AccessIntent | undefined> {
        return this.#intents.get(toolCallId);
    }

    static register(pi: ExtensionAPI): void {
        const intent = new ToolIntent();

        pi.on('tool_call', async (event, ctx) => {
            this.#intents.set(event.toolCallId, await intent.create(event, ctx));
        });
    }

    async create(
        event: ToolCallEvent | ToolResultEvent,
        ctx: ExtensionContext,
    ): Promise<AccessIntent> {
        let bashCommand: BashCommand | undefined;

        if (event.toolName === 'bash' && typeof event.input.command === 'string') {
            bashCommand = await ToolIntent.#parser.parse(event.input.command, ctx.cwd);
        }

        const paths: string[] = [];
        const hasPath =
            event.toolName === 'read' ||
            event.toolName === 'edit' ||
            event.toolName === 'grep' ||
            event.toolName === 'find' ||
            event.toolName === 'write' ||
            event.toolName === 'ls';

        if (hasPath && typeof event.input.path === 'string') {
            paths.push(normalizePath(event.input.path, ctx.cwd));
        }

        return {
            agentName: '', // TODO: implement agent name extraction
            toolName: event.toolName,
            input: event.input,
            paths,
            bashCommand,
        };
    }
}
