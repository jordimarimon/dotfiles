import type {ExtensionContext, ToolCallEvent} from '@earendil-works/pi-coding-agent';
import {resolve as resolvePath, isAbsolute} from 'node:path';
import type {AccessIntent} from './types.ts';
import {homedir} from 'node:os';

export class IntentFactory {
    create(event: ToolCallEvent, ctx: ExtensionContext): AccessIntent {
        let bashCommand: string | undefined;
        let path = '';

        const systemPrompt = ctx.getSystemPrompt();
        const agentMatch = systemPrompt.match(/<active_agent>([^<]+)<\/active_agent>/);
        const agentName = agentMatch ? agentMatch[1] : undefined;

        if (event.toolName === 'bash' && typeof event.input.command === 'string') {
            bashCommand = event.input.command;
        }

        const hasPath =
            event.toolName === 'read' ||
            event.toolName === 'edit' ||
            event.toolName === 'grep' ||
            event.toolName === 'find' ||
            event.toolName === 'write' ||
            event.toolName === 'ls';

        if (hasPath && typeof event.input.path === 'string') {
            path = this.#normalizePath(event.input.path, ctx.cwd);
        }

        return {
            agentName,
            toolName: event.toolName,
            input: event.input,
            path,
            bashCommand,
        };
    }

    #normalizePath(path: string, cwd: string): string {
        let normalized = path;

        if (path.startsWith('~')) {
            normalized = path.replace('~', homedir());
        }

        if (!isAbsolute(normalized)) {
            normalized = resolvePath(cwd, normalized);
        }

        return normalized;
    }
}
