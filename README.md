# Yespark Team Claude Code Marketplace

AI-powered skills for complete product development workflow: from PRD creation to implementation, commits, and pull requests. **Platform-agnostic** - adapts to your tech stack automatically.

## Overview

This marketplace provides **5 intelligent skills** that Claude Code automatically activates based on your needs. No slash commands to remember - just describe what you want, and Claude uses the right skill.

**Skills are model-invoked** - Claude decides when to use them based on your conversation, making your workflow natural and intuitive.

**Truly platform-agnostic** - Works with Ruby/Rails, JavaScript/Node.js, Python, Java/Kotlin, Swift/iOS, React, Vue, Angular, and more. Skills detect your tech stack and adapt automatically.

### Available Skills

| Skill | Purpose | Activated When You Say... |
|-------|---------|---------------------------|
| **generate-prd** | Create comprehensive PRDs with phases and substories | "create a PRD", "plan this feature", "document requirements" |
| **implement-prd** | Implement PRDs with automatic progress tracking | "implement the PRD", "continue implementing", references a PRD file |
| **commit** | Smart git commits with Conventional Commits format | "commit this", "save my work", "create a commit" |
| **create-pr** | Generate comprehensive PR descriptions | "create a PR", "make a pull request", "submit for review" |
| **code-review** | Multi-dimensional code quality analysis | "review my code", "code review", "check my changes" |

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

Unlike slash commands, **you don't invoke skills directly**. Just have a natural conversation:

```
You: "Let's create a PRD for the new payment feature"
Claude: [Activates generate-prd skill, asks clarifying questions, creates PRD]

You: "Now implement this PRD"
Claude: [Activates implement-prd skill, detects your tech stack, starts implementing]

You: "Commit my changes"
Claude: [Activates commit skill, analyzes changes, generates commit message]

You: "Review my code before I push"
Claude: [Activates code-review skill, performs comprehensive analysis]

You: "Create a pull request"
Claude: [Activates create-pr skill, generates PR with full description]
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

### 🎯 generate-prd
**Create comprehensive Product Requirements Documents**

Claude asks clarifying questions and generates structured PRDs in `docs/prds/` with:
- Problem statement and solution overview
- Functional and non-functional requirements
- Multiple implementation phases
- Substories with acceptance criteria
- API/interface specifications
- Data schema design
- Testing strategy
- Security and performance considerations

**Platform-aware sections adapt to your stack** - automatically tailors PRD structure for Rails backend, iOS mobile, or Android mobile development.

**Natural activation:**
- "Create a PRD for user authentication"
- "Let's plan out the booking feature"
- "Help me document these requirements"

---

### 🔨 implement-prd
**Implement PRDs with automatic progress tracking**

Claude reads your PRD, **detects your tech stack**, implements it substory by substory, and automatically updates the PRD with progress (✅ completed, 🔄 in progress, ⏳ pending).

**Features:**
- Automatic platform detection from project files
- Incremental implementation (one substory at a time)
- Real-time PRD status updates
- Creates appropriate commits per substory
- Adapts code patterns to your framework
- Resumes from where you left off
- Tests using your project's testing framework

**Natural activation:**
- "Implement the authentication PRD"
- "Continue implementing docs/prds/2024-10-25-booking.md"
- "Let's start building this feature"

**PRD Status Tracking:**
```markdown
## Implementation Status
- ✅ [Phase 1.1] User model - Completed (2024-10-25)
  Files: app/models/user.rb, spec/models/user_spec.rb
  Commit: a1b2c3d
- 🔄 [Phase 1.2] OAuth integration - In Progress
  Current: Implementing Google OAuth
- ⏳ [Phase 1.3] Password reset - Not Started
```

---

### 💾 commit
**Smart git commits with Conventional Commits format**

Claude analyzes your staged changes and generates descriptive commit messages following Conventional Commits specification.

**Platform-aware features:**
- Automatic change type detection (feat/fix/refactor/etc.)
- Scope detection from file paths (Rails: models/controllers, iOS: ui/viewmodel, Android: data/domain/presentation)
- Detailed commit body with context
- Links to PRD substories
- Suggests splitting unrelated changes

**Natural activation:**
- "Commit these changes"
- "Save my work"
- "Create a commit"

**Generated Format:**
```
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
```

---

### 🚀 create-pr
**Generate comprehensive GitHub pull requests**

Claude analyzes your branch, finds related PRD (if any), and creates a PR with detailed description covering all aspects.

**Platform-aware features:**
- Auto-generated title and description
- Links to related PRD with completed substories
- Comprehensive change summary by component
- Testing checklist (adapts to your test framework)
- Database/schema migration details
- Security and performance notes
- Deployment instructions

**Natural activation:**
- "Create a pull request"
- "Make a PR"
- "Submit this for review"

**Generated PR Includes:**
- Executive summary
- Related PRD and completed substories
- Changes by layer (backend/frontend/mobile/etc.)
- Testing performed
- Schema changes
- Security considerations
- Deployment notes and rollback plan
- Reviewer checklist

---

### 🔍 code-review
**Comprehensive multi-dimensional code analysis**

Claude performs thorough code review across quality, security, performance, and testing dimensions with **language-specific and framework-specific checks**.

**Review Dimensions:**
- **Code Quality**: Readability, maintainability, complexity, code smells
- **Architecture**: Design patterns, SOLID principles, separation of concerns
- **Security**: Auth/authz, input validation, secrets, data exposure
- **Performance**: Database queries, caching, algorithms, resource management
- **Testing**: Coverage, quality, edge cases

**Platform-specific checks:**
- **Ruby/Rails**: Strong parameters, N+1 queries, migrations reversibility, background jobs, ActiveRecord best practices
- **iOS/Swift**: Memory management, retain cycles, optional handling, main thread UI updates, async/await patterns
- **Android/Kotlin**: Lifecycle awareness, Context leaks, Coroutines usage, ViewModel patterns, Hilt dependency injection

**Natural activation:**
- "Review my code"
- "Check my changes"
- "Code review please"

**Output:**
- Findings by severity (Critical/Major/Minor)
- File:line references for each issue
- Code examples showing problems and fixes
- Positive feedback on what's done well
- Prioritized action items
- Approval recommendation

## Complete Workflow Example

Here's a natural conversation showing all skills in action:

```
You: "I want to build a parking spot reservation feature"

Claude: [generate-prd activates]
Let me help you create a PRD. I'll ask some questions to understand the requirements...

[After answering questions]
Claude: Created PRD at docs/prds/2024-10-25-parking-reservation.md with 3 phases and 8 substories.

You: "Great, let's start implementing it"

Claude: [implement-prd activates]
Detected Rails backend project. I'll implement the PRD starting with Phase 1, Substory 1: Creating the Reservation model...

[Claude implements code, writes tests, updates PRD status]

You: "Commit what we have so far"

Claude: [commit activates]
I'll analyze the changes and create a commit...

Generated commit message:
feat(booking): add reservation model and database schema

[Shows full commit message]

Shall I proceed with this commit?

You: "Yes, and review the code before we continue"

Claude: [code-review activates]
Performing comprehensive code review for Rails application...

# Code Review Report
✅ Overall Status: Approved with minor suggestions

[Shows detailed review with Rails-specific checks]

You: "Looks good, let's create a PR for this phase"

Claude: [create-pr activates]
Creating pull request...

✅ PR Created: https://github.com/yespark/app/pull/123
Title: feat(booking): implement reservation model (Phase 1.1)

[Shows PR summary]

PRD updated with PR reference.
```

## Benefits

### For Individual Developers
- **Natural Workflow**: Just describe what you want - no commands to remember
- **Automatic Best Practices**: Skills encode best practices for Rails, iOS Swift, and Android Kotlin
- **Complete Traceability**: From PRD → Implementation → Commit → PR
- **Time Savings**: Automate tedious parts (commit messages, PR descriptions, reviews)
- **Platform-aware**: Automatically adapts to Rails backend, iOS, or Android projects

### For Teams
- **Shared Standards**: Everyone's PRDs, commits, and PRs follow same format
- **Better Documentation**: PRDs with real-time status, comprehensive PR descriptions
- **Code Quality**: Consistent review standards for Rails, iOS, and Android
- **Knowledge Sharing**: New developers learn platform-specific patterns from skill outputs
- **Multi-Platform Support**: Same workflow whether building Rails backend, iOS app, or Android app

### For Product Management
- **Visibility**: PRD status shows real-time progress
- **Traceability**: Clear link from requirements to implementation to PR
- **Quality**: Automated reviews before human review
- **Documentation**: Living documentation that stays up-to-date
- **Cross-Platform Tracking**: Track progress across Rails backend, iOS, and Android implementations

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

## Sharing with Your Team

### Method 1: Marketplace (Recommended)
1. Push this repository to GitHub
2. Team members add marketplace to their `.claude/settings.json`
3. Skills automatically available in all their projects

### Method 2: Direct Copy
1. Copy `.claude/skills/` to your project
2. Commit to git
3. Team members pull and get skills immediately

## Troubleshooting

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

## Support

- **Quick Start**: See [QUICKSTART.md](QUICKSTART.md) for 2-minute setup
- **Issues**: Open an issue in this repository
- **Team Help**: Ask in your development channel
- **Claude Code Docs**: https://docs.claude.com/claude-code/skills

## Version

**Current version: 3.1.0**

### Changelog

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
