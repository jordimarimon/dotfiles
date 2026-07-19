import type {PermissionAction, PermissionRuleConfig} from './types.ts';
import type {AccessIntent} from '#src/utils/intent.ts';
import {PermissionRule} from './rule.ts';

export interface PermissionCheckResult {
    action: PermissionAction;
    rule?: PermissionRuleConfig;
    reason?: string;
}

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
        const agentPrefix = intent.agentName ? `[${intent.agentName}]` : '[*]';

        if (intent.toolName === 'bash' && intent.bashCommand) {
            return `${agentPrefix}:bash:${intent.bashCommand}`;
        }

        if (intent.paths.length > 0) {
            return `${agentPrefix}:paths:${intent.paths.join(',')}`;
        }

        return `${agentPrefix}:tool:${intent.toolName}`;
    }
}
