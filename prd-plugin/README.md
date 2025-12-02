# 📚 Skills Documentation

**3 orchestrated workflows for language-agnostic, PRD-driven development.**

---

## 🌱 Land Then Expand Philosophy

These skills use a **"land then expand"** approach optimized for Claude Sonnet 4.5:

1. **Start Minimal (Core)**: Build essential foundation with 2-4 substories max
2. **Establish Patterns**: Create clean, simple code that works
3. **Auto-Save Context**: Patterns, libraries, and decisions stored in `.claude/context/*.json`
4. **Expand Iteratively**: Add features one at a time with auto-loaded context
5. **Maintain Consistency**: Expansions automatically inherit core patterns

**Why this works better:**
- Prevents incorrect architectural assumptions
- Establishes patterns before adding complexity
- Context files enable cross-session memory
- Better token efficiency
- Shorter feedback cycles
- More consistent results

**Example Flow:**
```
Core PRD: Invoice with number, date, amount only
  ↓ implement (auto-test, auto-review, auto-fix)
  ↓ ship (commit + PR)
Expansion 1: Add customer details (auto-loads invoice core context)
  ↓ implement (extends core patterns)
  ↓ ship
Expansion 2: Add line items (auto-loads invoice + customer context)
  ↓ implement
  ↓ ship
```

---

## 🎯 Language-Agnostic Design

**Works with ANY programming language/framework by reading your project's conventions:**

### How It Works

All skills read project conventions from **`CLAUDE.md`** in your project root. This makes the plugin:
- ✅ **Truly reusable** across any project type
- ✅ **Not coupled** to specific platforms
- ✅ **User-configurable** via your CLAUDE.md
- ✅ **Adaptable** to your team's standards

### What Should Be in CLAUDE.md

Your project's `CLAUDE.md` should document:

- **Tech stack and frameworks** (Rails, Next.js, Go, Python, Swift, Kotlin, etc.)
- **Coding patterns and architecture** (MVC, MVVM, Clean Architecture, etc.)
- **Testing approach and framework** (RSpec, Jest, pytest, XCTest, JUnit, etc.)
- **Project-specific conventions** (naming, file structure, etc.)
- **Libraries and dependencies** (Stripe, Redux, Room, etc.)

### Example Tech Stacks

These skills work with any stack, including:
- 💎 Ruby on Rails, Sinatra
- ⚛️ React, Next.js, Vue, Angular
- 🐍 Python/Django, FastAPI, Flask
- 🔷 Go, Rust, Elixir
- 🍎 iOS/Swift (UIKit, SwiftUI)
- 🤖 Android/Kotlin (Jetpack Compose)
- 📱 React Native, Flutter

**The plugin adapts to YOUR project by reading CLAUDE.md.** ✨

---

## 🛠️ The 3 Orchestrated Skills

### 📋 plan-prd

**What:** Create core or expansion PRDs with automatic context management

<details>
<summary><strong>Click to expand full details</strong></summary>

<br>

### Core vs Expansion 🌱

**Always asks first:**
1. 🌱 New core feature (minimal foundation)
2. 🔧 Expansion of existing feature (builds on core)

### Core PRD Mode

- **Max 2-4 substories** - enforces minimalism
- **Essential fields only** - example: invoice with just number, date, amount
- **Single phase** - establish foundation
- **Out of scope section** - lists future expansions
- **Creates context file**: `.claude/context/YYYY-MM-DD-{feature}-core.json`
- File: `docs/prds/YYYY-MM-DD-{feature}-core.md`

**Goal**: Establish patterns, NOT completeness

**Context Initialized:**
```json
{
  "prd": "docs/prds/2024-10-25-invoice-core.md",
  "patterns": {},
  "libraries": {},
  "files_created": [],
  "architectural_decisions": []
}
```

### Expansion PRD Mode (AUTO-CONTEXT LOADING)

**Automatically:**
- ✅ Reads core PRD file
- ✅ Loads `.claude/context/{core-prd-name}.json`
- ✅ Extracts files_created, patterns, libraries, decisions
- ✅ Reads core implementation files
- ✅ Shows established patterns to user

**Then:**
- **Focused on ONE aspect** - customer details OR line items, not both
- **Extends core patterns** - maintains consistency
- **Inherits context** - expansion context starts with core as base
- File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

**Goal**: Add one feature using established patterns

**No manual work needed** - core context auto-loaded!

### Codebase Exploration 🔍

- ✅ Analyzes existing patterns and architecture
- ✅ Finds similar features for reference
- ✅ **For expansions**: Automatically loads completed core files
- ✅ Identifies testing frameworks and conventions
- ✅ Ensures PRD follows project patterns

**Project-aware** 🎯 - automatically tailors PRD structure based on your CLAUDE.md conventions.

### Natural Activation 🗣️

- "Plan a booking system"
- "Create an expansion for customer details"
- "Plan the core invoice feature"

</details>

---

### 💻 code-prd

**What:** Code + Auto-test + Auto-review + Auto-fix + Progress tracking (all-in-one)

<details>
<summary><strong>Click to expand full details</strong></summary>

<br>

### Orchestrated Workflow 🚀

**For each phase:**

1. **💻 Implement substories** (one-by-one)
   - Shows progress after EACH substory
   - Updates PRD status automatically
   - Updates context with patterns/decisions

2. **🧪 Auto-test** (after phase completes)
   - Detects framework from CLAUDE.md or existing tests
   - Writes comprehensive tests
   - Runs tests
   - Reports coverage

3. **🔍 Auto-review** (after tests pass)
   - Multi-dimensional analysis (quality, security, performance)
   - Project-specific checks based on CLAUDE.md
   - Categorizes findings (🔴 Critical, 🟠 Major, 🟡 Minor)

4. **🔧 Auto-fix** (if issues found)
   - Fixes critical/major issues automatically
   - Re-reviews until clean
   - Max 2 fix iterations

5. **✅ Approval gate** (phase boundary)
   - Shows: substories complete, tests passing, review clean
   - Asks: "Phase X complete. Approve to continue? [yes/no]"
   - User decides: continue or stop

### Core vs Expansion Implementation 🌱

**Core PRD Implementation:**
- Establishes clean, simple patterns
- Creates minimal working foundation
- Stores patterns/libraries/decisions in context
- After completion: Suggests creating expansion PRDs

**Expansion PRD Implementation (AUTO-CONTEXT):**
- **Automatically loads core context** and implementation files
- Analyzes and follows established patterns
- Extends (not replaces) core code
- Uses same libraries (from context)
- Maintains naming and structure consistency

### Standalone Test Mode 🧪

**Also works without PRD:**
- "Write tests for user.rb"
- Detects framework, writes tests, runs tests
- No PRD updates

### Features ⭐

- 🔍 Architecture analysis before coding
- 🎯 Follows existing project patterns from CLAUDE.md
- 📂 **For expansions**: Auto-loads and extends core files
- 🛠️ Project-specific best practices from CLAUDE.md
- 📦 Incremental implementation (one substory at a time)
- 🧪 **Auto-tests** after each phase
- 🔍 **Auto-reviews** code quality, security, performance
- 🔧 **Auto-fixes** critical/major issues
- 📊 Real-time progress tracking
- 📝 PRD and context auto-updated
- ✅ Approval gates at phase boundaries (not per substory)
- 💬 Clear communication, no hidden magic

### Natural Activation 🗣️

- "Implement" or "Implement the authentication PRD"
- "Build the booking feature"
- "Write tests for user.rb" (standalone)

</details>

---

## 📦 Shared Infrastructure

### Shared Libraries

Located in `skills/shared/scripts/`:

**git-tools.sh** - Git operations
- `analyze_git_changes()` - Parse git diff output
- `detect_scope_from_files()` - Simple scope detection using common directory heuristics
- `find_related_prd()` - Find PRD files
- `get_current_branch()` - Current git branch
- `has_uncommitted_changes()` - Check git status

**context-manager.sh** - Context management (used by `plan-prd`, `code-prd`)
- `init_context()` - Create new context file
- `read_context()` - Load context as JSON
- `context_exists()` - Check if context file exists
- `add_created_file()` - Track created files
- `add_modified_file()` - Track modified files
- `set_pattern()` - Store patterns
- `set_library()` - Store library choices
- `add_decision()` - Store architectural decisions
- `get_core_files()` - Extract core files for expansions
- `get_core_patterns()` - Extract core patterns for expansions
- `get_core_libraries()` - Extract core libraries for expansions
- `get_core_decisions()` - Extract core decisions for expansions
- `mark_phase_complete()` - Update phase status
- `set_current_phase()` - Set current working phase

### Platform References

Located in `skills/shared/references/{platform}/`:

### Project Conventions

Skills read project conventions from `CLAUDE.md` in the project root directory.

**CLAUDE.md should contain:**
- Tech stack and frameworks
- Coding patterns and architecture
- Testing approach and framework
- Project-specific conventions
- Libraries and dependencies used

**Auto-loaded** by all skills to ensure project-agnostic behavior.

---

## 🧠 Context System

### What is Context?

`.claude/context/{prd-name}.json` files that store:
- Patterns established (service objects, API structure, etc.)
- Libraries chosen (Stripe, Devise, etc.)
- Architectural decisions made
- Files created during implementation
- Testing framework detected
- Current/completed phases

### Context Structure

```json
{
  "prd": "docs/prds/2024-10-25-invoice-core.md",
  "created_at": "2024-10-25T10:00:00Z",
  "updated_at": "2024-10-25T14:30:00Z",
  "patterns": {
    "service_objects": "app/services/",
    "api_structure": "/api/v1/",
    "serializers": "ActiveModelSerializers"
  },
  "libraries": {
    "payment": "stripe",
    "auth": "devise + jwt"
  },
  "files_created": [
    "app/models/invoice.rb",
    "app/controllers/api/v1/invoices_controller.rb",
    "app/services/invoice_creation_service.rb"
  ],
  "architectural_decisions": [
    "Using service objects for business logic",
    "RESTful API under /api/v1/",
    "Stripe for payment processing"
  ],
  "testing_framework": "minitest",
  "completed_phases": ["Phase 1"]
}
```

### How Context Works

1. **plan (core)**: Initializes context file
2. **implement (core)**: Updates context with patterns/libraries/decisions
3. **plan (expansion)**: Auto-loads core context, reads core files
4. **implement (expansion)**: Uses core context to maintain consistency

**Result**: Expansions automatically follow core patterns without manual work.

---

## ⚠️ Important: Prompt-Based Workflow System

**Understanding what this is:**

These skills are **structured prompts** that guide Claude through a development workflow. They are NOT autonomous code automation.

**How it works:**
1. You activate a skill (`plan-prd`, `code-prd`)
2. Claude reads the skill's instructions (markdown prompts)
3. Claude **interprets and follows** the workflow
4. Claude updates files (PRDs, context, code)
5. **You verify** the results at each step

**What this means for you:**

✅ **Do this:**
- Review PRDs before approving
- Check code after each substory
- Verify context files are updated correctly
- Read commit messages before saying "yes"
- Treat Claude as a guided assistant, not autopilot

❌ **Don't assume:**
- Perfect state management across sessions
- All workflow steps executed correctly
- Context files are always accurate
- Claude won't skip or misinterpret steps

**Best results when:**
- Features are small (2-4 substories)
- Sessions are short (1-2 hours)
- You review frequently
- You verify state between sessions

**May struggle when:**
- Features are large/complex (>6 substories)
- Work spans multiple days
- Multiple people use same PRD
- Complex state dependencies

## 💡 Philosophy & Design Principles

### 1. Land Then Expand
Start minimal, expand iteratively with auto-loaded context.

### 2. Auto-Context Loading
Expansions inherit core patterns automatically via context files.

### 3. Iterative Refinement
`implement` auto-tests, auto-reviews, and auto-fixes before asking approval.

### 4. User Control with Less Friction
Approval gates at phase boundaries (not per substory). Skills suggest but never auto-invoke other skills.

### 5. Project Awareness
All code follows project-specific conventions loaded from CLAUDE.md.

### 6. Context as Memory
`.claude/context/*.json` files serve as cross-session memory.

### 7. Power User Focused
Orchestrated workflows reduce cognitive load while maintaining granular control.

---

## 🎯 Typical Workflows

### Full Feature (Core → Expansion)

```bash
# Day 1: Core foundation
User: "plan a booking system"
plan: Creates minimal core PRD (2-4 substories)
      Initializes .claude/context/booking-core.json

User: "implement"
implement: Phase 1 substories (with progress after each)
          Auto-test (23 tests, 94% coverage)
          Auto-review (found 2 issues)
          Auto-fix issues
          Re-review (clean!)
          "Phase 1 complete. Approve? [yes/no]"
User: "yes"

User: "ship"
ship: Commit mode, generates message, waits for approval
User: "yes"

User: "ship"
ship: PR mode, generates description, waits for approval
User: "yes"
ship: PR #123 created

# Day 2: Expansion
User: "plan payment details expansion"
plan: Auto-loads booking-core.json
      Reads booking.rb, bookings_controller.rb
      Shows established patterns
      Creates expansion PRD

User: "implement"
implement: Extends core using same libraries/patterns
          Auto-test, auto-review, auto-fix
          Approval gate
User: "yes"

User: "ship"
User: "ship"
# Done!
```

### Standalone Testing

```bash
User: "write tests for app/models/user.rb"
implement: Detects standalone mode
          Skips PRD loading
          Detects Minitest
          Writes comprehensive tests
          Runs tests
          Reports: "15/15 tests passing, 96% coverage"
          Done (no PRD updates)
```

---

<div align="center">

🔗 Back to [Main README](../../README.md)
</div>
