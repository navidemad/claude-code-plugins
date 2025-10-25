---
name: implement
description: Implement PRD substories with auto-testing, code review, and progress tracking. Works substory-by-substory with approval gates per phase. Can also write standalone tests. French: implémenter, coder, développer.
---

# Implement Feature from PRD

Write production-quality code for PRD substories with **automatic testing, code review, and iterative refinement** until ready.

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

### Step 1: Load PRD, Context, and Platform

**Execute in parallel:**
```bash
# Read the PRD file
# Source context manager
source .claude/skills/shared/lib/context-manager.sh

# Detect platform (cached for session)
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Load platform conventions
# Read .claude/skills/shared/references/${platform}/conventions.md

# Load or initialize PRD context
if context_exists "$prd_file"; then
    context=$(read_context "$prd_file")
else
    context_file=$(init_context "$prd_file" "$platform")
    context=$(read_context "$prd_file")
fi
```

**If no PRD specified:**
- Check `docs/prds/` for PRD files
- If multiple exist, ask user which PRD to implement
- List PRDs with their type (Core/Expansion) and completion status

**Determine PRD Type:**
Check PRD frontmatter for `**Type:** Core Feature` or `**Type:** Expansion`

**For Core PRDs:**
- Load platform reference
- Load context file (patterns, libraries, decisions from previous sessions)
- Goal: Establish clean patterns that expansions will follow

**For Expansion PRDs (CRITICAL - AUTO-LOAD CORE CONTEXT):**
- Load platform reference
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
From: docs/prds/2024-10-25-invoice-core.md
Context: .claude/context/2024-10-25-invoice-core.json

Core files:
- app/models/invoice.rb
- app/controllers/api/v1/invoices_controller.rb
- app/serializers/invoice_serializer.rb

Established patterns:
- Service objects in app/services/ for business logic
- RESTful API structure under /api/v1/
- ActiveModel serializers for JSON responses
- RSpec tests with FactoryBot

Libraries in use:
- Payment: Stripe
- Auth: Devise + JWT

Architectural decisions:
- Business logic extracted to service objects
- Background jobs for email notifications
- Validations in models, business rules in services

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
- Database schema (if Rails)
- API patterns (if backend)

**Document findings:**
- "Found existing auth in `app/services/auth/`, will follow same pattern"
- "ViewModels use Combine publishers, will maintain consistency"
- "Repository pattern used with Hilt DI, following established structure"

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

Platform: [rails/ios-swift/android-kotlin]
Context loaded: ✅
Patterns to follow: [list from context]

Ready to begin Phase 1? [yes/show-details/skip-to]
```

### Step 4: Implement Phase (Substory-by-Substory)

**For each substory in the phase:**

#### Mark Substory In Progress

Update PRD:
```markdown
- 🔄 [1.1] User OAuth model - In Progress
  - Current: Creating model and migration
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

Follow detected platform conventions:

**Rails:**
- Create/modify models with validations
- Add controllers following RESTful conventions
- Extract business logic to service objects
- Create database migrations (reversible)
- Add background jobs if needed
- **For expansions**: Extend core models/controllers, add new columns via migrations

**iOS Swift:**
- Implement ViewModels with published properties
- Create SwiftUI Views or UIKit ViewControllers
- Add Services for business logic
- Implement networking with async/await
- Handle UI updates on main thread
- **For expansions**: Extend core ViewModels, add properties following same patterns

**Android Kotlin:**
- Implement ViewModels with StateFlow
- Create Fragments/Activities or Composables
- Add UseCases for business logic
- Implement Repositories with Hilt DI
- Handle coroutines properly
- **For expansions**: Extend core data classes, add fields following same patterns

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
add_created_file "$prd_file" "app/models/user.rb"
add_created_file "$prd_file" "db/migrate/20241025_add_oauth_to_users.rb"
```

**Track decisions made:**
```bash
# If using a new library or pattern
add_decision "$prd_file" "Chose Stripe for payment processing"
set_library "$prd_file" "payment" "stripe"
set_pattern "$prd_file" "service_objects" "app/services/"
```

#### Mark Substory Complete

Update PRD:
```markdown
- ✅ [1.1] User OAuth model - Completed (YYYY-MM-DD)
  Files: app/models/user.rb, db/migrate/xxx_add_oauth_to_users.rb
  Summary: Added OAuth provider and UID fields with indexes
```

#### Show Progress After Each Substory

```markdown
✅ Substory 1.1 complete!

📝 Files created/modified:
- app/models/user.rb (User model with OAuth fields)
- db/migrate/20241025_add_oauth_to_users.rb (Migration)
- app/serializers/user_serializer.rb (Updated serializer)

📊 Progress: 1/4 substories (25% of Phase 1)

⏭️  Next: Substory 1.2 - OAuth callback handler
```

**Continue to next substory automatically** until phase is complete.

### Step 5: Phase Complete - Auto-Test and Review Loop

**When all substories in a phase are complete:**

```markdown
🎉 Phase 1 Complete: [Phase Name]

✅ Completed substories:
- [1.1] User OAuth model
- [1.2] OAuth callback handler
- [1.3] Token management
- [1.4] Account linking

📊 Phase Stats:
- Files: 8 files created/modified
- Lines: +350 lines
- Patterns: Service object pattern established

🧪 Now running automated testing and review...
```

#### Step 5a: Auto-Run Tests

**Detect testing framework:**
```bash
# Rails
if [ -d "spec/" ]; then
    framework="rspec"
elif [ -d "test/" ]; then
    framework="minitest"
fi

# iOS
if grep -q "Quick" *.xcodeproj/project.pbxproj 2>/dev/null; then
    framework="quick-nimble"
else
    framework="xctest"
fi

# Android
framework="junit-mockk"
```

**Write comprehensive tests:**
- Unit tests for models/ViewModels/domain logic
- Integration tests for controllers/services/repositories
- Cover all acceptance criteria from substories
- Test happy paths, error scenarios, edge cases
- Follow platform testing conventions

**Update context with testing framework:**
```bash
update_context "$prd_file" "testing_framework" "$framework"
```

**Run tests:**
```bash
# Rails
bundle exec rspec

# iOS
xcodebuild test -scheme YourApp

# Android
./gradlew testDebugUnitTest
```

**Report results:**
```
🧪 Tests Written and Executed:

✅ 23 tests passed
📊 Coverage: 94%
⏱️  Duration: 3.2s

Test breakdown:
- Unit tests: 15 (models, ViewModels)
- Integration tests: 8 (API endpoints, services)

All acceptance criteria verified!
```

**If tests fail:**
- Show failures
- Fix code
- Re-run tests
- Loop until all tests pass

#### Step 5b: Auto-Run Code Review (Internal)

**Run internal code review analysis:**

Perform multi-dimensional review:
- **Code Quality**: Readability, maintainability, complexity
- **Architecture**: Design patterns, SOLID principles, separation of concerns
- **Security**: Auth, input validation, secrets, data exposure
- **Performance**: N+1 queries, caching, algorithms, resource management
- **Testing**: Coverage, edge cases, meaningful tests
- **Platform-Specific**:
  - Rails: Strong params, N+1 queries, migrations, background jobs
  - iOS: Retain cycles, main thread UI, optional handling, async/await
  - Android: Context leaks, coroutines, ViewModels, lifecycle

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
1. [controllers/users_controller.rb:23] Missing pagination on index endpoint
   Risk: Could return thousands of records, causing performance issues
   Fix: Add .page(params[:page]).per(25)

2. [models/user.rb:45] Missing database index on (oauth_provider, oauth_uid)
   Risk: Slow queries when looking up OAuth users
   Fix: Add composite index in migration

Minor suggestions:
- [services/oauth_service.rb:12] Extract magic number to constant
- [ViewModels/UserViewModel.swift:34] Consider using weak self in closure
- ...

✅ Excellent work on:
- Clear separation of concerns with service objects
- Comprehensive error handling
- Consistent naming conventions
- Good test coverage (94%)
```

#### Step 5c: Auto-Fix Issues (If Any)

**If critical or major issues found:**

```markdown
🔧 Fixing [2] major issues automatically...

Fixing issue 1: Adding pagination to UsersController...
✅ Fixed app/controllers/api/v1/users_controller.rb

Fixing issue 2: Adding database index...
✅ Created db/migrate/20241025_add_oauth_index.rb

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

**If still has critical/major issues after 2 fix attempts:**
- Stop auto-fixing
- Show issues to user
- Ask: "Continue fixing? [yes/skip/manual]"

### Step 6: Phase Approval Gate

**When tests pass and review is clean (no critical/major issues):**

```markdown
🎉 Phase 1 Ready for Approval!

📊 Summary:
✅ 4 substories completed
✅ 23 tests passing (94% coverage)
✅ Code review: No critical/major issues
📝 8 files created/modified
⏱️  Duration: ~45 minutes

Changes:
- User OAuth model with validations
- OAuth callback endpoint
- Token management service
- Account linking logic

Patterns established:
- Service objects for business logic
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
  * Service objects in app/services/
  * RESTful API under /api/v1/
  * ActiveModel serializers
  * Background jobs for emails

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

2. **Detect platform and framework:**
   ```bash
   platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)
   # Detect testing framework (RSpec, Minitest, XCTest, JUnit)
   ```

3. **Read implementation files:**
   - Understand the code to test
   - Identify public methods, business logic, edge cases

4. **Write tests:**
   - Unit tests for logic
   - Integration tests if applicable
   - Cover happy paths, errors, edge cases
   - Follow platform conventions

5. **Run tests:**
   ```bash
   # Run test suite
   # Report results
   ```

6. **Report:**
   ```markdown
   ✅ Tests written for [file/feature]

   📝 Tests created:
   - spec/models/user_spec.rb (15 tests)
   - spec/services/oauth_service_spec.rb (8 tests)

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
- Always load PRD context at start
- For expansions: auto-load core context and files
- Always analyze existing architecture before coding
- Follow detected platform patterns religiously
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
