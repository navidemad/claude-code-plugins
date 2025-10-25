# Changelog

All notable changes to Yespark Claude Plugins.

## [Unreleased] - 2025-10-26

### Changed - Honest Positioning & Expectations
- **Updated positioning**: Now "AI-assisted PRD-driven development workflow for GitHub-based projects"
- Changed from "automated workflow" to "AI-assisted workflow guidance"
- Removed claims of full "project-agnostic" support - now accurately scoped to language-agnostic
- Clarified that these are **prompt-based workflows**, not code automation
- Updated all documentation to reflect realistic expectations

### Added - "How It Works" Section
- **Clear explanation** that skills provide structured guidance, not autonomous execution
- Documented that Claude interprets and follows workflow instructions
- Emphasized need for human verification at each step
- Set realistic expectations: "AI pair programmer with process knowledge, not a robot"

### Added - Best Practices & Verification Guidelines
- **Comprehensive verification checklist** for each workflow stage
- Planning verification: Review PRDs, check context files, verify substories
- Implementation verification: Review code per substory, check PRD updates, verify context
- Shipping verification: Review commits/PRs before approval
- Periodic maintenance: Clean up stale context, update CLAUDE.md
- Multi-day work guidance: How to re-orient Claude across sessions

### Added - Limitations Documentation
- **Documented when system works best**: Small features (2-4 substories), short sessions
- **Documented known limitations**: Multi-day work, complex features, session discontinuity
- Explicit warning not to blindly approve - Claude can make mistakes
- Clarified no guarantee of perfect state management across sessions

### Added - Requirements Documentation
- **System Requirements**:
  - Mac/Linux/Unix-like OS (or Windows with WSL)
  - bash >= 4.0
  - Git repository with GitHub remote
- **Tool Requirements**:
  - jq >= 1.6 (JSON processor)
  - gh CLI (GitHub CLI, authenticated)
  - CLAUDE.md file in project root
- Installation instructions for all required tools
- GitHub CLI authentication steps

### Added - CLAUDE.md Validation
- **All skills now validate CLAUDE.md exists** before proceeding
- Clear error message with instructions to run `/init` if missing
- Prevents confusing failures downstream
- Standardized error format across all skills

### Added - Graceful Test Handling
- **Testing can now be skipped** if CLAUDE.md indicates no tests
- Detects "no tests", "testing: none", "tests: n/a" in CLAUDE.md
- Falls back gracefully if test command fails or not found
- Clear warnings when tests are skipped
- Code review continues even without test results
- Approval summaries show test status (passed/skipped)

### Fixed - Path Configuration
- **Corrected marketplace.json paths**: Changed from `./skills/` to `../skills/`
- Matches actual directory structure where skills are in repo root
- Plugin installation will now work correctly

### Improved - True Language-Agnostic Implementation
- **Removed all hard-coded framework examples** from skill prompts
- No more Rails/Node.js/Stripe assumptions in documentation
- Generic placeholders only - Claude must read CLAUDE.md for specifics
- Removed testing framework detection logic - Claude analyzes from CLAUDE.md
- Skills now genuinely adapt to any language/framework

### Added - Task-Based PRD Support
- **New PRD type**: Task-based changes (option 3)
- For infrastructure, migrations, optimizations, refactors, security patches
- Uses checklist format instead of phases/substories
- Includes rollback plan section
- File pattern: `docs/prds/YYYY-MM-DD-{task-name}-task.md`
- Implement skill handles task PRDs with step-by-step execution

### Documentation Updates
- Updated README.md with accurate positioning and expectations
- Updated skills/README.md with prompt-based workflow explanation
- Added comprehensive requirements section
- Improved installation instructions with all dependencies
- Clarified that workflow is PRD-driven and prompt-based
- Added verification best practices throughout

---

## Summary of Changes

### Philosophy Shift
**Before**: "Automated intelligent workflow"
**After**: "AI-assisted workflow guidance with human verification"

### Positioning Shift
**Before**: "Project-agnostic" (overstated)
**After**: "Language-agnostic PRD-driven workflow" (accurate)

### Expectations Shift
**Before**: Implied autonomous execution
**After**: Clear that it's prompt-based guidance requiring human oversight

### Key Improvements
- ✅ Honest about capabilities and limitations
- ✅ Clear verification requirements
- ✅ Graceful error handling
- ✅ Proper validation
- ✅ Realistic use case guidance

This version sets realistic expectations while highlighting the genuine value: structured, language-agnostic workflow guidance for PRD-driven development teams.
