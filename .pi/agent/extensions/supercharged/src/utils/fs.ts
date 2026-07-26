import {join, resolve, isAbsolute, sep, relative} from 'node:path';
import {getAgentDir} from '@earendil-works/pi-coding-agent';
import {existsSync, lstatSync} from 'node:fs';
import {homedir} from 'node:os';

export function getExtensionsDir(): string {
    return join(getAgentDir(), 'extensions', 'supercharged');
}

export function getPathType(path: string): 'file' | 'directory' | null {
    if (!existsSync(path)) {
        return null;
    }

    const stats = lstatSync(path);

    if (stats.isDirectory()) {
        return 'directory';
    }

    return stats.isFile() ? 'file' : null;
}

export function normalizePath(path: string, cwd: string): string {
    let normalized = expandHomePath(path);

    if (!isAbsolute(normalized)) {
        normalized = resolve(cwd, normalized);
    }

    return normalized;
}

export function isInDirectory(path: string, dir: string): boolean {
    const absPath = resolve(dir, path);
    const relPath = relative(dir, absPath);

    return !relPath.startsWith('..' + sep) && relPath !== '..' && !isAbsolute(relPath);
}

/**
 * Expand `~` and `$HOME` prefixes in a pattern to the OS home directory.
 *
 * Supported forms:
 * - `~`          → `homedir()`
 * - `~/path`     → `homedir()/path`
 * - `~\path`     → `homedir()\path` (Windows)
 * - `$HOME`      → `homedir()`
 * - `$HOME/path` → `homedir()/path`
 * - `$HOME\path` → `homedir()\path` (Windows)
 *
 * All other patterns are returned unchanged.
 */
export function expandHomePath(pattern: string): string {
    if (pattern === '~' || pattern === '$HOME') {
        return homedir();
    }

    if (pattern.startsWith('~/') || pattern.startsWith('~\\')) {
        return join(homedir(), pattern.slice(2));
    }

    if (pattern.startsWith('$HOME/') || pattern.startsWith('$HOME\\')) {
        return join(homedir(), pattern.slice(6));
    }

    return pattern;
}
