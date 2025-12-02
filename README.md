# 🚀 Claude Code Plugins

**AI-assisted PRD-driven development workflow for GitHub-based projects**

Language-agnostic structured workflow guidance for faster development on Mac/Unix-like systems.
- `plan-prd`  ➡️ Generate PRD and auto-loads core context for expansions
- `code-prd`  ➡️ Code + Test + Review + Fix + Progress tracking

[![Documentation](https://img.shields.io/badge/Documentation-view-blue.svg)](skills/prd/README.md)

> 🗣️ **Just talk naturally! No slash commands needed** ✨

## 🤔 How It Works

These skills provide **structured guidance** for Claude to help you follow a consistent PRD-driven workflow.

**Important to understand:**
- These are **prompt-based workflows**, not code automation
- Claude interprets and follows the workflow instructions
- **You should review** all PRD updates, code changes, and context files
- Think of it as an **AI pair programmer with process knowledge**, not a robot
- Works best for **small-to-medium features** (2-4 substories per phase)

**What the skills do:**
- ✅ Guide Claude through structured development steps
- ✅ Maintain context files to track decisions and patterns
- ✅ Suggest tests, reviews, and improvements
- ✅ Format commits and PRs consistently
- ❌ Do NOT execute autonomously without your oversight
- ❌ Do NOT guarantee perfect state management across sessions
- ❌ Do NOT replace human verification and judgment

## 📋 Requirements

**System:**
- Mac/Linux/Unix-like OS (or Windows with WSL)
- bash >= 4.0
- Git repository with GitHub remote

**Tools:**
- [jq](https://jqlang.github.io/jq/) >= 1.6 (JSON processor for context management)
- [gh CLI](https://cli.github.com/) (GitHub CLI, authenticated)
- CLAUDE.md file in project root ([learn more](skills/prd/README.md#project-conventions))

## 📦 Installation

### Install required dependencies:

```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu) - also for WSL on Windows
sudo apt-get install jq

# Linux (RedHat/CentOS)
sudo yum install jq

# Install GitHub CLI
# macOS
brew install gh

# Linux - see https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

### Authenticate GitHub CLI:

```bash
gh auth login
```

### Add the marketplace from GitHub

```bash
claude plugin marketplace add navidemad/claude-code-plugins

# To update the marketplace:
claude plugin marketplace update claude-code-plugins
```

### Install the prd-skills plugin (includes all three skills)

```bash
claude plugin install prd-skills@claude-code-plugins
```

### Start Claude Code:

```bash
claude
```

**Verification:**
```bash
# View installed plugins
/plugin list

# You should see prd-skills with three skills:
# - plan-prd
# - code-prd
```

## ✅ Best Practices & Human Verification

**These workflows guide Claude, but you maintain control and verification:**

### During Planning (`plan-prd`)
- ✓ **Review the PRD** before approving - ensure scope is correct
- ✓ **Check context file** was created in `.claude/context/`
- ✓ **Verify substories** match your mental model
- ✓ **Confirm out-of-scope items** for future expansions

### During Implementation (`code-prd`)
- ✓ **Review code after each substory** - don't wait until the end
- ✓ **Check PRD status updates** - verify substories marked complete
- ✓ **Verify context updates** - patterns and decisions tracked correctly
- ✓ **Run tests manually** if coverage concerns exist
- ✓ **Review code changes** before approving phases
- ⚠️ **Don't blindly approve** - Claude can make mistakes

### Periodic Maintenance
- ✓ **Clean up old context files** from abandoned PRDs
- ✓ **Verify context files** match current codebase after refactors
- ✓ **Update CLAUDE.md** when tech stack or patterns change
- ✓ **Check PRD files** are up-to-date with reality

### Multi-Day Work
- ⚠️ When continuing work across sessions, **verify state first**:
  - Read the PRD file - what phase/substory are we on?
  - Check context file - what patterns were established?
  - Review recent commits - what actually got done?
- ⚠️ Claude may lose context between sessions - **re-orient it** with current status

## 🎯 Usage Example

```
 ▐▛███▜▌   Claude Code
▝▜█████▛▘  Sonnet x · Claude Max
  ▘▘ ▝▝    /Users/dev/code/project
──────────────────────────────────────────────────────────────
> plan a booking system
──────────────────────────────────────────────────────────────
Claude: Creates minimal core PRD (2-4 substories)
        Initializes .claude/context/booking-core.json

──────────────────────────────────────────────────────────────
> code-prd
──────────────────────────────────────────────────────────────
Claude: Phase 1:
        ├─ Substory 1.1 → ✅ (show progress)
        ├─ Substory 1.2 → ✅ (show progress)
        ├─ Substory 1.3 → ✅ (show progress)
        └─ Substory 1.4 → ✅ (show progress)

        Auto-test (23 tests, 94% coverage) ✅
        Auto-review (found 2 issues) 🔍
        Auto-fix issues 🔧
        Re-review (clean!) ✅

        "Phase 1 complete. Approve? [yes/no]"

──────────────────────────────────────────────────────────────
> yes
──────────────────────────────────────────────────────────────

# Next day - Expansion
──────────────────────────────────────────────────────────────
> plan payment details expansion
──────────────────────────────────────────────────────────────
Claude: Auto-loads booking-core context ✅
        Reads booking.rb, bookings_controller.rb ✅
        Creates expansion PRD following core patterns ✅

──────────────────────────────────────────────────────────────
> code-prd
──────────────────────────────────────────────────────────────
Claude: Extends core using same libraries/patterns ✅
        Auto-test + Auto-review + Auto-fix ✅
        Asks approval ✅
```

## CONTRIBUTING

### To install

```bash
claude plugin marketplace add ./
claude plugin install prd-skills@claude-code-plugins
```

### After a change

```bash
claude plugin uninstall prd-skills@claude-code-plugins
claude plugin install prd-skills@claude-code-plugins
```