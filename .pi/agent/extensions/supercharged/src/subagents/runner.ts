import {createAgentSession, SessionManager} from '@earendil-works/pi-coding-agent';
import type {AgentConfig, SubagentResult} from './types.ts';

export class SubagentRunner {
    public async run(
        agentConfig: AgentConfig,
        task: string,
        cwd: string,
        onUpdate?: (partial: string) => void,
    ): Promise<SubagentResult> {
        const {session} = await createAgentSession({
            sessionManager: SessionManager.inMemory(),
            tools: agentConfig.tools as string[],
            cwd,
        });

        if (agentConfig.model) {
            const registry = (session as any).modelRegistry;
            const model = registry.find(...agentConfig.model.split('/'));
            if (model) {
                await session.setModel(model);
            }
        }

        if (agentConfig.thinking) {
            session.setThinkingLevel(agentConfig.thinking);
        }

        const unsubscribe = session.subscribe(event => {
            if (event.type === 'message_update' && event.message.role === 'assistant') {
                const text = (event.message.content as any)
                    ?.filter((c: any) => c.type === 'text')
                    .map((c: any) => c.text)
                    .join('');

                if (text && onUpdate) {
                    onUpdate(text);
                }
            }
        });

        try {
            // 3. Build the prompt with the agent's identity
            // We use the <active_agent> tag so the permission system can identify the subagent
            const fullPrompt = `<active_agent>${agentConfig.name}</active_agent>\n\nYou are the specialized subagent: ${agentConfig.name}\n\n${agentConfig.systemPrompt}\n\nTask: ${task}`;

            // 4. Run the turn
            await session.prompt(fullPrompt);

            // 5. Collect final results
            const messages = session.state.messages;
            const lastAssistant = messages.filter(m => m.role === 'assistant').pop();
            const output =
                (lastAssistant?.content as any)
                    ?.filter((c: any) => c.type === 'text')
                    .map((c: any) => c.text)
                    .join('') || '';

            const usage = (lastAssistant as any)?.usage;

            return {
                kind: 'single',
                agent: agentConfig.name,
                output,
                usage: usage
                    ? {
                          input: usage.input,
                          output: usage.output,
                          total: usage.total,
                      }
                    : undefined,
            };
        } catch (error: unknown) {
            return {
                kind: 'single',
                agent: agentConfig.name,
                output: String(error),
                error: true,
            };
        } finally {
            unsubscribe();
            session.dispose();
        }
    }
}
