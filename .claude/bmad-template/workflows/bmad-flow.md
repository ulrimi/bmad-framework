# BMAD Process Flow

This adapts the BMAD orchestration framework for **{{PROJECT_NAME}}**. The BMAD Master coordinates specialist agent workstreams through a structured epic → story → implementation lifecycle.

## BMAD Master Coordination Protocol

### Specialist Agent Delegation

| Agent | Focus Area |
|-------|------------|
<!-- TODO: Replace with your active specialists. Example:
| **Backend Specialist** | API design, business logic, data access |
| **Frontend Specialist** | UI components, state management, UX |
| **Data Specialist** | Pipelines, storage, schema design |
Run /configure to auto-populate from your specialist stubs. -->
| **QA & Testing** | Testing, validation, edge cases, correctness |

> Edit `bmad/config/agents/active/` to match your project's specialist roles.

### Master Orchestration Responsibilities

1. **Master Todo Management**: Maintain dependency-aware todos across all workstreams
2. **Task Coordination**: Sequence stories in correct dependency order
3. **Knowledge Integration**: Fuse outputs from specialists into cohesive delivery
4. **Quality Gate Enforcement**: Enforce testing and linting guardrails
5. **Epic Organization**: Maintain epic/story structure in `bmad/epics/`

### Epic Directory Structure

```
bmad/epics/[epic-name]/
├── epic-overview.md
└── stories/
    ├── story-[prefix]-001-[name].md
    ├── story-[prefix]-002-[name].md
    └── ...
```

---

## The BMAD Development Lifecycle

### Phase 1: Research & Analysis

- What problem are we solving?
- How does it fit with `ARCHITECTURE.md` plans?
- Which modules are affected?
- What are the data/performance implications?

**Output**: Research notes, technical analysis

### Phase 2: Epic Creation

- Define scope and story breakdown
- Identify dependencies between stories
- Store in `bmad/epics/[epic-name]/`

**Output**: `epic-overview.md` with story list

### Phase 3: Story Creation

- User story (As a / I want / So that)
- Acceptance criteria (Given-When-Then)
- Technical context with real file paths
- Testing requirements

**Output**: Story files using templates

### Phase 4: Refinement

- Specialist review of stories
- Gap identification
- Story updates with technical details

### Phase 5: Implementation

- Follow story specifications
- Write tests alongside code
- Follow existing patterns

### Phase 6: Testing & Validation

- Run full test suite
- Lint check
- Verify app/service still launches
- Validate acceptance criteria

---

## Phase 0: Mandatory Pre-Flight

**Before starting any development work:**

```bash
# 1. Environment setup
<!-- TODO: e.g., source venv/bin/activate && pip install -r requirements.txt -->

# 2. Existing tests pass
{{TEST_COMMAND}}

# 3. Linting clean
{{LINT_COMMAND}}
```

**STOP if any pre-flight step fails.**

---

## Post-Work Verification

**After completing any development work:**

```bash
# 1. All tests pass
{{TEST_COMMAND}}

# 2. Linting clean
{{LINT_COMMAND}}

# 3. App/service still launches
{{APP_LAUNCH_COMMAND}}
```

---

## Recovery Protocol

```bash
# 1. Assess damage
git status
{{TEST_COMMAND}} --maxfail=3

# 2. Recovery options
git checkout -- <file>           # Revert specific file
git reset --hard HEAD            # Reset to last commit
git checkout -b recovery/$(date +%Y%m%d)  # Save current state

# 3. Post-recovery verification
{{TEST_COMMAND}}
{{LINT_COMMAND}}
{{APP_LAUNCH_COMMAND}}
```

---

## Quality Assurance Checklist

**Pre-Work:**
- [ ] Environment activated
- [ ] Dependencies installed
- [ ] App/service launches
- [ ] Tests pass
- [ ] Linting clean

**Post-Work:**
- [ ] All tests pass
- [ ] Linting clean
- [ ] App/service launches
- [ ] Story updated with dev notes
