---
name: publish
description: Ship code when user wants to commit changes, create pull requests, or save work. Auto-detects whether to create commits or PRs based on git state. Generates well-formatted messages with PRD references. Always waits for approval before executing git commands.
---

# Publish Changes

Create well-formatted git commits and GitHub pull requests with automatic PRD referencing. This skill is a **git assistant** - it helps you ship code, you stay in control.

## When to Activate

This skill activates when user says things like:
- "ship this"
- "commit changes"
- "save my work"
- "create a commit"
- "make a PR"
- "create pull request"
- "submit for review"
- "push this code"
- Any request to commit, ship, or create a pull request

## Mode Detection

The skill **automatically detects** what you want to do based on git state:

1. **Commit Mode** - When uncommitted changes exist
   - Detects: Uncommitted changes in working directory
   - Creates: Conventional commit with PRD reference
   - Shows: Preview before execution

2. **Pull Request Mode** - When branch is clean and ahead of base
   - Detects: Clean working directory + commits ahead of main/master
   - Creates: GitHub PR with comprehensive description
   - Shows: Preview before execution

**User says "ship" → Skill detects mode → Confirms with user → Executes**

## Workflow

### Mode 1: Commit

#### Step 0: Confirm Mode Detection

**Show detected mode to user:**
```
🔍 Detected uncommitted changes

Mode: Commit
Files changed: 8 files (+247/-58 lines)

Proceed with commit creation? [yes/show-changes/cancel]
```

**If user says "show-changes":**
- Show full `git diff --stat`
- Then ask again: "Proceed with commit? [yes/cancel]"

**If user says "cancel":**
- Exit without doing anything

**If user says "yes":**
- Continue to Step 1

#### Step 1: Analyze Changes Comprehensively

**Load git tools and analyze changes:**
```bash
# Source shared git tools
source skills/shared/scripts/git-tools.sh

# Analyze changes with detailed stats
changes=$(analyze_git_changes "HEAD")

# Parse the output
files_changed=$(echo "$changes" | grep "FILES_CHANGED=" | cut -d'=' -f2)
insertions=$(echo "$changes" | grep "INSERTIONS=" | cut -d'=' -f2)
deletions=$(echo "$changes" | grep "DELETIONS=" | cut -d'=' -f2)

# Get detailed file list with status
git diff HEAD --name-status

# Categorize changes by type
new_files=$(git diff HEAD --name-only --diff-filter=A)
modified_files=$(git diff HEAD --name-only --diff-filter=M)
deleted_files=$(git diff HEAD --name-only --diff-filter=D)
```

**Analyze change patterns:**
```bash
# Group files by directory/area
# Detect if changes span multiple features
# Identify primary area of change

# Analyze actual diff content to understand nature of changes:
# - Are we adding new functionality? (new classes, functions)
# - Are we fixing bugs? (error handling, validation)
# - Are we refactoring? (moving code, renaming)
# - Are we updating tests? (test files changed)
```

**Show comprehensive change summary:**
```
📊 Changes Analyzed:

Statistics:
- 8 files changed (+247/-58 lines)
- New files: 2
- Modified files: 5
- Deleted files: 1

Changes by area:
- Authentication (5 files, +180/-20 lines)
  * app/models/user.rb
  * app/services/auth/oauth_service.rb
  * app/controllers/auth_controller.rb
  * spec/models/user_spec.rb
  * spec/services/oauth_service_spec.rb

- Testing (3 files, +67/-38 lines)
  * spec/models/user_spec.rb
  * spec/services/oauth_service_spec.rb
  * spec/integration/oauth_flow_spec.rb

Nature of changes:
- New functionality: OAuth provider integration
- Modified: User model with OAuth fields
- Tests: Comprehensive test coverage added
```

**Check for multiple unrelated areas:**
If changes span multiple distinct features, suggest splitting:
```
💡 Notice: Changes span multiple areas:
   - Authentication (5 files)
   - Booking system (3 files)

   These appear to be unrelated changes. Recommend splitting into:
   1. Commit for authentication changes
   2. Commit for booking changes

   Benefits: Cleaner history, easier review, better git bisect

   Continue with single commit? [yes/split/cancel]
```

**If user chooses "split":**
- Help create multiple commits by feature area
- Process each area separately through commit workflow

#### Step 2: Analyze Changed Files

```bash
# Get changed files
changed_files=$(git diff HEAD --name-only)

# Optionally detect scope from common directory patterns
# Scope is optional and can be omitted if not clear
scope=$(detect_scope_from_files "$changed_files")
```

**Note**: Scope detection uses simple heuristics (most common directory). Claude will analyze the changes and may choose to omit scope if it's not meaningful or use a more descriptive scope based on the actual changes.

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

#### Step 4: Find Related PRD Intelligently

**Multi-strategy PRD detection:**
```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# Strategy 1: Check recent commits for PRD references
prd_from_commits=$(git log -5 --oneline | grep -o '.claude/prds/[^)]*\.md' | head -1)

# Strategy 2: Find PRD from changed files
# - Match file paths to PRD context files
# - Check .claude/prds/context/*.json for files_created
for context_file in .claude/prds/context/*.json; do
    if [[ -f "$context_file" ]]; then
        context_files=$(jq -r '.files_created[]' "$context_file")
        # Check if any changed files match context files
        for changed_file in $changed_files; do
            if echo "$context_files" | grep -q "$changed_file"; then
                prd_file=$(basename "$context_file" .json)
                related_prd=".claude/prds/${prd_file}.md"
                break 2
            fi
        done
    fi
done

# Strategy 3: Check for in-progress PRDs
# - Find PRDs with status "In Progress"
# - Suggest most recently modified PRD
in_progress_prds=$(grep -l "Status.*In Progress" .claude/prds/*.md 2>/dev/null)

# Strategy 4: Ask user if multiple matches or no match found
if [[ -z "$related_prd" ]] && [[ -n "$in_progress_prds" ]]; then
    # Present options to user
fi
```

**Show PRD detection results:**
```
🔍 PRD Detection:

Strategy used: [Strategy name]
Related PRD: .claude/prds/2024-10-25-oauth-core.md

PRD Details:
- Type: Core Feature
- Status: In Progress
- Phase: Phase 1 - OAuth Integration (3/4 substories complete)

This commit relates to: [Substory 1.3] Token management

✅ Will include PRD reference in commit message
```

**If no PRD detected:**
```
ℹ️  No related PRD detected

Checked:
- Recent commits (no PRD references found)
- Context files (changed files don't match any PRD)
- In-progress PRDs (none found)

Options:
1. Continue without PRD reference (standalone commit)
2. Manually specify PRD: [enter path]

Choice: [1/2]
```

#### Step 5: Generate Commit Message

**Format:**
```
<type>(<scope>): <subject>
# or if scope is not meaningful:
<type>: <subject>

<body>

<footer>

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Scope is optional** - omit it if the changes don't fit a clear scope.

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
- PRD reference: `Related: .claude/prds/2024-10-25-auth-core.md (Phase 1)`
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

Related: .claude/prds/2024-10-25-auth-core.md (Phase 1)

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

Related: .claude/prds/2024-10-25-auth-core.md (Phase 1)

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

#### Step 0: Confirm Mode Detection

**Show detected mode to user:**
```
🔍 Detected clean branch with commits ahead

Mode: Pull Request
Branch: feature/oauth-login
Base: main
Commits ahead: 5 commits

Proceed with PR creation? [yes/show-commits/cancel]
```

**If user says "show-commits":**
- Show `git log main..HEAD --oneline`
- Then ask again: "Proceed with PR? [yes/cancel]"

**If user says "cancel":**
- Exit without doing anything

**If user says "yes":**
- Continue to Step 1

#### Step 1: Verify Branch is Clean

**FIRST: Check for uncommitted changes:**

```bash
source skills/shared/scripts/git-tools.sh

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
   Say "ship" to commit these changes (will switch to Commit Mode)
   Then say "ship" again to create PR

Alternatively:
- git stash    (save changes for later)
- git reset    (discard changes)
```

**Do NOT auto-commit. User must explicitly commit first.**

#### Step 2: Gather Information and Analyze Comprehensively

**Source tools and gather git information:**
```bash
# Source shared tools
source skills/shared/scripts/git-tools.sh

# Get current branch
current_branch=$(get_current_branch)

# Get base branch (main/master)
base_branch=$(get_base_branch)

# Get commits ahead
commits_ahead=$(get_commits_ahead)
```

**Analyze branch changes comprehensively:**
```bash
# Get detailed change statistics
changes=$(analyze_git_changes "$base_branch...HEAD")

# Get commit messages with details
commits=$(git log "$base_branch..HEAD" --oneline)

# Get files changed with status (A=added, M=modified, D=deleted)
git diff "$base_branch...HEAD" --name-status

# Categorize files by change type
new_files=$(git diff "$base_branch...HEAD" --name-only --diff-filter=A)
modified_files=$(git diff "$base_branch...HEAD" --name-only --diff-filter=M)
deleted_files=$(git diff "$base_branch...HEAD" --name-only --diff-filter=D)

# Analyze diff content for detailed insights
git diff "$base_branch...HEAD" --stat
```

**Perform deep analysis:**

1. **Feature Analysis:**
   - Identify new features added (new classes, modules, endpoints)
   - Identify improvements to existing features
   - Identify bug fixes and corrections

2. **Test Analysis:**
   - Count test files changed
   - Estimate test coverage change (if coverage tool available)
   - Identify test types (unit, integration, e2e)

3. **Schema/Data Changes:**
   - Detect database migrations
   - Identify schema changes (models, SQL files)
   - Check for data transformation scripts

4. **Dependency Analysis:**
   - Check package.json, requirements.txt, Gemfile for new dependencies
   - Identify version upgrades
   - Note dependency removals

5. **Documentation:**
   - Check for README updates
   - Identify new documentation files
   - Note code comment additions

6. **Breaking Changes:**
   - Detect API signature changes
   - Identify removed public methods
   - Check for configuration changes

**Present comprehensive analysis:**
```
📊 Branch Analysis: feature/oauth-login → main

Commits: 5 commits ahead
Files: 12 files changed (+347/-89 lines)

Changes by category:
- New files (3):
  * src/services/oauth_service.ts - OAuth provider integration
  * src/models/oauth_token.ts - Token model
  * src/types/oauth.types.ts - Type definitions

- Modified files (8):
  * src/models/user.ts - Added OAuth fields
  * src/controllers/auth_controller.ts - OAuth endpoints
  * [+ 6 more files]

- Deleted files (1):
  * src/legacy/old_auth.ts - Removed deprecated code

Test Changes:
- New tests: 23 tests added
- Modified tests: 5 tests updated
- Coverage: 78% → 94% (+16%)
- Test breakdown:
  * Unit: 15 tests
  * Integration: 8 tests

Schema Changes:
- Database: 1 migration added (add_oauth_fields_to_users)
- Models: User model extended with oauth_provider, oauth_uid

Dependencies:
- Added: passport (v0.6.0) - OAuth authentication
- No version changes or removals

Documentation:
- README.md updated with OAuth setup instructions
- Added API documentation for OAuth endpoints
```

#### Step 3: Find Related PRD and Load Context

**Multi-strategy PRD detection (same as commit mode):**
```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# Strategy 1: Check commit messages for PRD references
prd_from_commits=$(git log "$base_branch..HEAD" | grep -o '.claude/prds/[^)]*\.md' | head -1)

# Strategy 2: Match changed files to PRD context files
for context_file in .claude/prds/context/*.json; do
    if [[ -f "$context_file" ]]; then
        context_files=$(jq -r '.files_created[]' "$context_file")
        for changed_file in $changed_files; do
            if echo "$context_files" | grep -q "$changed_file"; then
                prd_file=$(basename "$context_file" .json)
                related_prd=".claude/prds/${prd_file}.md"
                break 2
            fi
        done
    fi
done

# Strategy 3: Check branch name for PRD hints
# e.g., feature/oauth-login might match oauth-core PRD
branch_hint=$(echo "$current_branch" | sed 's/feature\///' | sed 's/-login//')
matching_prd=$(find .claude/prds/ -name "*${branch_hint}*.md" | head -1)
```

**If PRD found, load comprehensive context:**
```bash
# Read PRD file
prd_content=$(cat "$related_prd")

# Extract PRD metadata
prd_type=$(grep "Type:" "$related_prd" | head -1)
prd_status=$(grep "Status:" "$related_prd" | head -1)

# Load context file if exists
context_file=".claude/prds/context/$(basename $related_prd .md).json"
if [[ -f "$context_file" ]]; then
    prd_context=$(cat "$context_file")

    # Extract completed substories from PRD
    completed_substories=$(grep "✅.*\[" "$related_prd")

    # Extract phase information
    current_phase=$(grep "Phase.*Complete\|Phase.*In Progress" "$related_prd" | tail -1)
fi

# For expansion PRDs, load core PRD info too
if echo "$prd_type" | grep -q "Expansion"; then
    core_prd=$(grep "Builds On:" "$related_prd" | sed 's/.*(\(docs\/prds\/[^)]*\)).*/\1/')
    if [[ -f "$core_prd" ]]; then
        core_prd_name=$(basename "$core_prd" .md)
    fi
fi
```

**Show PRD detection and context loading:**
```
🔍 PRD Detection:

Found: .claude/prds/2024-10-25-oauth-core.md
Strategy: Matched changed files to PRD context
Type: Core Feature
Status: In Progress → Completed (with this PR)

Context loaded:
- Phase 1: OAuth Integration (4/4 substories completed)
- Files created: 12 files
- Patterns established: Service layer, Token encryption
- Tests: 45 tests, 94% coverage

Completed substories in this PR:
✅ [1.1] OAuth provider configuration
✅ [1.2] Callback handler implementation
✅ [1.3] Token encryption and storage
✅ [1.4] Account linking logic

This PR completes the core OAuth implementation!
```

#### Step 4: Generate PR Title and Description

**Title Format:** `[type](scope): brief description`

Examples:
- `feat(auth): add OAuth2 social login support`
- `fix(api): prevent null pointer in user serializer`
- `refactor(mobile): extract booking logic to view models`

**Description Template (Enhanced):**

```markdown
## Summary
[2-3 sentence overview of what this PR accomplishes and why it matters]

## Related PRD
[Link to PRD: `.claude/prds/YYYY-MM-DD-feature-name.md`]

**PRD Type:** [Core Feature/Expansion/Task]
**Status Change:** [Previous Status] → [New Status]

**Completed Substories:**
- ✅ [Phase X.Y] Substory title
- ✅ [Phase X.Y] Substory title
- ✅ [Phase X.Y] Substory title

[For Expansion PRDs only:]
**Builds On:** [Core PRD name and link]
**Extends Core With:** [Brief description of what this expansion adds]

## Changes

### Added ([X] new files)
- [Feature/component] - [Description of functionality]
- [New endpoint/API] - [Purpose and usage]
- [New model/service] - [What it handles]

### Modified ([Y] files)
- [File/component] - [What changed and why]
- [Existing feature] - [Enhancement description]

### Removed ([Z] files)
- [Deprecated code] - [Reason for removal]

[If schema changes exist:]
## Database Changes
- **Migrations:** [Count] migration(s) added
  - [Migration name] - [What it does]
- **Models Updated:** [List models with changes]
- **Indexes Added:** [If applicable]

[If dependencies changed:]
## Dependencies
**Added:**
- [package-name] (v[version]) - [Purpose]

**Updated:**
- [package-name] (v[old] → v[new]) - [Reason for update]

**Removed:**
- [package-name] - [Reason for removal]

## Testing

**Test Coverage:** [X]% → [Y]% ([+/-Z]%)

**Tests Added:** [Total] tests
- Unit tests: [count] tests
- Integration tests: [count] tests
- E2E tests: [count] tests (if applicable)

**Key Test Areas:**
- [Feature area 1] - [coverage description]
- [Feature area 2] - [coverage description]

**All tests passing:** ✅ [count]/[count]

[For Expansion PRDs only:]
## Pattern Consistency
✅ Follows core patterns:
- [Pattern 1 from core]
- [Pattern 2 from core]
- [Pattern 3 from core]

## Documentation
[If documentation changes exist:]
- README updated with [what was added]
- API docs added for [endpoints]
- Code comments added for [complex logic]

## Breaking Changes
[If none:] None

[If breaking changes exist:]
⚠️ **Breaking Changes:**
- [Change description]
  - **Migration path:** [How to update code]
- [Another change]
  - **Migration path:** [How to update code]

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
.claude/prds/2024-10-25-auth-core.md

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
.claude/prds/2024-10-25-auth-core.md

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

Related: .claude/prds/2024-10-25-auth-core.md (Phase 1)

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
.claude/prds/2024-10-28-invoice-customer-details.md

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

**Note**: The "Follows Core Patterns" section is specific to expansion PRs and should list the actual patterns established in the core PRD for that project (loaded from context). This example shows Rails patterns, but your project may use different patterns documented in CLAUDE.md.

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

## Directory Structure

This skill reads PRDs from:

```
.claude/prds/
├── YYYY-MM-DD-feature-core.md              # Active PRD files
├── YYYY-MM-DD-feature-expansion.md
├── context/                                 # Active context files
│   ├── YYYY-MM-DD-feature-core.json
│   └── YYYY-MM-DD-feature-expansion.json
└── archive/                                 # Archived PRDs (user managed)
    ├── old-feature.md
    └── context/
        └── old-feature.json
```

**Note:** The skill only searches active PRDs (not archived ones) when detecting related PRDs for commits/PRs.

## Shared Code

This skill uses `skills/shared/scripts/git-tools.sh` for common git operations, ensuring consistency and reducing code duplication.
