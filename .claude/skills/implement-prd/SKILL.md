---
name: implement-prd
description: Implement PRD features with auto progress tracking. Activates when user says implement PRD, build this PRD, continue implementing, start implementation, or references a PRD file path.
---

# Implement PRD with Progress Tracking

Implement features defined in PRD documents incrementally, updating status automatically as work progresses.

## Activation Context

Use when user:
- References PRD file path
- Requests PRD implementation
- Says "continue implementing"
- Wants to resume feature work

## Implementation Process

### Step 1: Load PRD and Detect Platform

**Execute in parallel:**
```bash
# Read the PRD file
# Detect platform (cached for session)
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)
```

**Then load platform reference:**
- Read `.claude/skills/shared/references/${platform}/conventions.md`
- **Rails**: Use models, controllers, services, ActiveRecord patterns, RSpec/Minitest
- **iOS Swift**: Use MVVM, SwiftUI/UIKit, ViewModels, Combine, async/await
- **Android Kotlin**: Use Clean Architecture, MVVM, Coroutines, Hilt DI, Repository pattern

**Parse PRD:**
- Phases and substories
- Current status (⏳/🔄/✅)
- Dependencies
- Acceptance criteria

### Step 2: Determine Starting Point

**If no PRD file specified:**
- Check `docs/prds/` for PRD files
- If multiple PRDs exist, **ask user which PRD to implement/continue**
- List PRDs with their status (completed substories count)

**For new implementation:**
- Start at Phase 1, Substory 1
- Confirm approach with user

**For continuation:**
- Find last in-progress (🔄) or next pending (⏳)
- Show completion summary
- Confirm continuation point

### Step 3: Create Task Breakdown

Use TodoWrite to track substory tasks:
- Files/modules to create or modify
- Tests to write
- Documentation to update

### Step 4: Implement Substory

#### Mark In Progress
Update PRD:
```markdown
- 🔄 [N.M] Substory Title - In Progress
  - Current: [What's being implemented]
```

#### Write Code

Follow project's conventions and best practices:

**Backend/API Development:**
- Data models with validation
- API endpoints/controllers
- Business logic in appropriate layer
- Database migrations/schema changes
- Background jobs if needed

**Frontend/Web Development:**
- UI components following project's framework
- State management
- API integration
- Client-side validation
- Responsive design

**Mobile Development:**
- Platform-appropriate architecture (MVVM, MVP, MVC)
- ViewModels/Presenters for logic
- UI components (native or cross-platform)
- API client integration
- Local data persistence
- Platform-specific considerations (lifecycle, memory)

**Cross-Platform:**
- Shared business logic
- Platform-specific UI layers
- Consistent data models
- API abstraction layers

#### Write Tests

- Unit tests for business logic and models
- Integration tests for APIs and data flow
- UI/component tests for user interfaces
- E2E tests for critical flows
- Verify acceptance criteria are met

#### Mark Complete

Update PRD:
```markdown
- ✅ [N.M] Substory Title - Completed (YYYY-MM-DD)
  - Files: `path/to/file1.ext`, `path/to/test_file.ext`
  - Commit: [hash if committed]
  - Tests: [count] tests, all passing
  - Notes: [Important implementation details]
```

### Step 5: Create Commit

After logical completion:
- Use commit skill for message generation
- Reference PRD and substory in message
- Link completed work

### Step 6: Progress Communication

Regularly update user:
- Current substory progress
- Completion notifications
- Blocker identification
- Next steps

### Step 7: Handle Blockers

If blocked:
- Mark as 🔄 with blocker note
- Ask user for clarification
- Suggest alternatives
- Document decision made

### Step 8: Phase Completion

When phase completes:
- Summary of phase accomplishments
- Run phase-level tests
- Ask about continuing to next phase
- Update PRD phase status

## Continuation Strategy

Resume by:
- Reading current PRD status
- Showing completion summary
- Identifying next substory
- Confirming approach

## Code Quality Standards

- Follow project conventions (check CLAUDE.md, .editorconfig, linting rules)
- Write clean, readable code
- Add comments for complex logic
- Use consistent naming conventions
- Handle errors properly
- Validate inputs
- Log appropriately

## Testing Requirements

Mark substory complete only when:
- All tests passing
- Acceptance criteria met
- Edge cases covered
- Manual testing done (if applicable)
- No regressions introduced
- Code reviewed (by skill or human)

## Platform Detection & References

**Primary Detection:** Run `.claude/skills/shared/scripts/detect_platform.sh` to identify:
- **android-kotlin**: `gradle.properties` exists at project root
- **ios-swift**: Any `.xcodeproj` folder exists
- **rails**: `tmp/pids` folder exists

**Load Platform Reference:**
Once platform is detected, read the corresponding conventions file:
- Rails: `.claude/skills/shared/references/rails/conventions.md`
- iOS: `.claude/skills/shared/references/ios-swift/conventions.md`
- Android: `.claude/skills/shared/references/android-kotlin/conventions.md`

**Apply Platform Patterns:**
Use the loaded reference to follow:
- Naming conventions
- Code structure patterns
- Architecture best practices
- Testing patterns
- Security guidelines specific to that platform

## Output Format

Provide:
- Current substory being worked
- Files/modules created or modified
- Tests written
- Completion status
- Next action

## Guidelines

- Work incrementally (one substory at a time)
- Update PRD frequently with status
- Commit logical units of work
- Test thoroughly before marking complete
- Ask questions if requirements unclear
- Suggest PRD improvements as learned
- Use terminology natural to project's stack
- Follow existing code patterns in project
