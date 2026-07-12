import {Container, Text, type Component} from '@earendil-works/pi-tui';
import type {SubagentResult, SubagentResults} from './types.ts';
import {AgentDiscovery} from './discovery.ts';
import type {AgentConfig} from './types.ts';
import {SubagentRunner} from './runner.ts';
import type {
    ExtensionAPI,
    AgentToolResult,
    ToolRenderResultOptions,
    Theme,
    AgentToolUpdateCallback,
    ExtensionContext,
} from '@earendil-works/pi-coding-agent';
import Type from 'typebox';

const SubagentParams = Type.Object({
    agent: Type.Optional(Type.String({description: 'Name of the agent (single mode)'})),
    cwd: Type.Optional(Type.String({description: 'Current working directory for single mode'})),
    task: Type.Optional(Type.String({description: 'Task for the agent (single mode)'})),
    tasks: Type.Optional(
        Type.Array(
            Type.Object({
                agent: Type.String(),
                task: Type.String(),
                cwd: Type.Optional(Type.String()),
            }),
            {description: 'Array of tasks for parallel execution'},
        ),
    ),
});

type SubagentParams = Type.Static<typeof SubagentParams>;

export class Orchestrator {
    readonly #runner = new SubagentRunner();

    static register(pi: ExtensionAPI): Orchestrator {
        const orchestrator = new Orchestrator();

        pi.registerTool({
            label: '',
            name: 'subagent',
            description: 'Delegate tasks to specialized in-process subagents.',
            parameters: SubagentParams,

            execute: async (
                _id: string,
                params: SubagentParams,
                _signal: AbortSignal | undefined,
                onUpdate: AgentToolUpdateCallback<SubagentResult | SubagentResults | null>,
                ctx: ExtensionContext,
            ): Promise<AgentToolResult<SubagentResult | SubagentResults | null>> => {
                const discovery = new AgentDiscovery(ctx.cwd);
                const agents = discovery.discover();

                if (params.tasks && params.tasks.length > 0) {
                    return await orchestrator.#runParallel(params.tasks, agents, ctx.cwd, onUpdate);
                }

                if (params.agent && params.task) {
                    return await orchestrator.#runSingle(
                        params.agent,
                        params.task,
                        agents,
                        params.cwd || ctx.cwd,
                        onUpdate,
                    );
                }

                return {
                    details: null,
                    content: [
                        {type: 'text', text: 'Invalid parameters. Provide agent+task or tasks.'},
                    ],
                };
            },

            renderCall(args: SubagentParams, theme: Theme): Component {
                const agent = args.agent || 'parallel';
                const text = `${theme.fg('toolTitle', theme.bold('subagent '))} ${theme.fg('accent', agent)}`;

                return new Text(text, 0, 0);
            },

            renderResult(
                result: AgentToolResult<SubagentResult | SubagentResults | null>,
                _options: ToolRenderResultOptions,
                theme: Theme,
            ): Component {
                const container = new Container();
                const details = result.details;

                if (!details) {
                    return new Text(
                        result.content[0]?.type === 'text' ? result.content[0].text : '',
                        0,
                        0,
                    );
                }

                if (details.kind === 'parallel') {
                    container.addChild(new Text(theme.fg('accent', 'Parallel Results:'), 0, 0));

                    for (const result of details.results) {
                        const icon = result.error
                            ? theme.fg('error', '✗')
                            : theme.fg('success', '✓');

                        container.addChild(new Text(`${icon} ${theme.bold(result.agent)}`, 0, 0));
                    }
                } else {
                    const icon = details.error ? theme.fg('error', '✗') : theme.fg('success', '✓');
                    container.addChild(
                        new Text(`${icon} ${theme.fg('accent', details.agent)} completed`, 0, 0),
                    );

                    if (details.usage) {
                        container.addChild(
                            new Text(
                                theme.fg(
                                    'dim',
                                    `Usage: ↑${details.usage.input} ↓${details.usage.output}`,
                                ),
                                0,
                                0,
                            ),
                        );
                    }
                }

                return container;
            },
        });

        return orchestrator;
    }

    async #runSingle(
        agentName: string,
        task: string,
        agents: AgentConfig[],
        cwd: string,
        onUpdate: AgentToolUpdateCallback<SubagentResult | SubagentResults | null>,
    ): Promise<AgentToolResult<SubagentResult>> {
        const agent = agents.find(a => a.name.toLowerCase() === agentName.toLowerCase());

        if (!agent) {
            return {
                content: [{type: 'text', text: `Agent not found: ${agentName}`}],
                details: {kind: 'single', error: true, agent: '', output: ''},
            };
        }

        const result = await this.#runner.run(agent, task, cwd, partial => {
            onUpdate?.({
                content: [{type: 'text', text: partial}],
                details: null,
            });
        });

        return {
            content: [{type: 'text', text: result.output}],
            details: result,
        };
    }

    async #runParallel(
        tasks: SubagentParams['tasks'],
        agents: AgentConfig[],
        cwd: string,
        _onUpdate: AgentToolUpdateCallback<SubagentResult | SubagentResults | null>,
    ): Promise<AgentToolResult<SubagentResults>> {
        const results = await Promise.all<SubagentResult>(
            tasks!.map(async t => {
                const agent = agents.find(a => a.name.toLowerCase() === t.agent.toLowerCase());

                if (!agent) {
                    return {
                        kind: 'single',
                        agent: t.agent,
                        output: `Agent not found: ${t.agent}`,
                        error: true,
                    };
                }

                return await this.#runner.run(agent, t.task, t.cwd || cwd);
            }),
        );

        const summaries = results.map(r => {
            const status = r.error ? '❌' : '✅';
            return `### [${r.agent}] ${status}\n\n${r.output}`;
        });

        return {
            content: [{type: 'text', text: summaries.join('\n\n---\n\n')}],
            details: {
                kind: 'parallel',
                results,
            },
        };
    }
}
