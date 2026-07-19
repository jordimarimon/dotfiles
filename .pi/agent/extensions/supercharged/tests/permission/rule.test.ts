import {PermissionRule} from '#src/permission/rule.ts';
import type {AccessIntent} from '#src/utils/intent.ts';
import {fromPartial} from '#tests/utils.ts';
import {describe, test} from 'node:test';
import * as assert from 'node:assert';

describe('PermissionRule', () => {
    describe('Agent matching', () => {
        test('should return false if rule specifies an agent and it does not match', () => {
            const rule = new PermissionRule({
                type: 'path',
                agent: 'Alice',
                pattern: '**/*',
                action: 'allow',
            });

            const intent = fromPartial<AccessIntent>({agentName: 'Bob'});

            assert.strictEqual(rule.matches(intent), false);
        });

        test('should proceed if rule specifies an agent and it matches', () => {
            const rule = new PermissionRule({
                type: 'path',
                agent: 'Alice',
                pattern: '/foo/bar',
                action: 'allow',
            });

            const intent = fromPartial<AccessIntent>({agentName: 'Alice', paths: ['/foo/bar']});

            assert.strictEqual(rule.matches(intent), true);
        });
    });

    describe('Path rule matching', () => {
        test('should match if any path matches the glob pattern', () => {
            const rule = new PermissionRule({
                type: 'path',
                pattern: '/src/**/*.ts',
                action: 'allow',
            });

            const intent = fromPartial<AccessIntent>({paths: ['/docs/readme.md', '/src/index.ts']});

            assert.strictEqual(rule.matches(intent), true);
        });

        test('should not match if no path matches the glob pattern', () => {
            const rule = new PermissionRule({
                type: 'path',
                pattern: '/src/**/*.ts',
                action: 'allow',
            });

            const intent = fromPartial<AccessIntent>({paths: ['/docs/readme.md', '/src/index.js']});

            assert.strictEqual(rule.matches(intent), false);
        });

        test('should always match * and ** patterns for path', () => {
            const rule1 = new PermissionRule({type: 'path', pattern: '*', action: 'allow'});
            const rule2 = new PermissionRule({type: 'path', pattern: '**', action: 'allow'});

            const intent = fromPartial<AccessIntent>({paths: ['/anything/really.txt']});

            assert.strictEqual(rule1.matches(intent), true);
            assert.strictEqual(rule2.matches(intent), true);
        });
    });

    describe('Tool rule matching', () => {
        test('should return false if toolName does not match config name', () => {
            const rule = new PermissionRule({
                type: 'tool',
                name: 'read',
                pattern: '*',
                action: 'allow',
            });

            const intent = fromPartial<AccessIntent>({toolName: 'write', paths: ['/foo/bar.txt']});
            assert.strictEqual(rule.matches(intent), false);
        });

        test('should match bash command against pattern if tool is bash', () => {
            const rule = new PermissionRule({
                type: 'tool',
                name: 'bash',
                pattern: 'rm -rf *',
                action: 'deny',
            });

            const intent = fromPartial<AccessIntent>({toolName: 'bash', bashCommand: 'rm -rf *'});
            assert.strictEqual(rule.matches(intent), true);

            const intent2 = fromPartial<AccessIntent>({toolName: 'bash', bashCommand: 'ls -la'});
            assert.strictEqual(rule.matches(intent2), false);
        });

        test('should match path against pattern if tool is not bash', () => {
            const rule = new PermissionRule({
                type: 'tool',
                name: 'read',
                pattern: '/etc/shadow',
                action: 'deny',
            });

            const intent = fromPartial<AccessIntent>({toolName: 'read', paths: ['/etc/shadow']});

            assert.strictEqual(rule.matches(intent), true);
        });
    });
});
