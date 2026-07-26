import {BashParser} from '#src/utils/bash-parser.ts';
import assert from 'node:assert';
import {join} from 'node:path';
import test from 'node:test';

void test('Bash Parser', async t => {
    const parser = new BashParser();
    const cwd = '/tmp';

    await t.test('extracts command names', async () => {
        const intent = await parser.parse('ls -la | grep "foo"', cwd);
        assert.deepStrictEqual(intent.names, ['ls', 'grep']);
        assert.strictEqual(intent.type, 'r');
    });

    await t.test('identifies write from redirection', async () => {
        const intent = await parser.parse('echo "hello" > log.txt', cwd);
        assert.strictEqual(intent.type, 'w');
        assert.deepStrictEqual(intent.names, ['echo']);
        assert.ok(intent.paths.some(({path}) => path === join(cwd, 'log.txt')));
    });

    await t.test('identifies write from mutative command', async () => {
        const intent = await parser.parse('rm -rf node_modules', cwd);
        assert.strictEqual(intent.type, 'w');
        assert.deepStrictEqual(intent.names, ['rm']);
    });

    await t.test('identifies write from sed -i', async () => {
        const intent = await parser.parse('sed -i "s/a/b/g" file.txt', cwd);
        assert.strictEqual(intent.type, 'w');
        assert.deepStrictEqual(intent.names, ['sed']);
        assert.ok(intent.paths.some(({path}) => path === join(cwd, 'file.txt')));
    });

    await t.test('extracts globs', async () => {
        const intent = await parser.parse('find . -name "*.ts"', cwd);
        assert.strictEqual(intent.names.includes('find'), true);
        assert.ok(intent.globs.includes(join(cwd, '*.ts')));
    });

    await t.test('fails closed on unparseable', async () => {
        const intent = await parser.parse('if [ -z "$VAR" ]; then', cwd);
        assert.strictEqual(intent.error, true);
    });
});
