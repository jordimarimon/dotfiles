import {BashParser, type BashCommand} from './bash-parser.ts';
import {PATH_BEARING_TOOLS} from './path-surfaces.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolCallEvent,
    ToolResultEvent,
} from '@earendil-works/pi-coding-agent';
import {normalizePath, isGitIgnored, isInDirectory} from './fs.ts';

interface PathInfo {
    path: string;
    external: boolean;
    ignored: boolean;
}

export interface AccessIntent {
    agentName?: string | undefined;
    toolName?: string | undefined;
    input: unknown;
    paths: PathInfo[];
    bashCommand?: BashCommand | undefined;
}

type ToolEvent = ToolCallEvent | ToolResultEvent;

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

    async create(event: ToolEvent, ctx: ExtensionContext): Promise<AccessIntent> {
        let bashCommand: BashCommand | undefined;

        if (event.toolName === 'bash' && typeof event.input.command === 'string') {
            bashCommand = await ToolIntent.#parser.parse(event.input.command, ctx.cwd);
        }

        const paths: AccessIntent['paths'] = [];

        if (
            PATH_BEARING_TOOLS.has(event.toolName) &&
            typeof (event.input as Record<string, string>)['path'] === 'string'
        ) {
            const path = normalizePath((event.input as Record<string, string>)['path']!, ctx.cwd);
            const ignoredSet = await isGitIgnored([path], ctx.cwd);

            paths.push({
                path,
                external: !isInDirectory(path, ctx.cwd),
                ignored: !!ignoredSet?.has(path),
            });
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
