# Create Development Story

**Task Type**: Planning Task
**Agent Types**: BMAD Master, Planning Agents
**Complexity**: Medium

## Purpose

Create a comprehensive development story with full context for autonomous implementation.

## Prerequisites

- [ ] Epic exists with story identified
- [ ] User story and business value defined
- [ ] Technical approach understood
- [ ] `ARCHITECTURE.md` reviewed for relevant guidance

## Task Instructions

### Step 1: Gather Story Context

Elicit from user:
1. **Epic Name**: Which epic does this story belong to?
2. **User Story**: What user value are we delivering?
3. **Priority**: High / Medium / Low
4. **Business Context**: Why is this story important?

### Step 2: Extract Technical Context

From `ARCHITECTURE.md` and codebase, gather:
- Relevant module(s) affected
- Existing code patterns to follow
- Integration points and dependencies
- Config changes needed

### Step 3: Define Implementation Details

- Files to create or modify (with real paths)
- Function signatures
- Data flow changes
- Configuration changes

### Step 4: Create Story File

Use `templates/story-template.yaml` to create a complete story.
Include YAML frontmatter (`---` fences) with routing metadata before the markdown body:
- `id`, `epic`, `specialist`, `status`, `scope`, `depends_on`

Then include all sections:
1. Story Header (bold metadata for human readability)
2. User Story (As a / I want / So that)
3. Acceptance Criteria (Given-When-Then)
4. Technical Context (architecture references)
5. Implementation Guidance (specific file changes)
6. Testing Requirements (patterns, edge cases)
7. Definition of Done (quality gates)

### Step 5: Validate Completeness

- [ ] A dev agent can implement autonomously using only the story file
- [ ] Acceptance criteria are specific and testable
- [ ] Technical context includes real file paths
- [ ] Testing requirements cover edge cases

### Step 6: Save Story File

Save to: `bmad/epics/{epic-name}/stories/story-{prefix}-{number}-{slug}.md`

## Anti-Patterns

- **Vague**: "Handle data better" → **Specific**: "Cache fetched data to disk, serve from cache on repeat loads"
- **Missing files**: No mention of which files change → List every file with description
- **Untestable criteria**: "Should be faster" → "Given cached data, when same range requested, no API calls made"
