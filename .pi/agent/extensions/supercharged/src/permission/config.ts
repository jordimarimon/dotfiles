import {PermissionConfigValidator, type PermissionConfig} from './types.ts';
import {logger, LogGroup} from '../utils/logger.ts';
import {getExtensionsDir} from '#src/utils/fs.ts';
import {readFileSync, existsSync} from 'node:fs';
import {join} from 'node:path';

export function loadConfig(cwd: string): PermissionConfig {
    const configPath = join(getExtensionsDir(), 'permissions.json');

    if (!existsSync(configPath)) {
        return {rules: []};
    }

    try {
        const content = readFileSync(configPath, 'utf-8');
        const config = JSON.parse(content);

        if (!PermissionConfigValidator.Check(config)) {
            logger.error(LogGroup.Permission, 'Invalid permissions configuration file format');
            return {rules: []};
        }

        // This rule needs to be added dynamically because the
        // workspace/session directory is only known at runtime
        config.rules.push({
            type: 'path',
            pattern: `!(${cwd}{,/**/*})`,
            action: 'ask',
            reason: 'Accessing a path outside the workspace is prohibited.',
        });

        return config;
    } catch (error: unknown) {
        logger.error(LogGroup.Permission, `Failed to load permissions.json: ${error}`);
        return {rules: []};
    }
}
