import type {PermissionCheckResult, PermissionRuleConfig, AccessIntent} from './types.ts';
import {PermissionRule} from './rule.ts';

export class PermissionEngine {
    #rules: PermissionRule[];

    #sessionCache: Map<string, PermissionCheckResult> = new Map();

    constructor(config: PermissionRuleConfig[]) {
        this.#rules = config.map(c => new PermissionRule(c));
    }

    check(intent: AccessIntent): PermissionCheckResult {
        const key = this.#getKey(intent);
        const previousResult = this.#sessionCache.get(key);

        if (previousResult) {
            return previousResult;
        }

        let result: PermissionCheckResult | undefined;

        // First match wins (from config)
        for (const rule of this.#rules) {
            if (rule.matches(intent)) {
                const config = rule.getConfiguration();

                result = {
                    action: config.action,
                    reason: config.reason ?? '',
                    rule: config,
                };

                break;
            }
        }

        // Fallback => allow
        if (!result) {
            result = {action: 'allow'};
        }

        this.#sessionCache.set(key, result);

        return result;
    }

    remember(intent: AccessIntent, result: PermissionCheckResult): void {
        this.#sessionCache.set(this.#getKey(intent), result);
    }

    #getKey(intent: AccessIntent): string {
        const agentPrefix = intent.agentName ? `[${intent.agentName}]` : '';

        if (intent.toolName === 'bash' && intent.bashCommand) {
            return `${agentPrefix}bash:${intent.bashCommand}`;
        }

        if (intent.path) {
            return `${agentPrefix}paths:${intent.path}`;
        }

        return `${agentPrefix}tool:${intent.toolName}`;
    }
}
