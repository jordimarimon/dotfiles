---
name: init
description: Initialize a new AGENTS.md file with codebase documentation.
---

Set up a minimal AGENTS.md for this repo. AGENTS.md is loaded into every agent/LLM session, so it must be concise — only include what an agent/LLM would get wrong without it.

## Phase 0: Check for an existing AGENTS.md

Before asking anything, check if AGENTS.md already exists at the project root (just `cat ./AGENTS.md` — only the project-root file counts; don't explore the tree yet). This branches Phase 1.

## Phase 1: Ask what to set up

Ask the user to find out what the user wants. Which question you ask depends on Phase 0.

Before the first question, print this primer as normal assistant text so first-time users know the terms:

> Quick context:
> - **AGENTS.md** files give agent persistent instructions for a project, your personal workflow, or your organization. Agent reads them at the start of every session.

**If AGENTS.md already exists**, ask:

- "I found an existing AGENTS.md. What would you like to do?"
  Options: "Review and improve it" | "Leave it, set up other things" | "Start fresh (replace it)"
  Description for improve: "Explore what's changed in the codebase and propose targeted edits to the existing file."
  Description for leave it: "Skip AGENTS.md. Go straight to skills and hooks."
  Description for start fresh: "Discard it and write new file(s)."
  Routing:
  - "Review and improve" → skip the rest of phase 1; explore (Phase 2), ask the Phase 3 question, then go to Phase 4's diff-proposal, then Phase 6.
  - "Leave it" → skip the rest of phase 1; jump straight to Phase 8 with: "Nothing to set up — your AGENTS.md is unchanged."
  - "Start fresh" → continue below as if no file existed.

**If no AGENTS.md exists** (or the user picked "Start fresh"), ask:

- "Which AGENTS.md files should /init set up?"
  Options: "Project AGENTS.md" | "Personal AGENTS.local.md" | "Both project + personal" | "Let agent decide"
  Description for project: "Team-shared instructions checked into source control — architecture, coding standards, common workflows."
  Description for personal: "Your private preferences for this project (gitignored, not shared) — your role, sandbox URLs, preferred test data, workflow quirks."
  Description for Let agent decide: "Fastest path — project AGENTS.md. No follow-on questions; you'll approve everything before it's written."

## Phase 2: Explore the codebase

Launch a subagent to survey the codebase, and ask it to read key files to understand the project: manifest files (package.json, Cargo.toml, pyproject.toml, go.mod, pom.xml, etc.), README, Makefile/build configs, CI config, existing AGENTS.md, docs, etc.

Detect:
- Build, test, and lint commands (especially non-standard ones)
- Languages, frameworks, and package manager
- Project structure (monorepo with workspaces, multi-module, or single project)
- Code style rules that differ from language defaults
- Non-obvious gotchas, required env vars, or workflow quirks
- Existing skills directories
- Formatter configuration (prettier, biome, ruff, black, gofmt, rustfmt, or a unified format script like `npm run format` / `make fmt`)
- Git worktree usage: run `git worktree list` to check if this repo has multiple worktrees (only relevant if the user wants a personal AGENTS.local.md)

Note what you could NOT figure out from code alone — these become interview questions.

## Phase 3: Fill in the gaps

Ask the user to gather what you still need to write good AGENTS.md files. Ask only things the code can't answer.

If the user chose project AGENTS.md, both, or "Let agent decide": ask about codebase practices — non-obvious commands, gotchas, branch/PR conventions, required env setup, testing quirks. Skip things already in README or obvious from manifest files. Do not mark any options as "recommended" — this is about how their team works, not best practices.

If the user chose personal AGENTS.local.md or both: ask about them, not the codebase. Do not mark any options as "recommended" — this is about their personal preferences, not best practices. Examples of questions:
  - What's their role on the team? (e.g., "backend engineer", "data scientist", "new hire onboarding")
  - How familiar are they with this codebase and its languages/frameworks? (so agent can calibrate explanation depth)
  - Do they have personal sandbox URLs, test accounts, API key paths, or local setup details agent should know?
  - Any communication preferences? (e.g., "be terse", "always explain tradeoffs", "don't summarize at the end")

If the user picked "Review and improve" in Phase 1: ask just one question — "Has anything changed about how the team works since this AGENTS.md was written (new conventions, commands, gotchas)?" with options "No, nothing's changed" | "Yes — let me describe". If they pick Yes, ask what changed (free text) before continuing. Then skip to Phase 4.

**Synthesize a proposal from Phase 2 findings and the gap-fill answers.**

Include the AGENTS.md file(s) (project, personal, both, or "Let agent decide" → project) as the first bullet(s) of the proposal, with a one-line summary of what each will cover. On the "Leave it" path, skip (Phase 4 won't run). On the "Start fresh" path with personal-only (AGENTS.local.md), add a bullet noting the existing project AGENTS.md will be left untouched (they chose not to replace it with a project file). Propose what fits. 

**Print the proposal as normal assistant text**, one bullet per item:

> Here's what I'd set up:
> • **[Artifact type: AGENTS.md]** — [summary]
> • **[Artifact type: AGENTS.local.md]** — [summary]
> • …

Ask the user a simple question ("Does this look right?") and options like "Looks good — proceed" | "Other".

## Phase 4: Write AGENTS.md (if the approved proposal includes it, or on the "Review and improve" path)

Write a minimal AGENTS.md at the project root. Every line must pass this test: "Would removing this cause agent to make mistakes?" If no, cut it.

If the user picked "Review and improve it" in Phase 0: don't write fresh — read the existing file, compare against Phase 2 findings and the Phase 3 answer, and propose specific additions/removals as diffs with a one-line reason for each. The existing file is the baseline; your job is to catch what's missing, outdated, or bloated. After printing the diffs, ask the user ("Apply these edits?" with options like "Apply all" | "Let me pick which" | "Skip — leave it as is") before writing anything.

**Consume `note` entries from the Phase 3 preference queue whose target is AGENTS.md** (team-level notes) — add each as a concise line in the most relevant section. These are the behaviors the user wants agent to follow but didn't need guaranteed (e.g., "propose a plan before implementing", "explain the tradeoffs when refactoring"). Leave personal-targeted notes for Phase 5.

Include:
- Build/test/lint commands agent can't guess (non-standard scripts, flags, or sequences)
- Code style rules that DIFFER from language defaults (e.g., "prefer type over interface")
- Testing instructions and quirks (e.g., "run single test with: pytest -k 'test_name'")
- Repo etiquette (branch naming, PR conventions, commit style)
- Required env vars or setup steps
- Non-obvious gotchas or architectural decisions
- Important parts from existing AI coding tool configs if they exist

Exclude:
- File-by-file structure or component lists (agent can discover these by reading the codebase)
- Standard language conventions agent already knows
- Generic advice ("write clean code", "handle errors")
- Detailed API docs or long references — use `@path/to/import` syntax instead (e.g., `@docs/api-reference.md`) to inline content on demand without bloating AGENTS.md
- Information that changes frequently — reference the source with `@path/to/import` so agent always reads the current version
- Long tutorials or walkthroughs (move to a separate file and reference with `@path/to/import`)
- Commands obvious from manifest files (e.g., standard "npm test", "cargo test", "pytest")

Be specific: "Use 2-space indentation in TypeScript" is better than "Format code properly."

Do not repeat yourself and do not make up sections like "Common Development Tasks" or "Tips for Development" — only include information expressly found in files you read.

Prefix the file with:

```
# AGENTS.md

This file provides guidance to an LLM when working with code in this repository.
```

For projects with distinct subdirectories (monorepos, multi-module projects, etc.): mention that subdirectory AGENTS.md files can be added for module-specific instructions (they're loaded automatically when agent works in those directories). Offer to create them if the user wants.

## Phase 5: Write AGENTS.local.md (if the approved proposal includes it)

Write a minimal AGENTS.local.md at the project root. This file is automatically loaded alongside AGENTS.md. After creating it, add `AGENTS.local.md` to the project's .gitignore so it stays private.

**Consume `note` entries from the Phase 3 preference queue whose target is AGENTS.local.md** (personal-level notes) — add each as a concise line. If the user chose personal-only in Phase 1, this is the sole consumer of note entries.

Include:
- The user's role and familiarity with the codebase (so agent can calibrate explanations)
- Personal sandbox URLs, test accounts, or local setup details
- Personal workflow or communication preferences

Keep it short — only include what would make agent's responses noticeably better for this user.

If AGENTS.local.md already exists: read it, propose specific additions, and do not silently overwrite.

## Phase 6: Summary and next steps

Recap what was set up — which files were written and the key points included in each. Remind the user these files are a starting point: they should review and tweak them, and can run `/init` again anytime to re-scan.

