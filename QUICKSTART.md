# Quick Start - 2 Minutes to AI-Powered Development

Get started with Yespark's Claude Code skills in 2 minutes.

## 1. Install

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

## 2. Trust Folder

When Claude Code prompts you, click **Trust**.

## 3. Start Using

Just talk naturally! No slash commands needed.

```
You: "Create a PRD for user authentication"
Claude: [Asks questions, generates PRD]

You: "Implement the PRD"
Claude: [Writes code substory by substory]

You: "Review my code"
Claude: [Performs quality analysis]

You: "Commit these changes"
Claude: [Generates commit message, waits for approval]

You: "Create a PR"
Claude: [Generates PR description, waits for approval]
```

## Available Skills

| Say This | Skill Activates | Result |
|----------|----------------|--------|
| "create a PRD" | generate-prd | Structured requirements doc |
| "implement PRD" | implement-code | Code generation substory-by-substory |
| "write tests" | implement-tests | Comprehensive test suites |
| "show progress" | track-prd-progress | PRD implementation metrics |
| "commit this" | commit | Well-formatted commit message |
| "create a PR" | create-pr | Comprehensive PR description |
| "review my code" | code-review | Multi-dimensional analysis |

## Key Philosophy

**You control the workflow.** Each skill:
- ✅ Does one thing well
- ✅ Suggests next steps
- ✅ Waits for your approval
- ❌ Never auto-invokes other skills

## Troubleshooting

**Skills not activating?**
1. Check `.claude/settings.json` is correct
2. Trust the folder in Claude Code
3. Say "use the [skill-name] skill" explicitly
4. Restart Claude Code

**Need help?**
- **Full docs**: See [README.md](README.md)
- **Issues**: Open an issue in this repo
- **Claude Code docs**: https://docs.claude.com/claude-code/skills

---

**Pro Tip**: After setup, try: *"Create a PRD for a simple hello world feature"* to see the full workflow.
