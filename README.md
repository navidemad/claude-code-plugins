# Claude Code

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows -- all through natural language commands. Use it in your terminal, IDE, or tag @claude on Github.

**Learn more in the [official documentation](https://docs.anthropic.com/en/docs/claude-code/overview)**.

## Get started

1. Install Claude Code:

```sh
bun -g install @anthropic-ai/claude-agent-sdk
```

2. Navigate to your project directory and run `claude`.

## Plugins

This repository includes several Claude Code plugins that extend functionality with custom commands and agents. See the [plugins directory](./plugins/README.md) for detailed documentation on available plugins.

# Yespark Team Claude Code Marketplace

**Powerful AI assistants for Rails, iOS Swift, and Android Kotlin development.** Smart tools that help you work faster while you stay in control.

## Overview

This marketplace provides **7 intelligent skills** that enhance your development workflow. Each skill is a focused assistant - it helps you accomplish a specific task, you decide what happens next.

**🎯 Philosophy:** Tools, not automation. Each skill does one thing well, you orchestrate the workflow.

**🤖 Model-invoked** - Claude activates skills based on your conversation. No slash commands to remember.

**🔧 Platform-aware** - Automatically detects Rails, iOS Swift, or Android Kotlin and adapts conventions.

**🌍 Bilingual** - All skills support English and French activation phrases.

**💪 Developer control** - You maintain full control. Skills suggest next steps, you decide.

### Available Skills

| Skill | Purpose | Activated When You Say... |
|-------|---------|---------------------------|
| **generate-prd** | Create adaptive PRDs with codebase exploration | "create a PRD", "plan feature" (🇫🇷 "créer un PRD") |
| **implement-code** | Write code substory-by-substory from PRDs | "implement PRD", "build this" (🇫🇷 "implémenter le PRD") |
| **implement-tests** | Write comprehensive test suites | "write tests", "add tests" (🇫🇷 "écrire des tests") |
| **track-prd-progress** | Track and update PRD implementation status | "update PRD", "show progress" (🇫🇷 "mettre à jour le PRD") |
| **commit** | Generate well-formatted commit messages | "commit this", "save my work" (🇫🇷 "committer") |
| **create-pr** | Generate comprehensive PR descriptions | "create a PR", "submit for review" (🇫🇷 "créer une PR") |
| **code-review** | Multi-dimensional code quality analysis | "review code", "check changes" (🇫🇷 "réviser le code") |

## Quick Start

### Installation

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "yespark-team-marketplace": {
      "source": {
        "source": "github",
        "repo": "yespark/yespark-claude-plugins"
      }
    }
  },
  "enabledPlugins": [
    "yespark-team-marketplace:product-workflow-skills"
  ]
}
```

Trust the folder in Claude Code - skills are immediately available!

### How It Works

**Skills activate naturally** when you describe what you want. Each skill helps with one task, then suggests next steps. You decide the workflow.

```
You: "Let's create a PRD for the new payment feature"

Claude: [generate-prd activates]
        🔍 Exploring codebase...
        Found: Existing payment logic in app/services/payment/
        ✨ Detected: FULL mode PRD (complex feature)

        [Asks 15 clarifying questions]

        ✅ Created PRD at docs/prds/2024-10-25-payments.md

        💡 Next steps:
        - "implement PRD" - Start coding
        - "review PRD" - Check requirements

        What would you like to do?

You: "Implement PRD"

Claude: [implement-code activates]
        📋 Implementing substory 1.1: Payment model...
        [Writes code following existing patterns]

        ✅ Substory 1.1 complete!

        💡 Next steps:
        - "review my code" - Check code quality
        - "commit these changes" - Save progress
        - "continue to 1.2" - Next substory

        What would you like to do?

You: "Review my code"

Claude: [code-review activates]
        📊 Auto-detected: Standard Review (247 lines, 8 files)

        [Performs comprehensive review]

        ✅ Review complete!
        - 🔴 0 critical issues
        - 🟠 2 major issues
        - 🟡 3 minor suggestions

        💡 Next steps:
        - "help fix X" - Get fix suggestions
        - "commit anyway" - Proceed with commit

        What would you like to do?

You: "Help fix the major issues"

Claude: [Helps fix issues interactively]

You: "Commit these changes"

Claude: [commit activates]
        📊 Changes: 8 files, 247 lines

        📝 Generated commit message:
        feat(payment): add payment model with validation
        [Shows full message]

        Proceed? [yes/no/edit]

You: "Yes"

Claude: ✅ Committed: a1b2c3d

        💡 Next steps:
        - "create a PR" - Submit for review
        - "continue to 1.2" - Next substory

        What would you like to do?

You: "Create a PR"

Claude: [create-pr activates]
        [Generates PR description]

        Create PR? [yes/no/edit]

You: "Yes"

Claude: ✅ PR #123 created!
        🔗 https://github.com/yespark/app/pull/123
```

## Platform Support

**Automatically detects and adapts to:**

### Supported Platforms
- **Ruby on Rails** - Models, controllers, services, migrations, ActiveRecord patterns, RSpec/Minitest
- **iOS/Swift** - MVVM architecture, SwiftUI/UIKit, ViewModels, Combine, async/await
- **Android/Kotlin** - Clean Architecture, MVVM, Coroutines, Hilt DI, Jetpack Compose

### Detection Method
Skills automatically detect your platform by analyzing project files:
- **Rails**: Presence of `Gemfile` with `gem "rails"`
- **iOS Swift**: `.xcodeproj` folder, `Podfile`, or `Package.swift`
- **Android Kotlin**: `gradle.properties` file at project root

Once detected, skills automatically load platform-specific conventions and best practices from reference files, ensuring code generation follows your platform's standards.

## Skills in Detail

<details>
<summary><strong>🎯 generate-prd</strong> - Create adaptive PRDs with codebase exploration</summary>

<br>

**Adaptive Modes:**
- **Quick Mode**: Simple features (5-7 questions, lightweight spec)
- **Full Mode**: Complex features (15-20 questions, comprehensive spec)

**Auto-detected based on feature description** - you can override if needed.

**Codebase Exploration:**
- Analyzes existing patterns and architecture
- Finds similar features for reference
- Discovers authentication/authorization approaches
- Identifies testing frameworks and conventions
- Ensures new PRD follows project patterns

**PRD Contents:**
- Problem statement and solution overview
- Functional and non-functional requirements
- Multiple implementation phases
- Substories with acceptance criteria
- API/interface specifications
- Data schema design
- Testing strategy
- Security and performance considerations

**Platform-aware** - automatically tailors PRD structure for Rails backend, iOS mobile, or Android mobile development.

**Natural activation:**
- "Create a PRD for user authentication"
- "Let's plan out the booking feature"
- "Write a spec for the payment system"
- 🇫🇷 "Créer un PRD", "planifier une fonctionnalité"

</details>

---

<details>
<summary><strong>🔨 implement-code</strong> - Implement PRDs substory-by-substory with smart guidance</summary>

<br>

**Guided Workflow:**
1. 📋 Implement substory code
2. ✅ Update PRD with completion status
3. 💡 Suggest next steps (review, test, commit, continue)
4. ⏸️ Wait for your decision

**Features:**
- Architecture analysis before coding
- Follows existing project patterns
- Platform-specific best practices
- Incremental implementation (one substory at a time)
- Real-time PRD status updates
- Clear suggestions, no auto-invocations
- You orchestrate review → test → commit → PR

**Natural activation:** "Implement the authentication PRD" • "Build the booking feature" • 🇫🇷 "Implémenter le PRD"

</details>

---

<details>
<summary><strong>✅ implement-tests</strong> - Write comprehensive test suites</summary>

<br>

**Features:**
- Auto-detects testing framework (RSpec, Minitest, XCTest, JUnit+MockK)
- Writes tests matching your project's style
- Maps tests to PRD acceptance criteria
- Covers happy paths, edge cases, and error scenarios
- Platform-specific test patterns

**Test Types:** Unit • Integration • E2E • Platform-specific UI tests

**Natural activation:** "Write tests for the auth feature" • "Add tests for booking service" • 🇫🇷 "Écrire des tests"

</details>

---

<details>
<summary><strong>📊 track-prd-progress</strong> - Track and update PRD implementation status</summary>

<br>

**Features:**
- Real-time progress dashboard
- Velocity calculations
- Blocker identification and management
- Status reports (daily/weekly)
- ETA predictions

**Progress Metrics:**
```
📊 Progress Metrics:
✅ Completed: 3 (37.5%)
🔄 In Progress: 1 (12.5%)
🚫 Blocked: 1 (12.5%)
⏳ Pending: 3 (37.5%)

📈 Velocity: 1.5 substories/day
🎯 ETA: 2 days
```

**Natural activation:** "Show PRD progress" • "Update the PRD status" • 🇫🇷 "Suivre la progression"

</details>

---

<details>
<summary><strong>💾 commit</strong> - Generate well-formatted commit messages</summary>

<br>

**Workflow:**
1. 📊 Show change summary (files, lines)
2. 📝 Generate conventional commit message
3. ✅ Wait for your approval
4. 💾 Create commit only after "yes"

**Platform-aware features:**
- Automatic change type detection (feat/fix/refactor/etc.)
- Scope detection from file paths
- Detailed commit body with context
- Links to PRD substories
- Suggests splitting unrelated changes

**Generated Format:**
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

**Natural activation:** "Commit these changes" • "Save my work" • 🇫🇷 "Committer"

</details>

---

<details>
<summary><strong>🚀 create-pr</strong> - Generate comprehensive GitHub pull requests</summary>

<br>

**Workflow:**
1. ❌ Error if uncommitted changes exist (tells you to commit first)
2. 📊 Analyze branch diff vs origin/main
3. 📝 Generate PR title and description
4. ✅ Wait for your approval
5. 🚀 Create PR only after "yes"

**Generated PR Includes:**
- Summary (2-3 sentences)
- Related PRD and completed substories
- Changes by category (Added/Modified/Removed)
- Test coverage metrics
- All tests passing confirmation

**Natural activation:** "Create a pull request" • "Make a PR" • 🇫🇷 "Créer une PR"

</details>

---

<details>
<summary><strong>🔍 code-review</strong> - Multi-dimensional code analysis with auto-depth detection</summary>

<br>

**Auto-Depth Detection:**
- **Quick** (<100 lines, ≤3 files): 2-3 min, critical issues only
- **Standard** (100-500 lines, 4-15 files): 10-15 min, comprehensive
- **Deep** (>500 lines, >15 files): 20-30 min, full architecture

**Review Dimensions:**
- **Code Quality**: Readability, maintainability, complexity
- **Architecture**: Design patterns, SOLID principles
- **Security**: Auth/authz, input validation, secrets
- **Performance**: N+1 queries, memory leaks, algorithms
- **Testing**: Coverage, quality, edge cases

**Platform-specific checks:**
- **Rails**: Strong parameters, N+1 queries, migrations, ActiveRecord
- **iOS Swift**: Retain cycles, optional handling, main thread UI, async/await
- **Android Kotlin**: Context leaks, Coroutines, ViewModel, Hilt DI

**Output:**
- Findings by severity (🔴 Critical, 🟠 Major, 🟡 Minor)
- File:line references with code examples
- Fix suggestions (you apply them)
- Positive feedback
- Approval recommendation
- Suggested next steps

**Natural activation:** "Review my code" • "Check my changes" • 🇫🇷 "Réviser le code"

</details>

## Complete Workflow Example

<details>
<summary>Click to see a full conversation showing all 7 skills in action</summary>

<br>

```
You: "I want to build a parking reservation feature"

Claude: [generate-prd activates]
        🔍 Exploring codebase...
        Found: Existing booking patterns in app/services/booking/
        ✨ Detected: FULL mode PRD

        [Asks 15 questions]

        ✅ Created PRD at docs/prds/2024-10-25-parking-reservation.md

        💡 Next: "implement PRD" to start coding

You: "Implement PRD"

Claude: [implement-code activates]
        🔍 Analyzing Rails architecture...
        📋 Implementing substory 1.1: Reservation model...

        ✅ Substory 1.1 complete!

        💡 Next steps:
        - "review my code" - Check quality
        - "write tests" - Add test coverage
        - "commit these changes" - Save progress
        - "continue to 1.2" - Next substory

        What would you like?

You: "Write tests"

Claude: [implement-tests activates]
        🔍 Detected: RSpec + FactoryBot
        ✅ Writing tests...

        📊 Coverage: 78% → 94% (+16%)
        All tests passing ✅

        💡 Next: "commit these changes"

You: "Review my code first"

Claude: [code-review activates]
        📊 Standard Review (247 lines, 8 files)

        ✅ Review complete!
        - 🔴 0 critical
        - 🟠 1 major (missing index)
        - 🟡 3 minor

        💡 Next: "help fix X" or "commit"

You: "Help fix the index issue"

Claude: [Shows fix, you apply it]

You: "Commit these changes"

Claude: [commit activates]
        📊 8 files, 247 lines

        📝 Generated:
        feat(booking): add reservation model with tests
        [Shows message]

        Proceed? [yes/no]

You: "Yes"

Claude: ✅ Committed: a1b2c3d

        💡 Next: "create a PR" or "continue to 1.2"

You: "Create a PR"

Claude: [create-pr activates]
        📝 Generated PR:
        Title: feat(booking): add reservation model
        [Shows description]

        Create? [yes/no]

You: "Yes"

Claude: ✅ PR #123 created!
        🔗 https://github.com/yespark/app/pull/123
```

**Notice:** You control every step. Skills suggest, you decide.

</details>

## Benefits

### For Individual Developers
- **Stay in Control**: You decide what happens next, skills just help
- **Learn Best Practices**: Skills show platform-specific patterns (Rails, iOS, Android)
- **Save Time**: Generate commit messages, PR descriptions, review reports instantly
- **Clear Mental Model**: Each skill does one thing, no hidden automation
- **Complete Traceability**: From PRD → Code → Review → Commit → PR
- **Work Your Way**: Use skills in any order, skip what you don't need

### For Teams
- **Consistent Standards**: Everyone's commits and PRs follow same format
- **Predictable Workflow**: Tools behave the same for everyone
- **No Surprises**: Skills suggest, never auto-execute
- **Easy Onboarding**: New developers see patterns in skill outputs
- **Multi-Platform**: Same skills for Rails backend, iOS, and Android

### For Product Management
- **Real-time Visibility**: Track PRD implementation progress
- **Requirements Traceability**: Link PRD → Code → Commit → PR
- **Quality Gates**: Reviews happen before commits
- **Living Documentation**: PRDs stay updated automatically
- **Cross-Platform Tracking**: Unified workflow across platforms

## Key Advantages of Skills vs Commands

**Skills (This Marketplace):**
- ✅ Natural conversation - no syntax to remember
- ✅ Claude decides when to use them
- ✅ Context-aware activation
- ✅ Progressive disclosure - details loaded as needed
- ✅ Team collaboration through git
- ✅ Platform-aware - adapts to Rails, iOS Swift, or Android Kotlin

**Traditional Commands:**
- ❌ Must remember exact command syntax
- ❌ Must explicitly invoke with `/command`
- ❌ Less contextual
- ❌ All logic loaded upfront
- ❌ Often platform-specific

## Requirements

- **Claude Code CLI** (latest version with skills support)
- **Git** for version control
- **GitHub CLI** (`gh`) for PR creation
- Your specific development tools (language runtimes, build tools, etc.)

## Advanced Usage

<details>
<summary>Customizing skills for your team</summary>

<br>

### Customizing Skills

Skills are in `.claude/skills/` - you can customize them:
1. Modify SKILL.md files to adjust behavior
2. Add reference files for skill-specific docs
3. Commit changes so team gets updates

### PRD Templates

The generate-prd skill creates structured PRDs. Customize the template by editing `.claude/skills/generate-prd/SKILL.md`.

### Project Guidelines

Create `CLAUDE.md` in your project root with:
- Coding conventions
- Architecture decisions
- Testing requirements
- Security policies

The code-review skill automatically checks against these guidelines.

</details>

<details>
<summary>Sharing with your team</summary>

<br>

### Method 1: Marketplace (Recommended)
1. Push this repository to GitHub
2. Team members add marketplace to their `.claude/settings.json`
3. Skills automatically available in all their projects

### Method 2: Direct Copy
1. Copy `.claude/skills/` to your project
2. Commit to git
3. Team members pull and get skills immediately

</details>

<details>
<summary>Troubleshooting</summary>

<br>

### Skills Not Activating
- **Check installation**: Verify `.claude/settings.json` has correct marketplace config
- **Trust folder**: Make sure you trusted the project folder
- **Restart Claude Code**: Close and reopen Claude Code
- **Be explicit**: Say "use the generate-prd skill" to force activation
- **Check logs**: Run `claude --debug` to see skill loading errors

### Wrong Platform Detected
- Skills detect from project files (Gemfile with rails gem, .xcodeproj, gradle.properties)
- Make sure these marker files are present at project root
- You can mention platform explicitly: "implement this as a Rails feature"

### Skill Errors
- Check required tools are installed (git, gh CLI)
- Verify permissions (can Claude write files?)
- Check Claude Code version (skills require recent version)

</details>

## Support

- **Quick Start**: See [QUICKSTART.md](QUICKSTART.md) for 2-minute setup
- **Issues**: Open an issue in this repository
- **Team Help**: Ask in your development channel
- **Claude Code Docs**: https://docs.claude.com/claude-code/skills

## Version

**Current version: 5.0.0**

### Changelog

#### 5.0.0 (2025-10-25) - **Developer Control Release**
- **🎯 Philosophy shift**: Tools, not automation - you control the workflow
- **7 focused skills** - each does one thing well, suggests next steps
  - `implement-prd` → `implement-code`, `implement-tests`, `track-prd-progress`
- **NO auto-invocations** - skills never call other skills automatically
  - `implement-code`: writes code, suggests review/test/commit
  - `commit`: generates message, waits for approval before committing
  - `create-pr`: requires clean branch, waits for approval before creating
  - `code-review`: reviews branch diff, suggests fixes (you apply them)
- **Approval gates** - every action requires explicit user confirmation
- **Clear suggestions** - skills show "Next steps" with natural phrases
- **Adaptive intelligence** retained:
  - `generate-prd`: auto-detects Quick vs Full mode
  - `code-review`: auto-detects Quick/Standard/Deep depth
- **Bilingual support** - English and French for all skills
- **Codebase exploration** - PRD generation analyzes existing patterns
- **Default scope**: code-review checks branch diff vs `origin/main`

#### 4.0.0 (2025-10-25) - **Automation Release** (deprecated)
- Fully automated workflow with auto-review → auto-commit → auto-PR
- Removed in favor of developer-controlled approach

#### 3.1.0 (2025-10-25)
- **Platform-aware skills** - supports Rails, iOS Swift, and Android Kotlin
- Automatic platform detection from project files (Gemfile, .xcodeproj, gradle.properties)
- Skills adapt terminology and patterns to detected platform
- Platform-specific reference files with conventions and best practices
- Platform-aware PRD templates and code generation
- Platform-specific code review checks (N+1 for Rails, retain cycles for iOS, Context leaks for Android)

#### 3.0.0 (2025-10-25)
- Complete redesign using Skills (model-invoked, not user-invoked)
- 5 core skills: generate-prd, implement-prd, commit, create-pr, code-review
- Natural language activation - no slash commands needed
- Followed Anthropic's official skill best practices
- Enhanced PRD format with real-time status tracking
- Comprehensive code review with platform-specific checks

## License

Internal use only - Yespark Development Team

---

🤖 Built with Claude Code Skills
Platform-aware AI-powered development workflow for Rails, iOS Swift, and Android Kotlin
