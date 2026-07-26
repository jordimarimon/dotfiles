import {getPathType, normalizePath} from './fs.ts';
import {Parser, Language} from 'web-tree-sitter';
import type {Node} from 'web-tree-sitter';
import {createRequire} from 'node:module';

export interface BashCommand {
    raw: string;
    cwd: string;
    names: string[]; // shell command names
    paths: {path: string; type: 'directory' | 'file' | null}[]; // static paths
    globs: string[]; // dynamic paths (have wildcards)
    type: 'r' | 'w' | 'rw' | undefined; // if the command only reads files/input or if it writes to a file or standard output
    error: boolean; // if there is an error parsing the command
}

const WRITE_COMMANDS = new Set([
    'rm',
    'touch',
    'mkdir',
    'cp',
    'mv',
    'rmdir',
    'chmod',
    'chown',
    'ln',
    'wget',
    'curl',
    'git',
    'npm',
    'pnpm',
    'yarn',
]);

let parser: Parser | null = null;
let language: Language | null = null;

async function getParser(): Promise<Parser> {
    if (parser) {
        return parser;
    }

    const req = createRequire(import.meta.url);
    await Parser.init({locateFile: () => req.resolve('web-tree-sitter/web-tree-sitter.wasm')});

    parser = new Parser();

    language = await Language.load(req.resolve('tree-sitter-bash/tree-sitter-bash.wasm'));
    parser.setLanguage(language);

    return parser;
}

export class BashParser {
    async parse(command: string, cwd: string): Promise<BashCommand> {
        const parser = await getParser();
        const tree = parser.parse(command);
        const result: BashCommand = {
            raw: command,
            cwd,
            names: [],
            paths: [],
            globs: [],
            type: undefined,
            error: false,
        };

        if (!tree || tree.rootNode.hasError) {
            result.error = true;
            return result;
        }

        this.#walk(tree.rootNode, result);

        result.type ??= 'r';

        return result;
    }

    #walk(node: Node, result: BashCommand): void {
        if (node.hasError) {
            result.error = true;
            return;
        }

        switch (node.type) {
            case 'command_name': {
                this.#walkCommandName(node, result);
                break;
            }
            case 'file_redirect': {
                this.#walkFileRedirect(node, result);
                break;
            }
            case 'command': {
                this.#walkCommand(node, result);
                break;
            }
        }

        if (result.error) {
            return;
        }

        for (const child of node.namedChildren) {
            this.#walk(child, result);

            if (result.error) {
                break;
            }
        }
    }

    #walkCommandName(node: Node, result: BashCommand): void {
        const name = node.text.trim();

        if (name && !result.names.includes(name)) {
            result.names.push(name);
        }

        if (WRITE_COMMANDS.has(name)) {
            this.#setType('w', result);
        }
    }

    #walkFileRedirect(node: Node, result: BashCommand): void {
        this.#setType('w', result);

        const outputPath = node.namedChildren.find(
            (n: Node) => n.type === 'word' || n.type === 'string' || n.type === 'raw_string',
        );

        if (!outputPath) {
            result.error = true;
            return;
        }

        let path = outputPath.text;

        if (
            outputPath.type === 'string' &&
            outputPath.namedChildren[0]?.type === 'string_content'
        ) {
            path = outputPath.namedChildren[0].text;
        } else if (outputPath.type === 'raw_string') {
            path = path.slice(1, -1);
        }

        path = normalizePath(path, result.cwd);

        if (!result.paths.some(p => p.path === path) && !path.includes('*')) {
            result.paths.push({path, type: getPathType(path)});
        }
    }

    #walkCommand(node: Node, result: BashCommand): void {
        const nameNode = node.namedChildren.find((n: Node) => n.type === 'command_name');
        const name = nameNode ? nameNode.text.trim() : '';

        for (const child of node.namedChildren) {
            if (
                child.type === 'word' ||
                child.type === 'string' ||
                child.type === 'raw_string' ||
                child.type === 'concatenation' ||
                child.type === 'simple_expansion' ||
                child.type === 'expansion'
            ) {
                if (child.type === 'word' && child.text.startsWith('-')) {
                    continue; // Skip simple flags
                }

                let text = child.text;
                if (child.type === 'string' && child.namedChildren[0]?.type === 'string_content') {
                    text = child.namedChildren[0].text;
                } else if (child.type === 'raw_string') {
                    text = text.slice(1, -1);
                } else if (child.type === 'simple_expansion' || child.type === 'expansion') {
                    const varNameNode = child.namedChildren.find(
                        (n: Node) => n.type === 'variable_name',
                    );
                    if (varNameNode && process.env[varNameNode.text]) {
                        text = process.env[varNameNode.text] as string;
                    }
                }

                // Skip command name itself
                if (text === name) {
                    continue;
                }

                if (name === 'sed' && text.startsWith('s/')) {
                    continue;
                }

                if (text.startsWith('http://') || text.startsWith('https://')) {
                    continue;
                }

                // Extremely simplified way to find paths vs globs vs arbitrary args.
                // If it contains a slash or dot, it might be a path.
                // If it contains *, ?, etc., it might be a glob.
                if (text.includes('*') || text.includes('?') || text.includes('[')) {
                    text = normalizePath(text, result.cwd);

                    if (!result.globs.includes(text)) {
                        result.globs.push(text);
                    }
                } else if (text.includes('/') || text.includes('.')) {
                    text = normalizePath(text, result.cwd);

                    if (!result.paths.some(p => p.path === text)) {
                        result.paths.push({path: text, type: getPathType(text)});
                    }
                }
            }
        }

        if (name === 'sed') {
            const hasDashI = node.namedChildren.some(
                (n: Node) => n.type === 'word' && (n.text === '-i' || n.text.startsWith('-i')),
            );

            if (hasDashI) {
                this.#setType('w', result);
            }
        }
    }

    #setType(type: 'r' | 'w', result: BashCommand): void {
        result.type = result.type === type || result.type === undefined ? type : 'rw';
    }
}
