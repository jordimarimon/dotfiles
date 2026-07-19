import type {PermissionRuleConfig} from '#src/permission/types.ts';
import {PermissionEngine} from '#src/permission/engine.ts';
import type {AccessIntent} from '#src/utils/intent.ts';
import {fromPartial} from '#tests/utils.ts';
import {describe, test} from 'node:test';
import * as assert from 'node:assert';

describe('PermissionEngine', () => {
    describe('Check', () => {
        test('should allow if no rules match (fallback)', () => {
            const engine = new PermissionEngine([]);
            const intent = fromPartial<AccessIntent>({paths: ['/some/path']});

            const result = engine.check(intent);
            assert.strictEqual(result.action, 'allow');
            assert.strictEqual(result.rule, undefined);
        });

        test('should return the action of the first matching rule', () => {
            const rules: PermissionRuleConfig[] = [
                {type: 'path', pattern: '/deny/path', action: 'deny'},
                {type: 'path', pattern: '/deny/path', action: 'ask'},
            ];
            const engine = new PermissionEngine(rules);
            const intent = fromPartial<AccessIntent>({paths: ['/deny/path']});
            const result = engine.check(intent);

            assert.strictEqual(result.action, 'deny');
            assert.strictEqual(result.rule?.action, 'deny');
        });
    });

    describe('Session Caching', () => {
        test('should cache and return previous results for the same intent', () => {
            const rules: PermissionRuleConfig[] = [
                {type: 'path', pattern: '/ask/path', action: 'ask'},
            ];
            const engine = new PermissionEngine(rules);
            const intent = fromPartial<AccessIntent>({paths: ['/ask/path']});

            const result1 = engine.check(intent);
            assert.strictEqual(result1.action, 'ask');

            engine.remember(intent, {action: 'allow'});

            const result2 = engine.check(intent);
            assert.strictEqual(result2.action, 'allow');
        });
    });

    describe('Key Generation for Caching', () => {
        test('should distinguish keys by agent name', () => {
            const rules: PermissionRuleConfig[] = [
                {type: 'path', agent: 'AgentA', pattern: '/path', action: 'deny'},
            ];
            const engine = new PermissionEngine(rules);

            const intentA = fromPartial<AccessIntent>({agentName: 'AgentA', paths: ['/path']});
            const intentB = fromPartial<AccessIntent>({agentName: 'AgentB', paths: ['/path']});

            assert.strictEqual(engine.check(intentA).action, 'deny');
            assert.strictEqual(engine.check(intentB).action, 'allow');
        });

        test('should generate keys for bash commands', () => {
            const rules: PermissionRuleConfig[] = [
                {type: 'tool', name: 'bash', pattern: 'rm *', action: 'deny'},
            ];
            const engine = new PermissionEngine(rules);

            const intent = fromPartial<AccessIntent>({toolName: 'bash', bashCommand: 'rm *'});
            assert.strictEqual(engine.check(intent).action, 'deny');

            engine.remember(intent, {action: 'allow'});

            assert.strictEqual(engine.check(intent).action, 'allow');
        });

        test('should generate keys for tool invocations without paths or bash', () => {
            const rules: PermissionRuleConfig[] = [
                {type: 'tool', name: 'ls', pattern: '*', action: 'ask'},
            ];
            const engine = new PermissionEngine(rules);

            const intent = fromPartial<AccessIntent>({toolName: 'ls', paths: []});
            assert.strictEqual(engine.check(intent).action, 'allow');

            engine.remember(intent, {action: 'allow'});

            assert.strictEqual(engine.check(intent).action, 'allow');
        });
    });
});
