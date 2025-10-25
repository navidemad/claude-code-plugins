---
name: plan
description: Generate core or expansion PRDs with automatic context loading using "land then expand" approach. Activates when user says create PRD, plan feature, document requirements, write spec. French: créer un PRD, planifier une fonctionnalité, rédiger les exigences.
---

# Plan Feature Implementation

Create structured PRDs using the **"land then expand"** approach with automatic context management for consistency.

**Communication Style**: In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Philosophy: Land Then Expand

Modern Claude models work best when they establish patterns first, then layer complexity. This skill creates:

1. **Core PRDs**: Minimal foundation with essential fields only (2-4 substories max)
2. **Expansion PRDs**: Focused enhancements building on completed core with auto-loaded context

**Why**: Large comprehensive PRDs lead to incorrect assumptions, token inefficiency, and inconsistent results.

## Activation Context

Use when user requests:
- PRD creation for new features
- Feature planning and documentation
- Requirements gathering
- Implementation roadmap
- French: création de PRD, planification de fonctionnalité, spécification

## Workflow

### Phase 0: Validate Prerequisites

**FIRST: Check for CLAUDE.md**

```bash
if [[ ! -f "CLAUDE.md" ]]; then
    cat <<EOF
❌ ERROR: CLAUDE.md file not found in project root

This workflow requires a CLAUDE.md file documenting your project conventions.

To create one, start a new Claude Code session and type:
  /init

Then describe your project, and Claude will help create CLAUDE.md.

Learn more: https://github.com/yespark/yespark-claude-plugins#claude-md

Exiting...
EOF
    exit 1
fi
```

**Show confirmation:**
```
✅ CLAUDE.md found
📋 Ready to plan PRD
```

### Phase 1: Determine PRD Type and Load Context

**Step 1: Ask PRD Type**

**CRITICAL**: Ask user to determine the PRD type:

```
Is this:
1. 🌱 A new core feature (minimal foundation to establish patterns)
2. 🔧 An expansion of existing feature (builds on completed core)
3. ⚡ A task-based change (infrastructure, migration, optimization, refactor, etc.)

Choose [1/2/3]:
```

**If user chooses "1 - Core Feature":**
- Create minimal foundation PRD
- Max 2-4 substories in single phase
- Essential fields only
- File: `docs/prds/YYYY-MM-DD-{feature}-core.md`
- Goal: Establish patterns and working code, NOT completeness
- Initialize context: `.claude/context/YYYY-MM-DD-{feature}-core.json`

**If user chooses "2 - Expansion":**
- Ask: "Which core feature does this expand?" or auto-detect from `docs/prds/`
- **AUTOMATICALLY:**
  1. Read core PRD file
  2. Load `.claude/context/{core-prd-name}.json`
  3. Extract files_created, patterns, libraries, architectural_decisions
  4. Read core implementation files
  5. Document established patterns
- Create focused expansion PRD building on core
- File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`
- Goal: Add ONE focused aspect using established patterns

**If user chooses "3 - Task-based Change":**
- Use task-oriented format instead of substories
- File: `docs/prds/YYYY-MM-DD-{task-name}-task.md`
- Format: Checklist of concrete steps instead of phases/substories
- Examples: Database migration, CI/CD setup, performance optimization, refactoring, security patch
- Goal: Complete specific technical task with clear acceptance criteria

**Step 2: Understand Feature Scope**

Ask scoping question:
```
"Describe the [core feature/expansion] briefly (1-2 sentences):"
```

**For Core PRDs - Enforce Minimalism:**
If user describes complex multi-part feature, push back:
```
🌱 Core PRD Mode: Let's start with the absolute minimum.

You described: [user's description]

What's the simplest version with just essential fields?
Example: If building invoices, start with just number, date, amount.
Everything else (customers, line items, tax) comes later as expansions.

Simplest core version:
```

**For Expansion PRDs:**
Ask specifically what this expansion adds to the core.

**Step 3: Explore Existing Codebase**

**Before asking detailed questions, understand what exists:**

```bash
# Read project conventions from CLAUDE.md in project root
# This file contains project-specific conventions, tech stack, patterns, etc.
# Example: Read CLAUDE.md
```

**For Core PRDs:**
Explore to understand project patterns and conventions from CLAUDE.md and existing codebase.

**For Expansion PRDs (CRITICAL - AUTO-LOAD):**
```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# Load core PRD context
core_context=$(read_context "$core_prd_file")

# Extract core files
core_files=$(get_core_files "$core_prd_file")

# Extract patterns
core_patterns=$(get_core_patterns "$core_prd_file")

# Read those core implementation files
for file in $core_files; do
    # Read file to understand patterns
done
```

**Document findings:**
```
🔍 Codebase Analysis:

[For Core:]
- Found similar feature: [describe what you found]
- Existing patterns: [list patterns from CLAUDE.md and codebase]
- Tech stack: [from CLAUDE.md]
- Testing approach: [from CLAUDE.md and existing tests]
- Key libraries: [from CLAUDE.md]

[For Expansion - AUTO-LOADED:]
- Core PRD: [path to core PRD]
- Core files created: [list from context]
- Established patterns: [list from context]
- Libraries in use: [list from context]
- Architectural decisions: [list from context]

Will follow these established patterns.
```

### Phase 1: Requirements Gathering

**Adapt questions based on PRD type:**

**CORE PRD MODE** - Ask minimal essential questions (5-7 questions):

**Focus on absolute essentials only:**

1. **What are the essential fields/data?** (Minimum viable data model)
2. **Who uses it?** (Target users)
3. **What's the single main user flow?** (One primary happy path only)
4. **How do we know it works?** (Basic success criteria)
5. **Any critical dependencies?** (Required features/services)
6. **What's explicitly out of scope for the core?** (Everything else becomes expansions)

**Important**: If answers suggest complexity, remind user that core is minimal and suggest moving complexity to expansions.

**EXPANSION PRD MODE** - Ask focused questions about the expansion (8-12 questions):

**Context Questions:**
1. **What does this expansion add to the core?** (Specific enhancement)
2. **Reference loaded core patterns** - Show what was auto-loaded
3. **Which patterns should we follow?** (Confirm auto-loaded patterns)

**Expansion Scope:**
4. **What new data/fields are needed?** (Additions to core data model)
5. **What user flows does this enable/enhance?** (New or modified flows)
6. **Integration points with core?** (How it connects to existing code)
7. **How do we know it works?** (Acceptance criteria)
8. **Any new dependencies?** (External services, libraries)
9. **Performance considerations?** (If applicable)
10. **Security considerations?** (Auth/validation needs)
11. **What's out of scope for this expansion?** (May become another expansion)

**Important**: Expansion PRDs should be focused on ONE aspect (e.g., customer details OR line items, not both)

### Phase 2: Document Generation

**CRITICAL**: Structure differs for core vs expansion PRDs.

#### Core PRD Structure

File: `docs/prds/YYYY-MM-DD-{feature}-core.md`

```markdown
# [Feature Name] - Core

**Type:** Core Feature
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/context/YYYY-MM-DD-{feature}-core.json`

## Overview

### Problem Statement
[Clear articulation of problem]

### Core Solution
[Minimal viable solution - essential fields/functionality ONLY]

### Users
[Target users]

### Success Criteria
- [Basic measurable criteria]

### SLC Commitment
**This PRD defines an SLC (Simple, Lovable, Complete) - *not* an MVP.** The release must feel complete, polished, and delightful even with a tight scope.

## Core Requirements

### Essential Data/Fields
[ONLY the minimum viable fields - example: invoice number, date, amount]

### Core User Flow
[Single primary happy path only]

### Out of Scope (Future Expansions)
[List everything NOT in core - these become expansion PRDs]
Examples:
- Customer details → expansion PRD
- Line items → expansion PRD
- Tax calculations → expansion PRD

## Implementation

**RULE**: Maximum ONE phase with 2-4 substories

### Phase 1: Core Foundation
**Goal:** Establish minimal working feature with essential patterns

#### Substory 1.1: [Minimal Model/Component]
**Description:** [Create basic entity with essential fields only]

**Acceptance Criteria:**
- [ ] [Essential field 1] works
- [ ] [Essential field 2] works
- [ ] Basic CRUD operations

**Status:** ⏳ Not Started

#### Substory 1.2: [Basic Interface/API]
**Description:** [Simple create/read operations]

**Acceptance Criteria:**
- [ ] Can create with essential fields
- [ ] Can retrieve

**Status:** ⏳ Not Started

[2-4 substories maximum]

## Project-Specific Notes
[Minimal project-specific details for core only - reference CLAUDE.md]

## Next Expansions
After core is complete, consider these expansion PRDs:
1. [Expansion 1 name]
2. [Expansion 2 name]
3. [Expansion 3 name]

## Context
This PRD has an associated context file at `.claude/context/YYYY-MM-DD-{feature}-core.json` which tracks:
- Architectural decisions
- Patterns established
- Libraries chosen
- Files created

This context is automatically loaded when creating expansion PRDs.
```

#### Expansion PRD Structure

File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

```markdown
# [Feature Name] - [Expansion Name]

**Type:** Expansion
**Builds On:** [Link to core PRD: docs/prds/YYYY-MM-DD-{feature}-core.md]
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/context/YYYY-MM-DD-{feature}-{expansion}.json` (inherits from core)

## Overview

### What This Expansion Adds
[Specific enhancement to core]

### Core Implementation Reference (AUTO-LOADED)

**Core PRD:** `docs/prds/YYYY-MM-DD-{feature}-core.md`

**Files created in core:**
[AUTO-POPULATED from context file - actual file paths from your project]

**Patterns established in core:**
[AUTO-POPULATED from context file - actual patterns used in your codebase]

**Libraries in use:**
[AUTO-POPULATED from context file - actual libraries chosen during core implementation]

**Architectural decisions:**
[AUTO-POPULATED from context file - actual decisions made during core implementation]

### Success Criteria
- [Measurable criteria for this expansion]

### SLC Commitment
**This PRD defines an SLC (Simple, Lovable, Complete) - *not* an MVP.** The release must feel complete, polished, and delightful even with a tight scope.

## Expansion Requirements

### New Data/Fields
[What's added to the core data model]

### Enhanced/New User Flows
[How this changes or adds to core flows]

### Integration with Core
[How this connects to existing core implementation]

## Implementation

### Phase 1: [Expansion Name]
**Goal:** [Expansion objective]

#### Substory 1.1: [Enhancement 1]
**Description:** [Building on core patterns]

**Core Files to Modify:**
- [existing file from core]

**Core Patterns to Follow:**
- [reference established patterns from auto-loaded context]

**Acceptance Criteria:**
- [ ] [Criterion 1]

**Status:** ⏳ Not Started

[Add substories as needed for focused expansion]

## Testing Strategy
[Test approach following core's testing framework]

## Security Considerations
[Following core's security patterns]

## Performance Considerations
[Optimizations specific to this expansion]

## Dependencies
**Internal:**
- Requires: [Core PRD completion]

**External:**
- [New third-party services if any]

## Context
This expansion inherits context from core and adds expansion-specific context to `.claude/context/YYYY-MM-DD-{feature}-{expansion}.json`.
```

#### Task-Based PRD Structure

File: `docs/prds/YYYY-MM-DD-{task-name}-task.md`

```markdown
# [Task Name]

**Type:** Task
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/context/YYYY-MM-DD-{task-name}-task.json`

## Overview

### Problem/Goal
[Clear description of what needs to be done and why]

### Success Criteria
- [Measurable criteria for completion]

## Technical Approach

[Describe the approach, technology choices, and reasoning]

## Implementation Checklist

**Each checkbox represents a concrete step:**

### Preparation
- [ ] [Step 1: e.g., Backup database, review current config]
- [ ] [Step 2: e.g., Set up test environment]

### Execution
- [ ] [Step 3: e.g., Create migration scripts]
- [ ] [Step 4: e.g., Update configuration files]
- [ ] [Step 5: e.g., Deploy changes]

### Validation
- [ ] [Step 6: e.g., Run integration tests]
- [ ] [Step 7: e.g., Verify monitoring/alerts]
- [ ] [Step 8: e.g., Document changes]

**Status:** ⏳ Not Started

## Testing Strategy
[How to verify this task is complete]

## Rollback Plan
[How to revert if something goes wrong]

## Dependencies
**Internal:** [Other PRDs or systems affected]
**External:** [Third-party services, tools required]

## Project-Specific Notes
[Any project-specific details from CLAUDE.md]

## Context
Task-based PRDs use simplified context tracking focused on steps completed rather than phases/substories.
```

### Phase 3: Context Initialization

**After creating PRD:**

```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# Initialize context file
context_file=$(init_context "$prd_file")

# For expansions: inherit core context
if [[ "$prd_type" == "expansion" ]]; then
    # Copy core context as base
    core_context=$(read_context "$core_prd_file")
    # Add expansion-specific fields
    # Update context with expansion name
fi

# For tasks: simpler context structure
if [[ "$prd_type" == "task" ]]; then
    # Task-based context focuses on checklist completion
    # No phases/substories tracking needed
fi
```

### Phase 4: Validation and Next Steps

**After Core PRD creation:**
- Verify it's truly minimal (2-4 substories max)
- Confirm essential fields only
- Suggest expansion PRDs for excluded features
- Confirm context file created
- Output message:
```
✅ Core PRD created: docs/prds/YYYY-MM-DD-{feature}-core.md
📋 Context file: .claude/context/YYYY-MM-DD-{feature}-core.json

📋 Core includes: [brief summary]
🚫 Out of scope (future expansions): [list]

💡 Next steps:
1. "implement" - Build core foundation with auto-testing and review
2. After core is complete, use "plan" again for expansions:
   - Customer details expansion
   - Line items expansion
   - [etc]
```

**After Expansion PRD creation:**
- Verify it builds on completed core
- Confirm focused on ONE aspect
- Reference core implementation patterns
- Confirm context inherited and extended
- Output message:
```
✅ Expansion PRD created: docs/prds/YYYY-MM-DD-{feature}-{expansion}.md
📋 Context file: .claude/context/YYYY-MM-DD-{feature}-{expansion}.json

🔧 Expands: {core feature name}
📋 Adds: [brief summary]
🎯 Auto-loaded from core:
   - [X] files created
   - [Y] patterns
   - [Z] libraries
   - [W] architectural decisions

💡 Next: "implement" to build this expansion following core patterns
```

**After Task-Based PRD creation:**
- Verify checklist is concrete and actionable
- Confirm rollback plan is included
- Confirm success criteria are measurable
- Output message:
```
✅ Task PRD created: docs/prds/YYYY-MM-DD-{task-name}-task.md
📋 Context file: .claude/context/YYYY-MM-DD-{task-name}-task.json

⚡ Task: [brief summary]
📋 Steps: [X] concrete steps defined
✅ Success criteria: [brief list]
🔄 Rollback plan: Included

💡 Next: "implement" to execute this task checklist
```

## Guidelines

**Critical Rules:**
- **ALWAYS ask core vs expansion first** - This determines everything
- **For Core: Enforce minimalism** - Push back on complexity, max 2-4 substories
- **For Expansion: AUTO-LOAD core context** - Read core PRD and context file automatically
- **Initialize context files** - Always create/update `.claude/context/{prd-name}.json`
- **Naming convention**:
  - Core: `docs/prds/YYYY-MM-DD-{feature}-core.md`
  - Expansion: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

**Project Conventions:**
- Read `CLAUDE.md` from project root for project-specific conventions
- Use project-defined terminology and patterns from CLAUDE.md
- Follow tech stack, architecture, and coding standards documented in CLAUDE.md

**Context Management:**
- Create context file on PRD creation
- For expansions: inherit core context automatically
- Store: patterns, libraries, architectural decisions from CLAUDE.md and codebase
- Used by `implement` skill for consistency

**Quality Checks:**
- Ensure acceptance criteria are testable
- Document assumptions explicitly
- Reference project patterns from CLAUDE.md and existing codebase
- For expansions: explicitly reference and auto-load core implementation patterns
- Verify context files are created and populated

## Auto-Loading Core Context (Expansion Mode)

When creating an expansion PRD, the skill **automatically**:

1. **Finds core PRD** - From user selection or docs/prds/ directory
2. **Reads context file** - `.claude/context/{core-prd-name}.json`
3. **Extracts information**:
   - `files_created` - Which files were implemented
   - `patterns` - Established patterns (service objects, API structure, etc.)
   - `libraries` - Libraries chosen (Stripe, Devise, etc.)
   - `architectural_decisions` - Key design decisions
4. **Reads core files** - Loads the actual implementation files for pattern analysis
5. **Populates expansion PRD** - Auto-fills "Core Implementation Reference" section
6. **Inherits context** - Expansion context starts with core context as base

**This ensures expansions are consistent with core without manual effort.**
