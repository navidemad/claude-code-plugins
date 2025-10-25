---
name: commit
description: Generate well-formatted conventional commit messages. Activates when user says commit, save changes, create commit, save my work, git commit. French: committer, sauvegarder les modifications, créer un commit.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(.claude/skills/shared/scripts/detect_platform.sh:*)
---

# Commit

Generate focused, well-formatted git commits using Conventional Commits format. This skill is a **commit message assistant** - it helps you create great commits, you stay in control.

## When to Activate

This skill activates automatically when the user:
- Says "commit", "create a commit", "make a commit"
- Says "save my work", "commit my changes", "save these changes"
- Mentions "git commit" or "commit this code"
- French: "committer", "sauvegarder", "créer un commit", "enregistrer les modifications"

## Process

### Step 1: Gather Context

Run git commands in parallel to understand changes:

```bash
git status                    # See staged/unstaged files
git diff HEAD                 # All changes (staged + unstaged)
git diff HEAD --shortstat     # Get lines/files changed count
git log --oneline -5          # Recent commits for style context
bash .claude/skills/shared/scripts/detect_platform.sh  # Detect platform
```

**Show change summary:**
```
📊 Changes detected:
- 8 files changed
- 247 lines (+189/-58)
- Files: app/models/user.rb, app/services/auth/, spec/...
```

**Analyze:**
- Which files changed and their paths
- Nature of changes (new feature, bug fix, refactor, etc.)
- Platform-specific scope from file paths
- If changes should be split into multiple commits

**If changes span multiple unrelated areas:**
```
💡 Notice: Changes span both authentication (3 files) and booking (5 files).
   Consider splitting into separate commits for cleaner history.

   Continue with single commit? [yes/split/cancel]
```

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

### Step 5: Present Commit Message and Get Approval

**Show the generated commit message to the user:**

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

Related: PRD-2024-10-25-auth (substory 1.3)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with this commit? [yes/no/edit message]
```

**Wait for user approval.**

### Step 6: Create the Commit (After Approval)

**Only after user says "yes", execute:**

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

### Step 7: Confirm Success and Suggest Next Steps

After commit is created:

```markdown
✅ Commit created successfully!
📝 Commit hash: a1b2c3d
📊 Files committed: 8 files, +189/-58 lines

💡 Suggested next steps:
- "review my code" - Review other changes before committing
- "create a PR" - Create pull request for this branch
- "show progress" - See PRD implementation status
- Continue working on your feature

What would you like to do next?
```

**Do NOT auto-invoke any other skills. Just suggest and wait.**

## Handling Different Scenarios

### Multiple Unrelated Changes

If changes span unrelated areas:
```
💡 Notice: Changes span both authentication (3 files) and booking (5 files).
   These seem unrelated - consider separate commits for cleaner history.

   Options:
   1. Create single commit anyway
   2. Commit authentication files only (I'll help with booking next)
   3. Cancel and let me manually stage files

   What would you like? [1/2/3]
```

### No Changes to Commit

If `git diff HEAD` shows no changes:
```
❌ No changes detected to commit.

💡 If you have untracked files, use: git add <file>
   Or if you want to amend the last commit, say "amend last commit"
```

### Unstaged Changes

If changes exist but nothing staged:
```
📊 Found unstaged changes in 8 files:
- app/models/user.rb
- app/services/auth/oauth_service.rb
- spec/models/user_spec.rb
...

Stage all files and commit? [yes/select files/cancel]
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
