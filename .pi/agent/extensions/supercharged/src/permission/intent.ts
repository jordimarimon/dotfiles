import type {ToolCallEvent} from '@earendil-works/pi-coding-agent';
import {resolve as resolvePath, isAbsolute} from 'node:path';
import type {AccessIntent} from './types.ts';
import {homedir} from 'node:os';

export class IntentFactory {
    create(event: ToolCallEvent, cwd: string): AccessIntent {
        let bashCommand: string | undefined;
        let path = '';

        if (event.toolName === 'bash' && typeof event.input.command === 'string') {
            bashCommand = event.input.command;
        }

        const hasPath =
            event.toolName === 'read' ||
            event.toolName === 'edit' ||
            event.toolName === 'grep' ||
            event.toolName === 'find' ||
            event.toolName === 'ls';

        if (hasPath && typeof event.input.path === 'string') {
            path = this.#normalizePath(event.input.path, cwd);
        }

        return {
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
