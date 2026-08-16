import {join, resolve, isAbsolute, sep, relative} from 'node:path';
import {getAgentDir} from '@earendil-works/pi-coding-agent';
import {execFileSync} from 'node:child_process';
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

/**
 * Checks which of the provided paths are ignored by Git.
 * Returns a Set of the ignored paths or null.
 */
export async function isGitIgnored(paths: string[], cwd: string): Promise<Set<string> | null> {
    if (paths.filter(Boolean).length === 0) {
        return null;
    }

    try {
        const ignoredPaths = execFileSync('git', ['check-ignore', '-z', '--stdin'], {
            cwd,
            input: paths.join('\0') + '\0',
            encoding: 'utf-8',
            stdio: ['pipe', 'ignore'], // ignore stderr
        });

        // Split by null terminator and filter out empty strings
        return new Set(ignoredPaths.split('\0').filter(Boolean));
    } catch (_error: unknown) {
        // On fatal error (like not a git repo), assume nothing is git-ignored
        return null;
    }
}
