import {resolve, isAbsolute, sep} from 'node:path';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolCallEvent,
    ToolResultEvent,
} from '@earendil-works/pi-coding-agent';
import {parse} from 'shell-quote';
import {homedir} from 'node:os';

// TODO: Implement agent name extraction

// TODO: Use "web-tree-sitter" + "tree-sitter-bash" grammar to parse bash commands

// TODO: When parsing bash commands, add information about if the command only reads or it also edits files

export interface AccessIntent {
    agentName?: string | undefined;
    toolName?: string | undefined;
    input: unknown;
    paths: string[];
    bashCommand?: string | undefined;
}

const KNOWN_COMMANDS: string[] = [
    'cat',
    'ls',
    'find',
    'bat',
    'touch',
    'echo',
    'grep',
    'rg',
    'which',
    'mkdir',
    'rm',
    'cp',
    'mv',
    'git',
    'pnpm',
    'npm',
    'node',
    'yarn',
    'docker',
    'sudo',
    'xargs',
    'sed',
    'awk',
    'tail',
    'head',
    'wc',
    'sort',
    'uniq',
    'jq',
];

export class ToolIntent {
    static #intents = new Map<string, AccessIntent>();

    static get(toolCallId: string): AccessIntent | undefined {
        return this.#intents.get(toolCallId);
    }

    static register(pi: ExtensionAPI): void {
        const intent = new ToolIntent();

        pi.on('tool_call', async (event, ctx) => {
            this.#intents.set(event.toolCallId, intent.create(event, ctx));
        });
    }

    create(event: ToolCallEvent | ToolResultEvent, ctx: ExtensionContext): AccessIntent {
        let bashCommand: string | undefined;

        const paths: string[] = [];

        if (event.toolName === 'bash' && typeof event.input.command === 'string') {
            bashCommand = event.input.command;

            for (const segment of parse(bashCommand, process.env)) {
                let text: string | undefined;

                if (typeof segment === 'string') {
                    text = segment;
                } else if (segment && typeof segment === 'object' && 'pattern' in segment) {
                    text = String(segment.pattern); // glob
                }

                // Ignore command options
                if (
                    !text ||
                    text.startsWith('-') ||
                    text.startsWith('+') ||
                    KNOWN_COMMANDS.includes(text)
                ) {
                    continue;
                }

                text = this.#normalizePath(text, ctx.cwd);

                // After normalizing it should include the path separator
                if (!text.includes(sep)) {
                    continue;
                }

                paths.push(text);
            }
        }

        const hasPath =
            event.toolName === 'read' ||
            event.toolName === 'edit' ||
            event.toolName === 'grep' ||
            event.toolName === 'find' ||
            event.toolName === 'write' ||
            event.toolName === 'ls';

        if (hasPath && typeof event.input.path === 'string') {
            paths.push(this.#normalizePath(event.input.path, ctx.cwd));
        }

        return {
            agentName: '',
            toolName: event.toolName,
            input: event.input,
            paths,
            bashCommand,
        };
    }

    #normalizePath(path: string, cwd: string): string {
        let normalized = path;

        if (path.startsWith('~')) {
            normalized = path.replace('~', homedir());
        }

        if (!isAbsolute(normalized)) {
            normalized = resolve(cwd, normalized);
        }

        return normalized;
    }
}
