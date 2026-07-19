This document outlines project specific coding conventions and rules. When contributing to this codebase, please adhere to the following guidelines.

This project is an extension for the PI harness. This extension has multiple modules:

- Autoformat: Format files automatically after an LLM turn end.
- Permission: Intercept LLM tool calls and allow/ask/deny them based on a set of rules.
- Subagents: Work in progress. Allow to orchestrate work with multiple agents.
- Scoped context: Appends AGENTS.md files, that are nested in a project, as additional context when the LLM reads a file.

## TypeScript Best Practices

- **Avoid the `any` type:** Always prefer strong typing. If a type is truly unknown, use `unknown` and validate or type-guard it before use.
- **Avoid type casting (`as`):** Try to construct types correctly. In tests, use the `fromPartial` utility imported from `#tests/utils.ts` to mock large or complex interfaces without needing an `as` cast.
- **Prefer typed imports:** When importing only interfaces or types, use explicit typed imports (e.g., `import type { ExtensionContext } from '@earendil-works/pi-coding-agent';`). This aids in code clarity and compiler optimizations.
- **Use TypeBox for runtime validation:** When handling external data (like JSON configurations or user inputs), define the structure using `typebox`. Derive your static types using `Type.Static<typeof Schema>` and validate runtime values using `TypeName.Check(data)`.

## Modules and Imports

- **Use Node Subpath Imports:** Leverage the subpath imports defined in `package.json` for internal absolute resolution.
    - Prefer `#src/...` instead of long relative paths like `../../../src/...`.
    - Prefer `#tests/...` for shared test utilities.
- **File Extensions:** All relative imports must include the `.ts` extension (e.g., `import { logger } from './utils.ts';`).
- **Node built-ins:** Always prefix Node.js core modules with `node:` (e.g., `import { join } from 'node:path';`, `import fs from 'node:fs';`).

## Testing Environment

- **Native Test Runner:** We use the native Node.js test runner (`node:test`) and assertions (`node:assert`).

## Logging

- **Custom Logger:** Avoid using raw `console.log`, `console.warn`, or `console.error` for extension logic. Use the project's internal logger:
    ```ts
    import {logger, LogGroup} from '#src/utils/logger.ts';
    logger.info(LogGroup.Permission, 'Message here', {optionalData});
    ```

## Formatting

- **Oxc:** Code formatting is managed by Oxfmt. Use `pnpm run format` to automatically format all files.
