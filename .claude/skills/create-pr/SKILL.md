---
name: create-pr
description: Generate GitHub PR titles and descriptions. Activates when user says create PR, make pull request, submit for review, open PR, ready for review. French: créer une PR, soumettre pour révision, ouvrir une pull request.
allowed-tools: Bash(git:*), Bash(gh pr create:*), Bash(.claude/skills/shared/scripts/detect_platform.sh:*), Read, Glob
---

# Create Pull Request

Generate comprehensive GitHub pull requests with platform-aware descriptions. This skill is a **PR description generator** - it helps you create great PRs, you stay in control.

## When to Activate

This skill activates automatically when the user:
- Says "create a PR", "create pull request", "make a PR"
- Mentions "submit for review", "ready for review", "open a PR"
- Says "I'm ready to push" or "ready for PR"
- French: "créer une PR", "soumettre pour révision", "ouvrir une pull request"

## Process

### Step 1: Verify Branch is Clean

**FIRST: Check if there are uncommitted changes:**
```bash
git status
```

**If uncommitted changes exist - STOP with error:**
```
❌ ERROR: Cannot create PR - you have uncommitted changes

📊 Uncommitted changes:
- app/models/user.rb (modified)
- app/services/auth/oauth_service.rb (modified)
- spec/models/user_spec.rb (new file)

💡 Please commit your changes first:
   Say "commit these changes" to create a commit
   Then try "create a PR" again

Alternatively:
- git stash    (to save changes for later)
- git reset    (to discard changes)
```

**Do NOT auto-commit. User must explicitly commit first.**

**If branch is clean:**
- Proceed to Step 2

### Step 2: Gather Information

Use git commands and platform detection to collect data:

```bash
# Detect platform first
bash .claude/skills/shared/scripts/detect_platform.sh

# Get current branch
git branch --show-current

# Get commits since divergence from main
git log main..HEAD --oneline

# Get full diff
git diff main...HEAD

# Check for related PRD
ls docs/prds/
```

Analyze:
- What was added (new features/files)
- What was modified (improvements/fixes)
- What was removed (deprecated code)
- Detected platform (Rails/Android Kotlin/iOS Swift)
- Test coverage changes
- Database migrations present (Rails)
- New dependencies added

### Step 3: Find Related PRD

Search for related PRD by:
- Looking in commit messages for PRD references
- Checking docs/prds/ for recent PRDs
- Reading PRD to understand which substories are completed

### Step 4: Generate PR Title and Description

**Title Format:** `[type](scope): brief description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

Examples:
- `feat(auth): add OAuth2 social login support`
- `fix(api): prevent null pointer in user serializer`
- `refactor(mobile): extract booking logic to view models`

**Description Template:**

Create focused, scannable description with core sections only:

```markdown
## Summary
[2-3 sentence overview of what this PR accomplishes and why]

## Related PRD
[Link to PRD if exists: `docs/prds/YYYY-MM-DD-feature-name.md`]

**Completed Substories:**
- ✅ [Phase X.Y] Substory title
- ✅ [Phase X.Z] Substory title

## Changes

### Added
- [List new features, files, endpoints]

### Modified
- [List changed files/features]

### Removed
- [List deprecated/deleted code]

## Testing

**Test Coverage:** X% → Y% (+Z%)

**Tests Added:**
- Unit tests: [count] tests
- Integration tests: [count] tests
- E2E tests: [count] tests (if applicable)

**Manual Testing:**
- [Platform-specific testing performed]
- [Devices/browsers tested]
- [Key scenarios verified]

**All tests passing:** ✅

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Keep it simple** - reviewers can read the code for implementation details!

### Step 5: Present PR Preview and Get Approval

**Show the generated PR to the user:**

```markdown
📝 Generated Pull Request:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: feat(auth): add OAuth2 social login support

## Summary
Implement OAuth2 authentication for Google, GitHub, and Apple.
Users can now sign in using their social accounts with secure
token management and account linking.

## Related PRD
docs/prds/2024-10-25-auth.md

**Completed Substories:**
- ✅ [Phase 1.1] OAuth provider configuration
- ✅ [Phase 1.2] Callback handler implementation
- ✅ [Phase 1.3] Token encryption and storage

## Changes

### Added
- OAuth2Service for provider authentication
- Token encryption using AES-256
- Account linking for existing users

### Modified
- User model to support OAuth identities
- Authentication controller for OAuth flow

## Testing

**Test Coverage:** 78% → 94% (+16%)

**Tests Added:**
- Unit tests: 23 tests
- Integration tests: 8 tests

**All tests passing:** ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create PR with this description? [yes/no/edit]
```

**Wait for user approval.**

### Step 6: Create the PR (After Approval)

**Only after user says "yes", execute:**

```bash
# Ensure branch is pushed (if not already)
git push -u origin $(git branch --show-current)

# Create PR with generated description
gh pr create \
  --title "[title]" \
  --body "$(cat <<'EOF'
[generated description]
EOF
)" \
  --base main
```

### Step 7: Update PRD and Confirm Success

After PR is created:

```markdown
✅ PR created successfully!
🔗 PR URL: https://github.com/org/repo/pull/123
📊 Summary: 8 files changed, 5 commits

💡 PR has been linked to PRD (if applicable)

Next steps:
- Wait for CI checks to complete
- Assign reviewers if needed: gh pr edit --add-reviewer @username
- Monitor PR for review feedback

🎉 Great work!
```

**If related to PRD, update it with PR reference:**
```markdown
## Implementation Status
- ✅ Phase 1 completed - PR #123 (2024-10-25)
```

## Best Practices

### Title
- Clear and concise
- Follow conventional commits format
- Mention key feature/fix

### Description
- Focused and scannable (4 core sections)
- Link to related PRD and substories
- Include testing evidence
- Show what changed (Added/Modified/Removed)

### Testing
- Be specific about test coverage changes
- List test types and counts
- Confirm all tests passing

## Important Notes

**This skill does NOT:**
- Auto-commit uncommitted changes
- Auto-push your branch
- Auto-merge or auto-approve
- Modify your code

**This skill DOES:**
- Generate comprehensive PR descriptions
- Link to related PRDs automatically
- Summarize changes intelligently
- Wait for your approval before creating PR
- Update PRD with PR reference after creation

**Philosophy:** You maintain full control. This skill is a writing assistant for PR descriptions, not an automation engine.
