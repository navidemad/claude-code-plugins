#!/usr/bin/env bash
# SessionStart Hook for PRD Plugin
# Purpose: Cache project state at session start for performance optimization
# Reduces redundant file reads and git queries throughout the session

# Note: Don't use set -e because we want to continue even if some commands fail
set -uo pipefail

# Initialize output
output=""
env_file="${CLAUDE_ENV_FILE:-}"

# Function to append to environment file
append_env() {
    local key="$1"
    local value="$2"
    if [[ -n "$env_file" ]]; then
        echo "export ${key}=\"${value}\"" >> "$env_file"
    fi
}

# 1. Check CLAUDE.md existence and cache result
if [[ -f "CLAUDE.md" ]]; then
    output+="✅ CLAUDE.md found"$'\n'
    append_env "PRD_CLAUDE_MD_EXISTS" "true"

    # Cache tech stack info from CLAUDE.md
    if grep -qi "tech stack" CLAUDE.md; then
        tech_stack=$(grep -i "tech stack" CLAUDE.md | head -1 | sed 's/.*://' | xargs)
        append_env "PRD_TECH_STACK" "${tech_stack}"
    fi
else
    output+="⚠️  No CLAUDE.md found (skills will prompt for /init)"$'\n'
    append_env "PRD_CLAUDE_MD_EXISTS" "false"
fi

# 2. Cache PRD directory state
if [[ -d ".claude/prds" ]]; then
    # Count active PRDs (not in archive)
    prd_count=$(find .claude/prds -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | xargs)
    append_env "PRD_COUNT" "${prd_count}"

    # Find in-progress PRD
    in_progress_prd=$(grep -l "Status.*In Progress" .claude/prds/*.md 2>/dev/null | head -1 || echo "")
    if [[ -n "$in_progress_prd" ]]; then
        append_env "PRD_IN_PROGRESS" "${in_progress_prd}"
        prd_basename=$(basename "$in_progress_prd")
        output+="📋 In-progress PRD: ${prd_basename}"$'\n'
    else
        append_env "PRD_IN_PROGRESS" ""
    fi

    # Count core vs expansion PRDs
    core_count=$(grep -l "Type.*Core" .claude/prds/*.md 2>/dev/null | wc -l | xargs)
    expansion_count=$(grep -l "Type.*Expansion" .claude/prds/*.md 2>/dev/null | wc -l | xargs)
    append_env "PRD_CORE_COUNT" "${core_count}"
    append_env "PRD_EXPANSION_COUNT" "${expansion_count}"
else
    output+="📁 PRD directory will be created on first use"$'\n'
    append_env "PRD_COUNT" "0"
    append_env "PRD_IN_PROGRESS" ""
    append_env "PRD_CORE_COUNT" "0"
    append_env "PRD_EXPANSION_COUNT" "0"
fi

# 3. Cache git state
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Current branch
    git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    append_env "PRD_GIT_BRANCH" "${git_branch}"

    # Base branch (main/master)
    base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    append_env "PRD_GIT_BASE_BRANCH" "${base_branch}"

    # Uncommitted changes count
    changes_count=$(git status --porcelain 2>/dev/null | wc -l | xargs)
    append_env "PRD_GIT_CHANGES" "${changes_count}"

    # Check if on main branch
    if [[ "$git_branch" == "main" ]] || [[ "$git_branch" == "master" ]] || [[ "$git_branch" == "$base_branch" ]]; then
        append_env "PRD_ON_MAIN" "true"
    else
        append_env "PRD_ON_MAIN" "false"
    fi

    output+="🌿 Git: ${git_branch} (${changes_count} changes)"$'\n'
else
    output+="⚠️  Not a git repository"$'\n'
    append_env "PRD_GIT_BRANCH" "none"
    append_env "PRD_GIT_BASE_BRANCH" "main"
    append_env "PRD_GIT_CHANGES" "0"
    append_env "PRD_ON_MAIN" "false"
fi

# 4. Cache timestamp
append_env "PRD_SESSION_START" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Output summary
output+=""$'\n'"📊 PRD Plugin Context Cached"
echo -e "$output"

exit 0
