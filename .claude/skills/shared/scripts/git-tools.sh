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

# Detect scope from file paths based on platform
detect_scope_from_files() {
    local platform="$1"
    local files="$2"

    case "$platform" in
        rails)
            if echo "$files" | grep -q "app/models/"; then
                echo "models"
            elif echo "$files" | grep -q "app/controllers/"; then
                echo "controllers"
            elif echo "$files" | grep -q "app/services/"; then
                echo "services"
            elif echo "$files" | grep -q "db/migrate/"; then
                echo "db"
            elif echo "$files" | grep -q "spec/\|test/"; then
                echo "test"
            else
                echo "app"
            fi
            ;;
        ios-swift)
            if echo "$files" | grep -q "ViewModel"; then
                echo "viewmodel"
            elif echo "$files" | grep -q "View\|ViewController"; then
                echo "ui"
            elif echo "$files" | grep -q "Model"; then
                echo "models"
            elif echo "$files" | grep -q "Service"; then
                echo "services"
            elif echo "$files" | grep -q "Tests"; then
                echo "tests"
            else
                echo "ios"
            fi
            ;;
        android-kotlin)
            if echo "$files" | grep -q "presentation/"; then
                echo "ui"
            elif echo "$files" | grep -q "data/"; then
                echo "data"
            elif echo "$files" | grep -q "domain/"; then
                echo "domain"
            elif echo "$files" | grep -q "test/"; then
                echo "tests"
            else
                echo "android"
            fi
            ;;
        *)
            echo "app"
            ;;
    esac
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
        # Find most recent PRD (last modified)
        find docs/prds -name "*.md" -type f -exec ls -t {} + | head -1
    fi
}

# Extract PRD reference from commit messages
get_prd_from_commits() {
    local base_branch=$(get_base_branch)
    local current_branch=$(get_current_branch)

    git log "$base_branch..$current_branch" --oneline | grep -o "PRD-[0-9-]*" | head -1 || echo ""
}
