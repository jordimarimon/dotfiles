import type {ThinkingLevel} from '@earendil-works/pi-agent-core';

export type AgentSource = 'user' | 'project';

export interface AgentConfig {
    [index: string]: unknown;
    name: string;
    description: string;
    tools?: string[] | string;
    model?: string;
    thinking?: ThinkingLevel;
    systemPrompt: string;
    source: AgentSource;
    filePath: string;
}

export interface SubagentTask {
    agent: string;
    task: string;
    cwd?: string;
}

export interface SubagentResult {
    kind: 'single';
    agent: string;
    output: string;
    usage?: {input: number; output: number; total: number} | undefined;
    error?: boolean;
}

export interface SubagentResults {
    kind: 'parallel';
    results: SubagentResult[];
}
