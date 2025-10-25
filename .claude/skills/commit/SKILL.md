---
name: commit
description: Create git commits with Conventional Commits format. Activates when user says commit, save changes, create commit, save my work, or git commit.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(.claude/skills/shared/scripts/detect_platform.sh:*)
---

# Commit

Create focused git commits with platform-aware, Conventional Commits formatted messages.

## When to Activate

This skill activates automatically when the user:
- Says "commit" or "create a commit"
- Says "save my work" or "commit my changes"
- Mentions "git commit" or "make a commit"
- Asks to "commit this code" or "commit these files"
- Says "save these changes"

## Process

### Step 1: Gather Context

Run git commands in parallel to understand changes:

```bash
git status                    # See staged/unstaged files
git diff HEAD                 # All changes (staged + unstaged)
git log --oneline -5          # Recent commits for style context
bash .claude/skills/shared/scripts/detect_platform.sh  # Detect platform
```

Analyze:
- Which files changed and their paths
- Nature of changes (new feature, bug fix, refactor, etc.)
- Platform-specific scope from file paths
- If changes should be split into multiple commits

### Step 2: Determine Commit Type

Identify the type based on changes:

- **feat**: New feature or capability
- **fix**: Bug fix
- **refactor**: Code refactoring (no functional change)
- **docs**: Documentation only
- **test**: Adding or updating tests
- **chore**: Maintenance (dependencies, config, etc.)
- **perf**: Performance improvement
- **style**: Code style/formatting (no logic change)
- **ci**: CI/CD changes
- **build**: Build system changes

### Step 3: Detect Platform & Scope

**First, detect the platform:**
```bash
bash .claude/skills/shared/scripts/detect_platform.sh
```

Determine scope from file paths based on detected platform:

**Rails** (if platform is `rails`):
- `app/models/` → models or specific model name
- `app/controllers/` → controllers or specific controller
- `app/services/` → services
- `db/migrate/` → db
- `config/` → config
- `lib/` → lib

**Android Kotlin** (if platform is `android-kotlin`):
- `presentation/` → ui or specific screen
- `data/` → data or repository
- `domain/` → domain or use-case
- UI files → ui-android or specific screen
- Multiple modules → module name

**iOS Swift** (if platform is `ios-swift`):
- ViewControllers → ui or specific screen
- ViewModels → viewmodel
- Models → models
- Services → services
- Views → ui or component

**Cross-cutting:**
- Multiple areas → use general scope like "auth", "api", "booking"

### Step 4: Generate Commit Message

#### Format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Subject Line (required, max 50 chars):
- Imperative mood: "add" not "added" or "adds"
- Lowercase (except proper nouns)
- No period at end
- Summarize WHAT was done

Examples:
- `feat(auth): add OAuth2 social login support`
- `fix(api): prevent null pointer in user serializer`
- `refactor(booking): extract validation logic to service`

#### Body (optional, wrap at 72 chars):
- Explain WHY the change was made
- Provide context not obvious from code
- Can use bullet points with `-`
- Separate from subject with blank line

Example:
```
Implement OAuth2 authentication to support social login.
Users can now sign in with Google, GitHub, or Apple.

- Add OAuth2 provider configurations
- Create callback handler for provider responses
- Store OAuth tokens securely in encrypted format
- Add user profile synchronization from providers
- Implement account linking for existing users
```

#### Footer (optional):
- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Fixes #123`, `Closes #456`
- PRD references: `Related: PRD-2024-10-25-auth (substory 1.3)`
- Co-authors: `Co-authored-by: Name <email>`

### Step 5: Create the Commit

**Execute in a SINGLE message with multiple tool calls:**

```bash
# Stage all relevant files
git add [files]

# Create commit with generated message
git commit -m "$(cat <<'EOF'
type(scope): subject

body

footer

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# Show result
git status
```

**Important:** Use heredoc format for commit message to preserve formatting.

### Step 6: Confirm Success

After commit is created:
1. Show commit hash and message
2. Display files committed
3. Confirm next steps if user requests (push, PR, continue working)

## Handling Different Scenarios

### Multiple Unrelated Changes

If changes span unrelated areas:
```
"I see changes to authentication (3 files) and booking system (5 files).
These seem unrelated. Should we create separate commits?"
```

Offer to commit them separately for cleaner history.

### Large Changesets

For many files changed:
- Group by logical areas
- Suggest breaking into multiple commits
- Or create one commit with detailed body listing all areas

### Incomplete Work

If changes are incomplete or break tests:
```
"These changes appear to be work in progress. Create a WIP commit?"
```

Format: `wip: describe what's in progress`

### No Changes Staged

If nothing is staged:
```
"No changes are staged. Would you like me to:
1. Stage all changes and commit
2. Help you select which files to stage
3. Cancel"
```

### Only Unstaged Changes

If changes are unstaged:
```
"Changes are unstaged. I'll stage them for commit. Files to include:
- file1.rb
- file2.kt
Proceed?"
```

## Examples

### Example 1: New Feature
```
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication to support social login.
Users can now sign in with Google, GitHub, and Apple.

Technical implementation:
- OAuth2Service handles provider authentication flow
- Secure token storage with encryption at rest
- Account linking for users with existing email accounts
- Graceful fallback to traditional email/password login

Related: PRD-2024-10-25-auth (substory 1.3)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example 2: Bug Fix
```
fix(api): prevent null pointer exception in user serializer

The UserSerializer was crashing when optional profile fields
were missing. Added null safety checks and default values.

- Check for nil before accessing nested attributes
- Provide sensible defaults for optional fields
- Add specs to cover edge cases

Fixes #789

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example 3: Refactor
```
refactor(booking): extract validation logic to service object

Move complex booking validation from controller to
BookingValidationService for better testability and reuse.

- Create BookingValidationService with clear interface
- Update controller to delegate validation
- Extract date/time validation rules
- Add comprehensive unit tests for validation logic

No functional changes - all existing tests pass.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example 4: Multiple Areas
```
feat(mobile): implement offline mode for parking history

Add offline support across Android and iOS apps to allow
users to view their parking history without internet.

Android changes:
- Room database for local caching
- WorkManager for background sync
- Repository pattern for data access

iOS changes:
- CoreData for local caching
- Background refresh for sync
- Repository pattern for data access

Shared:
- API models support offline state
- Sync conflict resolution
- Cache expiration after 7 days

Related: PRD-2024-10-20-offline (substory 2.1)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example 5: Tests
```
test(auth): add comprehensive OAuth flow integration tests

Add integration tests covering complete OAuth authentication
flow including success cases, failures, and edge cases.

Test scenarios:
- Successful OAuth login for each provider
- OAuth callback error handling
- Token refresh flow
- Account linking scenarios
- Concurrent authentication attempts
- Invalid state parameter (CSRF attack)

Coverage increased from 78% to 94% for auth module.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Best Practices

### Subject Line
- Be specific: "add OAuth login" not "update auth"
- Imperative mood: "fix bug" not "fixed bug"
- Keep under 50 characters
- Don't end with period

### Body
- Explain WHY, not WHAT (code shows what)
- Wrap at 72 characters
- Use bullet points for lists
- Mention PRD substories when applicable
- Note breaking changes prominently

### Scope
- Be consistent with project conventions
- Use general scopes for cross-cutting changes
- Platform-specific scopes when appropriate

### When to Split
- Unrelated functional changes
- Different types (feat + refactor)
- Different components/modules
- Makes code review easier

## Output

Provide:
- ✅ Commit created successfully
- 📝 Commit hash: abc123f
- 📊 Files changed: X files, +Y/-Z lines
- 💬 Message preview
- ➡️  Next steps: push, continue working, or create PR

## Tips

- Read recent commits to match project style
- Check for PRD references in related files
- Verify tests pass before committing
- Keep commits focused and atomic
- Use conventional commits for automation compatibility
- Always explain WHY in commit body for complex changes
