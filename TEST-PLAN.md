# plan-prd Skill Test Plan

This document provides step-by-step testing instructions for all features of the plan-prd skill.

## About This Test Plan

This test plan was created after refactoring the skill to follow the "Progressive Disclosure" principle:
- **SKILL.md**: Lean (927 words) with critical messages and workflow structure
- **references/workflow-guide.md**: Detailed step-by-step implementation
- **references/prd-templates.md**: Complete PRD structure templates

**Key Learning**: The "bones" in SKILL.md must include user-facing messages and critical validation logic, not just references. Claude needs to see the exact error messages and prompts to display them correctly.

## Prerequisites for All Tests

Before running any tests, ensure:
1. You have a project with a `CLAUDE.md` file in the root
2. The `.claude/prds/` directory structure exists (or will be created)
3. You're in a git repository

## Test Suite

### Test 1: Phase 0 - CLAUDE.md Validation

**Feature**: Prerequisite validation before creating PRD

**Important Note**: The skill should execute the validation logic from SKILL.md Phase 0 section. The validation messages are defined IN SKILL.md (not just in workflow-guide.md) to ensure they're always shown correctly.

**Steps**:
1. Navigate to a project WITHOUT `CLAUDE.md` in root
2. Invoke the skill: "plan a new feature for user authentication"
3. Watch for the skill to attempt `Read(CLAUDE.md)`
4. When Read fails, skill should show the error message

**Expected Behavior**:
```
❌ ERROR: CLAUDE.md file not found in project root

This workflow requires a CLAUDE.md file documenting your project conventions.

To create one, start a new Claude Code session and type:
  /init

Then describe your project, and Claude will help create CLAUDE.md.

Exiting...
```

**Success Criteria**:
- ✅ Skill immediately checks for CLAUDE.md
- ✅ Clear error message displayed
- ✅ Instructions provided on how to create CLAUDE.md
- ✅ Skill exits without continuing

**Steps with CLAUDE.md**:
1. Create a `CLAUDE.md` file in project root
2. Invoke skill: "plan a new feature"

**Expected Behavior**:
```
✅ CLAUDE.md found
📋 Ready to plan PRD
```

**Success Criteria**:
- ✅ Skill confirms CLAUDE.md found
- ✅ Continues to next phase

IT IS WORKING !

---

### Test 2: Phase 1 - PRD Type Selection

**Feature**: User chooses between Core, Expansion, or Task PRD

**Steps**:
1. Have `CLAUDE.md` in project root
2. Invoke: "plan a new feature for hello world"

**Expected Behavior**:
```
Is this:
1. 🌱 A new core feature (minimal foundation to establish patterns)
2. 🔧 An expansion of existing feature (builds on completed core)
3. ⚡ A task-based change (infrastructure, migration, optimization, refactor, etc.)

Choose [1/2/3]:
```

**Success Criteria**:
- ✅ Three clear options presented
- ✅ Emojis and descriptions match
- ✅ User must choose before continuing
- ✅ No automatic assumption made

---

### Test 3a: Core PRD - Minimalism Enforcement

**Feature**: Skill enforces minimal scope for core PRDs (2-4 substories max)

**Steps**:
1. Start planning a new feature
2. Choose option "1" (Core Feature)
3. When asked to describe the feature, provide a complex description:
   "I want to build an invoice system with customers, line items, tax calculations, payment processing, email notifications, and PDF generation"

**Expected Behavior**:
```
🌱 Core PRD Mode: Let's start with the absolute minimum.

You described: invoice system with customers, line items, tax calculations, payment processing, email notifications, PDF generation

What's the simplest version with just essential fields?
Example: If building invoices, start with just number, date, amount.
Everything else (customers, line items, tax) comes later as expansions.

Simplest core version:
```

**Success Criteria**:
- ✅ Skill pushes back on complexity
- ✅ Asks for simplest version
- ✅ Provides concrete example
- ✅ Guides user to minimal scope

**Follow-up**: Provide minimal description
- "Just invoice number, date, and amount"

**Expected**:
- ✅ Skill accepts minimal scope
- ✅ Continues with 5-8 focused questions
- ✅ Generated PRD has max 2-4 substories in ONE phase

---

### Test 3b: Core PRD - Context Loading

**Feature**: Read CLAUDE.md and explore codebase before asking questions

**Steps**:
1. Start core PRD planning
2. Choose core feature
3. Provide simple description

**Expected Behavior**:
```
🔍 Context Analysis Complete:

Project Conventions (from CLAUDE.md):
- Tech stack: [framework, language, key technologies]
- Architecture: [architectural pattern from CLAUDE.md]
- Testing: [testing framework and approach]
- Code style: [linting, formatting standards]

Existing Patterns (from codebase exploration):
- Similar features found: [list related features]
- Common patterns: [list patterns observed]
- File organization: [describe structure]
- Naming conventions: [describe conventions]
```

**Success Criteria**:
- ✅ Skill reads CLAUDE.md file
- ✅ Extracts tech stack, architecture, testing info
- ✅ Explores codebase for similar features
- ✅ Documents findings before asking questions
- ✅ Shows context analysis to user

---

### Test 3c: Core PRD - Requirements Gathering

**Feature**: Ask 5-8 focused questions about minimal scope

**Steps**:
1. After context analysis
2. Continue with core PRD

**Expected Behavior**:
- Asks about problem and context (2 questions)
- Asks about minimal scope (3 questions)
- Asks about success and boundaries (2 questions)
- Asks about technical constraints (2 questions)
- Total: 5-8 questions conversationally (not rigid checklist)

**Success Criteria**:
- ✅ Questions are conversational, not a rigid form
- ✅ Between 5-8 questions total
- ✅ Questions focus on minimal scope
- ✅ If answers suggest complexity, skill pushes back
- ✅ Questions reference CLAUDE.md conventions

**Example pushback**:
If you answer with complex features:
```
💡 That sounds complex for a core PRD. Core should be minimal (2-4 substories).

You mentioned: [complex features A, B, C]

Simplest core version: [essential feature only]
Future expansions: [B], [C]

Does that work?
```

---

### Test 3d: Core PRD - Document Generation

**Feature**: Generate minimal core PRD with proper structure

**Steps**:
1. Complete requirements gathering
2. Wait for PRD generation

**Expected Behavior**:
- File created: `.claude/prds/YYYY-MM-DD-{feature}-core.md`
- Contains:
  - `**Type:** Core Feature`
  - `**Status:** Planning`
  - Overview section with problem, solution, users, success criteria
  - SLC Commitment section
  - Core Requirements (essential data/fields only)
  - ONE phase with 2-4 substories maximum
  - Out of Scope section listing future expansions
  - Next Expansions section
  - Context file reference
- Context file created: `.claude/prds/context/YYYY-MM-DD-{feature}-core.json`

**Success Criteria**:
- ✅ File naming follows convention
- ✅ Maximum ONE phase
- ✅ Maximum 2-4 substories
- ✅ Each substory has acceptance criteria
- ✅ Out of scope items documented
- ✅ Context file initialized
- ✅ Template structure matches references/prd-templates.md

---

### Test 3e: Core PRD - Completion Message

**Feature**: Show next steps after core PRD creation

**Steps**:
1. After PRD generated

**Expected Behavior**:
```
✅ Core PRD created: .claude/prds/YYYY-MM-DD-{feature}-core.md
📋 Context file: .claude/prds/context/YYYY-MM-DD-{feature}-core.json

📋 Core includes: [brief summary]
🚫 Out of scope (future expansions): [list]

💡 Next steps:
1. "implement" - Build core foundation with auto-testing and review
2. After core is complete, use "plan" again for expansions:
   - Customer details expansion
   - Line items expansion
   - [etc]
```

**Success Criteria**:
- ✅ Shows file paths
- ✅ Summarizes what's included
- ✅ Lists out-of-scope items
- ✅ Provides clear next steps
- ✅ Mentions "implement" command
- ✅ Suggests future expansions

---

### Test 4a: Expansion PRD - Core Validation

**Feature**: Validate core PRD exists and is complete before creating expansion

**Steps**:
1. Start planning: "plan an expansion for hello-world"
2. Choose option "2" (Expansion)
3. When asked which core, specify a NON-EXISTENT core PRD

**Expected Behavior**:
```
❌ ERROR: Core PRD not found: .claude/prds/2025-10-26-nonexistent-core.md

This expansion requires a completed core PRD.

Exiting...
```

**Success Criteria**:
- ✅ Validates core PRD file exists
- ✅ Clear error if not found
- ✅ Exits without continuing

**Steps with incomplete core**:
1. Create a core PRD but mark `**Status:** Planning` (not Complete)
2. Try to create expansion

**Expected Behavior**:
```
⚠️  WARNING: Core PRD is not marked complete
Expansion PRDs should build on completed cores.
Continue anyway? [yes/no]
```

**Success Criteria**:
- ✅ Warns about incomplete core
- ✅ Asks user to confirm
- ✅ Allows override but warns

**Steps with missing context**:
1. Have core PRD but delete `.claude/prds/context/{core-name}.json`
2. Try to create expansion

**Expected Behavior**:
```
⚠️  WARNING: No context file found for core PRD
Context may be limited. Continue? [yes/no]
```

**Success Criteria**:
- ✅ Checks context file exists
- ✅ Warns if missing
- ✅ Allows override but warns

---

### Test 4b: Expansion PRD - Auto-Load Core Context

**Feature**: Automatically load and analyze core PRD and implementation

**Prerequisites**:
- Have a completed core PRD
- Core PRD has context file with files_created, patterns, libraries, decisions
- Implementation files exist

**Steps**:
1. Start expansion: "plan an expansion for hello-world core"
2. Choose option "2" (Expansion)
3. Specify the core PRD name

**Expected Behavior (BEFORE asking questions)**:
```
🔍 Core Implementation Analysis (AUTO-LOADED):

✅ Core Context Loaded: .claude/prds/YYYY-MM-DD-hello-world-core.md

Implementation Files ([X] files):
[List actual files with brief description of each]
- path/to/file1.ext - [what it does]
- path/to/file2.ext - [what it does]

Established Patterns ([Y] patterns):
[List specific patterns with examples from code]
- Pattern 1: [name] - [where used, how implemented]
- Pattern 2: [name] - [where used, how implemented]

Libraries in Use ([Z] libraries):
[List with purpose]
- library1 - [purpose in core]
- library2 - [purpose in core]

Architectural Decisions ([W] decisions):
[List key decisions with rationale]
1. [Decision 1]: [rationale from context]
2. [Decision 2]: [rationale from context]

Code Analysis Insights:
- Naming convention: [pattern observed, e.g., "FeatureNameService"]
- Error handling: [approach used, e.g., "Custom exception classes"]
- Validation: [approach used, e.g., "Schema validators"]
- Data access: [pattern used, e.g., "Repository pattern"]

✅ Expansion will extend these patterns consistently.
```

**Success Criteria**:
- ✅ Loads core PRD file automatically
- ✅ Reads context JSON file
- ✅ Extracts files_created from context
- ✅ Reads actual implementation files
- ✅ Analyzes code patterns (naming, error handling, validation)
- ✅ Presents findings BEFORE asking questions
- ✅ Shows specific code examples and patterns
- ✅ Confirms expansion will follow these patterns

**Verification**:
- Check that file paths listed are real files from core implementation
- Check that patterns mentioned are actually used in the code
- Check that libraries match what's in package.json/requirements.txt
- Check that architectural decisions reference context file

---

### Test 4c: Expansion PRD - Requirements Gathering

**Feature**: Ask 6-10 questions building on loaded core patterns

**Steps**:
1. After auto-loading core context
2. Continue with expansion

**Expected Behavior**:
- Shows loaded context summary first
- Asks expansion-specific questions:
  - What capability this adds to core (1-2 questions)
  - New data/fields needed (2-3 questions)
  - How it connects to core (2-3 questions)
  - User experience changes (1-2 questions)
  - Success criteria and boundaries (2-3 questions)
- Total: 6-10 questions
- Questions reference loaded patterns: "I see the core uses [Pattern X] for [Purpose]. Should this expansion follow the same pattern?"

**Success Criteria**:
- ✅ Between 6-10 questions
- ✅ Questions reference loaded core patterns explicitly
- ✅ Questions ask how to extend (not replace) core
- ✅ If scope seems large, suggests splitting into multiple expansions
- ✅ Questions are contextual to what was found in core

---

### Test 4d: Expansion PRD - Document Generation

**Feature**: Generate expansion PRD with auto-populated core references

**Steps**:
1. Complete expansion requirements gathering
2. Wait for PRD generation

**Expected Behavior**:
- File created: `.claude/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`
- Contains:
  - `**Type:** Expansion`
  - `**Builds On:** [Link to core PRD]`
  - `**Status:** Planning`
  - "Core Implementation Reference (AUTO-LOADED)" section with:
    - **Files created in core**: [AUTO-POPULATED from context]
    - **Patterns established in core**: [AUTO-POPULATED from context]
    - **Libraries in use**: [AUTO-POPULATED from context]
    - **Architectural decisions**: [AUTO-POPULATED from context]
  - Expansion Requirements section
  - Integration with Core section
  - Substories that reference extending core files
  - "Core Patterns to Follow" in substories
- Context file: `.claude/prds/context/YYYY-MM-DD-{feature}-{expansion}.json` (inherits from core)

**Success Criteria**:
- ✅ File naming follows convention
- ✅ Links to core PRD
- ✅ Core Implementation Reference section AUTO-POPULATED with real data
- ✅ Files listed are actual files from core implementation
- ✅ Patterns listed match what was found in code
- ✅ Substories reference extending existing core files
- ✅ Substories reference following core patterns
- ✅ Context file inherits from core context
- ✅ Template structure matches references/prd-templates.md

**Verification**:
- Open the generated expansion PRD
- Check "Files created in core" section contains real file paths
- Check "Patterns established" describes actual patterns from core code
- Check substories mention modifying specific core files
- Check expansion context JSON has link to core context

---

### Test 4e: Expansion PRD - Completion Message

**Feature**: Show expansion-specific next steps

**Steps**:
1. After expansion PRD generated

**Expected Behavior**:
```
✅ Expansion PRD created: .claude/prds/YYYY-MM-DD-{feature}-{expansion}.md
📋 Context file: .claude/prds/context/YYYY-MM-DD-{feature}-{expansion}.json

🔧 Expands: {core feature name}
📋 Adds: [brief summary]
🎯 Auto-loaded from core:
   - [X] files created
   - [Y] patterns
   - [Z] libraries
   - [W] architectural decisions

💡 Next: "implement" to build this expansion following core patterns
```

**Success Criteria**:
- ✅ Shows both file paths
- ✅ References which core it expands
- ✅ Summarizes what it adds
- ✅ Shows what was auto-loaded (with counts)
- ✅ Clear next step: "implement"
- ✅ Emphasizes "following core patterns"

---

### Test 5a: Task PRD - Type Selection

**Feature**: Create task-based PRD for infrastructure/technical work

**Steps**:
1. Start planning: "plan database migration task"
2. Choose option "3" (Task-based change)

**Expected Behavior**:
- Skill asks about the task goal
- Questions focus on technical approach, steps, rollback plan
- Different from core/expansion (no substories, just checklist)

**Success Criteria**:
- ✅ Recognizes task-based work
- ✅ Different question set than core/expansion
- ✅ Asks about rollback plan
- ✅ Asks for concrete steps

---

### Test 5b: Task PRD - Document Generation

**Feature**: Generate task PRD with checklist format

**Steps**:
1. Complete task requirements gathering

**Expected Behavior**:
- File created: `.claude/prds/YYYY-MM-DD-{task-name}-task.md`
- Contains:
  - `**Type:** Task`
  - `**Status:** Planning`
  - Problem/Goal section
  - Technical Approach section
  - Implementation Checklist (NOT phases/substories):
    - Preparation checkboxes
    - Execution checkboxes
    - Validation checkboxes
  - Testing Strategy section
  - Rollback Plan section
  - Dependencies section
- Context file: `.claude/prds/context/YYYY-MM-DD-{task-name}-task.json`

**Success Criteria**:
- ✅ File naming includes "-task"
- ✅ Uses checklist format, not phases/substories
- ✅ Includes rollback plan
- ✅ Each checkbox is a concrete step
- ✅ Template matches references/prd-templates.md
- ✅ Context file created with simplified structure

---

### Test 6: Directory Structure Initialization

**Feature**: Create required directory structure if it doesn't exist

**Steps**:
1. Delete `.claude/` directory if it exists
2. Start planning any PRD type

**Expected Behavior**:
```bash
# Directories created:
.claude/prds/
.claude/prds/context/
.claude/prds/archive/
.claude/prds/archive/context/
.claude/checkpoints/
```

**After creation**:
```bash
# .gitignore updated to include:
.claude/checkpoints/
```

**Success Criteria**:
- ✅ Creates `.claude/prds/` directory
- ✅ Creates `.claude/prds/context/` subdirectory
- ✅ Creates `.claude/prds/archive/` subdirectory
- ✅ Creates `.claude/prds/archive/context/` subdirectory
- ✅ Creates `.claude/checkpoints/` directory
- ✅ Adds `.claude/checkpoints/` to .gitignore
- ✅ Does NOT gitignore PRDs or context files (they're team-shared)

---

### Test 7: Context File Initialization

**Feature**: Create and populate context JSON file

**Steps**:
1. Create any type of PRD (core, expansion, or task)
2. Check for context file after PRD creation

**Expected File**: `.claude/prds/context/YYYY-MM-DD-{prd-name}.json`

**Expected Structure** (for core):
```json
{
  "prd_file": ".claude/prds/YYYY-MM-DD-feature-core.md",
  "prd_type": "core",
  "created": "YYYY-MM-DDTHH:MM:SSZ",
  "last_updated": "YYYY-MM-DDTHH:MM:SSZ",
  "files_created": [],
  "patterns": {},
  "libraries": {},
  "architectural_decisions": [],
  "current_phase": null
}
```

**Expected Structure** (for expansion):
```json
{
  "prd_file": ".claude/prds/YYYY-MM-DD-feature-expansion.md",
  "prd_type": "expansion",
  "core_prd": ".claude/prds/YYYY-MM-DD-feature-core.md",
  "created": "YYYY-MM-DDTHH:MM:SSZ",
  "last_updated": "YYYY-MM-DDTHH:MM:SSZ",
  "files_created": [],
  "patterns": {},
  "libraries": {},
  "architectural_decisions": []
}
```

**Success Criteria**:
- ✅ Context file created in correct location
- ✅ Valid JSON format
- ✅ Contains required fields
- ✅ For expansion: includes core_prd reference
- ✅ Timestamps are ISO 8601 format
- ✅ Empty arrays/objects for fields to be populated during implementation

---

### Test 8: Reading references/workflow-guide.md

**Feature**: Skill reads detailed workflow from references when needed

**Steps**:
1. Start planning a PRD
2. Observe if skill references the workflow guide

**Expected Behavior**:
- Skill should read `references/workflow-guide.md` for detailed instructions
- Workflow steps should match what's documented in the guide
- Bash commands should match the guide

**Success Criteria**:
- ✅ Skill follows workflow steps from guide
- ✅ Prerequisite validation matches guide
- ✅ Context loading approach matches guide
- ✅ Question frameworks match guide
- ✅ Output formats match guide

**Verification**:
Compare skill's actual behavior with `references/workflow-guide.md` sections.

---

### Test 9: Reading references/prd-templates.md

**Feature**: Skill uses templates from references for PRD structure

**Steps**:
1. Create a core PRD
2. Create an expansion PRD
3. Create a task PRD
4. Compare generated PRDs with templates

**Expected Behavior**:
- Generated PRDs match structure in `references/prd-templates.md`
- All sections present
- Formatting matches
- Field names match

**Success Criteria**:
- ✅ Core PRD structure matches Core PRD Structure template
- ✅ Expansion PRD structure matches Expansion PRD Structure template
- ✅ Task PRD structure matches Task-Based PRD Structure template
- ✅ All required sections present
- ✅ Frontmatter format matches
- ✅ Naming conventions match

**Verification**:
1. Open generated PRD
2. Open `references/prd-templates.md`
3. Compare section by section

---

### Test 10: Lean SKILL.md - Progressive Disclosure

**Feature**: SKILL.md is lean and references detailed guides when needed

**Steps**:
1. Count words in SKILL.md: `wc -w SKILL.md`
2. Verify it's under 1000 words

**Expected**: ~769 words (significantly less than original ~3,252)

**Success Criteria**:
- ✅ SKILL.md is under 1000 words
- ✅ Contains workflow overview only
- ✅ References workflow-guide.md for details
- ✅ References prd-templates.md for templates
- ✅ Critical rules are in SKILL.md
- ✅ Detailed implementations are in references/

**Verification**:
1. Check SKILL.md contains references to detailed guides
2. Check references/ files contain the detailed information
3. Verify no duplication between SKILL.md and references

---

### Test 11: Edge Case - PRD Type Determination

**Feature**: Skill correctly handles ambiguous requests

**Steps**:
1. Say: "plan something for my app"
2. Don't specify core, expansion, or task

**Expected Behavior**:
- Skill ALWAYS asks for PRD type
- Doesn't assume based on wording

**Success Criteria**:
- ✅ Always shows the 3 options (core/expansion/task)
- ✅ Waits for user selection
- ✅ Doesn't proceed without explicit choice

---

### Test 12: Edge Case - Expansion Without Core

**Feature**: Cannot create expansion without completed core

**Steps**:
1. Try to plan expansion when no core PRD exists in project

**Expected Behavior**:
```
❌ ERROR: Core PRD not found

This expansion requires a completed core PRD.
```

**Success Criteria**:
- ✅ Validates core PRD existence
- ✅ Exits if not found
- ✅ Clear error message

---

## Summary Checklist

After running all tests, verify:

### Core Functionality
- [ ] CLAUDE.md validation works
- [ ] PRD type selection works (3 options)
- [ ] Core PRD enforces minimalism (2-4 substories)
- [ ] Core PRD reads CLAUDE.md and explores codebase
- [ ] Expansion PRD validates core exists
- [ ] Expansion PRD auto-loads core context
- [ ] Expansion PRD auto-populates core references
- [ ] Task PRD uses checklist format
- [ ] Directory structure initialized correctly
- [ ] Context files created and populated

### Context Loading (Critical for Expansions)
- [ ] Reads core PRD file
- [ ] Reads core context JSON
- [ ] Reads actual implementation files
- [ ] Analyzes code patterns (naming, error handling, etc.)
- [ ] Presents findings BEFORE asking questions
- [ ] Uses loaded context in questions
- [ ] Auto-populates core references in expansion PRD

### Document Quality
- [ ] Core PRDs have max 2-4 substories
- [ ] Expansion PRDs reference core files
- [ ] Task PRDs have rollback plans
- [ ] All PRDs have acceptance criteria
- [ ] File naming follows conventions
- [ ] Templates match references/prd-templates.md

### Progressive Disclosure
- [ ] SKILL.md is lean (<1000 words)
- [ ] References workflow-guide.md for details
- [ ] References prd-templates.md for templates
- [ ] No duplication between SKILL.md and references

### Error Handling
- [ ] Missing CLAUDE.md handled gracefully
- [ ] Missing core PRD handled gracefully
- [ ] Invalid PRD type handled gracefully
- [ ] All errors have clear messages and next steps

---

## Quick Test Script

For rapid testing, run this sequence:

```bash
# Test 1: Missing CLAUDE.md
cd /tmp/test-project-no-claude
# Invoke skill: "plan a feature"
# Expected: Error about missing CLAUDE.md

# Test 2: Core PRD with minimalism enforcement
cd /path/to/project/with/claude-md
# Invoke: "plan invoicing system"
# Choose: 1 (Core)
# Describe complex feature
# Expected: Pushback and minimalism enforcement

# Test 3: Expansion with auto-loading
# First create a core PRD and implement it
# Invoke: "plan expansion for [core-name]"
# Choose: 2 (Expansion)
# Expected: Auto-loads core context BEFORE questions

# Test 4: Task PRD
# Invoke: "plan database migration"
# Choose: 3 (Task)
# Expected: Checklist format with rollback plan

# Test 5: Verify files
ls -la .claude/prds/
ls -la .claude/prds/context/
# Expected: PRD files and context JSON files exist
```

---

## Troubleshooting

If a test fails, check:

1. **SKILL.md**: Does it match the refactored version?
2. **references/workflow-guide.md**: Does it exist and have detailed steps?
3. **references/prd-templates.md**: Does it exist and have all three templates?
4. **Context manager**: Is `skills/shared/scripts/context-manager.sh` available?

Report issues with:
- Which test failed
- Expected behavior
- Actual behavior
- Screenshots/logs if available
