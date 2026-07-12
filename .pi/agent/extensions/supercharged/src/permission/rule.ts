import type {AccessIntent, PermissionRuleConfig} from './types.ts';
import picomatch from 'picomatch';

export class PermissionRule {
    readonly #isMatch: (str: string) => boolean;

    readonly #config: PermissionRuleConfig;

    constructor(config: PermissionRuleConfig) {
        this.#config = config;
        this.#isMatch = picomatch(config.pattern, {dot: true});
    }

    getConfiguration(): PermissionRuleConfig {
        return this.#config;
    }

    matches(intent: AccessIntent): boolean {
        if (this.#config.type === 'path' && intent.path) {
            return this.#isMatch(intent.path);
        }

        if (
            this.#config.type === 'tool' &&
            this.#config.name === intent.toolName &&
            intent.bashCommand
        ) {
            return this.#isMatch(intent.bashCommand);
        }

        return false;
    }
}
