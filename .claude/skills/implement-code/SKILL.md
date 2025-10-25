---
name: implement-code
description: Implement PRD substories with smart code generation. Activates when user says implement PRD, build feature, code this PRD, start implementation, or references PRD file. French: implémenter PRD, coder cette fonctionnalité, développer le PRD.
---

# Implement Code from PRD

Write production-quality code for PRD substories with smart guidance. This skill is a **coding assistant** - it helps you implement features systematically, you stay in control.

## When to Activate

This skill activates when user:
- Says "implement PRD", "build this PRD", "start implementation"
- Says "code this feature", "develop this", "build this"
- References a PRD file path (e.g., "implement docs/prds/2024-10-25-auth.md")
- French: "implémenter le PRD", "coder cette fonctionnalité", "développer le PRD"

## Implementation Workflow

### Step 1: Load PRD and Detect Platform

**Execute in parallel:**
```bash
# Read the PRD file
# Detect platform (cached for session)
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)
```

**If no PRD specified:**
- Check `docs/prds/` for PRD files
- If multiple exist, ask user which PRD to implement
- List PRDs with their completion status

**Then load platform reference:**
- Read `.claude/skills/shared/references/${platform}/conventions.md`
- **Rails**: Models, controllers, services, ActiveRecord, RSpec/Minitest
- **iOS Swift**: MVVM, SwiftUI/UIKit, ViewModels, Combine, async/await
- **Android Kotlin**: Clean Architecture, MVVM, Coroutines, Hilt DI, Repository pattern

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

### Step 3: Determine Starting Point

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
- Find last in-progress (🔄) or next pending (⏳)
- Show completion summary
- Confirm continuation point

### Step 4: Create Task Breakdown

Use TodoWrite to track current substory tasks:
```
- [pending] Create User model with OAuth fields
- [pending] Add database migration
- [pending] Update serializer
- [pending] Write unit tests
```

### Step 5: Implement Substory

#### Mark In Progress

Update PRD:
```markdown
- 🔄 [1.1] User OAuth model - In Progress
  - Current: Creating model and migration
  - Started: YYYY-MM-DD HH:MM
```

#### Write Code

Follow detected platform conventions and analyzed patterns:

**Rails:**
- Create/modify models with validations
- Add controllers following RESTful conventions
- Extract business logic to service objects
- Create database migrations (reversible)
- Add background jobs if needed

**iOS Swift:**
- Implement ViewModels with published properties
- Create SwiftUI Views or UIKit ViewControllers
- Add Services for business logic
- Implement networking with async/await
- Handle UI updates on main thread

**Android Kotlin:**
- Implement ViewModels with StateFlow
- Create Fragments/Activities or Composables
- Add UseCases for business logic
- Implement Repositories with Hilt DI
- Handle coroutines properly

**Quality Requirements:**
- Follow project conventions (CLAUDE.md, .editorconfig, linting)
- Write clean, readable code
- Add comments for complex logic
- Use consistent naming
- Handle errors properly
- Validate inputs
- Log appropriately

### Step 6: Mark Substory Complete and Suggest Next Steps

**Update PRD with completion status:**
```markdown
- ✅ [1.1] User OAuth model - Completed (YYYY-MM-DD)
  Files: app/models/user.rb, db/migrate/xxx_add_oauth_to_users.rb
  Summary: Added OAuth provider and UID fields with indexes
```

**Show completion summary:**
```markdown
✅ Substory 1.1 complete!

📝 Files created/modified:
- app/models/user.rb (User model with OAuth fields)
- db/migrate/20241025_add_oauth_to_users.rb (Migration)
- app/serializers/user_serializer.rb (Updated serializer)

📊 Progress: 1/8 substories (12.5%)

💡 Suggested next steps:
- "review my code" - Review changes before committing
- "write tests for this" - Add comprehensive tests
- "commit these changes" - Commit with conventional format
- "continue to 1.2" - Move to next substory
- "show progress" - See overall PRD status

What would you like to do?
```

**DO NOT:**
- Auto-invoke code-review
- Auto-invoke commit
- Auto-invoke any other skill
- Continue to next substory without user request

**DO:**
- Update PRD status
- Show what was accomplished
- Suggest logical next steps
- Wait for user decision

### Handling "Continue to Next Substory"

**When user says "continue to 1.2" or "next substory":**

1. Load next substory from PRD
2. Show substory details:
   ```markdown
   📋 Starting Substory 1.2: OAuth callback handler

   **Acceptance Criteria:**
   - [ ] Handle provider callbacks
   - [ ] Exchange code for tokens
   - [ ] Store tokens securely
   - [ ] Handle errors gracefully

   **Dependencies:** Substory 1.1 (✅ complete)

   Ready to implement? [yes/skip/details]
   ```
3. Loop back to Step 5 to implement
4. Repeat the guided workflow

### Phase Completion

**When all substories in a phase are complete:**
```markdown
🎉 Phase 1 Complete!

✅ Completed substories:
- [1.1] User OAuth model
- [1.2] OAuth callback handler
- [1.3] Token storage

📊 Phase 1 Stats:
- Time: 3 sessions
- Commits: 5
- Files: 12 files created/modified

💡 Next steps:
- "review my code" - Review entire phase
- "commit these changes" - Commit any uncommitted work
- "create a PR" - Submit phase for review
- "continue to phase 2" - Start next phase
- "show progress" - See overall PRD progress

What would you like to do?
```

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

## Continuation Strategy

When user says "continue implementing":
1. Read PRD current status
2. Show completion summary
3. Identify next pending or in-progress substory
4. Resume from Step 5

## Code Quality Standards

Mark substory complete when:
- ✅ Code written following platform conventions
- ✅ Files created/modified as needed
- ✅ PRD updated with completion status
- ✅ User has reviewed the code (or chosen to skip)
- ✅ Acceptance criteria are implementable (tests verify later)

**Note:** This skill writes code. User decides when to review, test, and commit.

## Important Philosophy

**This skill does NOT:**
- Auto-invoke code-review
- Auto-commit changes
- Auto-create PRs
- Auto-continue to next substory
- Fix issues without being asked
- Run tests automatically

**This skill DOES:**
- Write high-quality code following conventions
- Update PRD with progress
- Suggest logical next steps
- Wait for user direction
- Provide helpful guidance
- Maintain clear mental model

**Workflow:** Implement → Suggest → Wait → User decides next action

## Guidelines

- Work incrementally (one substory at a time)
- Always analyze existing architecture before coding
- Follow detected platform patterns religiously
- Update PRD status after each substory
- Suggest next steps but never auto-invoke other skills
- Let user orchestrate the workflow (review, test, commit, PR)
- Warn when on main/master branch
- Track progress with TodoWrite
- Communicate clearly and frequently
- Handle blockers gracefully
