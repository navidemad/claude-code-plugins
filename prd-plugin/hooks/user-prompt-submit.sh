#!/usr/bin/env bash
# UserPromptSubmit Hook for PRD Plugin
# Purpose: Auto-inject contextual information based on user intent
# Reduces redundant questions and speeds up skill activation

# Note: Don't use set -e because we want to continue even if some commands fail
set -uo pipefail

# Read hook input from stdin
hook_input=$(cat)
user_prompt=$(echo "$hook_input" | jq -r '.prompt' 2>/dev/null || echo "")

# Initialize additional context
additional_context=""

# Helper function to add context
add_context() {
    if [[ -n "$additional_context" ]]; then
        additional_context+=$'\n\n'
    fi
    additional_context+="$1"
}

# 1. IMPLEMENT/CODE/BUILD commands - Inject PRD status
if echo "$user_prompt" | grep -qiE '\b(implement|code|build|develop|start implementation)\b'; then
    # Check for in-progress PRD
    if [[ -n "${PRD_IN_PROGRESS:-}" ]] && [[ -f "${PRD_IN_PROGRESS}" ]]; then
        prd_name=$(basename "$PRD_IN_PROGRESS" .md)
        add_context "📋 Current Context: In-progress PRD detected"
        add_context "PRD: ${prd_name}"

        # Extract progress
        completed=$(grep -c "✅" "$PRD_IN_PROGRESS" 2>/dev/null || echo 0)
        implementing=$(grep -c "🔄" "$PRD_IN_PROGRESS" 2>/dev/null || echo 0)
        not_started=$(grep -c "⏳" "$PRD_IN_PROGRESS" 2>/dev/null || echo 0)

        add_context "Progress: ${completed} completed, ${implementing} implementing, ${not_started} not started"

        # Get PRD type
        prd_type=$(grep "Type:" "$PRD_IN_PROGRESS" | head -1 | sed 's/.*Type://' | sed 's/\*//g' | xargs || echo "Unknown")
        add_context "Type: ${prd_type}"

        # If expansion, check for core PRD reference
        if echo "$prd_type" | grep -qi "expansion"; then
            core_ref=$(grep "Builds On:" "$PRD_IN_PROGRESS" | sed 's/.*Builds On://' | sed 's/\[//' | sed 's/\]//' | xargs || echo "")
            if [[ -n "$core_ref" ]]; then
                add_context "Builds on: ${core_ref}"
            fi
        fi
    elif [[ "${PRD_COUNT:-0}" -gt 0 ]]; then
        add_context "📋 Multiple PRDs available (${PRD_COUNT} total)"
        add_context "User should specify which PRD to implement"
    else
        add_context "⚠️  No PRDs found - user may need to create one first with 'plan' skill"
    fi
fi

# 2. SHIP/COMMIT/PR commands - Inject git status
if echo "$user_prompt" | grep -qiE '\b(ship|commit|pr|pull request|push|merge)\b'; then
    git_branch="${PRD_GIT_BRANCH:-unknown}"
    git_changes="${PRD_GIT_CHANGES:-0}"
    on_main="${PRD_ON_MAIN:-false}"

    add_context "🌿 Git Context:"
    add_context "Branch: ${git_branch}"
    add_context "Uncommitted changes: ${git_changes}"

    if [[ "$on_main" == "true" ]]; then
        if [[ "$git_changes" -gt 0 ]]; then
            add_context "⚠️  On main branch with uncommitted changes - recommend creating feature branch first"
        else
            add_context "✅ On main branch, all changes committed"
        fi
    else
        if [[ "$git_changes" -gt 0 ]]; then
            add_context "Status: Feature branch with uncommitted changes - ready to commit"
        else
            add_context "Status: Feature branch, all committed - ready for PR"
        fi
    fi
fi

# 3. PLAN commands - Inject PRD context and validation
if echo "$user_prompt" | grep -qiE '^\s*(plan|write.*prd|create.*prd)\b'; then
    # Check CLAUDE.md
    if [[ "${PRD_CLAUDE_MD_EXISTS:-false}" == "false" ]]; then
        add_context "⚠️  CRITICAL: CLAUDE.md not found in project root"
        add_context "The plan-prd skill requires CLAUDE.md - user should run '/init' first"
    else
        add_context "✅ CLAUDE.md found"

        # Add tech stack if available
        if [[ -n "${PRD_TECH_STACK:-}" ]]; then
            add_context "Tech stack: ${PRD_TECH_STACK}"
        fi
    fi

    # PRD statistics
    prd_count="${PRD_COUNT:-0}"
    core_count="${PRD_CORE_COUNT:-0}"
    expansion_count="${PRD_EXPANSION_COUNT:-0}"

    if [[ "$prd_count" -eq 0 ]]; then
        add_context "📋 No existing PRDs - likely creating first core PRD"
    else
        add_context "📋 Existing PRDs: ${prd_count} total (${core_count} core, ${expansion_count} expansions)"

        # If user mentions expansion but no cores exist
        if echo "$user_prompt" | grep -qiE '\bexpan(d|sion)\b' && [[ "$core_count" -eq 0 ]]; then
            add_context "⚠️  User mentioned expansion but no core PRDs exist - expansion requires completed core"
        fi

        # Suggest expansions if cores exist
        if [[ "$core_count" -gt 0 ]] && ! echo "$user_prompt" | grep -qiE '\bcore\b'; then
            add_context "💡 ${core_count} core PRD(s) available for expansion"
        fi
    fi
fi

# 4. TEST commands - Inject testing context
if echo "$user_prompt" | grep -qiE '\b(test|tests|testing|write tests)\b'; then
    # Check if user mentioned specific file
    if echo "$user_prompt" | grep -qE '\.(ts|js|py|rb|go|java)'; then
        add_context "💡 Standalone test mode detected (write tests for specific file)"
        add_context "code-prd skill supports standalone testing without PRD"
    fi
fi

# 5. Learning Mode context
learning_mode="${PRD_LEARNING_MODE:-true}"
if [[ "$learning_mode" == "true" ]]; then
    # Only add on first interaction or implement commands
    if echo "$user_prompt" | grep -qiE '\b(implement|code|build)\b'; then
        add_context "🎓 Learning Mode: ON (will explain approach before implementation)"
    fi
fi

# Return JSON response
if [[ -n "$additional_context" ]]; then
    # Escape for JSON
    escaped_context=$(echo "$additional_context" | jq -Rs .)
    echo "{\"continue\": true, \"additionalContext\": ${escaped_context}}"
else
    echo "{\"continue\": true}"
fi

exit 0
