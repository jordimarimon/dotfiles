import {defineConfig} from 'rolldown';

export default defineConfig({
    input: 'src/index.js',
    platform: 'node',
    external: [/^@earendil-works/, /^node:/],
    output: {
        format: 'esm',
        file: 'dist/index.js',
        sourcemap: 'inline',
    },
});
