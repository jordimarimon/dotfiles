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

describe('IntentFactory', () => {
    const factory = new ToolIntent();
    const dir = cwd();
    const ctx = fromPartial<ExtensionContext>({cwd: dir});

    describe('Standard tool path normalization', () => {
        const tools: ToolName[] = ['read', 'edit', 'grep', 'find', 'write', 'ls'];

        for (const tool of tools) {
            test(`should extract and normalize path for tool: ${tool}`, () => {
                const event = fromPartial<ToolCallEvent>({
                    toolName: tool,
                    input: {path: 'relative/file.txt'},
                });

                const result = factory.create(event, ctx);
                assert.deepStrictEqual(result.paths, [resolve(dir, 'relative/file.txt')]);
                assert.strictEqual(result.toolName, tool);
            });
        }

        test('should not extract path if path is missing or not a string', () => {
            const event = fromPartial<ToolCallEvent>({toolName: 'read', input: {path: 123}});
            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
        });

        test('should normalize paths starting with ~', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'read',
                input: {path: '~/docs/readme.md'},
            });

            const result = factory.create(event, ctx);
            const expectedPath = resolve(homedir(), 'docs/readme.md');
            assert.deepStrictEqual(result.paths, [expectedPath]);
        });

        test('should handle already absolute paths', () => {
            const absolutePath = resolve('/absolute/dir/file.txt');
            const event = fromPartial<ToolCallEvent>({
                toolName: 'write',
                input: {path: absolutePath},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [absolutePath]);
        });
    });

    describe('Bash tool path extraction', () => {
        test('should extract paths from bash command', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'cat docs/readme.md'},
            });

            const result = factory.create(event, ctx);

            assert.deepStrictEqual(result.paths, [resolve(dir, 'docs/readme.md')]);

            assert.strictEqual(result.bashCommand, 'cat docs/readme.md');
        });

        test('should extract paths from globs in bash command', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'ls src/**/*.ts'},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [resolve(dir, 'src/**/*.ts')]);
        });

        test('should ignore arguments starting with - or +', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'grep -r +x "pattern" src/'},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [resolve(dir, 'pattern'), resolve(dir, 'src/')]);
        });

        test('should ignore shell operators like >, >>, <, |', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'echo "hello" > file.txt | cat'},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [resolve(dir, 'hello'), resolve(dir, 'file.txt')]);
        });

        test('should not extract paths if command is not a string', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: ['ls', '-la']},
            });

            const result = factory.create(event, ctx);

            assert.deepStrictEqual(result.paths, []);
            assert.strictEqual(result.bashCommand, undefined);
        });

        test('should expand environment variables if present in process.env', () => {
            process.env['TEST_VAR'] = 'my_dir/my_file.txt';

            const event = fromPartial<ToolCallEvent>({
                toolName: 'bash',
                input: {command: 'cat $TEST_VAR'},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, [resolve(dir, 'my_dir/my_file.txt')]);
        });
    });

    describe('Unknown tools', () => {
        test('should not extract paths for unknown tools', () => {
            const event = fromPartial<ToolCallEvent>({
                toolName: 'some_unknown_tool',
                input: {path: 'relative/file.txt'},
            });

            const result = factory.create(event, ctx);
            assert.deepStrictEqual(result.paths, []);
        });
    });
});
