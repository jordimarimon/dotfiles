import {PhpCodeStandardFixerFormatter} from './formatters/php-cs-fixer.ts';
import {PrettierFormatter} from './formatters/prettier.ts';
import {OxfmtFormatter} from './formatters/oxfmt.ts';
import {BaseFormatter} from './formatter.ts';

export const FORMATTERS: Record<string, BaseFormatter> = {
    prettier: new PrettierFormatter(),
    php_cs_fixer: new PhpCodeStandardFixerFormatter(),
    oxfmt: new OxfmtFormatter(),
};

export const FORMATTERS_BY_FILETYPE: Record<string, string[]> = {
    typescript: ['oxfmt', 'prettier'],
    javascript: ['oxfmt', 'prettier'],
    php: ['php_cs_fixer'],
    json: ['oxfmt', 'prettier'],
    markdown: ['oxfmt', 'prettier'],
    css: ['oxfmt', 'prettier'],
    html: ['oxfmt', 'prettier'],
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
    html: 'html',
};
