# Harness Engineering: An Engineering Team's Guide to Autonomous Agentic Coding Pipelines

*Synthesized from OpenAI's Harness Engineering report, matklad's ARCHITECTURE.md patterns, and the Codex Execution Plans (ExecPlans) specification. Adapted for both Codex and Claude-based agent workflows.*

---

## 1. The Core Thesis

The traditional role of a software engineer — writing code — is being replaced by a higher-order function: designing environments, specifying intent, and building feedback loops that allow coding agents to produce reliable work autonomously.

OpenAI's internal experiment demonstrated this concretely: three engineers shipped roughly one million lines of code across 1,500 pull requests in five months, with zero manually-written code. Throughput averaged 3.5 PRs per engineer per day and increased as the team grew to seven. The product had real daily users.

The constraint they imposed — no human-written code, ever — forced them to discover what actually matters when agents do the writing. What follows is the distilled set of principles and techniques that emerged.

---

## 2. The Engineer's New Job Description

When agents write all the code, the engineer's role shifts to three activities:

**Environment Design.** Build the scaffolding, tooling, abstractions, and repository structure that make agent work tractable. When an agent fails, the diagnosis is almost never "try harder" — it's "what capability, context, or constraint is missing?"

**Intent Specification.** Translate product goals, user feedback, and architectural decisions into prompts, stories, execution plans, and acceptance criteria that are precise enough for a stateless agent to act on.

**Feedback Loop Construction.** Wire up the systems — linters, tests, CI, observability, agent-driven review — that let agents validate their own work and self-correct without human intervention.

### Practical Implications

The engineers on this team interacted with the system almost entirely through prompts. They described tasks, ran agents, and let agents open pull requests. To drive a PR to completion, they instructed the agent to review its own changes, request additional agent reviews, respond to feedback, and iterate in a loop until all reviewers were satisfied. Humans could review PRs but were not required to. Over time, almost all review was agent-to-agent.

---

## 3. Repository Knowledge Architecture

This is the highest-leverage investment a team can make. The repository itself must become the single source of truth for everything an agent needs to know.

### 3.1 The "Table of Contents" Pattern (Not the Encyclopedia)

A monolithic instruction file fails predictably: it crowds out task context, creates a false sense of guidance where nothing stands out, rots instantly as the codebase evolves, and resists mechanical verification.

Instead, treat your top-level agent instructions (AGENTS.md, CLAUDE.md, or equivalent) as a short map — roughly 100 lines — with pointers to deeper sources of truth elsewhere in the repository.

**Recommended repository knowledge layout:**

```
AGENTS.md (or CLAUDE.md)     ← ~100-line table of contents
ARCHITECTURE.md               ← High-level system map
docs/
├── design-docs/
│   ├── index.md
│   ├── core-beliefs.md        ← Agent-first operating principles
│   └── ...
├── exec-plans/
│   ├── active/
│   ├── completed/
│   └── tech-debt-tracker.md
├── generated/
│   └── db-schema.md           ← Auto-generated from live system
├── product-specs/
│   ├── index.md
│   └── ...
├── references/
│   ├── design-system-reference-llms.txt
│   └── ...
├── DESIGN.md
├── FRONTEND.md
├── PLANS.md
├── PRODUCT_SENSE.md
├── QUALITY_SCORE.md
├── RELIABILITY.md
└── SECURITY.md
```

This enables **progressive disclosure**: agents start with a small, stable entry point and navigate to deeper context only when relevant, rather than being overwhelmed upfront.

### 3.2 The ARCHITECTURE.md Pattern

matklad's ARCHITECTURE.md concept is a foundational piece of this system. The insight: it takes roughly 2x more time to write a patch when unfamiliar with a codebase, but 10x more time to figure out *where* to write it. An ARCHITECTURE.md bridges that gap for both humans and agents.

**What to include:**

- A bird's-eye overview of the problem being solved
- A coarse-grained codemap: modules, domains, and how they relate to each other — answering both "where's the thing that does X?" and "what does the thing I'm looking at do?"
- Named important files, modules, and types (by name, not by link — links rot; names can be searched)
- Architectural invariants, especially those expressed as the *absence* of something (e.g., "the model layer does not depend on the views")
- Boundaries between layers and systems — good boundaries have measure zero in a random code walk, but they constrain all possible implementations behind them
- A separate section on cross-cutting concerns

**What to exclude:**

- Implementation details of individual modules (pull those into inline docs or separate files)
- Anything that changes frequently — the ARCHITECTURE.md should be revisited a few times a year, not kept in lockstep with every commit

**For agents specifically:** Name things precisely so the agent can use symbol search. Do not deep-link to line numbers. Encourage navigation by name.

### 3.3 Making All Context Repository-Local

From the agent's perspective, anything it cannot access in-context while running effectively does not exist. Knowledge that lives in Slack threads, Google Docs, or people's heads is invisible.

The operational rule: if a decision, pattern, or constraint matters, it must be discoverable in the repository as a versioned artifact — code, markdown, schema, or executable plan. That Slack discussion where the team aligned on an architectural pattern? If it is not in the repo, it is unknown to every future agent run and every new hire who joins three months later.

This applies to Claude workflows as well. Claude Code reads CLAUDE.md, specialist agent files, and in-repo docs. Anything not reachable from that graph is effectively nonexistent to the agent.

---

## 4. Enforcing Architecture Mechanically

Documentation alone does not keep a fully agent-generated codebase coherent. Architecture must be enforced through tooling that runs automatically.

### 4.1 Rigid Layered Architecture

Build the application around a fixed architectural model with strictly validated dependency directions. For example, within each business domain, code may only depend "forward" through a defined layer sequence:

```
Types → Config → Repo → Service → Runtime → UI
```

Cross-cutting concerns (auth, connectors, telemetry, feature flags) enter through a single explicit interface: Providers. Everything else is mechanically disallowed.

This is the kind of architecture teams typically postpone until they have hundreds of engineers. With coding agents, it is an early prerequisite — constraints are what allow speed without decay.

### 4.2 Custom Linters as Agent Guardrails

Enforce invariants through custom linters and structural tests. Key patterns:

- **Structured logging enforcement.** Agents must use the logging framework correctly, not ad-hoc print statements.
- **Naming conventions for schemas and types.** Consistent naming allows agents to discover and extend patterns.
- **File size limits.** Prevent monolithic files that degrade agent comprehension.
- **Dependency direction validation.** Mechanically enforce that code in layer N does not import from layer N+1.
- **Boundary validation.** Data shapes must be parsed at the boundary (e.g., Zod schemas, Pydantic models) — the *what* is enforced, not the *how*.

**Critical detail:** Because the lints are custom, write error messages that inject remediation instructions directly into agent context. The lint failure message *is* the prompt.

### 4.3 Taste Invariants

Beyond structural rules, encode "golden principles" — opinionated, mechanical rules that keep the codebase legible:

- Prefer shared utility packages over hand-rolled helpers (centralizes invariants)
- Validate at boundaries or use typed SDKs — never probe data shapes speculatively
- Favor "boring" technologies: composable, API-stable, well-represented in training data
- In some cases, reimplement subsets of functionality rather than pulling in opaque upstream packages — the result is tightly integrated, fully tested, and behaves exactly as the system expects

---

## 5. Execution Plans (ExecPlans)

ExecPlans are the mechanism for steering agents through complex, multi-hour work. They function as living design documents that an agent follows from design through implementation.

### 5.1 Core Requirements

Every ExecPlan must be:

- **Fully self-contained.** A complete novice with only the working tree and the plan itself must be able to implement the feature end-to-end. No external blogs, docs, or assumed context.
- **A living document.** Updated as progress is made, discoveries occur, and design decisions are finalized. Each revision remains self-contained.
- **Outcome-focused.** Must produce demonstrably working behavior, not merely code changes. Acceptance is phrased as observable behavior ("navigating to /health returns HTTP 200") not internal attributes ("added a HealthCheck struct").
- **Idempotent and safe.** Steps can be run multiple times without damage. Risky steps include rollback paths.

### 5.2 ExecPlan Structure

```
# [Short, action-oriented description]

## Purpose / Big Picture
Why this work matters from a user's perspective. What becomes possible after this change.

## Progress
Granular checklist with timestamps. Updated at every stopping point.
- [x] (2026-03-10 14:00Z) Completed step
- [ ] Next step
- [ ] Partially completed (done: X; remaining: Y)

## Surprises & Discoveries
Unexpected behaviors, bugs, performance tradeoffs discovered during work.

## Decision Log
Every design decision with rationale and date.

## Outcomes & Retrospective
Summary at major milestones or completion. Compares result against original purpose.

## Context and Orientation
Current state as if reader knows nothing. Key files and modules by full path.

## Plan of Work
Prose description of the sequence of edits and additions.

## Concrete Steps
Exact commands, working directories, expected transcripts.

## Validation and Acceptance
How to exercise the system and what to observe. Behavior-based.

## Idempotence and Recovery
Safe retry and rollback paths.

## Interfaces and Dependencies
Prescribed libraries, types, function signatures.
```

### 5.3 Key Authoring Principles

- **Repeat assumptions.** The agent executing the plan has no memory of prior context. State everything needed explicitly.
- **Embed knowledge.** Do not point to external docs. If knowledge is required, include it in the plan in your own words.
- **Specify precisely.** Name files with full repository-relative paths, name functions and modules exactly, describe where new files go.
- **Include prototyping milestones.** When de-risking a larger change, it is encouraged to include explicit proof-of-concept milestones. Keep prototypes additive and testable.
- **Write in prose.** Prefer sentences over lists. Checklists are permitted only in the Progress section.

### 5.4 Claude Adaptation

Claude Code and Codex share the same fundamental need for self-contained plans. For Claude workflows:

- Store ExecPlans alongside stories in `bmad/epics/[epic-name]/` or in a dedicated `docs/exec-plans/` directory
- Reference plans from CLAUDE.md so the agent knows where to find them
- Use the same living-document discipline: Progress, Surprises, Decision Log, Retrospective
- Claude's subagent architecture (Explore, Plan, general-purpose) can be leveraged to parallelize research and implementation phases within a single ExecPlan

---

## 6. Increasing Application Legibility to Agents

As code throughput increases, the bottleneck shifts to human QA capacity. The solution is to make the application itself directly legible to agents.

### 6.1 Per-Worktree Application Instances

Make the application bootable per git worktree so each agent can launch and drive its own isolated instance. This enables:

- Bug reproduction without interfering with other work
- Fix validation in isolation
- UI reasoning via DOM snapshots, screenshots, and navigation

### 6.2 Observability as Agent Context

Expose logs, metrics, and traces to the agent through a local observability stack that is ephemeral per worktree. Agents query logs with LogQL and metrics with PromQL. Prompts like "ensure service startup completes in under 800ms" or "no span in these four critical user journeys exceeds two seconds" become tractable.

### 6.3 Browser Automation

Wire the Chrome DevTools Protocol (or equivalent) into the agent runtime. Create skills for working with DOM snapshots, screenshots, and navigation. This enables agents to reason about UI behavior directly — reproducing bugs, validating fixes, and recording evidence.

### 6.4 Claude-Specific Legibility

Claude Code supports similar patterns:

- **Worktree isolation** via `claude-feature` / `git worktree` — each session gets its own branch and working directory
- **Application driving** via bash commands, curl, and test harnesses referenced in CLAUDE.md
- **Screenshot and DOM verification** when using MCP tools or browser automation integrations
- **Ephemeral environments** where the agent validates its own work against running services

---

## 7. The Agent Review Loop

Human review does not scale when agents produce 3-5 PRs per engineer per day. The solution is agent-to-agent review.

### 7.1 The Self-Review Pattern

Instruct the agent to:
1. Validate the current codebase state
2. Implement the change
3. Review its own changes locally
4. Request additional agent reviews (both local and cloud-based)
5. Respond to feedback from human or agent reviewers
6. Iterate until all reviewers are satisfied
7. Squash and merge

This creates a "Ralph Wiggum Loop" — a fully autonomous cycle that only escalates to humans when genuine judgment is required.

### 7.2 Merge Philosophy at Scale

At high agent throughput, conventional merge gates become counterproductive:

- Pull requests are short-lived
- Test flakes are addressed with follow-up runs rather than blocking indefinitely
- Corrections are cheap; waiting is expensive
- Minimal blocking merge gates

This requires strong automated guardrails (tests, linters, architectural enforcement) to be safe. It would be irresponsible without them.

---

## 8. Entropy Management and Garbage Collection

Agents replicate patterns that already exist in the repository, including suboptimal ones. Over time, this leads to drift.

### 8.1 The Problem

The OpenAI team initially spent 20% of their week (every Friday) manually cleaning up agent-generated code. This did not scale.

### 8.2 The Solution: Continuous Garbage Collection

Encode "golden principles" directly into the repository and build a recurring cleanup process:

- On a regular cadence, background agent tasks scan for deviations from golden principles
- Agents update quality grades per domain and architectural layer
- Agents open targeted refactoring PRs
- Most cleanup PRs can be reviewed in under a minute and automerged

This functions like garbage collection for technical debt. Small, continuous payments prevent compounding.

### 8.3 Human Taste as Input

Human taste is captured once, then enforced continuously:

- Review comments become documentation updates
- Refactoring PRs encode improved patterns
- User-facing bugs are captured as documentation updates or tooling changes
- When documentation falls short, the rule is promoted into code (linter, test, structural check)

---

## 9. Autonomy Levels and the End-to-End Agent

As more of the development loop is encoded into the system, agents can drive increasingly complex workflows from a single prompt:

1. Validate codebase state
2. Reproduce a reported bug
3. Record evidence of the failure
4. Implement a fix
5. Validate the fix by driving the application
6. Record evidence of the resolution
7. Open a pull request
8. Respond to agent and human feedback
9. Detect and remediate build failures
10. Escalate to a human only when judgment is required
11. Merge the change

This level of autonomy depends on heavy investment in repository structure, tooling, and feedback loops. It does not generalize without similar investment.

---

## 10. Technology Selection Principles for Agent-First Development

When agents are the primary code authors, technology choices should optimize for agent comprehension:

- **Favor "boring" technologies.** Composable, API-stable, well-represented in training data. These are easier for agents to model correctly.
- **Prefer in-repo implementations over opaque dependencies.** When a library's behavior is unpredictable or poorly documented, it may be cheaper to have the agent reimplement the needed subset with full test coverage.
- **Make everything inspectable.** Pull configuration, schemas, and behavior descriptions into forms the agent can read, validate, and modify.
- **Treat documentation as code.** Version it, lint it, enforce freshness mechanically.

---

## 11. Implementation Checklist for Engineering Teams

**Week 1: Foundation**
- [ ] Create ARCHITECTURE.md following matklad's pattern (bird's-eye overview, codemap, invariants, boundaries)
- [ ] Create AGENTS.md or CLAUDE.md as a short table of contents (~100 lines) pointing to deeper docs
- [ ] Establish `docs/` directory structure with design docs, product specs, and references
- [ ] Define and document the architectural layer model with dependency rules

**Week 2: Enforcement**
- [ ] Write custom linters for dependency direction validation
- [ ] Write structural tests for naming conventions, file size limits, and boundary validation
- [ ] Ensure lint error messages contain remediation instructions (they become agent prompts)
- [ ] Set up CI to validate the knowledge base (cross-links, freshness, structure)

**Week 3: Plans and Workflow**
- [ ] Author a PLANS.md (ExecPlan template) and check it into the repository
- [ ] Create your first ExecPlan for a real feature
- [ ] Establish the exec-plans directory structure (active, completed, tech-debt-tracker)
- [ ] Define quality scoring per domain and architectural layer

**Week 4: Legibility and Automation**
- [ ] Make the application bootable per worktree for agent isolation
- [ ] Wire observability (logs, metrics) into a form agents can query
- [ ] Set up agent-to-agent review workflow
- [ ] Create recurring "doc-gardening" and "garbage collection" agent tasks
- [ ] Establish golden principles document and automated deviation scanning

**Ongoing**
- [ ] Capture every human review comment as a documentation update or tooling change
- [ ] Promote recurring documentation gaps into mechanical enforcement (lints, tests)
- [ ] Run quality scoring on a regular cadence
- [ ] Maintain the ARCHITECTURE.md (revisit 2-4 times per year)

---

*Sources: OpenAI Harness Engineering (openai.com/index/harness-engineering), matklad ARCHITECTURE.md (matklad.github.io/2021/02/06/ARCHITECTURE.md.html), Codex Execution Plans (developers.openai.com/cookbook/articles/codex_exec_plans)*
