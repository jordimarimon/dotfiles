import type {AccessIntent, PermissionRuleConfig} from './types.ts';
import picomatch from 'picomatch';

export class PermissionRule {
    readonly #isMatch: (str: string) => boolean;

    readonly #config: PermissionRuleConfig;

    constructor(config: PermissionRuleConfig) {
        this.#config = config;
        this.#isMatch =
            config.pattern === '*' || config.pattern === '**'
                ? (_: string) => true
                : picomatch(config.pattern, {dot: true});
    }

    getConfiguration(): PermissionRuleConfig {
        return this.#config;
    }

    matches(intent: AccessIntent): boolean {
        // If rule specifies an agent, it must match
        if (this.#config.agent && this.#config.agent !== intent.agentName) {
            return false;
        }

        // If it's a path
        if (this.#config.type === 'path') {
            return intent.path ? this.#isMatch(intent.path) : false;
        }

        // It's tool
        if (intent.toolName !== this.#config.name) {
            return false;
        }

        // If it's bash, match against the command.
        if (intent.toolName === 'bash') {
            return intent.bashCommand ? this.#isMatch(intent.bashCommand) : false;
        }

        return intent.path ? this.#isMatch(intent.path) : false;
    }
}
