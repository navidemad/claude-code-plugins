---
name: code-prd
description: Implement PRD substories with testing, code review, and progress tracking. Works substory-by-substory with approval gates per phase. Can also write standalone tests. Activates when user says code PRD, implement PRD, build PRD, code this, implement feature. French: coder le PRD, implémenter le PRD, développer le PRD.
---

# Code PRD Implementation

Write production-quality code for PRD substories with **automatic testing, code review, and iterative refinement** until ready.

**Communication Style**: In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Philosophy

- **Substory-by-substory**: Implement incrementally with progress tracking
- **Phase-level approval**: Auto-test and review each phase, get user approval before continuing
- **Auto-refinement**: Run code-review internally, fix issues, re-review until satisfied
- **Context-aware**: Load PRD context to maintain consistency (especially for expansions)
- **Flexible**: Can implement full PRD OR write standalone tests for any file

## When to Activate

This skill activates when user:
- Says "implement PRD", "implement", "build this PRD", "start implementation"
- Says "code this feature", "develop this", "build this"
- References a PRD file path (e.g., "implement docs/prds/2024-10-25-invoice-core.md")
- Says "write tests for file X" (standalone mode - no PRD needed)
- French: "implémenter le PRD", "coder cette fonctionnalité", "développer le PRD", "écrire des tests"

## Implementation Workflow

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

Exiting...
EOF
    exit 1
fi
```

**Show confirmation:**
```
✅ CLAUDE.md found
📋 Ready to implement
```

### Mode Detection

**Check user request:**

1. **PRD Implementation Mode** - User mentions PRD or says "implement"
   - Full workflow with phases, substories, auto-testing, review

2. **Standalone Test Mode** - User says "write tests for [file/feature]"
   - Skip PRD, just write tests for specified files
   - Detect testing framework
   - Write comprehensive tests
   - Run tests
   - Done

**For Standalone Test Mode**, jump to Step 8 (Write Tests).

**For PRD Implementation Mode**, continue below:

### Step 1: Load PRD, Context, and Project Conventions

**Execute in parallel:**
```bash
# Read the PRD file
# Source context manager
source skills/shared/scripts/context-manager.sh

# Read project conventions from CLAUDE.md in project root
# Read CLAUDE.md

# Load or initialize PRD context
if context_exists "$prd_file"; then
    context=$(read_context "$prd_file")
else
    context_file=$(init_context "$prd_file")
    context=$(read_context "$prd_file")
fi
```

**If no PRD specified:**
- Check `docs/prds/` for PRD files
- If multiple exist, ask user which PRD to implement
- List PRDs with their type (Core/Expansion) and completion status

**Determine PRD Type:**
Check PRD frontmatter for:
- `**Type:** Core Feature`
- `**Type:** Expansion`
- `**Type:** Task`

**For Core PRDs:**
- Load CLAUDE.md for project conventions
- Load context file (patterns, libraries, decisions from previous sessions)
- Goal: Establish clean patterns that expansions will follow

**For Task PRDs:**
- Load CLAUDE.md for project conventions
- Work through Implementation Checklist sequentially
- No phases/substories - just step-by-step execution
- Update checkboxes as steps complete
- Goal: Complete technical task efficiently

**For Expansion PRDs (CRITICAL - AUTO-LOAD CORE CONTEXT):**
- Load CLAUDE.md for project conventions
- **Find the core PRD** referenced in "Builds On" field
- **Read core context file**: `.claude/context/{core-prd-name}.json`
- **Auto-extract**:
  - `files_created` - Core implementation files
  - `patterns` - Established patterns
  - `libraries` - Libraries in use
  - `architectural_decisions` - Design decisions made in core
- **Read all core implementation files** to understand established patterns
- Document patterns found:
```
🔍 Core Implementation Analysis (AUTO-LOADED):
From: [path to core PRD]
Context: [path to core context file]

Core files: [list actual files from context]

Established patterns: [list actual patterns from context and code analysis]

Libraries in use: [list actual libraries from context]

Architectural decisions: [list actual decisions from context]

✅ Will extend these patterns for [expansion name].
```

### Step 2: Analyze Existing Architecture

**Before writing code, understand the codebase:**

```bash
# Explore existing architecture patterns
# Find similar features/components
# Identify naming conventions
# Locate relevant directories
```

**Analyze:**
- Existing code structure and patterns
- Current architecture (layering, separation of concerns)
- Naming conventions in use
- Where similar features are implemented
- Data layer patterns (if applicable - database, ORM, storage)
- API patterns (if applicable - REST, GraphQL, gRPC)

**Document findings based on your project's CLAUDE.md and codebase analysis.**

### Step 3: Parse PRD and Create Implementation Plan

**Parse PRD for:**
- Phases and substories
- Current status (⏳ Not Started / 🔄 In Progress / ✅ Completed)
- Dependencies between substories
- Acceptance criteria for each

**For new implementation:**
- Start at Phase 1, Substory 1
- Show implementation plan
- Confirm approach with user

**For continuation:**
- Load current_phase from context
- Find last in-progress (🔄) or next pending (⏳)
- Show completion summary
- Confirm continuation point

**Show plan:**
```
📋 Implementation Plan: [Feature Name]

Phase 1: [Phase Name] (4 substories)
├─ Substory 1.1: [Name] - ⏳ Not Started
├─ Substory 1.2: [Name] - ⏳ Not Started
├─ Substory 1.3: [Name] - ⏳ Not Started
└─ Substory 1.4: [Name] - ⏳ Not Started

Context loaded: ✅
Patterns to follow: [list from context and CLAUDE.md]

Ready to begin Phase 1? [yes/show-details/skip-to]
```

### Step 4: Implement Phase (Substory-by-Substory)

**For each substory in the phase:**

#### Mark Substory In Progress

Update PRD:
```markdown
- 🔄 [1.1] User OAuth integration - In Progress
  - Current: Implementing OAuth flow
  - Started: YYYY-MM-DD HH:MM
```

Update context:
```bash
set_current_phase "$prd_file" "Phase 1: Substory 1.1"
```

#### Write Code

**For Core PRDs:**
Establish clean, simple patterns that will be extended later.

**For Expansion PRDs (CRITICAL - USE LOADED PATTERNS):**
- Reference loaded core implementation files
- Follow established patterns exactly
- Extend, don't replace core code
- Maintain consistency in naming, structure, and approach
- Use same libraries/services as core

Follow project conventions from CLAUDE.md and established patterns from context.
- **For expansions**: Extend core code following established patterns

**Quality Requirements:**
- Follow project conventions (CLAUDE.md, .editorconfig, linting)
- Write clean, readable code
- Add comments for complex logic
- Use consistent naming (especially in expansions - match core naming)
- Handle errors properly
- Validate inputs
- Log appropriately

**Track files created/modified:**
```bash
# Add to context
add_created_file "$prd_file" "src/models/user.model.ts"
add_created_file "$prd_file" "src/services/oauth.service.ts"
```

**Track decisions made:**
```bash
# If using a new library or pattern
add_decision "$prd_file" "[Your architectural decision]"
set_library "$prd_file" "[category]" "[library name]"
set_pattern "$prd_file" "[pattern name]" "[pattern location/description]"
```

#### Mark Substory Complete

Update PRD:
```markdown
- ✅ [1.1] User OAuth integration - Completed (YYYY-MM-DD)
  Files: src/models/user.model.ts, src/services/oauth.service.ts
  Summary: Implemented OAuth flow with provider support
```

#### Show Progress After Each Substory

```markdown
✅ Substory 1.1 complete!

📝 Files created/modified:
- src/models/user.model.ts (User model with OAuth fields)
- src/services/oauth.service.ts (OAuth service)
- src/dto/oauth-response.dto.ts (Response DTO)

📊 Progress: 1/4 substories (25% of Phase 1)

⏭️  Next: Substory 1.2 - OAuth callback handler
```

**Continue to next substory automatically** until phase is complete.

### Step 5: Phase Complete - Auto-Test and Review Loop

**When all substories in a phase are complete:**

```markdown
🎉 Phase 1 Complete: [Phase Name]

✅ Completed substories:
- [1.1] User OAuth integration
- [1.2] OAuth callback handler
- [1.3] Token management
- [1.4] Account linking

📊 Phase Stats:
- Files: 8 files created/modified
- Lines: +350 lines
- Patterns: Service layer pattern established

🧪 Now running testing and review...
```

#### Step 5a: Auto-Run Tests

**Check if testing is applicable:**

```bash
# Read CLAUDE.md for testing info
if grep -qi "no tests\|testing: none\|tests: n/a" CLAUDE.md; then
    testing_disabled=true
fi
```

**If testing is disabled in CLAUDE.md:**
```markdown
ℹ️  Testing skipped (CLAUDE.md indicates no tests for this project)

Proceeding to code review...
```

**If testing is enabled, analyze project testing setup:**
- Read CLAUDE.md for testing framework and conventions
- Examine existing test files to understand patterns
- Identify test command from CLAUDE.md or project config files

**Write comprehensive tests:**
- Unit tests for core logic (business logic, utilities, domain models)
- Integration tests for interactions between components
- Cover all acceptance criteria from substories
- Test happy paths, error scenarios, edge cases
- Follow project testing conventions from CLAUDE.md
- Match existing test file patterns and structure

**Update context with testing framework:**
```bash
update_context "$prd_file" "testing_framework" "[framework identified from CLAUDE.md or project]"
```

**Run tests:**
```bash
# Identify test command from CLAUDE.md or project config
# Execute tests
# Capture results

# If test command fails or not found:
if [[ $test_exit_code -ne 0 ]] && [[ "$test_output" == *"command not found"* ]]; then
    cat <<EOF
⚠️  Warning: Unable to run tests

Test command failed or not found. Possible reasons:
- Test command not configured in CLAUDE.md
- Dependencies not installed
- Test framework not set up

Skipping test execution. Please verify tests manually.

Proceeding to code review...
EOF
    tests_skipped=true
fi
```

**If tests run successfully:**
- Report results with pass/fail counts and coverage if available

**Report results:**
```
🧪 Tests Written and Executed:

✅ [X] tests passed
📊 Coverage: [Y]%
⏱️  Duration: [time]

Test breakdown:
- [Test type 1]: [count] tests
- [Test type 2]: [count] tests

All acceptance criteria verified!
```

**If tests fail (and tests weren't skipped):**
- Show failures
- Fix code
- Re-run tests
- Loop until all tests pass

**If tests were skipped:**
- Continue to code review without test results
- Note in review summary that tests were not executed

#### Step 5b: Auto-Run Code Review (Internal)

**Run internal code review analysis:**

Perform multi-dimensional review:
- **Code Quality**: Readability, maintainability, complexity
- **Architecture**: Design patterns, SOLID principles, separation of concerns
- **Security**: Auth, input validation, secrets, data exposure
- **Performance**: Query optimization, caching, algorithms, resource management
- **Testing**: Coverage, edge cases, meaningful tests
- **Project-Specific**: Checks based on tech stack from CLAUDE.md (e.g., async/await patterns, memory management, concurrency, error handling)

**Categorize findings:**
- 🔴 Critical (Must fix before approval)
- 🟠 Major (Should fix)
- 🟡 Minor (Nice to have)
- ✅ Positive (Done well)

**Show review summary:**
```
📋 Code Review Complete:

🔴 Critical: 0
🟠 Major: 2
🟡 Minor: 5
✅ Positive: 8 things done well

Major issues:
1. [src/controllers/users.controller.ts:23] Missing pagination on list endpoint
   Risk: Could return thousands of records, causing performance issues
   Fix: Add pagination with skip/take or cursor-based pagination

2. [src/repositories/user.repository.ts:45] Missing database index on (oauth_provider, oauth_uid)
   Risk: Slow queries when looking up OAuth users
   Fix: Add composite index in schema migration

Minor suggestions:
- [src/services/oauth.service.ts:12] Extract magic number to constant
- [src/utils/validators.ts:34] Consider adding input sanitization
- ...

✅ Excellent work on:
- Clear separation of concerns with service layer
- Comprehensive error handling
- Consistent naming conventions
- Good test coverage (94%)
```

#### Step 5c: Auto-Fix Issues (If Any)

**If critical or major issues found:**

```markdown
🔧 Fixing [2] major issues automatically... (Iteration 1/3)

Fixing issue 1: Adding pagination to users endpoint...
✅ Fixed src/controllers/users.controller.ts

Fixing issue 2: Adding database index...
✅ Updated database schema with composite index

Re-running code review to verify fixes...
```

**Re-run review:**
```markdown
📋 Re-Review Complete:

🔴 Critical: 0
🟠 Major: 0 (all fixed!)
🟡 Minor: 5
✅ Positive: 10 things done well

All critical and major issues resolved!
```

**If still has critical/major issues after iteration 1:**
- Continue to iteration 2 with auto-fix

**If still has critical/major issues after iteration 2:**
- Ask user for guidance:
```markdown
🔧 Auto-fix iteration 2/3 complete, but issues remain:

🔴 Critical: 1
🟠 Major: 1

Remaining issues:
1. [Critical] [file:line] Issue description
   Current approach tried: [what was attempted]

2. [Major] [file:line] Issue description
   Current approach tried: [what was attempted]

💡 Need your input for final iteration (3/3):
- Do you have additional context about these issues?
- Any specific approach you'd like me to try?
- Alternative libraries or patterns to consider?

Your guidance: [user input]
```

**After receiving user guidance:**
- Apply user suggestions in iteration 3
- Re-run review
- Report final results

**If still has critical/major issues after iteration 3:**
- Stop auto-fixing
- Show detailed issue summary
- Provide options:
```markdown
⚠️ Unable to resolve all issues after 3 iterations.

Remaining issues:
🔴 Critical: X
🟠 Major: Y

Options:
1. **approve-with-issues** - Continue anyway, fix in next phase/PR review
2. **manual-fix** - You'll fix manually, then continue
3. **redo-substory** - Re-implement substory with different approach
4. **get-help** - Pause and document blocker

What would you like to do? [1/2/3/4]
```

### Step 6: Phase Approval Gate

**When review is complete and clean (no critical/major issues):**

```markdown
🎉 Phase 1 Ready for Approval!

📊 Summary:
✅ 4 substories completed
✅ 23 tests passing (94% coverage) [or "⚠️ Tests skipped - manual verification needed"]
✅ Code review: No critical/major issues
📝 8 files created/modified
⏱️  Duration: ~45 minutes

Changes:
- User OAuth integration with validations
- OAuth callback endpoint
- Token management service
- Account linking logic

Patterns established:
- Service layer for business logic
- RESTful API structure
- JWT token management

Context updated: .claude/context/{prd-name}.json
PRD updated with completion status

Approve Phase 1 and continue? [yes/show-changes/redo-phase/stop]
```

**User options:**
- **yes**: Mark phase complete, continue to next phase (if exists)
- **show-changes**: Show detailed git diff
- **redo-phase**: Re-implement phase with different approach
- **stop**: Stop here, don't continue to next phase

**If user approves ("yes"):**
```bash
# Mark phase complete in context
mark_phase_complete "$prd_file" "Phase 1"

# Update PRD
- ✅ Phase 1: Core Foundation - Completed (YYYY-MM-DD)

# Continue to next phase or finish
```

### Step 7: Continuation or Completion

**If more phases exist:**
- Show next phase plan
- Continue to Step 4 for next phase
- Repeat: Implement → Test → Review → Fix → Approve

**If all phases complete:**

**For CORE PRD:**
```markdown
🎉 Core PRD Complete!

✅ All phases implemented and tested:
- Phase 1: Core Foundation (4 substories)

📊 Core Stats:
- Files: 12 files created
- Tests: 45 tests, 95% coverage
- Patterns established:
  * Service layer pattern
  * RESTful API endpoints
  * DTO validation
  * Event-driven notifications

🌱 Core foundation is ready!

Context saved: .claude/context/2024-10-25-invoice-core.json
This context will be auto-loaded when creating expansion PRDs.

💡 Next steps:
1. "ship" - Create commit and PR for core
2. "plan" - Create expansion PRDs to add more features:
   - Customer details
   - Line items
   - Tax calculations
   - Payment integration

What would you like to do?
```

**For EXPANSION PRD:**
```markdown
🎉 Expansion Complete: [Expansion Name]

✅ All phases implemented and tested:
- Phase 1: [Expansion Name] (3 substories)

📊 Expansion Stats:
- Core files extended: 3
- New files created: 5
- Tests: 18 tests, 93% coverage
- Followed core patterns: ✅

Extended core with:
- [New functionality 1]
- [New functionality 2]

Context updated: .claude/context/2024-10-25-invoice-{expansion}.json

💡 Next steps:
- "ship" - Create commit and PR for expansion
- "plan" - Create another expansion PRD
- Continue building more expansions

What would you like to do?
```

### Step 8: Standalone Test Mode (No PRD)

**When user says "write tests for [file/feature]":**

1. **Identify target:**
   - Specific files mentioned
   - Or feature area to test

2. **Understand testing setup from CLAUDE.md:**
   - Read CLAUDE.md for testing framework and conventions
   - Examine existing test files to understand patterns and structure

3. **Read implementation files:**
   - Understand the code to test
   - Identify public methods, business logic, edge cases

4. **Write tests:**
   - Unit tests for logic
   - Integration tests if applicable
   - Cover happy paths, errors, edge cases
   - Follow project testing conventions from CLAUDE.md

5. **Run tests:**
   ```bash
   # Run test suite
   # Report results
   ```

6. **Report:**
   ```markdown
   ✅ Tests written for [file/feature]

   📝 Tests created:
   - tests/unit/user.test.ts (15 tests)
   - tests/integration/oauth.test.ts (8 tests)

   🧪 Test results:
   ✅ 23/23 tests passing
   📊 Coverage: 96%

   Done!
   ```

**No PRD updates, no context management, just tests.**

## Blocker Handling

If implementation is blocked:
1. Mark substory as 🔄 with blocker note
2. Document blocker in PRD:
   ```markdown
   - 🔄 [1.2] OAuth callback handler - Blocked
     - Blocker: Need OAuth credentials from PM
     - Waiting for: Client IDs and secrets
   ```
3. Ask user for resolution or skip to next non-blocked substory
4. Suggest workarounds if possible

## Key Principles

**This skill DOES:**
- Implement code substory-by-substory
- Show progress after each substory
- Auto-run tests after each phase
- Auto-run code review after each phase
- Auto-fix critical/major issues
- Ask for approval at phase boundaries
- Update PRD with status automatically
- Update context with patterns/decisions automatically
- Load core context for expansions automatically
- Write standalone tests without PRD

**This skill DOES NOT:**
- Auto-continue to next phase without approval
- Auto-commit changes (that's "ship" skill's job)
- Auto-create PRs (that's "ship" skill's job)
- Skip testing or review
- Hide review findings from user

**Workflow:**
```
Implement substories → Show progress → Phase complete →
Auto-test → Auto-review → Auto-fix → Ask approval →
Continue or stop
```

## Guidelines

- Work incrementally (one substory at a time)
- Always load PRD context and CLAUDE.md at start
- For expansions: auto-load core context and files
- Always analyze existing architecture before coding
- Follow project conventions from CLAUDE.md and established patterns religiously
- Update PRD status after each substory
- Update context with patterns/libraries/decisions
- Auto-test after each phase (not per substory)
- Auto-review after tests pass
- Auto-fix critical/major issues
- Get approval at phase boundaries
- Track files created in context
- Communicate clearly and frequently
- Handle blockers gracefully
- Support standalone test mode
