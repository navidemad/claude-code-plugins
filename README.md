# 🚀 Yespark Claude Plugins
![Claude Code Skill](https://img.shields.io/badge/Claude_Code-Skill-8A2BE2)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
[![Changelog](https://img.shields.io/badge/changelogs-view-blue.svg)](CHANGELOG.md)
![Status: Production](https://img.shields.io/badge/Status-Production-green)

> **Orchestrated AI workflows development for :**

> [![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-CC0000?logo=rubyonrails&logoColor=white)](CLAUDE.md)
> [![iOS Swift](https://img.shields.io/badge/iOS%20Swift-F05138?logo=swift&logoColor=white)](CLAUDE.md)
> [![Android Kotlin](https://img.shields.io/badge/Android%20Kotlin-7F52FF?logo=kotlin&logoColor=white)](CLAUDE.md)

> 🗣️ **Just talk naturally! No slash commands needed** ✨ 

## ✨ Orchestrated Skills

| | Skill | Purposes |
|-|-------|----------|
| 📋 | **plan** | Auto-loads core context for expansions |
| 💻 | **implement** | Auto-test + Auto-review + Auto-fix + Progress tracking |
| 🚀 | **ship** | Single skill for commit AND PR |

## 📦 Quick Start

### 1. Install Claude Code

```bash
bun -g install @anthropic-ai/claude-agent-sdk
```

### 2. Add to `.claude/settings.json`

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

### 3. Run `claude` in your project

## 🎯 Usage

```
 ▐▛███▜▌   Claude Code v2.0.27
▝▜█████▛▘  Sonnet 4.5 · Claude Max
  ▘▘ ▝▝    /Users/navid/code/yespark-claude-plugins
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

---

## 🎨 The Three Skills

### 📋 plan

**What:** Create PRDs with auto-context loading

**Modes:**
- **Core**: Minimal foundation (2-4 substories max)
- **Expansion**: Auto-loads core patterns/files/libraries

**Activates when:** "plan", "create PRD", "plan feature"

**Creates:**
- `docs/prds/YYYY-MM-DD-feature-core.md`
- `.claude/context/YYYY-MM-DD-feature-core.json`

---

### 💻 implement

**What:** Code + Tests + Review + Progress (all-in-one)

**Flow:**
1. Implement substories one-by-one
2. Show progress after each
3. After phase: Auto-test → Auto-review → Auto-fix
4. Ask approval at phase boundary
5. Continue or stop

**Also works standalone:** "write tests for user.rb"

**Activates when:** "implement", "build this", "write tests"

**Updates:**
- PRD status automatically
- Context file with patterns/decisions

---

### 🚀 ship

**What:** Commit + PR with approval gates

**Auto-detects mode:**
- Commit mode: Generate conventional commit
- PR mode: Generate comprehensive description

**Activates when:** "ship", "commit", "create PR"

**Waits for approval** before executing git commands

---

## 💡 Philosophy

### Land Then Expand

1. **Core PRD** → Minimal foundation (just essential fields)
2. **Implement Core** → Establish patterns
3. **Expansion PRDs** → Add features one at a time
4. **Auto-load Context** → Expansions inherit core automatically

**Why?** Large upfront PRDs lead to incorrect assumptions. Starting small and expanding works better with modern LLMs.

### Context as Memory

`.claude/context/{prd-name}.json` tracks:
- Platform (Rails/iOS/Android)
- Patterns established (service objects, API structure, etc.)
- Libraries chosen (Stripe, Devise, etc.)
- Architectural decisions
- Files created

**Expansions auto-load this context** to maintain consistency.

---

## 📚 Documentation

- **[.claude/skills/README.md](./.claude/skills/README.md)** - Individual skill implementations
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
