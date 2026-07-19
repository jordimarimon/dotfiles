import type {AccessIntent} from '#src/utils/intent.ts';
import type {PermissionRuleConfig} from './types.ts';
import {matchesGlob} from 'node:path';

export class PermissionRule {
    readonly #isMatch: (str: string) => boolean;

    readonly #config: PermissionRuleConfig;

    constructor(config: PermissionRuleConfig) {
        this.#config = config;
        this.#isMatch =
            config.pattern === '*' || config.pattern === '**'
                ? (_: string) => true
                : (value: string): boolean => matchesGlob(value, config.pattern);
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
            return intent.paths.some(path => this.#isMatch(path));
        }

        // It's tool
        if (intent.toolName !== this.#config.name) {
            return false;
        }

        // If it's bash, match against the command.
        if (intent.toolName === 'bash') {
            return intent.bashCommand ? this.#isMatch(intent.bashCommand) : false;
        }

        return intent.paths.some(path => this.#isMatch(path));
    }
}
