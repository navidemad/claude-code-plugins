# Changelog

All notable changes to Yespark Claude Plugins will be documented in this file.

## [5.0.0] - 2025-10-25 - **Developer Control Release**

- **<¯ Philosophy shift**: Tools, not automation - you control the workflow
- **7 focused skills** - each does one thing well, suggests next steps
  - `implement-prd` ’ `implement-code`, `implement-tests`, `track-prd-progress`
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

## [4.0.0] - 2025-10-25 - **Automation Release** (deprecated)

- Fully automated workflow with auto-review ’ auto-commit ’ auto-PR
- Removed in favor of developer-controlled approach

## [3.1.0] - 2025-10-25

- **Platform-aware skills** - supports Rails, iOS Swift, and Android Kotlin
- Automatic platform detection from project files (Gemfile, .xcodeproj, gradle.properties)
- Skills adapt terminology and patterns to detected platform
- Platform-specific reference files with conventions and best practices
- Platform-aware PRD templates and code generation
- Platform-specific code review checks (N+1 for Rails, retain cycles for iOS, Context leaks for Android)

## [3.0.0] - 2025-10-25

- Complete redesign using Skills (model-invoked, not user-invoked)
- 5 core skills: generate-prd, implement-prd, commit, create-pr, code-review
- Natural language activation - no slash commands needed
- Followed Anthropic's official skill best practices
- Enhanced PRD format with real-time status tracking
- Comprehensive code review with platform-specific checks
