import {defineConfig} from 'oxfmt';

export default defineConfig({
    tabWidth: 4,
    printWidth: 100,
    singleQuote: true,
    quoteProps: 'consistent',
    arrowParens: 'avoid',
    bracketSpacing: false,
    sortPackageJson: false,
    ignorePatterns: [],
});
