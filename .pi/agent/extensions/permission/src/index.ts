import {basename, resolve} from 'node:path';
import {homedir} from 'node:os';
import {
    type ExtensionAPI,
    isToolCallEventType,
    type ToolCallEventResult,
} from '@earendil-works/pi-coding-agent';

export default function (pi: ExtensionAPI): void {
    pi.on('tool_call', async (event, ctx): Promise<ToolCallEventResult | void> => {
        const sshDir = resolve(homedir(), '.ssh');

        // 1. Block reading environment files and SSH directory for common tools
        if (
            isToolCallEventType('read', event) ||
            isToolCallEventType('grep', event) ||
            isToolCallEventType('ls', event) ||
            isToolCallEventType('find', event) ||
            isToolCallEventType('edit', event) ||
            isToolCallEventType('write', event)
        ) {
            const path = (event.input as any).path || (event.input as any).dir;

            if (path) {
                const absolutePath = resolve(
                    path.startsWith('~') ? path.replace('~', homedir()) : resolve(ctx.cwd, path),
                );

                // Block .env files
                const filename = basename(path);

                if (filename.startsWith('.env')) {
                    return {
                        block: true,
                        reason: `Accessing environment files (${filename}) is prohibited for security reasons.`,
                    };
                }

                // Block ~/.ssh access
                if (absolutePath.startsWith(sshDir)) {
                    return {
                        block: true,
                        reason: 'Accessing the SSH directory is strictly prohibited.',
                    };
                }
            }
        }

        // 2. Block dangerous bash commands
        if (isToolCallEventType('bash', event)) {
            const command = event.input.command;

            // Block bash access to .env files
            if (/(^|[\s\/|&;<>="'])\.env/.test(command)) {
                return {
                    block: true,
                    reason: 'Accessing environment files via bash is prohibited.',
                };
            }

            // Block 'git push'
            if (/\bgit\s+push\b/.test(command)) {
                return {
                    block: true,
                    reason: 'Executing "git push" is not allowed via the agent.',
                };
            }

            // Block 'rm' with globs
            if (/\brm\s+.*[*?\[]/.test(command)) {
                return {
                    block: true,
                    reason: 'Using "rm" with globs is prohibited to prevent accidental data loss.',
                };
            }

            // Block bash access to .ssh
            if (command.includes('.ssh')) {
                return {
                    block: true,
                    reason: 'Accessing SSH files via bash is prohibited.',
                };
            }
        }
    });
}
