import {existsSync, readFileSync, readdirSync, realpathSync} from 'node:fs';
import {logger, LogGroup} from '../utils/logger.ts';
import {dirname, join, relative} from 'node:path';
import {ToolIntent} from '#src/utils/intent.ts';
import type {
    ExtensionAPI,
    ExtensionContext,
    ToolResultEvent,
    AgentToolResult,
    BeforeAgentStartEvent,
    BeforeAgentStartEventResult,
} from '@earendil-works/pi-coding-agent';

export class ScopedContext {
    readonly #agentFiles = new Set<string>();

    #ruleFiles: string[] = [];

    static register(pi: ExtensionAPI): void {
        const context = new ScopedContext();

        // Scan for rules on session start
        pi.on('session_start', async (_event, ctx) => {
            context.#handleSessionStart(ctx);
        });

        pi.on('before_agent_start', async event => {
            // Append available rules to system prompt
            return context.#handleAgentStart(event);
        });

        // Search for AGENTS.md files near the files the agent is working on
        pi.on('tool_result', (event: ToolResultEvent, ctx: ExtensionContext) => {
            return context.#handleTool(event, ctx);
        });
    }

    #handleSessionStart(ctx: ExtensionContext): void {
        const rulesDir = join(ctx.cwd, '.claude', 'rules');
        this.#ruleFiles = this.#searchClaudeRules(rulesDir);

        logger.info(`Found ${this.#ruleFiles.length} rule(s) in ${rulesDir}`, 'info');

        if (this.#ruleFiles.length > 0) {
            ctx.ui.notify(`Found ${this.#ruleFiles.length} rule(s) in .claude/rules/`, 'info');
        }
    }

    #handleAgentStart(event: BeforeAgentStartEvent): BeforeAgentStartEventResult | void {
        if (this.#ruleFiles.length === 0) {
            return;
        }

        const rulesList = this.#ruleFiles.map(f => `- .claude/rules/${f}`).join('\n');
        const appendPrompt: string[] = [
            '## Project Rules',
            'The following project rules are available in .claude/rules/:',
            rulesList,
            'When working on tasks related to these rules (see frontmatter), use the read tool to load the relevant rule files for guidance.',
        ];

        return {
            systemPrompt: event.systemPrompt + appendPrompt.join('\n'),
        };
    }

    async #handleTool(
        event: ToolResultEvent,
        ctx: ExtensionContext,
    ): Promise<AgentToolResult<unknown>> {
        if (event.isError) {
            return event;
        }

        const intent = await ToolIntent.get(event.toolCallId);

        if (!intent) {
            return event;
        }

        const paths = intent.paths.map(p => p.path);

        if (intent.bashCommand && !intent.bashCommand.error) {
            paths.push(...intent.bashCommand.paths.map(({path}) => path));
        }

        const newContent: ToolResultEvent['content'] = [];

        for (const {path} of intent.paths) {
            const newContextFiles = this.#searchAgents(path, ctx.cwd);

            if (!newContextFiles.length) {
                return event;
            }

            logger.info(
                LogGroup.ScopedContext,
                `Found ${newContextFiles.length} new AGENTS.md files for ${path}`,
            );

            const contextBlocks = newContextFiles.map(f => {
                const content = readFileSync(f, 'utf8');
                const relativePath = relative(ctx.cwd, f);
                return `[Context from ${relativePath}]\n${content}`;
            });

            newContent.push({
                type: 'text' as const,
                text: `### Hierarchical Context Discovery\n\nNew context rules found for this path:\n\n${contextBlocks.join('\n\n')}`,
            });
        }

        newContent.push(...event.content);

        return {content: newContent, details: event.details};
    }

    #searchAgents(target: string, root: string): string[] {
        const found: string[] = [];

        let currentDir = dirname(target);

        while (true) {
            const next = dirname(currentDir);
            const agentsPath = join(currentDir, 'AGENTS.md');
            const isRoot = currentDir === root;

            if (!isRoot && !this.#agentFiles.has(agentsPath) && existsSync(agentsPath)) {
                found.push(agentsPath);
                this.#agentFiles.add(agentsPath);
            }

            if (isRoot || currentDir === next) {
                break;
            }

            currentDir = next;
        }

        return found.reverse();
    }

    #searchClaudeRules(dir: string): string[] {
        const results: string[] = [];

        if (!existsSync(dir)) {
            return results;
        }

        const entries = readdirSync(dir, {withFileTypes: true});

        for (const entry of entries) {
            const entryPath = join(entry.parentPath, entry.name);

            if ((entry.isFile() || entry.isSymbolicLink()) && entry.name.endsWith('.md')) {
                results.push(realpathSync(entryPath));
            }
        }

        return results;
    }
}
