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
    let normalized = path;

    if (path.startsWith('~')) {
        normalized = path.replace('~', homedir());
    }

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
