import {readFileSync, existsSync} from 'node:fs';
import type {PermissionConfig} from './types.ts';
import {join} from 'node:path';

export function loadConfig(cwd: string): PermissionConfig {
    const configPath = join(import.meta.dirname, '..', '..', 'permissions.json');

    if (!existsSync(configPath)) {
        return {rules: []};
    }

    try {
        const content = readFileSync(configPath, 'utf-8');
        const config = JSON.parse(content) as PermissionConfig;

        config.rules.push({
            type: 'path',
            pattern: `!(${cwd}{,/**/*})`,
            action: 'ask',
            reason: 'Accessing a path outside the workspace is prohibited.',
        });

        return config;
    } catch (error: unknown) {
        console.error(`Failed to load permissions.json: ${error}`);
        return {rules: []};
    }
}
