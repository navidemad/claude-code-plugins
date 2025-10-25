---
name: ship
description: Create commits and pull requests with conventional formats. Auto-references PRDs, waits for approval before executing git commands. Activates when user says commit, create PR, ship changes. French: committer, créer une PR, soumettre.
allowed-tools: Bash(git:*), Bash(gh pr create:*), Bash(.claude/skills/shared/scripts/detect_platform.sh:*), Read, Glob
---

# Ship Changes

Create well-formatted git commits and GitHub pull requests with automatic PRD referencing. This skill is a **git assistant** - it helps you ship code, you stay in control.

## When to Activate

This skill activates when user:
- Says "commit", "create a commit", "save changes"
- Says "create PR", "make pull request", "submit for review"
- Mentions "git commit" or "ship this code"
- French: "committer", "créer une PR", "soumettre pour révision"

## Mode Detection

The skill automatically detects what you want to do:

1. **Commit Mode** - Create a git commit
   - Triggers: "commit", "save changes", "git commit"
   - Creates: Conventional commit with PRD reference

2. **Pull Request Mode** - Create a GitHub PR
   - Triggers: "create PR", "pull request", "submit for review"
   - Creates: GitHub PR with comprehensive description

## Workflow

### Mode 1: Commit

#### Step 1: Analyze Changes

```bash
# Source shared git tools
source .claude/skills/shared/lib/git-tools.sh

# Analyze changes
changes=$(analyze_git_changes "HEAD")

# Parse the output
files_changed=$(echo "$changes" | grep "FILES_CHANGED=" | cut -d'=' -f2)
insertions=$(echo "$changes" | grep "INSERTIONS=" | cut -d'=' -f2)
deletions=$(echo "$changes" | grep "DELETIONS=" | cut -d'=' -f2)

# Get file list
git diff HEAD --name-only
```

**Show change summary:**
```
📊 Changes detected:
- 8 files changed
- +247 lines added
- -58 lines removed
- Files: app/models/user.rb, app/services/auth/, spec/...
```

**Check for multiple unrelated areas:**
If changes span both "auth" and "booking" (for example), suggest splitting:
```
💡 Notice: Changes span both authentication (3 files) and booking (5 files).
   Consider splitting into separate commits for cleaner history.

   Continue with single commit? [yes/split/cancel]
```

#### Step 2: Detect Platform and Scope

```bash
# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Get changed files
changed_files=$(git diff HEAD --name-only)

# Detect scope based on files
scope=$(detect_scope_from_files "$platform" "$changed_files")
```

#### Step 3: Determine Commit Type

Analyze changes to identify type:

- **feat**: New feature or capability
- **fix**: Bug fix
- **refactor**: Code refactoring (no functional change)
- **docs**: Documentation only
- **test**: Adding or updating tests
- **chore**: Maintenance (dependencies, config, etc.)
- **perf**: Performance improvement
- **style**: Code style/formatting (no logic change)

#### Step 4: Find Related PRD

```bash
# Source context manager
source .claude/skills/shared/lib/context-manager.sh

# Find related PRD
related_prd=$(find_related_prd "$changed_files")

# Or check commits for PRD reference
prd_ref=$(get_prd_from_commits)
```

#### Step 5: Generate Commit Message

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Subject Line (max 50 chars):**
- Imperative mood: "add" not "added"
- Lowercase (except proper nouns)
- No period at end
- Summarize WHAT was done

**Body (wrap at 72 chars):**
- Explain WHY the change was made
- Provide context not obvious from code
- Can use bullet points with `-`

**Footer:**
- PRD reference: `Related: docs/prds/2024-10-25-auth-core.md (Phase 1)`
- Issue refs: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`

#### Step 6: Present Commit Message for Approval

```markdown
📝 Generated commit message:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication for Google, GitHub, and Apple.
Users can now sign in using their social accounts.

- Add OAuth2 provider configurations
- Create callback handler for authentication flow
- Store OAuth tokens securely with encryption
- Implement account linking for existing users

Related: docs/prds/2024-10-25-auth-core.md (Phase 1)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with this commit? [yes/no/edit]
```

**Wait for user approval.**

#### Step 7: Create Commit (After Approval)

**Only after user says "yes":**

```bash
# Stage all relevant files
git add [files]

# Create commit with heredoc format
git commit -m "$(cat <<'COMMITMSG'
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication for Google, GitHub, and Apple.
Users can now sign in using their social accounts.

- Add OAuth2 provider configurations
- Create callback handler for authentication flow
- Store OAuth tokens securely with encryption
- Implement account linking for existing users

Related: docs/prds/2024-10-25-auth-core.md (Phase 1)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
COMMITMSG
)"

# Get commit hash
commit_hash=$(git rev-parse HEAD)

# Update PRD if related
if [[ -n "$related_prd" ]]; then
    # Add commit hash to PRD
    # (Update Implementation Status section)
fi
```

#### Step 8: Confirm Success

```markdown
✅ Commit created successfully!

📝 Commit: a1b2c3d
📊 Files committed: 8 files, +247/-58 lines

💡 Next steps:
- "ship" again to create a PR
- Continue working on your feature
- "implement" to continue PRD implementation

What would you like to do?
```

---

### Mode 2: Pull Request

#### Step 1: Verify Branch is Clean

**FIRST: Check for uncommitted changes:**

```bash
source .claude/skills/shared/lib/git-tools.sh

if has_uncommitted_changes; then
    # ERROR - stop
fi
```

**If uncommitted changes exist - STOP:**
```
❌ ERROR: Cannot create PR - you have uncommitted changes

📊 Uncommitted changes:
- app/models/user.rb (modified)
- app/services/auth/oauth_service.rb (modified)
- spec/models/user_spec.rb (new file)

💡 Please commit your changes first:
   Say "ship" to commit these changes
   Then try "ship" again to create PR

Alternatively:
- git stash    (save changes for later)
- git reset    (discard changes)
```

**Do NOT auto-commit. User must explicitly commit first.**

#### Step 2: Gather Information

```bash
# Source shared tools
source .claude/skills/shared/lib/git-tools.sh

# Detect platform
platform=$(bash .claude/skills/shared/scripts/detect_platform.sh)

# Get current branch
current_branch=$(get_current_branch)

# Get base branch
base_branch=$(get_base_branch)

# Get commits ahead
commits_ahead=$(get_commits_ahead)

# Analyze branch diff
changes=$(analyze_git_changes "$base_branch...HEAD")

# Get commit messages
git log "$base_branch..HEAD" --oneline

# Get full diff
git diff "$base_branch...HEAD" --name-only
```

**Analyze:**
- What was added (new features/files)
- What was modified (improvements/fixes)
- What was removed (deprecated code)
- Test coverage changes
- Database migrations (Rails)
- New dependencies

#### Step 3: Find Related PRD

```bash
# Find PRD from commits or docs/prds/
related_prd=$(find_related_prd)

# Or get from commit messages
prd_ref=$(get_prd_from_commits)

# Read PRD if found
if [[ -n "$related_prd" ]]; then
    # Read PRD to extract completed substories
fi
```

#### Step 4: Generate PR Title and Description

**Title Format:** `[type](scope): brief description`

Examples:
- `feat(auth): add OAuth2 social login support`
- `fix(api): prevent null pointer in user serializer`
- `refactor(mobile): extract booking logic to view models`

**Description Template:**

```markdown
## Summary
[2-3 sentence overview of what this PR accomplishes and why]

## Related PRD
[Link to PRD if exists: `docs/prds/YYYY-MM-DD-feature-name.md`]

**Completed Substories:**
- ✅ [Phase 1.1] Substory title
- ✅ [Phase 1.2] Substory title

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

**All tests passing:** ✅

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

#### Step 5: Present PR Preview for Approval

```markdown
📝 Generated Pull Request:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: feat(auth): add OAuth2 social login support

## Summary
Implement OAuth2 authentication for Google, GitHub, and Apple.
Users can now sign in using their social accounts with secure
token management and account linking.

## Related PRD
docs/prds/2024-10-25-auth-core.md

**Completed Substories:**
- ✅ [Phase 1.1] OAuth provider configuration
- ✅ [Phase 1.2] Callback handler implementation
- ✅ [Phase 1.3] Token encryption and storage
- ✅ [Phase 1.4] Account linking logic

## Changes

### Added
- OAuth2Service for provider authentication
- Token encryption using AES-256
- Account linking for existing users
- Comprehensive test suite

### Modified
- User model to support OAuth identities
- Authentication controller for OAuth flow

## Testing

**Test Coverage:** 78% → 94% (+16%)

**Tests Added:**
- Unit tests: 23 tests
- Integration tests: 8 tests

**All tests passing:** ✅

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch: feature/oauth-login
Base: main
Commits: 5 commits ahead

Create PR with this description? [yes/no/edit]
```

**Wait for user approval.**

#### Step 6: Create PR (After Approval)

**Only after user says "yes":**

```bash
# Ensure branch is pushed
git push -u origin $(get_current_branch)

# Create PR using gh CLI
gh pr create \
  --title "feat(auth): add OAuth2 social login support" \
  --body "$(cat <<'PRBODY'
## Summary
Implement OAuth2 authentication for Google, GitHub, and Apple.
Users can now sign in using their social accounts with secure
token management and account linking.

## Related PRD
docs/prds/2024-10-25-auth-core.md

**Completed Substories:**
- ✅ [Phase 1.1] OAuth provider configuration
- ✅ [Phase 1.2] Callback handler implementation
- ✅ [Phase 1.3] Token encryption and storage
- ✅ [Phase 1.4] Account linking logic

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

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
PRBODY
)" \
  --base main

# Get PR URL
pr_url=$(gh pr view --json url --jq '.url')
```

#### Step 7: Update PRD and Confirm Success

```bash
# If related to PRD, update it with PR reference
if [[ -n "$related_prd" ]]; then
    # Add PR link to PRD Implementation Status
fi
```

```markdown
✅ PR created successfully!

🔗 PR URL: https://github.com/org/repo/pull/123
📊 Summary: 8 files changed, 5 commits

💡 PR has been linked to PRD (if applicable)

Next steps:
- Wait for CI checks to complete
- Assign reviewers: gh pr edit --add-reviewer @username
- Monitor PR for review feedback

🎉 Great work!
```

---

## Examples

### Example Commit

```
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication to support social login.
Users can now sign in with Google, GitHub, and Apple.

Technical implementation:
- OAuth2Service handles provider authentication flow
- Secure token storage with encryption at rest
- Account linking for users with existing email accounts
- Graceful fallback to traditional email/password login

Related: docs/prds/2024-10-25-auth-core.md (Phase 1)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example PR (Expansion)

```
feat(invoice): add customer details to invoices

## Summary
Extend invoice core with customer information tracking.
Invoices can now be associated with customer records including
contact details and billing information.

## Related PRD
docs/prds/2024-10-28-invoice-customer-details.md

**Type:** Expansion (builds on invoice-core)

**Completed Substories:**
- ✅ [Phase 1.1] Customer model and associations
- ✅ [Phase 1.2] Customer selection in invoice form
- ✅ [Phase 1.3] Customer details in invoice display

## Changes

### Added
- Customer model with validations
- Invoice-Customer association
- Customer selection dropdown in UI
- Customer details section in invoice view

### Modified
- Extended Invoice model with customer_id
- Updated invoice serializer to include customer
- Enhanced invoice form with customer selection

## Testing

**Test Coverage:** 94% → 95% (+1%)

**Tests Added:**
- Unit tests: 12 tests
- Integration tests: 5 tests

**All tests passing:** ✅

**Follows Core Patterns:** ✅
- Service objects for business logic
- RESTful API structure
- ActiveModel serializers

---

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Best Practices

### Commit Messages
- Be specific: "add OAuth login" not "update auth"
- Imperative mood: "fix bug" not "fixed bug"
- Keep under 50 characters
- Don't end with period

### PR Descriptions
- Focused and scannable (4 core sections)
- Link to related PRD and substories
- Include testing evidence
- Show what changed (Added/Modified/Removed)
- For expansions: Note core patterns followed

### When to Split Commits
- Unrelated functional changes
- Different types (feat + refactor)
- Different components/modules
- Makes code review easier

## Important Notes

**This skill does NOT:**
- Auto-commit without approval
- Auto-push without approval
- Auto-merge or auto-approve PRs
- Modify code

**This skill DOES:**
- Analyze changes intelligently
- Generate well-formatted messages/descriptions
- Reference PRDs automatically
- Wait for explicit approval
- Update PRDs with commit/PR links
- Use shared git-tools library for consistency

**Philosophy:** You maintain full control. This skill is a writing assistant for git operations, not an automation engine.

## Shared Code

This skill uses `.claude/skills/shared/lib/git-tools.sh` for common git operations, ensuring consistency and reducing code duplication.
