# 🚀 Yespark Claude Plugins
![Claude Code Skills](https://img.shields.io/badge/Claude_Code-Skills-D87757)
[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-CC0000?logo=rubyonrails&logoColor=white)](CLAUDE.md)
[![iOS Swift](https://img.shields.io/badge/iOS%20Swift-F05138?logo=swift&logoColor=white)](CLAUDE.md)
[![Android Kotlin](https://img.shields.io/badge/Android%20Kotlin-7F52FF?logo=kotlin&logoColor=white)](CLAUDE.md)

> 🗣️ **Just talk naturally! No slash commands needed** ✨

**Orchestrated AI skills for faster development**
- `plan`      ➡️ Generate PRD and auto-loads core context for expansions |
- `implement` ➡️ Auto-code + Auto-test + Auto-review + Auto-fix + Progress tracking |
- `ship`      ➡️ Single skill for commit and creating pull requests |

[![Documentation](https://img.shields.io/badge/Documentation-view-blue.svg)](.claude/skills/README.md)

## 📦 Installation

### Prerequisites

**Required dependency:**
```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu) - also for WSL on Windows
apt-get install jq

# Linux (RedHat/CentOS)
yum install jq
```

### Claude Code Settings `.claude/settings.json`

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
