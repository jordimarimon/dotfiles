import {PhpCodeStandardFixerFormatter} from './formatters/php-cs-fixer.ts';
import {PrettierFormatter} from './formatters/prettier.ts';
import {BaseFormatter} from './formatter.ts';

export const FORMATTERS: Record<string, BaseFormatter> = {
    prettier: new PrettierFormatter(),
    php_cs_fixer: new PhpCodeStandardFixerFormatter(),
};

export const FORMATTERS_BY_FILETYPE: Record<string, string[]> = {
    typescript: ['prettier'],
    javascript: ['prettier'],
    php: ['php_cs_fixer'],
    json: ['prettier'],
    markdown: ['prettier'],
    css: ['prettier'],
};

export const EXTENSION_TO_FILETYPE: Record<string, string> = {
    ts: 'typescript',
    tsx: 'typescript',
    js: 'javascript',
    jsx: 'javascript',
    php: 'php',
    json: 'json',
    md: 'markdown',
    css: 'css',
};
