---
name: code-prd
description: Build features when user wants to implement PRDs, write code for specs, or develop functionality. Works incrementally substory-by-substory with automatic testing and code review. Automatically loads PRD context to maintain consistency. Also writes standalone tests for any file.
---

# Code PRD Implementation

Write production-quality code for PRD substories with **automatic testing, code review, and iterative refinement** until ready.

**Communication Style**: In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

**UX Enhancements**: This skill includes advanced UX features detailed in `references/ux-enhancements.md`:
- Learning Mode (explain approach before substories)
- Smart PRD Discovery (auto-resume from last session)
- PRD Health Check (validate quality before implementing)
- Progress Visualization (visual progress bars)
- Dependency Warnings (detect blockers early)
- Smart Test Suggestions (complexity-based test plans)
- Code Review Insights (trends and gamification)
- Rollback Protection (auto-checkpoints at phases)
- Context-Aware Expansion Suggestions (data-driven next steps)
- Parallel Work Detection (merge conflict prevention)
- Adaptive Difficulty (workflow speeds up as you improve)

## Philosophy

- **Substory-by-substory**: Implement incrementally with progress tracking
- **Phase-level approval**: Auto-test and review each phase, get user approval before continuing
- **Auto-refinement**: Run code-review internally, fix issues, re-review until satisfied
- **Context-aware**: Load PRD context to maintain consistency (especially for expansions)
- **Flexible**: Can implement full PRD OR write standalone tests for any file

## When to Activate

This skill activates when user says things like:
- "implement [feature/PRD]"
- "build this feature"
- "code this"
- "develop [feature name]"
- "start implementation"
- "write code for [PRD/feature]"
- "write tests for [file/feature]" (standalone test mode)
- Any request to implement, build, or code a feature or PRD

## Implementation Workflow

### Phase 0: Validate Prerequisites and Configure Session

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

**Check for Adaptive Difficulty settings:**
```bash
# Load user skill level from context if exists
user_level="beginner"  # default
auto_approve_safe_changes=false
learning_mode=true  # default ON

if [[ -f ".claude/user-preferences.json" ]]; then
    user_level=$(jq -r '.skill_level // "beginner"' .claude/user-preferences.json)
    auto_approve_safe_changes=$(jq -r '.auto_approve_safe_changes // false' .claude/user-preferences.json)
    learning_mode=$(jq -r '.learning_mode // true' .claude/user-preferences.json)
fi
```

**Show configuration prompt:**
```
✅ CLAUDE.md found
📋 Ready to implement

💡 Session Configuration:

Learning Mode: [Currently: ${learning_mode ? "ON" : "OFF"}]
  When ON: I'll explain my approach before each substory
  When OFF: I'll implement directly without explanations

  Recommended for: Understanding patterns and decisions

Change Learning Mode? [yes/no/default: no]:
```

**If user says "yes":**
```
Enable or disable Learning Mode?
1. 💡 Enable (explain approach for each substory)
2. ⚡ Disable (faster, direct implementation)
3. 🎯 Smart (only explain new patterns)

Choice [1/2/3]:
```

**Save preference:**
```bash
# Save to .claude/user-preferences.json (user-specific, gitignored)
mkdir -p .claude

# Ensure user-preferences.json is gitignored
if [[ -f ".gitignore" ]]; then
    if ! grep -q "\.claude/user-preferences\.json" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code user-specific preferences (do not commit)" >> .gitignore
        echo ".claude/user-preferences.json" >> .gitignore
    fi
else
    cat > .gitignore <<'GITIGNORE'
# Claude Code user-specific preferences (do not commit)
.claude/user-preferences.json
GITIGNORE
fi

# Write user preferences
echo "{
  \"skill_level\": \"$user_level\",
  \"learning_mode\": $learning_mode,
  \"auto_approve_safe_changes\": $auto_approve_safe_changes,
  \"last_updated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
}" > .claude/user-preferences.json

echo "✅ Preferences saved (local only, not committed to git)"
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

**First, ensure directory structure and load PRD:**

```bash
# Ensure .claude directory structure exists
mkdir -p .claude/prds/context
mkdir -p .claude/prds/archive/context
mkdir -p .claude/checkpoints

# Ensure checkpoints are gitignored
if [[ -f ".gitignore" ]]; then
    if ! grep -q "\.claude/checkpoints" .gitignore; then
        echo ".claude/checkpoints/" >> .gitignore
    fi
fi

# Source context manager
source skills/shared/scripts/context-manager.sh

# Validate PRD file exists
if [[ ! -f "$prd_file" ]]; then
    echo "❌ ERROR: PRD file not found: $prd_file"
    exit 1
fi

# Read the PRD file
prd_content=$(cat "$prd_file")

# Read project conventions from CLAUDE.md
if [[ ! -f "CLAUDE.md" ]]; then
    echo "❌ ERROR: CLAUDE.md not found"
    exit 1
fi
claude_md=$(cat "CLAUDE.md")

# Load or initialize PRD context
if context_exists "$prd_file"; then
    context=$(read_context "$prd_file")
    echo "✅ Loaded existing context"
else
    context_file=$(init_context "$prd_file")
    context=$(read_context "$prd_file")
    echo "✅ Initialized new context"
fi
```

**If no PRD specified - Smart PRD Discovery:**

```bash
# Strategy 1: Check for in-progress PRD from last session
last_prd=""
last_timestamp=0

# Check context files for most recently updated in-progress PRD
for context_file in .claude/prds/context/*.json; do
    if [[ -f "$context_file" ]]; then
        # Get last updated timestamp
        timestamp=$(jq -r '.last_updated // 0' "$context_file" 2>/dev/null || echo 0)
        prd_file=$(basename "$context_file" .json)
        prd_path=".claude/prds/${prd_file}.md"

        # Check if PRD exists and is in progress
        if [[ -f "$prd_path" ]] && grep -q "Status.*In Progress" "$prd_path"; then
            if [[ $timestamp -gt $last_timestamp ]]; then
                last_timestamp=$timestamp
                last_prd=$prd_path
                last_context=$context_file
            fi
        fi
    fi
done

# Strategy 2: Check git log for recently committed PRD references
recent_prd=$(git log -10 --oneline 2>/dev/null | grep -o '.claude/prds/[^)]*\.md' | head -1)

# Strategy 3: Check recently modified files in .claude/prds/
recent_file=$(ls -t .claude/prds/*.md 2>/dev/null | head -1)
```

**If found recent PRD in progress:**
```
🔍 Detected context from your last session:

Working on: .claude/prds/2025-10-26-hello-world-core.md
Type: Core Feature
Status: Phase 1 - In Progress (2/3 substories complete)
Last worked: 2 hours ago

Completed:
✅ Substory 1.1: Basic MVC structure
✅ Substory 1.2: RESTful routing

Next up:
⏳ Substory 1.3: Integration tests

Continue where you left off? [yes/choose-different/new]:
```

**If user says "choose-different" or no recent PRD found:**
```
Available PRDs:

In Progress:
  1. 🔄 [Core] hello-world-core - Basic hello world feature
     Progress: ████████░░ 66% (2/3 substories)
     Last updated: 2 hours ago

Not Started:
  2. ⏸️  [Expansion] hello-world-personalized - Add name parameter
     Depends on: hello-world-core (not complete)

  3. ⏸️  [Task] setup-ci-cd - Configure GitHub Actions
     Estimated: 5 steps

Completed:
  4. ✅ [Core] auth-core - OAuth authentication
     Completed: 3 days ago
     (Move to archive? Type 'archive 4')

Which PRD? [1/2/3/4/new]:
```

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

**Step 1: Validate core PRD exists and is complete:**
```bash
# Extract core PRD path from "Builds On" field
core_prd=$(grep "Builds On:" "$prd_file" | sed 's/.*Builds On:.*\(docs\/prds\/[^)]*\).*/\1/')

# Validate core PRD exists
if [[ ! -f "$core_prd" ]]; then
    echo "❌ ERROR: Core PRD not found: $core_prd"
    echo "This expansion requires a completed core PRD."
    exit 1
fi

# Check core is marked complete
if ! grep -q "Status.*Complete" "$core_prd"; then
    echo "⚠️  WARNING: Core PRD is not marked complete"
    echo "Building expansions on incomplete cores may cause inconsistencies."
    echo "Continue anyway? [yes/no]"
fi

# Validate core context exists
core_context_file=".claude/prds/context/$(basename $core_prd .md).json"
if [[ ! -f "$core_context_file" ]]; then
    echo "⚠️  WARNING: Core context file not found: $core_context_file"
    echo "Context loading will be limited. Continue? [yes/no]"
fi
```

**Step 2: Load and analyze core context comprehensively:**
```bash
# Load CLAUDE.md for project conventions
claude_md=$(cat "CLAUDE.md")

# Read core PRD
core_prd_content=$(cat "$core_prd")

# Read core context file
core_context=$(cat "$core_context_file")

# Extract structured data from context
core_files=$(echo "$core_context" | jq -r '.files_created[]')
core_patterns=$(echo "$core_context" | jq -r '.patterns')
core_libraries=$(echo "$core_context" | jq -r '.libraries')
core_decisions=$(echo "$core_context" | jq -r '.architectural_decisions[]')
testing_framework=$(echo "$core_context" | jq -r '.testing_framework')

# Read and analyze each core implementation file
echo "📖 Analyzing core implementation..."
for file in $core_files; do
    if [[ -f "$file" ]]; then
        # Read file to understand:
        # - Class/function naming patterns
        # - Code organization and structure
        # - Error handling approaches
        # - Validation patterns
        # - API/interface design
        # - Data access patterns
    fi
done
```

**Step 3: Document comprehensive findings:**
```
🔍 Core Implementation Analysis (AUTO-LOADED):

Core PRD: .claude/prds/YYYY-MM-DD-{feature}-core.md
Context: .claude/prds/context/YYYY-MM-DD-{feature}-core.json
Status: ✅ Complete

Implementation Files ([X] files analyzed):
- path/to/model.ext - Data model with validations [describe key aspects]
- path/to/service.ext - Business logic service [describe key aspects]
- path/to/controller.ext - API endpoints [describe key aspects]
- path/to/repository.ext - Data access layer [describe key aspects]

Established Patterns ([Y] patterns identified):
1. [Pattern Name] - [Description]
   Location: [where used in core]
   Example: [specific code example or approach]

2. [Pattern Name] - [Description]
   Location: [where used in core]
   Example: [specific code example or approach]

Libraries in Use ([Z] libraries):
- [Library 1] ([Version]) - [Purpose in core implementation]
- [Library 2] ([Version]) - [Purpose in core implementation]

Architectural Decisions ([W] decisions):
1. [Decision]: [Rationale from context]
2. [Decision]: [Rationale from context]

Code Analysis Insights:
- Naming convention: [Observed pattern, e.g., "FeatureService", "FeatureRepository"]
- Error handling: [Approach, e.g., "Custom exception hierarchy with FeatureError base"]
- Validation: [Approach, e.g., "Joi schemas in validators/ directory"]
- Data access: [Pattern, e.g., "Repository pattern with TypeORM"]
- Testing: [Framework and approach, e.g., "Jest with 95% coverage requirement"]

Project Conventions (from CLAUDE.md):
- Tech stack: [List from CLAUDE.md]
- Architecture: [Pattern from CLAUDE.md]
- Code style: [Standards from CLAUDE.md]

✅ Expansion will EXTEND these patterns consistently.
   - Will modify existing files where appropriate
   - Will create new files following established naming
   - Will use same libraries and approaches
   - Will maintain architectural consistency
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

### Step 2a: PRD Health Check

**Before implementing, validate PRD quality:**

```bash
# Run automated PRD quality analysis
prd_score=0
issues=()
warnings=()

# Check 1: Acceptance criteria defined
if grep -q "Acceptance Criteria:" "$prd_file"; then
    prd_score=$((prd_score + 20))
else
    issues+=("❌ Missing acceptance criteria")
fi

# Check 2: Success metrics defined
if grep -q "Success Criteria:" "$prd_file"; then
    prd_score=$((prd_score + 15))
else
    warnings+=("⚠️  Missing success metrics")
fi

# Check 3: Security considerations
if grep -qi "security\|auth\|permission\|sanitiz" "$prd_file"; then
    prd_score=$((prd_score + 15))
else
    warnings+=("⚠️  No security considerations documented")
fi

# Check 4: Performance requirements
if grep -qi "performance\|latency\|speed\|optimize" "$prd_file"; then
    prd_score=$((prd_score + 10))
else
    warnings+=("⚠️  No performance requirements")
fi

# Check 5: Error handling approach
if grep -qi "error\|exception\|failure\|fallback" "$prd_file"; then
    prd_score=$((prd_score + 10))
else
    warnings+=("⚠️  No error handling strategy")
fi

# Check 6: Testing strategy
if grep -qi "test\|testing\|coverage" "$prd_file"; then
    prd_score=$((prd_score + 15))
else
    warnings+=("⚠️  No testing strategy defined")
fi

# Check 7: Clear substories with phases
substory_count=$(grep -c "Substory" "$prd_file" || echo 0)
if [[ $substory_count -gt 0 ]]; then
    prd_score=$((prd_score + 15))
else
    issues+=("❌ No substories defined")
fi
```

**Show health check results:**
```
🔍 PRD Health Check

Analyzing: .claude/prds/2025-10-26-hello-world-core.md

Quality Score: ${prd_score}/100 $(if [[ $prd_score -ge 80 ]]; then echo "(Excellent ✅)"; elif [[ $prd_score -ge 60 ]]; then echo "(Good 👍)"; elif [[ $prd_score -ge 40 ]]; then echo "(Acceptable ⚠️)"; else echo "(Needs Improvement ❌)"; fi)

[If issues found:]
Critical Issues:
${issues[@]}

[If warnings found:]
Recommendations:
${warnings[@]}

[If prd_score >= 60:]
✅ PRD quality is sufficient for implementation

[If prd_score < 60:]
⚠️  PRD quality is below recommended threshold

Options:
1. 🔧 Fix issues now (pause to improve PRD)
2. ⏭️  Implement anyway (accept risks)
3. 📋 Show detailed recommendations

Choice [1/2/3/default: 2]:
```

**If user chooses "3 - Show detailed recommendations":**
```
📋 Detailed Recommendations

To improve this PRD to ${100 - prd_score}% better quality:

1. Add acceptance criteria for each substory
   Why: Defines "done" clearly, prevents scope creep
   How: For each substory, add checklist of verifiable outcomes

2. Define success metrics
   Why: Measurable goals help track feature effectiveness
   How: Add metrics like "response time < 200ms" or "95% test coverage"

3. Document security approach
   Why: Security considerations upfront prevent vulnerabilities
   How: Add section covering auth, input validation, data protection

[etc for each missing element]

Would you like to improve the PRD now? [yes/no/implement-anyway]
```

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

**Show plan with Progress Visualization:**
```
📋 Implementation Plan: [Feature Name]

Overall Progress: ░░░░░░░░░░ 0% (0/4 substories complete)

Phase 1: [Phase Name] (4 substories)
├─ ⏳ Substory 1.1: [Name] - Not Started
├─ ⏳ Substory 1.2: [Name] - Not Started
├─ ⏳ Substory 1.3: [Name] - Not Started
└─ ⏳ Substory 1.4: [Name] - Not Started

Context loaded: ✅
Patterns to follow: [list from context and CLAUDE.md]

Ready to begin Phase 1? [yes/show-details/skip-to]
```

**For continuation (resuming in-progress PRD):**
```
📋 Implementation Plan: Hello World Core

Overall Progress: ████████░░ 66% (2/3 substories complete)

Phase 1: Core Foundation (3 substories)
├─ ✅ Substory 1.1: Basic MVC structure - Completed
├─ ✅ Substory 1.2: RESTful routing - Completed
└─ 🔄 Substory 1.3: Integration tests - In Progress

Context loaded: ✅
Patterns established: Rails MVC, Thin controller pattern
Files created so far: 3 files, 1 modified

Resume at Substory 1.3? [yes/show-details/restart-substory]
```

### Step 4: Implement Phase (Substory-by-Substory)

**For each substory in the phase:**

#### Step 4.0: Learning Mode Explanation (If Enabled)

**📚 See references/ux-enhancements.md Section 1 for full implementation**

If Learning Mode is enabled, explain approach before implementing:
- Show what will be built and why
- Explain pattern choices and decisions
- List files to be created/modified
- Estimate complexity

Give user option to proceed, request more details, or adjust approach.

#### Step 4.1: Dependency Warnings Check

**⚠️ See references/ux-enhancements.md Section 2 for full implementation**

Before implementing substory, detect and warn about dependencies:
- Check for required API keys/credentials
- Verify external services are running
- Check for pending migrations
- Validate package dependencies

If blockers found, offer to resolve, skip, or continue anyway.

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

### Step 4.9: Rollback Protection Checkpoint

**💾 See references/ux-enhancements.md Section 3 for full implementation**

Before starting each new phase, create automatic checkpoint:
- Save git state (diffs, status, commit hash)
- Backup PRD and context files
- Create rollback script
- Auto-add to .gitignore

Show checkpoint confirmation with rollback instructions.

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

**🧪 See references/ux-enhancements.md Section 4 for Smart Test Suggestions**

Before writing tests, analyze code complexity and suggest test strategy:
- Calculate cyclomatic complexity
- Count public methods and edge cases
- Recommend test coverage level (minimal/standard/comprehensive)
- Let user choose or customize test plan

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

**If testing is enabled, analyze project testing setup comprehensively:**

**Step 1: Identify testing framework and conventions:**
```bash
# Check CLAUDE.md for testing info
testing_info=$(grep -A 10 -i "testing\|test" CLAUDE.md)

# Detect testing framework from multiple sources:
# 1. CLAUDE.md explicit mention
# 2. package.json/requirements.txt dependencies
# 3. Existing test file patterns
# 4. Test configuration files

# Common framework detection:
if grep -q "jest" package.json 2>/dev/null; then
    framework="Jest"
    test_pattern="**/*.test.ts"
elif grep -q "pytest" requirements.txt 2>/dev/null; then
    framework="pytest"
    test_pattern="**/test_*.py"
elif grep -q "rspec" Gemfile 2>/dev/null; then
    framework="RSpec"
    test_pattern="**/spec/**/*_spec.rb"
elif grep -q "vitest" package.json 2>/dev/null; then
    framework="Vitest"
    test_pattern="**/*.test.ts"
fi

# Find test command from package.json, Makefile, or CLAUDE.md
if [[ -f "package.json" ]]; then
    test_cmd=$(jq -r '.scripts.test // empty' package.json)
elif [[ -f "Makefile" ]]; then
    test_cmd=$(grep "^test:" Makefile | cut -d':' -f2 | xargs)
fi

# Examine existing test files for patterns
existing_tests=$(find . -name "*test*" -o -name "*spec*" | head -5)
```

**Step 2: Analyze existing test patterns:**
```
📊 Testing Framework Detected: [Framework]

Test Configuration:
- Framework: [Framework and version]
- Test pattern: [File pattern, e.g., "*.test.ts"]
- Test command: [Command, e.g., "npm test"]
- Coverage tool: [Tool if detected, e.g., "Istanbul"]

Existing Test Patterns (from analysis):
- Test file location: [Pattern, e.g., "__tests__/" or "spec/"]
- Naming convention: [Pattern, e.g., "feature.test.ts" or "feature_spec.rb"]
- Test structure: [Describe/it, test/expect, etc.]
- Mocking approach: [Library and pattern used]
- Setup/teardown: [How tests are initialized]

Conventions from CLAUDE.md:
- Coverage requirement: [E.g., ">= 90%"]
- Test types required: [Unit, integration, e2e]
- Mock strategy: [Real vs mocked dependencies]
```

**Step 3: Write comprehensive tests following established patterns:**
- **Unit tests** for core logic (business logic, utilities, domain models)
- **Integration tests** for component interactions
- **Coverage** for all acceptance criteria from substories
- **Test cases**:
  - Happy paths (expected successful flows)
  - Error scenarios (validation failures, exceptions)
  - Edge cases (boundary conditions, null/empty values)
  - Business rule validation
- **Follow project conventions**:
  - Match file naming and location patterns
  - Use same test structure and assertions
  - Follow mocking strategy from existing tests
  - Match code style and organization

**Step 4: Update context with testing info:**
```bash
# Save testing framework for future reference
update_context "$prd_file" "testing_framework" "$framework"
update_context "$prd_file" "test_command" "$test_cmd"
update_context "$prd_file" "test_pattern" "$test_pattern"
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

**📋 See references/ux-enhancements.md Section 5 for Code Review Insights Summary**

Enhanced code review with trends, gamification, and achievements:
- Track quality score trends across substories
- Show improvement/regression in each dimension
- Unlock achievements for consistent quality
- Provide focus areas for next substory

**Run comprehensive internal code review analysis:**

**Review Dimensions:**

1. **Code Quality**:
   - Readability (clear naming, appropriate comments)
   - Maintainability (DRY, single responsibility)
   - Complexity (cyclomatic complexity, nesting depth)
   - Code organization and structure

2. **Architecture & Design**:
   - Design patterns (match established patterns from context)
   - SOLID principles adherence
   - Separation of concerns
   - Dependency management
   - **For Expansions**: Consistency with core implementation

3. **Security**:
   - Authentication and authorization
   - Input validation and sanitization
   - SQL injection prevention
   - XSS prevention
   - Secrets management (no hardcoded credentials)
   - Data exposure (sensitive data handling)

4. **Performance**:
   - Database query optimization (N+1 queries, indexes)
   - Caching strategy
   - Algorithm efficiency
   - Resource management (connections, memory)
   - Async/await usage (if applicable)

5. **Testing Quality**:
   - Coverage of acceptance criteria
   - Edge case coverage
   - Meaningful test assertions
   - Test maintainability
   - Mock appropriateness

6. **Project-Specific** (from CLAUDE.md and context):
   - Tech stack best practices
   - Framework conventions
   - Coding standards and style
   - **For Expansions**: Pattern consistency with core

**Categorize findings by severity:**
- 🔴 **Critical** (Must fix before approval):
  - Security vulnerabilities
  - Data loss risks
  - Breaking changes without migration
  - Crashes or fatal errors

- 🟠 **Major** (Should fix):
  - Performance issues
  - Missing validation
  - Poor error handling
  - Pattern inconsistencies (especially in expansions)
  - Missing tests for critical paths

- 🟡 **Minor** (Nice to have):
  - Code style inconsistencies
  - Missing edge case tests
  - Refactoring opportunities
  - Documentation improvements

- ✅ **Positive** (Done well):
  - Highlight good patterns
  - Acknowledge thorough testing
  - Note security best practices
  - Recognize clear, maintainable code

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

### Step 6.5: Parallel Work Detection

**🔍 See references/ux-enhancements.md Section 6 for full implementation**

Before continuing to next phase, check for parallel work on main branch:
- Fetch latest from remote
- Compare changed files between branches
- Identify potential conflicts
- Show risk level and affected substories

If conflicts detected, offer to merge now, continue anyway, or coordinate with team.

### Step 7: Continuation or Completion

**If more phases exist:**
- Show next phase plan
- Continue to Step 4 for next phase
- Repeat: Implement → Test → Review → Fix → Approve

**If all phases complete:**

**For CORE PRD:**

First, detect git state to provide contextual next steps:

```bash
# Detect current git branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Check if on main/master
on_main=false
if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]] || [[ "$current_branch" == "$base_branch" ]]; then
    on_main=true
fi

# Check for uncommitted changes
has_changes=false
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    has_changes=true
fi
```

Then show contextual completion message:

```markdown
🎉 Core PRD Complete!

✅ All phases implemented and tested:
- Phase 1: Core Foundation (3 substories)

📊 Core Stats:
- Files created: 3 files
- Files modified: 1 file
- Tests: 2 tests, 3 assertions, 100% passing
- Patterns established:
  * Rails MVC structure
  * Thin controller pattern
  * RESTful routing
  * Minitest integration testing
  * frozen_string_literal pragma

🌱 Core foundation is ready!

Context saved: .claude/prds/context/2025-10-26-hello-world-core.json
This context will be auto-loaded when creating expansion PRDs.

💡 Next steps:

[If on_main == true && has_changes == true:]
**Git Status:** On main branch with uncommitted changes

Choose an option or type your own:
1. 🚀 Create pull request (creates feature branch, commits, pushes, opens PR)
2. 📋 Plan expansion (create expansion PRD to add more features)
3. ✏️  Continue coding (keep working on this branch)

[If on_main == false && has_changes == true:]
**Git Status:** On branch '${current_branch}' with uncommitted changes

Choose an option or type your own:
1. 💾 Commit changes (creates commit on current branch)
2. 📋 Plan expansion (create expansion PRD to add more features)
3. ✏️  Continue coding (keep working without committing)

[If on_main == false && has_changes == false:]
**Git Status:** On branch '${current_branch}' - ready to ship

Choose an option or type your own:
1. 🚀 Create pull request (push branch and open PR to ${base_branch})
2. 💾 Commit more changes (continue working on branch)
3. 📋 Plan expansion (create expansion PRD to add more features)

[If on_main == true && has_changes == false:]
**Git Status:** On main branch - all changes committed

**🎯 See references/ux-enhancements.md Section 7 for Context-Aware Expansion Suggestions**

Analyze core implementation for smart expansion suggestions:
- Check "Out of Scope" section from PRD
- Find TODO comments in implemented files
- Analyze data model for missing relationships
- Rank by effort, impact, and dependencies

Choose an option or type your own:
1. 📋 Plan expansion (create expansion PRD to add more features):
   [Smart suggestions based on code analysis:]
   - Personalized greeting (accept name parameter)
   - Styling with CSS/Tailwind
   - Interactive form version
   - API endpoint version (JSON response)
2. ✏️  Start new feature (plan a different PRD)
3. 🎯 Other (describe what you'd like to do)

What would you like to do? [1/2/3 or type your request]:
```

**For EXPANSION PRD:**

First, detect git state (same as Core PRD), then show contextual completion:

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

Context updated: .claude/prds/context/2024-10-25-invoice-{expansion}.json

💡 Next steps:

[If on_main == true && has_changes == true:]
**Git Status:** On main branch with uncommitted changes

Choose an option or type your own:
1. 🚀 Create pull request (creates feature branch, commits, pushes, opens PR)
2. 📋 Plan another expansion (add more features to core)
3. ✏️  Continue coding (keep working on this branch)

[If on_main == false && has_changes == true:]
**Git Status:** On branch '${current_branch}' with uncommitted changes

Choose an option or type your own:
1. 💾 Commit changes (creates commit on current branch)
2. 📋 Plan another expansion (add more features to core)
3. ✏️  Continue coding (keep working without committing)

[If on_main == false && has_changes == false:]
**Git Status:** On branch '${current_branch}' - ready to ship

Choose an option or type your own:
1. 🚀 Create pull request (push branch and open PR to ${base_branch})
2. 💾 Commit more changes (continue working on branch)
3. 📋 Plan another expansion (add more features to core)

[If on_main == true && has_changes == false:]
**Git Status:** On main branch - all changes committed

Choose an option or type your own:
1. 📋 Plan another expansion (continue building on core)
2. ✏️  Start new feature (plan a different PRD)
3. 🎯 Other (describe what you'd like to do)

What would you like to do? [1/2/3 or type your request]:
```

**Handling User Response:**

The user can respond in three ways:
1. **Select numbered option**: "1" or "2" or "3"
2. **Type natural language**: "I want to add authentication" or "let's create a PR"
3. **Use skill keywords**: "ship", "plan", "implement"

**Map responses to actions:**
```bash
# If user selects option 1-3, map to the corresponding action
# If user types natural language, interpret intent:
#   - Words like "commit", "save", "ship" → trigger publish skill
#   - Words like "pr", "pull request", "merge" → trigger publish skill in PR mode
#   - Words like "plan", "expansion", "add feature" → trigger plan-prd skill
#   - Otherwise, treat as continuation of conversation
```

### Step 8: Standalone Test Mode (No PRD)

**When user says "write tests for [file/feature]":**

**Step 1: Identify and validate target:**
```bash
# Specific files mentioned
if [[ -f "$target_file" ]]; then
    target_files=("$target_file")
else
    # Feature area - find related files
    target_files=$(find . -name "*$feature*" -type f ! -path "*/test/*" ! -path "*/spec/*")
fi

# Validate files exist
if [[ ${#target_files[@]} -eq 0 ]]; then
    echo "❌ ERROR: No files found for: $target"
    exit 1
fi

echo "📋 Found ${#target_files[@]} files to test"
```

**Step 2: Comprehensive testing setup analysis:**
```bash
# Read CLAUDE.md for testing framework and conventions
testing_info=$(grep -A 10 -i "testing\|test" CLAUDE.md)

# Detect framework (same logic as Phase implementation)
# - Check package.json, requirements.txt, Gemfile
# - Identify test command
# - Find test file patterns

# Analyze existing test files
existing_tests=$(find . -name "*test*" -o -name "*spec*" | head -5)

# For each existing test file, analyze:
# - File structure and organization
# - Test naming patterns
# - Assertion style
# - Mocking patterns
# - Setup/teardown approach
```

**Step 3: Present testing plan:**
```
📊 Testing Setup Detected:

Framework: [Framework name]
Test command: [Command to run tests]
Test file pattern: [Where to place tests]

Files to test ([X] files):
- path/to/file1.ext - [Brief description of what it does]
- path/to/file2.ext - [Brief description of what it does]

Test plan:
- Unit tests: [Estimated count] tests for [specific areas]
- Integration tests: [If applicable]
- Coverage goals: [From CLAUDE.md or project standard]

Proceeding with test generation...
```

**Step 4: Analyze implementation files deeply:**
```bash
# For each target file, analyze:
# - Public API (exported functions, classes, methods)
# - Business logic and algorithms
# - Error handling paths
# - Input validation
# - Edge cases and boundary conditions
# - Dependencies and interactions
```

**Step 5: Write comprehensive tests following patterns:**
- **Unit tests** for:
  - Each public method/function
  - Business logic and calculations
  - Validation rules
  - Error handling
  - Edge cases (null, empty, boundary values)

- **Integration tests** (if applicable):
  - Component interactions
  - Database operations
  - External service calls
  - Full feature workflows

- **Follow established patterns**:
  - Match test file naming and location
  - Use same test structure (describe/it, test/expect)
  - Follow mocking strategy from existing tests
  - Match assertion style and organization
  - Include setup/teardown as needed

**Step 6: Run tests and verify:**
```bash
# Run test command
$test_cmd

# Capture results:
# - Pass/fail count
# - Coverage percentage
# - Any failures or errors
```

**Step 7: Report comprehensive results:**
```markdown
✅ Tests written for [file/feature]

📝 Test files created:
- tests/unit/feature.test.ts (15 tests)
  * Happy path scenarios: 5 tests
  * Error handling: 4 tests
  * Edge cases: 6 tests
- tests/integration/feature-flow.test.ts (8 tests)
  * End-to-end workflows: 8 tests

🧪 Test results:
✅ 23/23 tests passing
📊 Coverage:
  - Overall: 96% (+12% from baseline)
  - Branches: 94%
  - Functions: 100%
  - Lines: 96%

⏱️  Duration: 2.3s

Test breakdown:
- Unit tests: 15/15 passing
- Integration tests: 8/8 passing

All acceptance criteria verified ✅
Done!
```

**Important**: No PRD updates, no context management, just comprehensive tests following project patterns.

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

## Directory Structure

The skill works with this directory structure:

```
.claude/
├── prds/
│   ├── YYYY-MM-DD-feature-core.md              # Active PRD files
│   ├── YYYY-MM-DD-feature-expansion.md
│   ├── context/                                 # Active context files
│   │   ├── YYYY-MM-DD-feature-core.json
│   │   └── YYYY-MM-DD-feature-expansion.json
│   └── archive/                                 # Manual archival (user responsibility)
│       ├── old-feature.md                       # Archived PRD
│       └── context/
│           └── old-feature.json                 # Archived context
├── user-preferences.json                        # User-specific settings (GITIGNORED)
└── checkpoints/                                 # Rollback protection (GITIGNORED)
    └── phase-1-20251026-143022/
        ├── git-diff.patch
        ├── prd.md
        └── rollback.sh

.gitignore additions:
# Claude Code user-specific files (do not commit)
.claude/user-preferences.json
.claude/checkpoints/
```

**Important Notes:**
- **PRDs and context files**: Committed to git (team-shared)
- **User preferences**: Local only, auto-gitignored (personal settings)
- **Checkpoints**: Local only, auto-gitignored (temporary rollback points)
- **Archive folder**: When archiving, move both .md and .json files to maintain the pair

## UX Enhancement Reference Map

This skill includes advanced UX features. At each workflow step, refer to references/ux-enhancements.md:

| Workflow Step | UX Enhancement | Section |
|---------------|----------------|---------|
| **Phase 0** | Learning Mode Toggle | Section 1 |
| **Phase 0** | Adaptive Difficulty Check | Section 8 |
| **Step 1** | Smart PRD Discovery | Built-in |
| **Step 2a** | PRD Health Check | Built-in |
| **Step 3** | Progress Visualization | Built-in |
| **Step 4.0** | Learning Mode Explanation | Section 1 |
| **Step 4.1** | Dependency Warnings | Section 2 |
| **Step 4.9** | Rollback Protection | Section 3 |
| **Step 5a** | Smart Test Suggestions | Section 4 |
| **Step 5b** | Code Review Insights | Section 5 |
| **Step 6.5** | Parallel Work Detection | Section 6 |
| **Step 7** | Context-Aware Expansions | Section 7 |

**When to read references/ux-enhancements.md:**
- At workflow step callouts (📚 🧪 📋 💾 🔍 🎯 markers)
- When user requests specific feature (e.g., "enable learning mode")
- To understand full implementation details for any enhancement

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
- **Reference references/ux-enhancements.md at callout steps for full feature implementation**
