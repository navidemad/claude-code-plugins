# Hooks Quick Reference

## Environment Variables (Cached at SessionStart)

### CLAUDE.md & Project
```bash
PRD_CLAUDE_MD_EXISTS    # "true" or "false"
PRD_TECH_STACK          # "Node.js, React, PostgreSQL"
```

### PRD State
```bash
PRD_COUNT               # "3" (total active PRDs)
PRD_IN_PROGRESS         # ".claude/prds/2025-10-26-hello-world-core.md"
PRD_CORE_COUNT          # "2" (core PRDs)
PRD_EXPANSION_COUNT     # "1" (expansion PRDs)
```

### Git State
```bash
PRD_GIT_BRANCH          # "feature/hello-world"
PRD_GIT_BASE_BRANCH     # "main"
PRD_GIT_CHANGES         # "5" (uncommitted changes)
PRD_ON_MAIN             # "true" or "false"
```

### Metadata
```bash
PRD_SESSION_START       # "2025-10-26T14:30:22Z"
```

## Usage Patterns

### Check CLAUDE.md exists
```bash
if [[ "${PRD_CLAUDE_MD_EXISTS:-false}" == "false" ]]; then
    echo "❌ ERROR: CLAUDE.md not found"
    exit 1
fi
```

### Get in-progress PRD
```bash
in_progress="${PRD_IN_PROGRESS:-}"
if [[ -n "$in_progress" ]]; then
    echo "Resuming: $(basename "$in_progress")"
fi
```

### Check git state
```bash
if [[ "${PRD_ON_MAIN:-false}" == "true" ]]; then
    if [[ "${PRD_GIT_CHANGES:-0}" -gt 0 ]]; then
        echo "⚠️  On main with uncommitted changes"
    fi
fi
```

### Get PRD statistics
```bash
total="${PRD_COUNT:-0}"
cores="${PRD_CORE_COUNT:-0}"
expansions="${PRD_EXPANSION_COUNT:-0}"
echo "PRDs: $total ($cores core, $expansions expansions)"
```

## Auto-Injected Context (UserPromptSubmit)

### Triggers: implement, code, build
**Injects**:
- In-progress PRD name and progress
- PRD type (core/expansion)
- Core PRD reference for expansions

### Triggers: ship, commit, pr
**Injects**:
- Current git branch
- Uncommitted changes count
- Warning if on main branch

### Triggers: plan
**Injects**:
- CLAUDE.md validation warning
- Existing PRD statistics
- Expansion suggestions

### Triggers: test
**Injects**:
- Standalone test mode detection

## Testing Commands

```bash
# Test SessionStart hook
export CLAUDE_ENV_FILE=/tmp/test-env.sh
./hooks/session-start.sh
cat /tmp/test-env.sh

# Test UserPromptSubmit hook
echo '{"prompt": "implement hello world"}' | ./hooks/user-prompt-submit.sh

# Check variables in Claude Code session
echo ${PRD_CLAUDE_MD_EXISTS}
echo ${PRD_COUNT}
echo ${PRD_GIT_BRANCH}
```

## Performance

- **SessionStart**: ~500ms (one-time per session)
- **Variable access**: <1ms (instant)
- **Context injection**: ~50-100ms
- **Total savings**: 3-9 seconds per workflow
