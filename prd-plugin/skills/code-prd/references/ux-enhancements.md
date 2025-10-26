# UX Enhancements Reference

**Purpose:** Detailed implementation specifications for all UX enhancements in the code-prd skill.

**Location:** `skills/code-prd/references/ux-enhancements.md`

**How to use this reference:**
- Main workflow is in `SKILL.md` with callout markers (📚 🧪 📋 💾 🔍 🎯)
- When you see a callout, read the corresponding section here for full implementation
- See "UX Enhancement Reference Map" in `SKILL.md` for quick navigation

**File Type:** Reference documentation (loaded as needed, not executed directly)

---

## Section 1: Learning Mode (Step 4.0 - Before each substory)

**When enabled**, show explanation before implementing:

```markdown
💡 Learning Mode: ON

About to implement: Substory 1.2 - OAuth callback handler

📚 My Approach:

**What I'll build:**
Create `/auth/callback` endpoint to handle OAuth provider redirects

**Why this pattern:**
- Follows RESTful routing (established in Substory 1.1)
- Separates concerns: Controller handles HTTP, Service handles OAuth logic
- Pattern from CLAUDE.md: Thin controller pattern

**Key decisions:**
1. Use OAuthService (created in 1.1) for token exchange
2. Store tokens in encrypted format (Security best practice)
3. Handle errors with custom OAuthError class (Consistent error handling)

**Files I'll create/modify:**
- `app/controllers/auth_controller.rb` - Add callback action
- `app/services/oauth_service.rb` - Add token_exchange method
- `spec/controllers/auth_controller_spec.rb` - Test callback flow

**Estimated complexity:** Medium (involves external API calls)

Ready to proceed? [yes/explain-more/adjust-approach]
```

**Smart mode** (only explain new patterns):
- Only shows explanation when introducing a pattern not seen in prior substories
- Skips explanation for repetitive patterns

**Disabled mode:**
- Proceeds directly to implementation without explanation

## Section 2: Dependency Warnings (Step 4.1 - Before substory execution)

Before implementing each substory, check for dependencies:

```bash
# Detect dependencies from substory description and acceptance criteria
dependencies=()

# Check for API keys/credentials
if grep -qi "api\|oauth\|key\|secret\|credential" <<< "$substory_text"; then
    # Check environment or config files
    if ! grep -q "GOOGLE_CLIENT_ID\|GITHUB_CLIENT_ID" .env 2>/dev/null; then
        dependencies+=("oauth_credentials")
    fi
fi

# Check for database migrations
if grep -qi "database\|migration\|schema\|table" <<< "$substory_text"; then
    # Check if migrations are pending
    if [[ $(rails db:migrate:status 2>/dev/null | grep -c "down") -gt 0 ]]; then
        dependencies+=("pending_migrations")
    fi
fi

# Check for external services
if grep -qi "redis\|elasticsearch\|postgres\|mysql" <<< "$substory_text"; then
    # Check if services are running
    if ! pgrep -x "redis-server" > /dev/null 2>&1; then
        dependencies+=("redis_not_running")
    fi
fi

# Check for package dependencies
if grep -qi "npm install\|bundle install\|pip install" <<< "$substory_text"; then
    # Check if lock file is newer than node_modules
    if [[ package-lock.json -nt node_modules ]]; then
        dependencies+=("packages_outdated")
    fi
fi
```

**Show dependency warnings:**

```markdown
⚠️  Dependency Check: Substory 1.3 - Token encryption

Found 2 potential blockers:

1. 🔑 OAuth Credentials Required
   - Need: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET
   - Status: ❌ Not found in .env file

   Options:
   a. Set up credentials now (I'll guide you)
   b. Skip this substory for now (mark as blocked)
   c. Use mock credentials for testing

2. 📦 Package Dependencies
   - Package 'jose' (JWT library) not installed
   - Required for token encryption

   Options:
   a. Install now: npm install jose
   b. Use alternative library
   c. Skip encryption for now (not recommended)

How would you like to proceed? [resolve-all/skip/continue-anyway]
```

**If user chooses "resolve-all":**
Guide through each dependency setup step-by-step.

**If user chooses "skip":**
Mark substory as blocked, move to next unblocked substory.

**If user chooses "continue-anyway":**
Warn about potential failures, proceed with implementation.

## Section 3: Rollback Protection (Step 4.9 - Phase boundaries)

Before starting each new phase, create automatic checkpoint:

```bash
# Create rollback checkpoint before Phase start
phase_number="$1"
checkpoint_dir=".claude/checkpoints"
checkpoint_name="phase-${phase_number}-$(date +%Y%m%d-%H%M%S)"
checkpoint_path="${checkpoint_dir}/${checkpoint_name}"

mkdir -p "$checkpoint_path"

# Note: checkpoints directory and gitignore are created in Phase 0/Step 1

# Save git state
git diff > "${checkpoint_path}/git-diff.patch"
git diff --cached > "${checkpoint_path}/git-diff-staged.patch"
git status --porcelain > "${checkpoint_path}/git-status.txt"
git rev-parse HEAD > "${checkpoint_path}/git-commit.txt"

# Save PRD state
cp "$prd_file" "${checkpoint_path}/prd.md"
cp "$context_file" "${checkpoint_path}/context.json"

# Save file list
find . -type f -newer "${checkpoint_path}/../last-checkpoint" 2>/dev/null > "${checkpoint_path}/modified-files.txt" || true

# Create rollback script
cat > "${checkpoint_path}/rollback.sh" <<'ROLLBACK'
#!/bin/bash
echo "🔄 Rolling back to checkpoint: ${checkpoint_name}"
echo ""
echo "This will:"
echo "- Restore PRD and context files"
echo "- Undo all uncommitted changes since checkpoint"
echo "- Restore modified files"
echo ""
read -p "Continue with rollback? [yes/no]: " confirm

if [[ "$confirm" == "yes" ]]; then
    git apply --reverse git-diff.patch 2>/dev/null || true
    git apply --reverse git-diff-staged.patch 2>/dev/null || true
    cp prd.md "$prd_file"
    cp context.json "$context_file"
    echo "✅ Rollback complete"
else
    echo "Rollback cancelled"
fi
ROLLBACK

chmod +x "${checkpoint_path}/rollback.sh"

# Update last checkpoint marker
touch "${checkpoint_dir}/last-checkpoint"
```

**Show checkpoint confirmation:**

```markdown
💾 Checkpoint Created: Phase 2 Start

Saved current state before beginning Phase 2

Checkpoint includes:
- Current code state (3 files modified)
- PRD status (Phase 1 complete, 66% overall)
- Context data (patterns, decisions, files)

If something goes wrong during Phase 2:
- Type "rollback" to undo Phase 2 changes
- Run: .claude/checkpoints/phase-2-20251026-143022/rollback.sh

Checkpoint expires: 24 hours (auto-cleanup)

Proceeding to Phase 2...
```

## Section 4: Smart Test Suggestions (Step 5a - Test writing)

Analyze code complexity before writing tests:

```bash
# Analyze code complexity for smart test suggestions
analyze_code_complexity() {
    local file="$1"

    # Cyclomatic complexity (count branches: if, case, for, while, &&, ||)
    complexity=$(grep -c "if\|case\|for\|while\|&&\|||" "$file" 2>/dev/null || echo 0)

    # Count public methods/functions
    public_methods=$(grep -c "def \|function \|export function" "$file" 2>/dev/null || echo 0)

    # Count edge cases (null checks, empty checks, error handling)
    edge_cases=$(grep -c "nil?\|null\|undefined\|empty?\|rescue\|catch\|raise\|throw" "$file" 2>/dev/null || echo 0)

    # Lines of code
    loc=$(wc -l < "$file" 2>/dev/null || echo 0)

    # Determine complexity level
    if [[ $complexity -lt 3 ]] && [[ $loc -lt 50 ]]; then
        echo "low"
    elif [[ $complexity -lt 8 ]] && [[ $loc -lt 150 ]]; then
        echo "medium"
    else
        echo "high"
    fi
}
```

**Show test strategy suggestion:**

```markdown
🧪 Test Strategy: Substory 1.3 - OAuth token encryption

📊 Code Complexity Analysis:
- Complexity score: Medium (cyclomatic complexity: 5)
- Public API: 3 methods (encrypt_token, decrypt_token, validate_token)
- Edge cases detected: 4 (nil token, invalid format, expired token, encryption error)
- Lines of code: 87 lines

🎯 Recommended Test Coverage:

Unit Tests (Recommended: 10 tests)
  ✅ Happy paths: 3 tests
     - encrypt_token with valid data
     - decrypt_token with valid encrypted token
     - validate_token with valid token

  ✅ Error handling: 4 tests
     - nil/empty token input
     - malformed encrypted data
     - expired token validation
     - encryption key missing

  ✅ Edge cases: 3 tests
     - Very long tokens (>4KB)
     - Special characters in tokens
     - Concurrent encryption requests

Integration Tests (Optional: 1 test)
  ⚡ Full OAuth flow with token encryption/decryption

E2E Tests (Skip)
  ⏭️  Not needed - no direct user interaction

📋 Test Plan Summary:
- Total tests: 10-11
- Estimated coverage: 95%+
- Focus: Error handling (high risk area)

Proceed with this test plan? [yes/add-more/minimal/custom]
```

**If user chooses "minimal":**
Only write happy path tests (3 tests).

**If user chooses "add-more":**
Ask what additional scenarios to cover.

**If user chooses "custom":**
Let user specify exact test cases.

## Section 5: Code Review Insights Summary (Step 5b - After review)

Enhanced review output with trends and gamification:

```markdown
📋 Code Review Complete: Substory 1.3

🎯 Quality Score: 89/100 (Excellent ✅)

📈 Trend Analysis:
  Security:     ██████████ 95% (+5% from last substory ⬆️)
  Performance:  ████████░░ 85% (+2% ⬆️)
  Readability:  █████████░ 92% (same)
  Testability:  ████████░░ 88% (+8% ⬆️)
  Maintainability: ████████░░ 87% (+3% ⬆️)

🏆 Achievements Unlocked:
  ✨ Security Champion - 3 substories in a row with 90%+ security score
  🎯 Test Master - Achieved 95%+ test coverage
  📚 Pattern Consistency - 100% adherence to established patterns

✅ Top Wins:
  • Excellent error handling with custom exception hierarchy
  • Clear naming conventions throughout
  • Comprehensive test coverage (96%)
  • Good documentation in complex methods

💡 Focus Areas for Next Substory:
  • Consider extracting magic constants (found 2 instances)
  • Add database index for oauth_tokens.user_id (performance optimization)
  • Document the encryption algorithm choice (maintainability)

🔄 Iteration History:
  • Iteration 1: Found 2 major issues → Auto-fixed
  • Iteration 2: Clean ✅

All critical and major issues resolved!
```

## Section 6: Parallel Work Detection (Step 6.5 - Before continuing to next phase)

Check for concurrent changes on main branch:

```bash
# Detect parallel work that might conflict
current_branch=$(git rev-parse --abbrev-ref HEAD)
base_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Get files changed in current branch
our_files=$(git diff --name-only $base_branch...HEAD)

# Fetch latest from remote
git fetch origin $base_branch --quiet 2>/dev/null

# Get files changed on base branch since we branched off
their_files=$(git diff --name-only HEAD...origin/$base_branch)

# Find overlapping files
conflicts=$(comm -12 <(echo "$our_files" | sort) <(echo "$their_files" | sort))

if [[ -n "$conflicts" ]]; then
    # Analyze conflict risk
    conflict_count=$(echo "$conflicts" | wc -l)

    # Get commit authors
    for file in $conflicts; do
        author=$(git log -1 --format='%an <%ae>' origin/$base_branch -- "$file")
        timestamp=$(git log -1 --format='%ar' origin/$base_branch -- "$file")
    done
fi
```

**Show parallel work warning:**

```markdown
⚠️  Parallel Work Detected

While working on this PRD, changes were made to ${base_branch}:

Potentially Conflicting Files:
  1. src/services/oauth_service.rb
     - Modified by: Sarah Chen <sarah@example.com>
     - When: 2 hours ago
     - Commit: "refactor: extract token validation logic"

  2. app/controllers/auth_controller.rb
     - Modified by: Mike Johnson <mike@example.com>
     - When: 45 minutes ago
     - Commit: "feat: add rate limiting to auth endpoints"

Risk Level: 🟡 MEDIUM
  - 2 files overlap with your changes
  - Affects Substories: 1.2, 1.3

📊 Impact Analysis:
  - Both files are in your current phase
  - oauth_service.rb: Moderate overlap (refactored same methods)
  - auth_controller.rb: Minor overlap (different endpoints)

Options:
1. 🔄 Merge ${base_branch} now (recommended)
   - Pauses PRD implementation
   - Resolves conflicts immediately
   - Continues with updated code

2. ⏭️  Continue and merge later
   - Higher risk of complex conflicts
   - May require rework

3. 📞 Coordinate with team
   - Notify Sarah and Mike
   - Discuss approach before proceeding

4. 🔍 Show detailed diff
   - Review exactly what changed

What would you like to do? [1/2/3/4]
```

## Section 7: Context-Aware Expansion Suggestions (Step 7 - Core PRD completion)

Analyze codebase to suggest smart expansions:

```bash
# Analyze core implementation for expansion suggestions
analyze_for_expansions() {
    local prd_file="$1"
    local context_file="$2"

    suggestions=()

    # Strategy 1: Analyze "Out of Scope" section from PRD
    out_of_scope=$(sed -n '/Out of Scope/,/^##/p' "$prd_file")

    # Strategy 2: Find TODO comments in implemented files
    files_created=$(jq -r '.files_created[]' "$context_file")
    todos=$(grep -rh "TODO\|FIXME\|ENHANCEMENT" $files_created 2>/dev/null || true)

    # Strategy 3: Analyze data model for missing relationships
    # Look for foreign keys without inverse relationships

    # Strategy 4: Check CLAUDE.md for planned features
    planned_features=$(sed -n '/Planned Features\|Roadmap/,/^##/p' CLAUDE.md 2>/dev/null || true)

    # Strategy 5: Analyze usage patterns (if analytics/logs available)
    # Find commonly accessed fields that don't exist yet

    # Rank suggestions by:
    # - Effort (lines of code, complexity)
    # - Impact (usage frequency, business value from comments)
    # - Dependencies (what else is needed)
}
```

**Show smart expansion suggestions:**

```markdown
🎯 Smart Expansion Suggestions

Based on your core implementation, here are natural next steps:

┌─────────────────────────────────────────────────────────┐
│ 1. 🔥 Customer Details (HIGH PRIORITY)                   │
├─────────────────────────────────────────────────────────┤
│ Why recommended:                                         │
│ • Found 73% of invoices reference 'customer_id' in DB   │
│ • Listed in "Out of Scope" section of core PRD          │
│ • 5 TODO comments mention customer information          │
│                                                          │
│ Effort: ██████░░░░ Medium (2-3 substories)               │
│ Impact: ██████████ Very High (critical for production)  │
│ Builds on: Invoice model, InvoiceService pattern        │
│                                                          │
│ Would add:                                               │
│ • Customer model with name, email, address              │
│ • Invoice-Customer association                          │
│ • Customer selection in invoice forms                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 2. 💡 Line Items (QUICK WIN)                             │
├─────────────────────────────────────────────────────────┤
│ Why recommended:                                         │
│ • Follows same service pattern as InvoiceService        │
│ • Mentioned in CLAUDE.md planned features               │
│ • Low complexity, high value                            │
│                                                          │
│ Effort: ████░░░░░░ Small (1-2 substories)                │
│ Impact: ████████░░ High (enables itemized invoices)     │
│ Builds on: Invoice model, existing CRUD patterns        │
│                                                          │
│ Would add:                                               │
│ • LineItem model (description, quantity, unit_price)   │
│ • Has-many relationship with Invoice                    │
│ • Automatic total calculation                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 3. 🚀 Tax Calculations (HIGH IMPACT)                     │
├─────────────────────────────────────────────────────────┤
│ Why recommended:                                         │
│ • TODO comment: "Add tax calculation for compliance"    │
│ • Required for production use                           │
│ • Blocked until Line Items implemented                  │
│                                                          │
│ Effort: ████████░░ Large (4-5 substories)                │
│ Impact: ██████████ Critical (regulatory requirement)    │
│ Depends on: Line Items expansion                        │
│ Complexity: Tax rules, multi-jurisdiction support       │
│                                                          │
│ Would add:                                               │
│ • TaxRule model with regional rates                     │
│ • Tax calculation service                               │
│ • Tax line items in invoices                            │
└─────────────────────────────────────────────────────────┘

📊 Recommended Order:
  1st: Customer Details (unblocks other features)
  2nd: Line Items (enables Tax Calculations)
  3rd: Tax Calculations (compliance requirement)

Which expansion interests you? [1/2/3/custom/plan-all]:
```

**If user selects number:**
Trigger plan-prd skill with pre-filled expansion context.

**If user chooses "plan-all":**
Create PRDs for all three expansions in sequence.

**If user chooses "custom":**
Let user describe their own expansion idea.

## Section 8: Adaptive Difficulty (Phase 0 - Session configuration)

Track user progress and adapt workflow:

```bash
# Calculate user skill level based on history
calculate_skill_level() {
    local prds_completed=$(find .claude/prds/context -name "*.json" -exec jq -r 'select(.status=="complete") | .prd_name' {} \; | wc -l)
    local avg_quality=$(find .claude/prds/context -name "*.json" -exec jq -r '.code_quality_scores[]' {} \; | awk '{sum+=$1; n++} END {if (n>0) print sum/n; else print 0}')
    local avg_coverage=$(find .claude/prds/context -name "*.json" -exec jq -r '.test_coverage' {} \; | awk '{sum+=$1; n++} END {if (n>0) print sum/n; else print 0}')

    # Determine level
    if [[ $prds_completed -ge 10 ]] && [[ $(echo "$avg_quality > 90" | bc) -eq 1 ]]; then
        echo "advanced"
    elif [[ $prds_completed -ge 5 ]] && [[ $(echo "$avg_quality > 80" | bc) -eq 1 ]]; then
        echo "intermediate"
    else
        echo "beginner"
    fi
}
```

**Advanced mode unlocked message:**

```markdown
🎓 Level Up! Advanced Mode Unlocked

Based on your track record:
- ✅ PRDs completed: 12
- ✅ Avg code quality: 94/100
- ✅ Test coverage: Consistently 92%+
- ✅ Pattern consistency: Excellent

You've unlocked Advanced Mode features:

🚀 Speed Optimizations:
  • Auto-approve low-risk changes (skip simple confirmations)
  • Skip repetitive explanations in Learning Mode
  • Parallel substory execution where possible
  • Fast-track phase approvals for clean code

🎯 Advanced Features:
  • Custom code review rules
  • Configurable test thresholds
  • Advanced refactoring suggestions
  • Performance profiling integration

⚙️ Customization:
  • Define your own quality gates
  • Set preferred patterns per project
  • Custom commit message templates

Enable Advanced Mode? [yes/not-yet/customize]

(You can always change this in .claude/user-preferences.json)
```

**Adaptive behaviors by level:**

**Beginner:**
- Learning Mode ON by default
- Detailed explanations
- All confirmations required
- Guided dependency resolution
- Thorough code review

**Intermediate:**
- Learning Mode Smart by default
- Condensed explanations
- Skip trivial confirmations
- Suggested fixes with approval
- Standard code review

**Advanced:**
- Learning Mode OFF by default
- Minimal explanations
- Auto-approve safe changes
- Auto-fix simple issues
- Streamlined code review with trends

---

## Implementation Notes

All these features integrate seamlessly into the existing code-prd workflow:

1. **Learning Mode**: Triggered before each substory if enabled (Step 4.0)
2. **Dependency Warnings**: Checked before substory execution (Step 4.1)
3. **Rollback Protection**: Created at phase boundaries (Step 4.9)
4. **Smart Test Suggestions**: Integrated into test writing step (Step 5a)
5. **Code Review Insights**: Enhanced review output format (Step 5b)
6. **Parallel Work Detection**: Checked at phase boundaries before continuing (Step 6.5)
7. **Context-Aware Suggestions**: Shown at PRD completion (Step 7)
8. **Adaptive Difficulty**: Calculated at session start, influences all steps (Phase 0)

User preferences stored in `.claude/user-preferences.json` (auto-gitignored):
```json
{
  "skill_level": "intermediate",
  "learning_mode": true,
  "auto_approve_safe_changes": false,
  "last_updated": "2025-10-26T14:30:22Z"
}
```

**Important:** This file is automatically added to `.gitignore` to prevent:
- Merge conflicts between developers
- Accidentally committing personal preferences
- Team preferences overwriting individual settings

The skill automatically ensures `.gitignore` contains:
```gitignore
# Claude Code user-specific files (do not commit)
.claude/user-preferences.json
.claude/checkpoints/
```
