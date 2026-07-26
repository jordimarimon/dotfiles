import type {ExtensionContext} from '@earendil-works/pi-coding-agent';
import type {ToolCallEvent} from '@earendil-works/pi-agent-core';
import type {ToolName} from '#src/permission/types.ts';
import {ToolIntent} from '#src/utils/intent.ts';
import {fromPartial} from '#tests/utils.ts';
import {describe, test} from 'node:test';
import * as assert from 'node:assert';
import {resolve} from 'node:path';
import {cwd} from 'node:process';
import {homedir} from 'node:os';

void describe('IntentFactory', () => {
    const factory = new ToolIntent();
    const dir = cwd();
    const ctx = fromPartial<ExtensionContext>({cwd: dir});

    void describe('Standard tool path normalization', () => {
        const tools: ToolName[] = ['read', 'edit', 'grep', 'find', 'write', 'ls'];

        for (const tool of tools) {
            void test(`should extract and normalize path for tool: ${tool}`, async () => {
                const event = fromPartial<ToolCallEvent>({
                    toolName: tool,
                    input: {path: 'relative/file.txt'},
                });

                const result = await factory.create(event, ctx);
                assert.deepStrictEqual(result.paths, [resolve(dir, 'relative/file.txt')]);
                assert.strictEqual(result.toolName, tool);
            });
        }

        void test('should not extract path if path is missing or not a string', async () => {
            const event = fromPartial<ToolCallEvent>({toolName: 'read', input: {path: 123}});
            const result = await factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
        });

        void test('should normalize paths starting with ~', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'read',
                input: {path: '~/docs/readme.md'},
            });

            const result = await factory.create(event, ctx);
            const expectedPath = resolve(homedir(), 'docs/readme.md');
            assert.deepStrictEqual(result.paths, [expectedPath]);
        });

        void test('should handle already absolute paths', async () => {
            const absolutePath = resolve('/absolute/dir/file.txt');
            const event = fromPartial<ToolCallEvent>({
                toolName: 'write',
                input: {path: absolutePath},
            });

            const result = await factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [absolutePath]);
        });
    });

    void describe('Bash tool path extraction', () => {
        void test('should extract paths from bash command', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'cat docs/readme.md'},
            });

            const result = await factory.create(event, ctx);

            assert.deepStrictEqual(result.paths, []);
            assert.strictEqual(result.bashCommand?.raw, 'cat docs/readme.md');
            assert.deepStrictEqual(
                result.bashCommand?.paths.map(p => p.path),
                [resolve(dir, 'docs/readme.md')],
            );
        });

        void test('should extract paths from globs in bash command', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'ls src/**/*.ts'},
            });

            const result = await factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
            assert.deepStrictEqual(result.bashCommand?.globs, [resolve(dir, 'src/**/*.ts')]);
        });

        void test('should ignore arguments starting with - or +', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'grep -r +x "pattern" src/'},
            });

            const result = await factory.create(event, ctx);
            // "pattern" does not look like a path, but "src/" does.
            assert.deepStrictEqual(result.paths, []);
            assert.deepStrictEqual(
                result.bashCommand?.paths.map(p => p.path),
                [resolve(dir, 'src/')],
            );
        });

        void test('should ignore shell operators like >, >>, <, |', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'echo "hello" > file.txt | cat'},
            });

            const result = await factory.create(event, ctx);
            // "hello" is just a string without path-like characteristics, "file.txt" is a path.
            assert.deepStrictEqual(result.paths, []);
            assert.deepStrictEqual(
                result.bashCommand?.paths.map(p => p.path),
                [resolve(dir, 'file.txt')],
            );
        });

        void test('should not extract paths if command is not a string', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: ['ls', '-la']},
            });

            const result = await factory.create(event, ctx);

            assert.deepStrictEqual(result.paths, []);
            assert.strictEqual(result.bashCommand, undefined);
        });

        void test('should expand environment variables if present in process.env', async () => {
            process.env['TEST_VAR'] = 'my_dir/my_file.txt';

            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'cat $TEST_VAR'},
            });

            const result = await factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
            assert.deepStrictEqual(
                result.bashCommand?.paths.map(p => p.path),
                [resolve(dir, 'my_dir/my_file.txt')],
            );
        });
    });

    void describe('Unknown tools', () => {
        void test('should not extract paths for unknown tools', async () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'some_unknown_tool',
                input: {path: 'relative/file.txt'},
            });

            const result = await factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
        });
    });
});
