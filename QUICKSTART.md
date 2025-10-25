# Quick Start Guide

Get AI-powered product development skills for Rails, iOS Swift, and Android Kotlin in 2 minutes!

## Installation

### Step 1: Add Marketplace

Copy this to your project's `.claude/settings.json`:

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

### Step 2: Trust Folder

When Claude Code prompts you, click "Trust" to enable skills.

### Step 3: Start Talking!

**No commands to type!** Just have a natural conversation with Claude.

## The 5 Skills

Skills activate automatically based on what you say:

| What You Say | Skill That Activates | What It Does |
|--------------|---------------------|--------------|
| "Create a PRD for..." | generate-prd | Asks questions, creates structured PRD |
| "Implement this PRD" | implement-prd | Builds feature with progress tracking |
| "Commit my changes" | commit | Generates smart commit message |
| "Review my code" | code-review | Multi-dimensional quality analysis |
| "Create a PR" | create-pr | Generates comprehensive PR description |

## Complete Example Workflow

```
You: "I want to build a user authentication feature with OAuth"

Claude: [generate-prd activates]
"Let me create a PRD. I'll ask some questions to understand the requirements..."

[After Q&A]
Claude: "Created PRD at docs/prds/2024-10-25-user-auth.md with 3 phases and 6 substories"

You: "Let's start implementing it"

Claude: [implement-prd activates]
"Starting Phase 1, Substory 1: User model and database...
[Creates model, migration, tests]
✅ Substory 1.1 complete. Moving to 1.2..."

You: "Commit what we have"

Claude: [commit activates]
"Analyzing changes... Generated commit:
feat(auth): add user model and authentication schema
[Shows full message]
Proceed?"

You: "Yes. Now review the code"

Claude: [code-review activates]
"Performing review across quality, security, performance...
✅ Overall: Approved with minor suggestions
[Shows detailed report]"

You: "Create a pull request"

Claude: [create-pr activates]
"Creating PR...
✅ PR #123 created: https://github.com/yespark/app/pull/123
[Shows summary]"
```

## Key Differences from Commands

**Skills (What We Use):**
- Just talk naturally - no `/commands` needed
- Claude knows when to use each skill
- Context-aware
- Feels like pair programming

**Traditional Commands:**
- Must type `/command-name`
- Must remember exact syntax
- Less natural
- More typing

## How It Works

### Natural Language → Skill Activation

```
"Create a PRD" → generate-prd skill
"Implement docs/prds/2024-10-25-auth.md" → implement-prd skill
"Commit this code" → commit skill
"Review my changes" → code-review skill
"Make a pull request" → create-pr skill
```

Claude reads your message and automatically chooses the right skill based on what you need.

## Common Phrases

### For generate-prd:
- "Create a PRD for [feature]"
- "Help me plan [feature]"
- "Let's document requirements for [feature]"
- "I want to create product requirements"

### For implement-prd:
- "Implement the PRD"
- "Continue implementing [PRD file path]"
- "Start building [PRD file path]"
- "Let's implement this feature"

### For commit:
- "Commit these changes"
- "Create a commit"
- "Save my work"
- "Commit this"

### For code-review:
- "Review my code"
- "Check my changes"
- "Code review please"
- "Review this before I commit"

### For create-pr:
- "Create a PR"
- "Make a pull request"
- "Open a pull request"
- "Submit for review"

## Tips

### Tip 1: Be Natural
```
✅ "I want to build a booking feature - let's create a PRD"
❌ Don't need to say: "activate generate-prd skill"
```

### Tip 2: Reference Files
```
✅ "Implement docs/prds/2024-10-25-booking.md"
Claude knows to use implement-prd skill
```

### Tip 3: Chain Actions
```
You: "Commit this and then review the code"
Claude: [Does both - commit then code-review]
```

### Tip 4: Be Specific
```
✅ "Create a PRD for OAuth social login with Google and Apple"
Better than: "Create a PRD for auth"
```

## Real PRD Example

When you say "Create a PRD for parking reservations", you'll get:

```markdown
docs/prds/2024-10-25-parking-reservations.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Parking Reservation System

## Overview
[Problem statement, solution, users, success criteria]

## Requirements
[Functional, non-functional, platform-specific]

## Implementation Phases

### Phase 1: Backend API
- ⏳ [1.1] Reservation model and database
- ⏳ [1.2] Booking endpoints
- ⏳ [1.3] Availability checking

### Phase 2: Mobile UI
- ⏳ [2.1] Spot browsing (Android)
- ⏳ [2.2] Spot browsing (iOS)
...

[Full PRD with API specs, database schema, testing strategy]
```

Then "Implement this PRD" and watch it build with live status updates!

## Troubleshooting

### "Skill not activating"
1. Make sure `.claude/settings.json` is correct
2. Trust the folder in Claude Code
3. Try being more explicit: "use the generate-prd skill"
4. Restart Claude Code

### "Wrong skill activated"
- Be more specific in what you say
- Mention the skill name explicitly
- Example: "use code-review skill to check my changes"

### "Skill errors"
- Check git is installed
- Check gh CLI is installed (for PRs)
- Make sure Claude can write files
- Check Claude Code version is recent

## Next Steps

1. **Read Full Docs**: See [README.md](README.md) for detailed skill descriptions
2. **Try It**: Say "Create a PRD for [your feature]"
3. **Customize**: Edit skills in `.claude/skills/` for your team
4. **Share**: Commit to git so team gets the skills

## What Makes This Special

### Before (Traditional Workflow):
1. Manually write PRD in docs
2. Implement feature
3. Manually write commit messages
4. Manually write PR description
5. Request human code review
6. Track progress in spreadsheet

### After (With These Skills):
1. Say "Create a PRD" → Done in minutes
2. Say "Implement it" → Builds with tracking
3. Say "Commit" → Perfect message generated
4. Say "Create PR" → Comprehensive description
5. Say "Review code" → AI review first
6. PRD updates automatically with status

**Result:** 10x faster, better quality, complete traceability

## Need Help?

- **Issues**: Open an issue in the marketplace repo
- **Team Chat**: Ask in your dev channel
- **Docs**: https://docs.claude.com/claude-code/skills

---

Happy building with AI-powered skills! 🚀

**Pro Tip**: After setup, try saying "Create a PRD for a simple hello world feature" to see the full workflow in action.
