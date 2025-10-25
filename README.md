# 🚀 Yespark Claude Plugins

**Language-agnostic PRD-driven development workflow for GitHub-based projects**

Orchestrated AI skills for faster, structured development on Mac/Unix-like systems.
- `plan`      ➡️ Generate PRD and auto-loads core context for expansions
- `implement` ➡️ Auto-code + Auto-test + Auto-review + Auto-fix + Progress tracking
- `ship`      ➡️ Single skill for commit and creating pull requests

[![Documentation](https://img.shields.io/badge/Documentation-view-blue.svg)](skills/README.md)

> 🗣️ **Just talk naturally! No slash commands needed** ✨

## 📋 Requirements

**System:**
- Mac/Linux/Unix-like OS (or Windows with WSL)
- bash >= 4.0
- Git repository with GitHub remote

**Tools:**
- [jq](https://jqlang.github.io/jq/) >= 1.6 (JSON processor for context management)
- [gh CLI](https://cli.github.com/) (GitHub CLI, authenticated)
- CLAUDE.md file in project root ([learn more](skills/README.md#project-conventions))

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

### Claude Code Settings `.claude/settings.json`

```json
{
  "extraKnownMarketplaces": {
    "yespark-agent-skills": {
      "source": {
        "source": "github",
        "repo": "yespark/yespark-claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "yespark-agent-skills:plan": true,
    "yespark-agent-skills:implement": true,
    "yespark-agent-skills:ship": true
  }
}
```

## 🎯 Usage Example

```
 ▐▛███▜▌   Claude Code
▝▜█████▛▘  Sonnet 4.5 · Claude Max
  ▘▘ ▝▝    /Users/dev/code/yespark-project
──────────────────────────────────────────────────────────────
> plan a booking system
──────────────────────────────────────────────────────────────
Claude: Creates minimal core PRD (2-4 substories)
        Initializes .claude/context/booking-core.json

──────────────────────────────────────────────────────────────
> implement
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

──────────────────────────────────────────────────────────────
> ship
──────────────────────────────────────────────────────────────
Claude: Generated commit message
        "Approve? [yes/no]"

──────────────────────────────────────────────────────────────
> yes
──────────────────────────────────────────────────────────────

──────────────────────────────────────────────────────────────
> ship
──────────────────────────────────────────────────────────────
Claude: Generated PR description
        "Create PR? [yes/no]"

──────────────────────────────────────────────────────────────
> yes
──────────────────────────────────────────────────────────────
Claude: PR #123 created ✅

# Next day - Expansion
──────────────────────────────────────────────────────────────
> plan payment details expansion
──────────────────────────────────────────────────────────────
Claude: Auto-loads booking-core context ✅
        Reads booking.rb, bookings_controller.rb ✅
        Creates expansion PRD following core patterns ✅

──────────────────────────────────────────────────────────────
> implement
──────────────────────────────────────────────────────────────
Claude: Extends core using same libraries/patterns ✅
        Auto-test + Auto-review + Auto-fix ✅
        Asks approval ✅
```
