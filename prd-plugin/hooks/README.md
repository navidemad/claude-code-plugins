# PRD Plugin Hooks

Performance optimization hooks for the PRD plugin skills (plan-prd, code-prd).

## Overview

These hooks cache project state at session start and auto-inject contextual information, reducing redundant file reads and improving response times by 3-9 seconds per workflow.

## Hooks Implemented

### 1. SessionStart Hook

**Purpose**: Cache project state once at session start for reuse throughout the session.

**Script**: `session-start.sh`

**What it caches**:
- CLAUDE.md existence and tech stack
- PRD directory state (count, in-progress PRDs, core/expansion counts)
- Git state (branch, uncommitted changes, on main check)
- User preferences (learning mode)

**Environment variables set** (available to all skills):

| Variable | Description | Example |
|----------|-------------|---------|
| `PRD_CLAUDE_MD_EXISTS` | Whether CLAUDE.md exists | `"true"` or `"false"` |
| `PRD_TECH_STACK` | Tech stack from CLAUDE.md | `"Node.js, React, PostgreSQL"` |
| `PRD_COUNT` | Total active PRDs | `"3"` |
| `PRD_IN_PROGRESS` | Path to in-progress PRD | `".claude/prds/2025-10-26-hello-world-core.md"` |
| `PRD_CORE_COUNT` | Number of core PRDs | `"2"` |
| `PRD_EXPANSION_COUNT` | Number of expansion PRDs | `"1"` |
| `PRD_GIT_BRANCH` | Current git branch | `"feature/hello-world"` |
| `PRD_GIT_BASE_BRANCH` | Base branch (main/master) | `"main"` |
| `PRD_GIT_CHANGES` | Count of uncommitted changes | `"5"` |
| `PRD_ON_MAIN` | Whether on main branch | `"true"` or `"false"` |
| `PRD_LEARNING_MODE` | Learning mode enabled | `"true"` or `"false"` |
| `PRD_SESSION_START` | Session start timestamp | `"2025-10-26T14:30:22Z"` |

**Performance gain**: 500-1000ms per skill invocation (eliminates redundant file reads and git queries)

---

### 2. UserPromptSubmit Hook

**Purpose**: Auto-inject contextual information based on user intent to reduce clarification questions.

**Script**: `user-prompt-submit.sh`

**Triggers on keywords**: `plan`, `implement`, `code`, `build`, `ship`, `commit`, `pr`, `test`

**What it injects**:

#### For "implement" / "code" / "build" commands:
- In-progress PRD details (name, progress, type)
- Core PRD reference for expansions
- Warning if no PRDs exist

#### For "ship" / "commit" / "pr" commands:
- Current git branch and changes count
- Warning if on main branch with uncommitted changes
- Status indication (ready to commit, ready for PR)

#### For "plan" commands:
- CLAUDE.md validation warning if missing
- Existing PRD statistics (core, expansion counts)
- Warning if user mentions expansion but no cores exist
- Suggestions for expansions if cores available

#### For "test" commands:
- Standalone test mode detection
- Indication that code-prd supports testing without PRD

**Performance gain**: 2-5 seconds per interaction (fewer back-and-forth questions)

---

## Configuration

Hooks are configured in `hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "description": "Cache PRD project state for performance optimization"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "plan|implement|code|build|ship|commit|pr|test",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/user-prompt-submit.sh",
            "description": "Auto-inject contextual information based on user intent"
          }
        ]
      }
    ]
  }
}
```

## Usage in Skills

Skills can access cached environment variables to avoid redundant operations:

### Example: Check CLAUDE.md exists

**Without hooks** (slow):
```bash
if [[ ! -f "CLAUDE.md" ]]; then
    echo "❌ ERROR: CLAUDE.md not found"
    exit 1
fi
```

**With hooks** (fast):
```bash
if [[ "${PRD_CLAUDE_MD_EXISTS:-false}" == "false" ]]; then
    echo "❌ ERROR: CLAUDE.md not found"
    exit 1
fi
# No file read needed!
```

### Example: Get in-progress PRD

**Without hooks** (slow):
```bash
in_progress=$(grep -l "Status.*In Progress" .claude/prds/*.md 2>/dev/null | head -1)
```

**With hooks** (fast):
```bash
in_progress="${PRD_IN_PROGRESS:-}"
# Already cached from SessionStart hook
```

### Example: Check git state

**Without hooks** (slow):
```bash
current_branch=$(git rev-parse --abbrev-ref HEAD)
git_changes=$(git status --porcelain | wc -l)
```

**With hooks** (fast):
```bash
current_branch="${PRD_GIT_BRANCH:-unknown}"
git_changes="${PRD_GIT_CHANGES:-0}"
# Already cached from SessionStart hook
```

## Testing

### Manual Testing

1. **Test SessionStart hook**:
```bash
cd /path/to/your/project
# Start a new Claude Code session
# Check session output for hook confirmation:
# ✅ CLAUDE.md found
# 🌿 Git: feature/hello-world (5 changes)
# 📊 PRD Plugin Context Cached
```

2. **Test UserPromptSubmit hook**:
```bash
# Type: "implement hello world"
# Check for auto-injected context:
# 📋 Current Context: In-progress PRD detected
# PRD: 2025-10-26-hello-world-core
# Progress: 2 completed, 1 implementing, 0 not started
```

3. **Verify environment variables**:
```bash
# In a bash tool call during session:
echo "CLAUDE.md exists: ${PRD_CLAUDE_MD_EXISTS}"
echo "PRD count: ${PRD_COUNT}"
echo "Git branch: ${PRD_GIT_BRANCH}"
```

### Automated Testing

Run the hook scripts directly to test:

```bash
# Test SessionStart hook
cd /path/to/your/project
export CLAUDE_ENV_FILE=/tmp/test-env.sh
./hooks/session-start.sh
cat /tmp/test-env.sh

# Test UserPromptSubmit hook
echo '{"prompt": "implement hello world"}' | ./hooks/user-prompt-submit.sh
```

## Performance Metrics

### Before Hooks
- CLAUDE.md read: ~200ms per skill invocation
- Git queries: ~100-300ms per skill invocation
- PRD discovery: ~150-400ms per skill invocation
- User clarification questions: ~2-5 seconds per workflow

**Total**: ~3-9 seconds per workflow

### After Hooks
- All cached at SessionStart: ~500-1000ms saved per invocation
- Context auto-injected: ~2-5 seconds saved per workflow
- User sees relevant context immediately

**Total Savings**: 3-9 seconds per PRD workflow

## Troubleshooting

### Hook not executing
- Check hook script is executable: `chmod +x hooks/*.sh`
- Verify hooks.json syntax is valid JSON
- Check Claude Code settings loaded the plugin

### Environment variables not set
- Verify `CLAUDE_ENV_FILE` is being used by Claude Code
- Check hook scripts have no bash errors
- Test hooks manually (see Testing section)

### Stale cached data
- Environment variables are session-specific
- Restart Claude Code session to refresh cache
- Skills should still validate critical state (don't rely solely on cache)

## Future Enhancements (Optional)

### PreToolUse Hook
Could add auto-approval for safe operations:
- Auto-approve reading CLAUDE.md, PRD files, context files
- Block dangerous operations (deleting PRD files)
- Suggest optimizations (rg instead of grep)

**Not implemented yet** - SessionStart and UserPromptSubmit provide most value.

## Files

```
prd-plugin/hooks/
├── hooks.json                  # Hook configuration
├── session-start.sh            # SessionStart hook script
├── user-prompt-submit.sh       # UserPromptSubmit hook script
└── README.md                   # This file
```

## Contributing

When modifying hooks:
1. Test manually before committing
2. Verify no breaking changes to skills
3. Update this README with new environment variables
4. Document performance impact
5. Add examples for skill usage

## References

- [Claude Code Hooks Documentation](https://docs.claude.com/en/docs/claude-code/hooks.md)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference.md)
- [Hooks Analysis](../HOOKS-ANALYSIS.md) - Detailed analysis and decision rationale
