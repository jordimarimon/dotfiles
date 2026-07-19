import {logger, LogGroup} from '../utils/logger.ts';
import {ToolIntent} from '#src/utils/intent.ts';
import {PermissionEngine} from './engine.ts';
import {loadConfig} from './config.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolCallEvent,
    ToolCallEventResult,
} from '@earendil-works/pi-coding-agent';

export class PermissionGate {
    #engine: PermissionEngine | undefined;

    static register(pi: ExtensionAPI): void {
        const gate = new PermissionGate();

        pi.on('tool_call', async (event, ctx) => {
            return await gate.#handle(event, ctx);
        });
    }

    async #handle(ev: ToolCallEvent, ctx: ExtensionContext): Promise<ToolCallEventResult | void> {
        this.#engine ??= new PermissionEngine(loadConfig(ctx.cwd).rules);

        const intent = ToolIntent.get(ev.toolCallId);

        if (!intent) {
            return;
        }

        const result = this.#engine!.check(intent);

        logger.info(LogGroup.Permission, 'Action result: ', {intent, result});

        if (result.action === 'deny') {
            const defaultReason = `Action blocked by permission policy: ${result.rule?.pattern ?? '-'}`;

            return {
                block: true,
                reason: result.reason || defaultReason,
            };
        }

        if (result.action === 'ask') {
            const bashCommand = intent.bashCommand ? `: ${intent.bashCommand}` : '';
            const reason = result.reason ? `\nReason: ${result.reason}` : '';

            const ok = await ctx.ui.confirm(
                'Permission Request',
                `Allow ${ev.toolName}${bashCommand}?${reason}`,
            );

            this.#engine!.remember(intent, {...result, action: ok ? 'allow' : 'deny'});

            if (!ok) {
                return {block: true, reason: 'Blocked by user'};
            }
        }
    }
}
