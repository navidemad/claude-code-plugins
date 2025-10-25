# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code Skills marketplace plugin** that provides 7 developer-controlled workflow skills for Rails, iOS Swift, and Android Kotlin development. The skills are designed as tools, not automation - users stay in control at every step.

## Core Architecture

### Skills System

Skills are located in `.claude/skills/` with each skill having:
- `SKILL.md`: Full skill implementation prompt with activation triggers, workflow steps, and platform-specific logic
- Activation via natural language (both English and French)
- Platform detection via `.claude/skills/shared/scripts/detect_platform.sh`

**Platform Detection Logic:**
1. Android Kotlin: `gradle.properties` at root
2. iOS Swift: `*.xcodeproj` folder, `Package.swift`, or `Podfile`
3. Rails: `Gemfile` with `gem "rails"`

**Platform-Specific Conventions:**
- Loaded from `.claude/skills/shared/references/{platform}/conventions.md`
- Rails: Models, controllers, services, RSpec/Minitest patterns
- iOS Swift: MVVM, SwiftUI/UIKit, ViewModels, Combine, async/await
- Android Kotlin: Clean Architecture, MVVM, Coroutines, Hilt DI

### PRD Philosophy: Land Then Expand

**Critical Design Pattern**: This plugin uses a "land then expand" approach instead of large upfront planning documents.

**Why**: Modern Claude models work better when they establish patterns first, then layer complexity. Large comprehensive PRDs lead to:
- Incorrect architectural assumptions
- Token inefficiency
- Inconsistent results
- Longer feedback cycles

**The Pattern**:

1. **Core PRD** (minimal foundation):
   - File: `docs/prds/YYYY-MM-DD-{feature}-core.md`
   - Contains: Essential fields only, basic CRUD, foundational architecture
   - Example for invoices: just invoice number, date, amount
   - Goal: Establish patterns and working code, NOT completeness
   - Max 2-4 substories in a single phase

2. **Expansion PRDs** (after core lands):
   - Files: `docs/prds/YYYY-MM-DD-{feature}-{expansion}.md`
   - Examples: `-customer-details.md`, `-line-items.md`, `-payment-logic.md`
   - Each focuses on ONE aspect building on completed core
   - References and uses patterns from implemented core code
   - Claude loads completed core files as context for consistency

**Workflow**:
```
User: "Create PRD for invoice system"
→ generate-prd creates CORE PRD (minimal fields only)

User: "Implement the core PRD"
→ implement-code builds foundation

User: "Create expansion PRDs"
→ generate-prd creates separate PRDs for customer-details, line-items, etc.

User: "Implement customer-details expansion"
→ implement-code loads core files as context, extends patterns
```

### Seven Core Skills

1. **generate-prd**: Core/Expansion PRD generation with codebase exploration
   - Asks: "Is this a new core feature or expansion of existing feature?"
   - **Core mode**: Generates minimal foundation PRD (2-4 substories max)
   - **Expansion mode**: Builds focused PRD on top of completed core
   - Explores existing patterns before generating PRD
   - Creates structured PRDs in `docs/prds/` directory

2. **implement-code**: Substory-by-substory code implementation
   - For expansions: loads completed core files as context
   - Analyzes architecture before coding
   - Updates PRD progress in real-time
   - After core completion: suggests creating expansion PRDs
   - Suggests next steps (review/test/commit/continue) but waits for user decision

3. **implement-tests**: Test suite generation
   - Auto-detects testing framework (RSpec, Minitest, XCTest, JUnit+MockK)
   - **Important**: Prioritize Minitest if both RSpec and Minitest exist in Rails projects
   - Maps tests to PRD acceptance criteria

4. **track-prd-progress**: PRD implementation tracking
   - Shows completion metrics and velocity
   - Identifies blockers
   - Provides ETA predictions

5. **commit**: Conventional commit message generation
   - Shows change summary before generating message
   - Waits for explicit "yes" approval before committing
   - Uses conventional commit format with PRD substory links

6. **create-pr**: GitHub PR creation
   - Errors if uncommitted changes exist
   - Analyzes branch diff vs origin/main
   - Waits for approval before creating PR

7. **code-review**: Multi-dimensional code analysis
   - Auto-detects review depth (Quick/Standard/Deep) based on lines changed and files modified
   - Reviews current branch vs origin/main by default
   - Platform-specific checks (Rails: N+1 queries, iOS: retain cycles, Android: Context leaks)

## Development Commands

This repository is a **plugin marketplace** - there is no build, test, or run process. Development involves:

### Testing Skills Locally

Install in a target project's `.claude/settings.json`:
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
    "yespark-team-marketplace:workflow-skills"
  ]
}
```

Then navigate to the target project and run `claude`.

### Modifying Skills

Skills are markdown files in `.claude/skills/{skill-name}/SKILL.md`. Each skill:
- Declares activation triggers in YAML frontmatter
- Contains full implementation prompt with step-by-step workflow
- References platform conventions from `.claude/skills/shared/references/`

### Key Design Principles

1. **Land Then Expand**: Start with minimal core, expand iteratively with separate PRDs. Prevents incorrect assumptions and enables pattern establishment.
2. **User Control**: Skills suggest, never auto-invoke other skills. Users orchestrate the workflow.
3. **Platform Awareness**: All code generation follows platform-specific conventions loaded from reference files.
4. **Bilingual**: All skills support English and French activation phrases.
5. **Codebase Exploration**: Skills explore existing patterns before generating/implementing code.
6. **Approval Loops**: commit and create-pr wait for explicit "yes" before executing git commands.
7. **Progressive Implementation**: implement-code works substory-by-substory, updating PRD progress after each.

## Important Notes

- **PRD Naming Convention**:
  - Core PRDs: `docs/prds/YYYY-MM-DD-{feature}-core.md`
  - Expansion PRDs: `docs/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`
  - This naming makes the relationship explicit and helps with file organization
- **Core PRD Size Limit**: Maximum 2-4 substories in a single phase. If generate-prd creates more, it's violating the "land then expand" principle.
- **Expansion Context Loading**: When implementing expansions, always load the completed core implementation files as context to maintain pattern consistency.
- **Testing Framework Priority**: When both RSpec and Minitest exist in Rails projects, prioritize Minitest (noted in `.claude/skills/shared/references/rails/conventions.md:8`)
- **No Auto-Invocations**: Skills never automatically invoke other skills - they suggest next steps and wait for user decision
- **Platform Detection is Cached**: The platform detection script runs once per session and results are reused
- **Token Efficiency**: The land-then-expand approach preserves tokens for implementation rather than consuming them on large upfront planning documents

## Marketplace Metadata

Located in `.claude-plugin/marketplace.json`:
- Plugin name: `workflow-skills`
- Marketplace name: `yespark-team-marketplace`
- Version: 1.0.0
- Status: Beta
