#!/bin/bash
# Shared Git Analysis Tools
# Used by commit and create-pr (now in 'ship' skill)

# Analyze git changes and return structured data
analyze_git_changes() {
    local scope="${1:-.}"

    # Get file count
    local files_changed=$(git diff "$scope" --name-only | wc -l | tr -d ' ')

    # Get line stats
    local stats=$(git diff "$scope" --shortstat)

    # Get changed files list
    local changed_files=$(git diff "$scope" --name-only)

    # Parse insertions/deletions
    local insertions=$(echo "$stats" | grep -o '[0-9]* insertion' | grep -o '[0-9]*' || echo "0")
    local deletions=$(echo "$stats" | grep -o '[0-9]* deletion' | grep -o '[0-9]*' || echo "0")

    # Output as structured data (can be parsed)
    cat <<EOF
FILES_CHANGED=$files_changed
INSERTIONS=$insertions
DELETIONS=$deletions
CHANGED_FILES<<FILELIST
$changed_files
FILELIST
EOF
}

# Detect scope from file paths using simple heuristics
# Returns the primary scope for conventional commit messages
# This is intentionally simple and generic to work across any project type
detect_scope_from_files() {
    local files="$1"

    # Extract common directory patterns from file paths
    # Get the most common top-level directory (after src/ or app/)
    local scope=$(echo "$files" | \
        sed -E 's#^(src/|app/|lib/)?([^/]+)/.*#\2#' | \
        sort | uniq -c | sort -rn | head -1 | awk '{print $2}')

    # Fallback to generic scopes if nothing found
    if [[ -z "$scope" ]]; then
        echo ""
    else
        echo "$scope"
    fi
}

# Check for uncommitted changes
has_uncommitted_changes() {
    if [[ -n $(git status --porcelain) ]]; then
        return 0  # Has changes
    else
        return 1  # Clean
    fi
}

# Get current branch name
get_current_branch() {
    git branch --show-current
}

# Get base branch (main or master)
get_base_branch() {
    if git show-ref --verify --quiet refs/heads/main; then
        echo "main"
    elif git show-ref --verify --quiet refs/heads/master; then
        echo "master"
    else
        echo "main"  # Default
    fi
}

# Get commits ahead of base branch
get_commits_ahead() {
    local base_branch=$(get_base_branch)
    local current_branch=$(get_current_branch)

    if [[ "$current_branch" == "$base_branch" ]]; then
        echo "0"
    else
        git rev-list --count "$base_branch..$current_branch" 2>/dev/null || echo "0"
    fi
}

# Format git message with heredoc (for commit/PR)
format_git_message() {
    local message="$1"

    cat <<'EOF'
git commit -m "$(cat <<'COMMITMSG'
EOF
    echo "$message"
    cat <<'EOF'
COMMITMSG
)"
EOF
}

# Find related PRD files
find_related_prd() {
    local changed_files="$1"

    # Check recent PRDs
    if [[ -d "docs/prds" ]]; then
        # Find most recent PRD (last modified) - use printf for reliable sorting
        find docs/prds -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || \
        # Fallback for systems without -printf (macOS)
        find docs/prds -name "*.md" -type f -print0 | xargs -0 stat -f '%m %N' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || \
        # Final fallback
        find docs/prds -name "*.md" -type f | head -1
    fi
}

# Extract PRD reference from commit messages
get_prd_from_commits() {
    local base_branch=$(get_base_branch)
    local current_branch=$(get_current_branch)

    git log "$base_branch..$current_branch" --oneline | grep -o "PRD-[0-9-]*" | head -1 || echo ""
}
