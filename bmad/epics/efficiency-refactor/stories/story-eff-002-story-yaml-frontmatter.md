---
id: eff-002
epic: efficiency-refactor
specialist: backend
status: ✅ Complete
scope: [.claude/bmad-template/templates/, .claude/commands/implement.md, .claude/commands/story.md]
depends_on: [eff-001]
---

# Story: Story YAML Frontmatter for Routing

**Story ID**: EFF-002
**Epic**: efficiency-refactor
**Priority**: High
**Estimated Effort**: Small
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: backend-specialist
**Created**: 2026-03-20

## User Story

**As a** BMAD orchestrator
**I want** stories to carry lean YAML frontmatter with routing metadata
**So that** I can determine specialist, status, and dependencies without loading the full story body

## Business Context

**Problem Statement**: Currently, the orchestrator must read entire story files (100-200+ lines each) to determine routing decisions — which specialist, what status, what dependencies. For an epic with 10 stories, this means loading 1,000-2,000+ lines just to build a queue.

**Business Value**: Frontmatter allows queue building with ~10 lines per story instead of 100-200, reducing routing overhead by ~90%.

## Acceptance Criteria

### AC1: Story template includes frontmatter
- **Given** the story template at `.claude/bmad-template/templates/story-template.yaml`
- **When** the refactor is complete
- **Then** the template's output includes a YAML frontmatter block (`---` fences) with fields: `id`, `epic`, `specialist`, `status`, `scope`, `depends_on`

### AC2: Implement index uses frontmatter for routing
- **Given** a story file with YAML frontmatter containing `status: 📋 Ready` and `specialist: backend`
- **When** `/implement` builds the story queue
- **Then** it extracts status and specialist from frontmatter without loading the full story body

### AC3: Backward compatibility
- **Given** an existing story file using only bold metadata (no YAML frontmatter)
- **When** `/implement` processes it
- **Then** it falls back to parsing bold metadata lines (`**Status**:`, `**Assigned to**:`, etc.)

### AC4: Story creation produces frontmatter
- **Given** a user runs `/story create`
- **When** the story file is generated
- **Then** it contains both YAML frontmatter (for machine parsing) and the traditional bold metadata section (for human readability)

## Technical Context

**Current Story Header Format** (bold metadata only):
```markdown
# Story: Brief Title

**Story ID**: epic-name-001
**Epic**: epic-name
**Priority**: Medium
**Status**: 📋 Ready
**Assigned to**: backend-specialist
```

**New Format** (frontmatter + bold metadata):
```markdown
---
id: epic-name-001
epic: epic-name
specialist: backend
status: 📋 Ready
scope: [src/api/, src/models/]
depends_on: []
---

# Story: Brief Title

**Story ID**: epic-name-001
**Epic**: epic-name
**Priority**: Medium
**Status**: 📋 Ready
**Assigned to**: backend-specialist
```

**Files to Modify**:
- `.claude/bmad-template/templates/story-template.yaml` — add frontmatter to output section
- `.claude/commands/implement.md` — update queue builder to parse frontmatter first
- `.claude/commands/story.md` — update story creation to emit frontmatter
- `.claude/bmad-template/tasks/create-story.md` — update task instructions

## Implementation Guidance

### Step 1: Update story template
Add frontmatter block to the output section of `story-template.yaml`. Fields should map from template variables.

### Step 2: Update implement index
In the queue-building logic of `implement.md` (or its index after EFF-001), add frontmatter parsing that:
1. Reads first 10 lines of each story file
2. If `---` fence detected, parses YAML frontmatter for status/specialist/depends_on
3. If no fence, falls back to bold metadata parsing

### Step 3: Update story command
Ensure `/story create` populates frontmatter from provided arguments.

### Step 4: Update existing stories in this epic
Add frontmatter to all EFF-* story files (dogfooding).

## Testing Requirements

- Verify frontmatter is correctly produced by story template
- Verify implement index correctly parses frontmatter
- Verify fallback to bold metadata works for legacy stories
- Verify frontmatter `status` field is updated when story status changes (Phase 9)

## Definition of Done

- [x] Story template produces YAML frontmatter
- [x] `/implement` queue builder parses frontmatter
- [x] Fallback to bold metadata works for legacy stories
- [x] `/story create` produces frontmatter
- [x] All stories in this epic updated with frontmatter (dogfooding)

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/bmad-template/templates/story-template.yaml` - Added frontmatter block to header section, added specialist_domain variable
- `.claude/commands/implement.md` - Updated queue builder with frontmatter-first parsing instructions
- `.claude/commands/story.md` - Added frontmatter emission instructions for create mode
- `.claude/bmad-template/tasks/create-story.md` - Added frontmatter mention to task instructions
- `.claude/commands/implement/phase-9-completion.md` - Added frontmatter status update to completion phase

### Simplification Results
- Files reviewed: 5
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total
- Fixed: 0

### Notes
- All 7 EFF-* stories already had frontmatter (dogfooding was pre-done during epic creation)
- Frontmatter fields: id, epic, specialist, status, scope, depends_on
- Backward compatibility: fallback to bold metadata parsing when no frontmatter present
