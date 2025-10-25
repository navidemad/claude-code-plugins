# 📚 Skills Documentation

Detailed guide for all available skills in the Yespark Claude Plugins marketplace.

---

## 🌱 Land Then Expand Philosophy

These skills use a **"land then expand"** approach for optimal results with modern Claude models:

1. **Start Minimal (Core)**: Build essential foundation with 2-4 substories max
2. **Establish Patterns**: Create clean, simple code that works
3. **Expand Iteratively**: Add features one at a time in separate PRDs
4. **Maintain Consistency**: Expansions load and extend core patterns

**Why this works better:**
- Prevents incorrect architectural assumptions
- Establishes patterns before adding complexity
- Better token efficiency
- Shorter feedback cycles
- More consistent results

**Example Flow:**
```
Core PRD: Invoice with number, date, amount only
  ↓ implement & merge
Expansion 1: Add customer details
  ↓ implement & merge
Expansion 2: Add line items
  ↓ implement & merge
Expansion 3: Add tax calculations
```

---

## 🎯 Platform Support

**Automatically detects and adapts to your platform:**

### Supported Platforms

| Platform | Technologies | What We Support |
|----------|-------------|-----------------|
| 💎 **Ruby on Rails** | Backend | Models, controllers, services, migrations, ActiveRecord patterns, RSpec/Minitest |
| 🍎 **iOS/Swift** | Mobile | MVVM architecture, SwiftUI/UIKit, ViewModels, Combine, async/await |
| 🤖 **Android/Kotlin** | Mobile | Clean Architecture, MVVM, Coroutines, Hilt DI, Jetpack Compose |

### 🔍 Detection Method

Skills automatically detect your platform by analyzing project files:

- **Rails** 💎: Presence of `Gemfile` with `gem "rails"`
- **iOS Swift** 🍎: `.xcodeproj` folder, `Podfile`, or `Package.swift`
- **Android Kotlin** 🤖: `gradle.properties` file at project root

Once detected, skills automatically load platform-specific conventions and best practices from reference files, ensuring code generation follows your platform's standards. ✨

---

## 🛠️ Skills in Detail

<details>
<summary><strong>📋 generate-prd</strong> - Create core or expansion PRDs with codebase exploration</summary>

<br>

### Land Then Expand Approach 🌱

**Always asks first:**
1. 🌱 New core feature (minimal foundation)
2. 🔧 Expansion of existing feature (builds on core)

### Core PRD Mode

- **Max 2-4 substories** - enforces minimalism
- **Essential fields only** - example: invoice with just number, date, amount
- **Single phase** - establish foundation
- **Out of scope section** - lists future expansions
- File: `docs/prds/YYYY-MM-DD-{feature}-core.md`

**Goal**: Establish patterns, NOT completeness

### Expansion PRD Mode

- **Focused on ONE aspect** - customer details OR line items, not both
- **Loads core implementation** - reads completed core files for patterns
- **Extends core patterns** - maintains consistency
- File: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

**Goal**: Add one feature using established patterns

### Codebase Exploration 🔍

- ✅ Analyzes existing patterns and architecture
- ✅ Finds similar features for reference
- ✅ **For expansions**: Loads completed core files as context
- ✅ Identifies testing frameworks and conventions
- ✅ Ensures PRD follows project patterns

**Platform-aware** 🎯 - automatically tailors PRD structure for Rails backend, iOS mobile, or Android mobile development.

### Natural Activation 🗣️

- "Create a PRD for invoices"
- "Create an expansion for customer details"
- "Let's plan the core booking feature"
- 🇫🇷 "Créer un PRD", "planifier une fonctionnalité"

</details>

---

<details>
<summary><strong>💻 implement-code</strong> - Implement core or expansion PRDs with pattern-aware code generation</summary>

<br>

### Land Then Expand Implementation 🌱

**Detects PRD type automatically** and adjusts workflow:

**Core PRD Implementation:**
- Establishes clean, simple patterns
- Creates minimal working foundation
- Max 2-4 substories
- After completion: Suggests creating expansion PRDs

**Expansion PRD Implementation (CRITICAL):**
- **Loads completed core files** as context
- Analyzes and follows established patterns
- Extends (not replaces) core code
- Maintains naming and structure consistency

### Guided Workflow 🚀

1. 📋 Load PRD and detect type (core vs expansion)
2. 🔍 For expansions: Load core implementation files
3. 💻 Implement substory code following patterns
4. ✅ Update PRD with completion status
5. 💡 Suggest next steps (review, test, commit, continue)
6. ⏸️ Wait for your decision

### Features ⭐

- 🔍 Architecture analysis before coding
- 🎯 Follows existing project patterns
- 📂 **For expansions**: Loads and extends core files
- 🛠️ Platform-specific best practices
- 📦 Incremental implementation (one substory at a time)
- 📊 Real-time PRD status updates
- 💬 Clear suggestions, no auto-invocations
- 🎮 You orchestrate review → test → commit → PR

### Natural Activation 🗣️

- "Implement the authentication PRD"
- "Build the booking feature"
- 🇫🇷 "Implémenter le PRD"

</details>

---

<details>
<summary><strong>🧪 implement-tests</strong> - Write comprehensive test suites</summary>

<br>

### Features ⭐

- 🔍 Auto-detects testing framework (RSpec, Minitest, XCTest, JUnit+MockK)
- ✍️ Writes tests matching your project's style
- 📋 Maps tests to PRD acceptance criteria
- ✅ Covers happy paths, edge cases, and error scenarios
- 🎯 Platform-specific test patterns

### Test Types 🧪

Unit • Integration • E2E • Platform-specific UI tests

### Natural Activation 🗣️

- "Write tests for the auth feature"
- "Add tests for booking service"
- 🇫🇷 "Écrire des tests"

</details>

---

<details>
<summary><strong>📊 track-prd-progress</strong> - Track and update PRD implementation status</summary>

<br>

### Features ⭐

- 📈 Real-time progress dashboard
- ⚡ Velocity calculations
- 🚫 Blocker identification and management
- 📅 Status reports (daily/weekly)
- 🎯 ETA predictions

### Progress Metrics 📊

```
📊 Progress Metrics:
✅ Completed: 3 (37.5%)
🔄 In Progress: 1 (12.5%)
🚫 Blocked: 1 (12.5%)
⏳ Pending: 3 (37.5%)

📈 Velocity: 1.5 substories/day
🎯 ETA: 2 days
```

### Natural Activation 🗣️

- "Show PRD progress"
- "Update the PRD status"
- 🇫🇷 "Suivre la progression"

</details>

---

<details>
<summary><strong>💾 commit</strong> - Generate well-formatted commit messages</summary>

<br>

### Workflow 🔄

1. 📊 Show change summary (files, lines)
2. 📝 Generate conventional commit message
3. ✅ Wait for your approval
4. 💾 Create commit only after "yes"

### Platform-aware Features ⭐

- 🏷️ Automatic change type detection (feat/fix/refactor/etc.)
- 📂 Scope detection from file paths
- 📝 Detailed commit body with context
- 🔗 Links to PRD substories
- 💡 Suggests splitting unrelated changes

### Generated Format 📄

```
feat(auth): add OAuth2 social login support

Implement OAuth2 authentication for Google, GitHub, and Apple.

- Add OAuth2 provider configurations
- Create callback handler for authentication flow
- Store OAuth tokens securely with encryption

Related: PRD-2024-10-25-auth (substory 1.3)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Natural Activation 🗣️

- "Commit these changes"
- "Save my work"
- 🇫🇷 "Committer"

</details>

---

<details>
<summary><strong>🚀 create-pr</strong> - Generate comprehensive GitHub pull requests</summary>

<br>

### Workflow 🔄

1. ❌ Error if uncommitted changes exist (tells you to commit first)
2. 📊 Analyze branch diff vs origin/main
3. 📝 Generate PR title and description
4. ✅ Wait for your approval
5. 🚀 Create PR only after "yes"

### Generated PR Includes 📄

- 📝 Summary (2-3 sentences)
- 🔗 Related PRD and completed substories
- 📊 Changes by category (Added/Modified/Removed)
- 📈 Test coverage metrics
- ✅ All tests passing confirmation

### Natural Activation 🗣️

- "Create a pull request"
- "Make a PR"
- 🇫🇷 "Créer une PR"

</details>

---

<details>
<summary><strong>🔍 code-review</strong> - Multi-dimensional code analysis with auto-depth detection</summary>

<br>

### Auto-Depth Detection 🎯

- **⚡ Quick** (<100 lines, ≤3 files): 2-3 min, critical issues only
- **📊 Standard** (100-500 lines, 4-15 files): 10-15 min, comprehensive
- **🔬 Deep** (>500 lines, >15 files): 20-30 min, full architecture

### Review Dimensions 📋

- **✨ Code Quality**: Readability, maintainability, complexity
- **🏗️ Architecture**: Design patterns, SOLID principles
- **🔒 Security**: Auth/authz, input validation, secrets
- **⚡ Performance**: N+1 queries, memory leaks, algorithms
- **🧪 Testing**: Coverage, quality, edge cases

### Platform-specific Checks 🎯

- **💎 Rails**: Strong parameters, N+1 queries, migrations, ActiveRecord
- **🍎 iOS Swift**: Retain cycles, optional handling, main thread UI, async/await
- **🤖 Android Kotlin**: Context leaks, Coroutines, ViewModel, Hilt DI

### Output 📤

- 🎯 Findings by severity (🔴 Critical, 🟠 Major, 🟡 Minor)
- 📍 File:line references with code examples
- 💡 Fix suggestions (you apply them)
- ✅ Positive feedback
- 👍 Approval recommendation
- 💬 Suggested next steps

### Natural Activation 🗣️

- "Review my code"
- "Check my changes"
- 🇫🇷 "Réviser le code"

</details>

---

<div align="center">

💡 **Tip**: All skills support both English and French activation phrases!

🔗 Back to [Main README](../../README.md)

</div>
