# Core Beliefs

> Operating principles for agent-first development in {{PROJECT_NAME}}.
>
> **This is NOT a code style guide.** For concrete code-level rules, see
> `bmad/config/golden-principles.md`. Core beliefs define HOW the team thinks
> about development — the philosophy behind decisions, tradeoff frameworks, and
> cultural norms that guide both humans and agents.

---

## 1. Agents write the code; engineers design the environment

When an agent produces bad output, ask "what context or constraint is missing from the repo?" not "try harder." Agent quality is a function of repository knowledge architecture, not prompt engineering.

**Agent action**: Before asking for clarification, exhaust what the repo already provides — ARCHITECTURE.md, story files, golden principles, and existing patterns.

## 2. The repository is the only truth

If it's not in the repo, it doesn't exist for agents. Decisions, patterns, constraints, and conventions must be captured as versioned artifacts. Slack threads, meeting notes, and tribal knowledge have zero value to an autonomous agent.

**Agent action**: When you discover an undocumented decision or convention, flag it for documentation. Never rely on assumed context.

## 3. Mechanical enforcement over aspirational documentation

If a rule matters, express it as a linter config, test assertion, or structural check — not just a comment or document. Documents drift; automated checks don't.

**Agent action**: When implementing a new constraint, prefer adding a test or lint rule over adding a comment.

## 4. Stories are self-contained context vehicles

A story file must contain everything needed for autonomous implementation: goal, acceptance criteria, technical context, files to touch, and testing requirements. No assumed context. No "see the discussion in the PR."

**Agent action**: If a story lacks enough context to implement confidently, stop and ask rather than guessing.

## 5. Corrections are cheap; waiting is expensive

Ship and fix forward rather than blocking on perfection. This is ONLY safe when strong automated guardrails (tests, linting, review gates) catch regressions. Without guardrails, this principle is dangerous.

**Agent action**: Prefer completing a full implementation cycle (code + tests + lint) over deliberating on edge cases. Let the quality gates catch problems.

## 6. Favor boring technologies

Composable, API-stable, well-represented in LLM training data. Agents model standard libraries and popular frameworks correctly. Exotic choices cause subtle bugs that are expensive to diagnose.

**Agent action**: When choosing between approaches, prefer the one with more Stack Overflow answers and better documentation.

## 7. Capture taste once, enforce everywhere

Human review feedback is a signal that documentation is incomplete. Every review comment that says "we don't do it that way" should become a golden principle, a linter rule, or a structural test — so no human ever needs to say it again.

**Agent action**: When receiving feedback on code style or patterns, check if golden-principles.md already covers it. If not, suggest adding it.

<!-- TODO: Add project-specific beliefs below. Delete any defaults that don't apply to your team. -->
