import {CONFIG_DIR_NAME, getAgentDir, parseFrontmatter} from '@earendil-works/pi-coding-agent';
import type {AgentConfig, AgentSource} from './types.ts';
import * as path from 'node:path';
import * as fs from 'node:fs';

export class AgentDiscovery {
    readonly #cwd: string;

    constructor(cwd: string) {
        this.#cwd = cwd;
    }

    discover(): AgentConfig[] {
        const userDir = path.join(getAgentDir(), 'agents');
        const projectDir = this.#findNearestProjectAgentsDir();

        const userAgents = this.#loadAgents(userDir, 'user');
        const projectAgents = projectDir ? this.#loadAgents(projectDir, 'project') : [];

        const agentMap = new Map<string, AgentConfig>();

        // Project level agents override global agents

        for (const agent of userAgents) {
            agentMap.set(agent.name.toLowerCase(), agent);
        }

        for (const agent of projectAgents) {
            agentMap.set(agent.name.toLowerCase(), agent);
        }

        return Array.from(agentMap.values());
    }

    #loadAgents(dir: string, source: AgentSource): AgentConfig[] {
        const agents: AgentConfig[] = [];

        if (!fs.existsSync(dir)) {
            return agents;
        }

        const entries = fs.readdirSync(dir, {withFileTypes: true});

        for (const entry of entries) {
            if (!entry.name.endsWith('.md')) {
                continue;
            }

            if (!entry.isFile() && !entry.isSymbolicLink()) {
                continue;
            }

            const filePath = path.join(dir, entry.name);
            const content = fs.readFileSync(filePath, 'utf-8');
            const {frontmatter, body} = parseFrontmatter<AgentConfig>(content);
            const name = frontmatter.name || path.parse(entry.name).name;
            const tools = (frontmatter.tools as string)
                ?.split(',')
                .map((t: string) => t.trim())
                .filter(Boolean);

            agents.push({
                name,
                description: frontmatter.description ?? '',
                tools,
                model: frontmatter.model ?? '',
                thinking: frontmatter.thinking ?? 'high',
                systemPrompt: body,
                source,
                filePath,
            });
        }

        return agents;
    }

    #findNearestProjectAgentsDir(): string | null {
        let currentDir = this.#cwd;

        while (true) {
            const candidate = path.join(currentDir, CONFIG_DIR_NAME, 'agents');

            if (fs.existsSync(candidate) && fs.statSync(candidate).isDirectory()) {
                return candidate;
            }

            const parentDir = path.dirname(currentDir);

            if (parentDir === currentDir) {
                return null;
            }

            currentDir = parentDir;
        }
    }
}
