import {PermissionEngine} from './engine.ts';
import {IntentFactory} from './intent.ts';
import {loadConfig} from './config.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolCallEvent,
    ToolCallEventResult,
} from '@earendil-works/pi-coding-agent';

export class PermissionGate {
    #engine: PermissionEngine | undefined;

    readonly #intentFactory: IntentFactory;

    constructor() {
        this.#intentFactory = new IntentFactory();
    }

    static register(pi: ExtensionAPI): PermissionGate {
        const gate = new PermissionGate();

        pi.on('tool_call', async (event, ctx) => {
            if (!gate.#engine) {
                gate.#engine = new PermissionEngine(loadConfig(ctx.cwd).rules);
            }

            return await gate.#handle(event, ctx);
        });

        return gate;
    }

    async #handle(ev: ToolCallEvent, ctx: ExtensionContext): Promise<ToolCallEventResult | void> {
        const intent = this.#intentFactory.create(ev, ctx.cwd);
        const result = this.#engine!.check(intent);

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

        // result.action === 'confirm' or there is no matching rule (we allow it)
    }
}
