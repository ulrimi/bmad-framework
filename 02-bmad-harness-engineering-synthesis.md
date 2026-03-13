# BMAD × Harness Engineering: Synthesis and Integration Guide

*Applying OpenAI's Harness Engineering principles, ARCHITECTURE.md patterns, and Codex ExecPlans to the Breakthrough Method of Agile AI-Driven Development (BMAD) framework.*

---

## 1. Why This Synthesis Matters

BMAD already solves several of the problems that OpenAI's harness engineering team discovered from scratch: story-driven decomposition, specialist agent personas, quality gates, and worktree-based parallel development. But the harness engineering findings reveal additional leverage points — particularly around repository knowledge architecture, mechanical enforcement, execution plans, application legibility, and continuous entropy management — that can push BMAD from a disciplined agent workflow into a fully autonomous development pipeline.

This document maps each harness engineering concept to its BMAD equivalent, identifies gaps, and provides concrete actions to close them.

---

## 2. Alignment Map: What BMAD Already Has

| Harness Engineering Concept | BMAD Equivalent | Status |
|---|---|---|
| Story-driven decomposition | `/epic` → `/story` → `/implement` lifecycle | Strong |
| Specialist agent personas | `bmad/qf-bmad/agents/active/` specialist stubs | Strong |
| Quality gates before merge | Pre-work and post-work checklists, Phase 7 (simplification) and Phase 8 (CodeRabbit review) | Strong |
| Worktree-based parallelism | `claude-feature` with HITL, Yolo, and Ralph modes | Strong |
| Agent instructions file | CLAUDE.md (global + project-level) | Present, expandable |
| Architecture documentation | ARCHITECTURE.md (optional, recommended after bootstrap) | Present, under-specified |
| Acceptance criteria as behavior | Given-When-Then format in story templates | Strong |
| 10-phase implementation cycle | `/implement` command with Phases 1-11 | Strong |
| Autonomous merge loop | Ralph mode (`claude-feature --ralph`) | Present |

BMAD's core loop — epic → story → implement — is fundamentally sound and maps directly to the harness engineering philosophy of "humans steer, agents execute." The story file functions as a self-contained context vehicle, which is the same principle behind ExecPlans.

---

## 3. Gap Analysis: What to Add

### Gap 1: Repository Knowledge Architecture

**Current state:** BMAD's CLAUDE.md is a project-level instruction file. It holds commands, style mandates, and test/lint/launch commands. The `bmad/` directory stores epics, stories, and agent configs. But there is no structured `docs/` knowledge base with progressive disclosure.

**What's missing:**
- A `docs/` directory treated as the system of record with indexed design docs, product specs, and references
- Quality scoring per domain and architectural layer
- Generated documentation (e.g., auto-generated schema docs, API docs)
- Reference materials for external libraries and design systems (the `references/` directory pattern with `*-llms.txt` files)
- A core-beliefs document defining agent-first operating principles

**Action: Add a `docs/` knowledge layer to the BMAD project scaffold.**

Modify `init-bmad` to optionally scaffold:

```
your-project/
├── CLAUDE.md                       ← Table of contents (~100 lines)
├── ARCHITECTURE.md                 ← High-level system map (promoted from optional to recommended)
├── bmad/
│   ├── qf-bmad/                    ← Existing BMAD config
│   └── epics/                      ← Existing epic/story storage
└── docs/                           ← NEW: Repository knowledge base
    ├── design-docs/
    │   ├── index.md
    │   └── core-beliefs.md         ← Agent-first operating principles
    ├── exec-plans/
    │   ├── active/
    │   ├── completed/
    │   └── tech-debt-tracker.md
    ├── product-specs/
    │   ├── index.md
    │   └── ...
    ├── references/                  ← LLM-friendly reference docs for key dependencies
    ├── generated/                   ← Auto-generated docs (schema, API, etc.)
    ├── QUALITY_SCORE.md             ← Quality grades per domain and layer
    └── RELIABILITY.md               ← Reliability requirements and SLOs
```

CLAUDE.md becomes the table of contents — short, stable, pointing to deeper sources. The current content of CLAUDE.md (style mandates, commands, test/lint/launch) stays, but is restructured as a map rather than an instruction manual.

### Gap 2: ARCHITECTURE.md as a First-Class Artifact

**Current state:** BMAD recommends creating ARCHITECTURE.md after bootstrap but does not scaffold it or provide a template. It is listed as "optional" in the post-bootstrap steps.

**What's missing:**
- A template that encodes matklad's ARCHITECTURE.md principles (bird's-eye overview, codemap, invariants, boundaries, cross-cutting concerns)
- Guidance on naming entities for symbol search rather than linking to line numbers
- Guidance on calling out architectural invariants, especially those expressed as absences
- Mechanical validation that ARCHITECTURE.md stays current

**Action: Create an ARCHITECTURE.md template and make it a standard part of `init-bmad`.**

Template structure:

```markdown
# Architecture of [Project Name]

## Overview
[2-3 sentences: What problem does this system solve? What are the key user-facing behaviors?]

## Codemap

### [Domain/Module 1]
[What it does, key files/types by name (not link), relationship to other modules]

### [Domain/Module 2]
...

## Architectural Invariants
[Rules expressed as constraints, especially absences:
- "The data layer never imports from the UI layer"
- "All external data is validated at the boundary before entering the service layer"
- "No module depends on concrete implementations of cross-cutting concerns; all access is through the Providers interface"]

## Layer Boundaries
[Describe the dependency direction and what each layer boundary implies]

## Cross-Cutting Concerns
[Auth, logging, telemetry, feature flags, error handling — how they're accessed and constrained]
```

### Gap 3: Mechanical Architecture Enforcement

**Current state:** BMAD enforces quality through checklists (pre-work, post-work), CodeRabbit review, and simplification passes. But these are behavioral — they rely on the agent following the checklist faithfully. There is no mechanical enforcement of architectural invariants.

**What's missing:**
- Custom linters that validate dependency direction between architectural layers
- Structural tests that enforce naming conventions, file size limits, and boundary validation
- Lint error messages written as agent-comprehensible remediation instructions
- CI jobs that validate the knowledge base (docs freshness, cross-links, structure)

**Action: Add a "mechanical enforcement" phase to the BMAD lifecycle.**

This integrates at two levels:

**Project bootstrap (`init-bmad`):** Scaffold a `lints/` or `tools/` directory with starter linter configurations based on the chosen stack. For Python projects, this could include custom ruff rules or standalone lint scripts. For TypeScript, custom ESLint rules.

**Implementation cycle (new Phase 6.5 or enhancement to Phase 6):** After linting, run structural validation:

```yaml
6.5 Structural Validation:
    Run architectural enforcement checks:
    - Dependency direction validation (no backward imports)
    - Naming convention compliance
    - File size limit checks
    - Boundary validation (data shapes parsed at entry points)

    If violations found:
    - Fix violations before proceeding
    - If fix requires architectural discussion, log to Decision Log and flag for human review
```

**Lint message design principle:** Every custom lint failure message should contain the rule being violated, why it matters, and what to do instead. The failure message *is* the agent's prompt.

### Gap 4: Execution Plans (ExecPlans) for Complex Work

**Current state:** BMAD uses stories as the primary context vehicle. Stories are well-structured with acceptance criteria, technical context, and testing requirements. But they are scoped to individual features — there is no mechanism for multi-hour, multi-story design documents that guide an agent through complex research, prototyping, and implementation.

**What's missing:**
- A PLANS.md specification for complex, multi-story work
- Living document sections: Progress (with timestamps), Surprises & Discoveries, Decision Log, Outcomes & Retrospective
- Prototyping milestones that de-risk larger changes
- The discipline of embedding all required knowledge directly in the plan (no pointing to external docs)

**Action: Add ExecPlans as a complement to stories for complex work.**

ExecPlans and stories serve different purposes and should coexist:

| Artifact | Scope | Duration | Use When |
|---|---|---|---|
| Story | Single feature or change | Hours | Well-understood work with clear acceptance criteria |
| ExecPlan | Multi-story initiative or complex research | Hours to days | Significant unknowns, architectural changes, multi-phase migrations |

**Integration points:**

1. **New command: `/plan <name>`** — Creates an ExecPlan in `docs/exec-plans/active/` following the PLANS.md template. The plan may reference stories it will generate or implement.

2. **Epic-level ExecPlans:** For complex epics, create an ExecPlan before decomposing into stories. The plan captures the design rationale, prototyping results, and architectural decisions that inform story creation.

3. **Living document discipline:** Add the four mandatory sections (Progress, Surprises & Discoveries, Decision Log, Outcomes & Retrospective) to the ExecPlan template. Require agents to update these at every stopping point.

4. **Self-containment rule:** Every ExecPlan must be implementable by an agent with no prior context — only the working tree and the plan itself. This mirrors the story template's principle of "contains all context needed for autonomous implementation."

### Gap 5: Application Legibility for Agents

**Current state:** BMAD's `/implement` cycle validates through test execution and linting. The agent runs tests and checks lint, but does not interact with the running application directly (no UI driving, no observability queries, no runtime behavior validation).

**What's missing:**
- Per-worktree application instances that agents can launch and drive
- Agent-accessible observability (logs, metrics, traces)
- Browser/UI automation for validating user-facing behavior
- Skills for working with DOM snapshots, screenshots, and navigation

**Action: Add application-driving capabilities to the BMAD specialist agents.**

This is stack-dependent and should be wired per-project rather than at the framework level. But BMAD can provide the scaffolding:

**New specialist capability block (in specialist agent templates):**

```yaml
application_driving:
  launch_command: "{{APP_LAUNCH_COMMAND}}"
  health_check: "curl -s http://localhost:{{PORT}}/health"
  ui_validation:
    enabled: false  # Set true for frontend projects
    tool: "playwright"  # or puppeteer, cypress
    screenshot_dir: "tests/screenshots/"
  observability:
    enabled: false  # Set true when observability stack exists
    log_query: "{{LOG_QUERY_COMMAND}}"
    metrics_query: "{{METRICS_QUERY_COMMAND}}"
```

**Enhanced acceptance criteria in stories:** For user-facing stories, acceptance criteria should include observable runtime behavior, not just test passage:

```markdown
## Acceptance Criteria
- Given the server is running, when I navigate to /dashboard, then the page loads in under 2 seconds
- Given I submit the form with valid data, when the response returns, then I see a success message and the data appears in the list
```

### Gap 6: Agent-to-Agent Review and the Autonomous Loop

**Current state:** BMAD has CodeRabbit review (Phase 8) and the Ralph mode for autonomous execution. But the full agent-to-agent review loop — where agents request reviews from other agents, respond to feedback, and iterate until satisfied — is not formalized.

**What's missing:**
- Multi-agent review workflow where different specialist agents review from their domain perspective
- Feedback-response loop where the implementing agent addresses review comments and re-submits
- Escalation rules for when to involve a human vs. letting agents resolve

**Action: Enhance the Ralph loop with structured agent review.**

Extend Phase 8 to support multi-agent review:

```yaml
8.0 Agent Review Orchestration:
    For each specialist domain touched by this story:
      1. Run domain-specific review (e.g., security specialist reviews auth changes)
      2. Run general CodeRabbit review
      3. Collect all findings
      4. Address findings in priority order
      5. Re-run reviews if >10 lines changed
      6. Maximum 3 review cycles

    Escalation criteria:
      - Conflicting review guidance → escalate to human
      - Architectural boundary violation that requires design discussion → escalate
      - Security-critical finding with unclear remediation → escalate
      - All other findings → resolve autonomously
```

For Claude specifically, this can leverage subagents: spawn a review agent with the specialist persona loaded, have it review the diff, and pipe findings back to the implementing agent.

### Gap 7: Continuous Entropy Management

**Current state:** BMAD has Phase 7 (simplification) which applies the Boy Scout Rule on each implementation. But there is no recurring, repository-wide cleanup process — no background agents scanning for pattern drift, no quality scoring over time, no "doc-gardening" tasks.

**What's missing:**
- Recurring background tasks that scan for architectural drift and pattern inconsistency
- Quality scoring per domain that tracks gaps over time
- "Doc-gardening" agent that checks documentation freshness against actual code behavior
- Golden principles document that defines what "good" looks like, enforced continuously

**Action: Add a maintenance layer to BMAD.**

**New command: `/maintain`** — Runs a suite of maintenance tasks:

```yaml
Maintenance Tasks:
  1. Quality Scoring:
     - Score each domain/module against QUALITY_SCORE.md criteria
     - Compare against previous scores
     - Flag regressions

  2. Pattern Consistency:
     - Scan for duplicated utility patterns that should be centralized
     - Identify hand-rolled helpers that could use shared packages
     - Flag boundary violations where data shapes are probed without validation

  3. Documentation Freshness:
     - Compare docs/ content against actual code behavior
     - Flag stale references to files or functions that no longer exist
     - Check ARCHITECTURE.md accuracy against current module structure

  4. Tech Debt Assessment:
     - Update docs/exec-plans/tech-debt-tracker.md
     - Prioritize items by impact and effort
     - Open targeted refactoring stories for high-priority items
```

This can be run manually via `/maintain` or scheduled as a recurring Ralph task (weekly or per-sprint).

---

## 4. Enhanced BMAD Lifecycle with Harness Engineering

The integrated lifecycle adds three new phases to the existing BMAD flow:

```
Phase 0: Pre-Flight (existing)
  ↓
Phase 0.5: Context Verification (NEW)
  - Verify ARCHITECTURE.md is current
  - Verify CLAUDE.md pointers are valid
  - Check quality scores for target domain
  ↓
Phase 1-3: Context Loading, Exploration, Planning (existing)
  ↓
Phase 3.5: ExecPlan Creation (NEW, for complex work)
  - If story is part of a complex epic with significant unknowns
  - Create ExecPlan with prototyping milestones
  - Validate approach before full implementation
  ↓
Phase 4-6: Implementation, Testing, Validation (existing)
  ↓
Phase 6.5: Structural Validation (NEW)
  - Dependency direction checks
  - Naming convention enforcement
  - Boundary validation
  - File size limits
  ↓
Phase 7-8: Simplification, CodeRabbit Review (existing, enhanced with multi-agent review)
  ↓
Phase 9-11: Commit, Story Completion, PR (existing)
  ↓
Phase 12: Knowledge Update (NEW)
  - Update docs if architectural decisions were made
  - Log discoveries to Decision Log
  - Update quality scores if domain improved
```

---

## 5. BMAD Template Modifications

### 5.1 Enhanced `init-bmad` Scaffold

Add these to the project scaffold (can be opt-in via `--full` flag):

```
your-project/
├── CLAUDE.md                          ← Restructured as table of contents
├── ARCHITECTURE.md                    ← NEW: Template from matklad's pattern
├── bmad/
│   ├── qf-bmad/
│   │   ├── core-config.yaml
│   │   ├── agents/
│   │   ├── workflows/
│   │   ├── tasks/
│   │   ├── templates/
│   │   │   ├── epic-template.md
│   │   │   ├── story-template.yaml
│   │   │   ├── exec-plan-template.md  ← NEW
│   │   │   └── architecture-template.md ← NEW
│   │   ├── checklists/
│   │   └── golden-principles.md       ← NEW: Taste invariants for this project
│   └── epics/
├── docs/                              ← NEW
│   ├── design-docs/
│   │   ├── index.md
│   │   └── core-beliefs.md
│   ├── exec-plans/
│   │   ├── active/
│   │   ├── completed/
│   │   └── tech-debt-tracker.md
│   ├── product-specs/
│   ├── references/
│   ├── generated/
│   └── QUALITY_SCORE.md
└── lints/                             ← NEW: Custom structural validation
    └── README.md                      ← Describes how to add project-specific lints
```

### 5.2 New Commands

| Command | Purpose |
|---|---|
| `/plan <name>` | Create an ExecPlan for complex, multi-story work |
| `/maintain` | Run repository-wide quality, consistency, and documentation checks |
| `/score` | Display quality scores per domain and flag regressions |
| `/garden` | Run documentation freshness checks and open fix-up PRs |

### 5.3 Enhanced Story Template

Add these optional sections to the story template for stories that touch user-facing behavior:

```yaml
runtime_validation:
  launch_command: "{{APP_LAUNCH_COMMAND}}"
  acceptance_checks:
    - description: "Health endpoint returns 200"
      command: "curl -s -o /dev/null -w '%{http_code}' http://localhost:{{PORT}}/health"
      expected: "200"
    - description: "Dashboard loads under 2s"
      command: "curl -s -o /dev/null -w '%{time_total}' http://localhost:{{PORT}}/dashboard"
      expected: "< 2.0"
```

---

## 6. Implementation Priority

These changes range from quick wins to significant infrastructure. Prioritized by leverage:

### Tier 1: High Leverage, Low Effort (Do This Week)

1. **Create ARCHITECTURE.md template** and add to `init-bmad` scaffold. Make it recommended rather than optional.
2. **Create golden-principles.md template** — a short document of 10-15 opinionated rules about code quality for this project. Reference it from CLAUDE.md.
3. **Restructure CLAUDE.md** to be a table of contents pointing to deeper docs, rather than an instruction manual.
4. **Add living-document sections** (Progress, Surprises, Decision Log, Retrospective) to the epic-overview template for complex epics.

### Tier 2: Medium Leverage, Medium Effort (Do This Sprint)

5. **Create ExecPlan template** (`exec-plan-template.md`) based on the PLANS.md specification. Add `/plan` command.
6. **Add `docs/` directory** to the `init-bmad` scaffold with the knowledge base structure.
7. **Enhance Phase 6** with structural validation hooks that projects can customize.
8. **Add QUALITY_SCORE.md** template and `/score` command.

### Tier 3: High Leverage, High Effort (Do This Quarter)

9. **Build the `/maintain` command** with pattern scanning, doc freshness, and tech debt tracking.
10. **Add multi-agent review** to the Ralph loop — specialist agents reviewing from their domain perspective.
11. **Create application-driving skills** per stack (Python/FastAPI, TypeScript/Next.js, etc.) so agents can validate runtime behavior.
12. **Build custom lint scaffolding** per stack with dependency direction validation and agent-friendly error messages.

---

## 7. Philosophical Alignment

BMAD and harness engineering share a deep structural alignment that makes this synthesis natural:

**Both treat stories/plans as self-contained context vehicles.** BMAD's story files are designed so a dev agent can implement autonomously. ExecPlans extend this to multi-hour, complex work. The principle is identical: the document must contain everything a stateless agent needs.

**Both encode quality as mechanical enforcement, not aspirational documentation.** BMAD's Phase 7 (simplification) and Phase 8 (CodeRabbit) are automated quality gates. Harness engineering extends this with custom linters, structural tests, and recurring maintenance. The direction is the same — capture human taste once, enforce it everywhere.

**Both use worktree isolation for parallel agent work.** BMAD's `claude-feature` and the harness engineering team's per-worktree application instances serve the same purpose: let agents work in isolation without interfering with each other or the main branch.

**Both recognize that the engineer's job is designing the environment, not writing the code.** BMAD's specialist agents, workflows, and templates *are* the environment. Harness engineering's repository knowledge architecture, custom linters, and observability integration *are* the environment. The code is output. The scaffolding is the product.

The key difference: harness engineering emphasizes that the repository is the *only* context that exists for the agent. BMAD can strengthen this by pushing more project knowledge into versioned, in-repo artifacts and building the mechanical enforcement that ensures those artifacts stay accurate.

---

*Sources: OpenAI Harness Engineering (openai.com/index/harness-engineering), matklad ARCHITECTURE.md (matklad.github.io/2021/02/06/ARCHITECTURE.md.html), Codex Execution Plans (developers.openai.com/cookbook/articles/codex_exec_plans), BMAD Framework (github.com/ulrimi/bmad-framework)*
