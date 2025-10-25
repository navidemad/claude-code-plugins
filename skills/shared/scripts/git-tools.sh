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
# Returns the primary scope for conventional commit messages
detect_scope_from_files() {
    local platform="$1"
    local files="$2"

    case "$platform" in
        rails)
            # Common Rails structure: app/{models,controllers,services,jobs,mailers,interactors,queries,presenters,serializers}
            if echo "$files" | grep -q "app/models/"; then
                echo "models"
            elif echo "$files" | grep -q "app/controllers/"; then
                echo "controllers"
            elif echo "$files" | grep -q "app/services/"; then
                echo "services"
            elif echo "$files" | grep -q "app/jobs/"; then
                echo "jobs"
            elif echo "$files" | grep -q "app/mailers/"; then
                echo "mailers"
            elif echo "$files" | grep -q "app/interactors/"; then
                echo "interactors"
            elif echo "$files" | grep -q "app/components/"; then
                echo "components"
            elif echo "$files" | grep -q "app/queries/"; then
                echo "queries"
            elif echo "$files" | grep -q "app/presenters/"; then
                echo "presenters"
            elif echo "$files" | grep -q "app/serializers/"; then
                echo "serializers"
            elif echo "$files" | grep -q "app/policies/"; then
                echo "policies"
            elif echo "$files" | grep -q "db/migrate/"; then
                echo "db"
            elif echo "$files" | grep -q "spec/\|test/"; then
                echo "test"
            elif echo "$files" | grep -q "config/"; then
                echo "config"
            elif echo "$files" | grep -q "lib/"; then
                echo "lib"
            else
                echo "app"
            fi
            ;;
        ios-swift)
            # Common iOS structure: organized by feature modules
            if echo "$files" | grep -q "Tests\|Test"; then
                echo "tests"
            elif echo "$files" | grep -q "Network/"; then
                echo "network"
            elif echo "$files" | grep -q "Storage/"; then
                echo "storage"
            elif echo "$files" | grep -q "Manager/"; then
                echo "manager"
            elif echo "$files" | grep -q "Coordinator/"; then
                echo "coordinator"
            elif echo "$files" | grep -q "Router/"; then
                echo "router"
            elif echo "$files" | grep -q "Payment/"; then
                echo "payment"
            elif echo "$files" | grep -q "Checkout/"; then
                echo "checkout"
            elif echo "$files" | grep -q "Tracking/"; then
                echo "tracking"
            elif echo "$files" | grep -q "DependencyInjection/"; then
                echo "di"
            elif echo "$files" | grep -q "Configuration/"; then
                echo "config"
            elif echo "$files" | grep -q "\.xcdatamodel"; then
                echo "data"
            elif echo "$files" | grep -q "Podfile\|\.xcodeproj"; then
                echo "project"
            else
                echo "ios"
            fi
            ;;
        android-kotlin)
            # Common Android structure: feature-based or layered architecture
            if echo "$files" | grep -q "src/test/\|src/androidTest/"; then
                echo "tests"
            elif echo "$files" | grep -q "presentation/\|ui/"; then
                echo "ui"
            elif echo "$files" | grep -q "data/"; then
                echo "data"
            elif echo "$files" | grep -q "domain/"; then
                echo "domain"
            elif echo "$files" | grep -q "network/\|api/"; then
                echo "network"
            elif echo "$files" | grep -q "di/\|injection/"; then
                echo "di"
            elif echo "$files" | grep -q "build.gradle\|gradle"; then
                echo "build"
            elif echo "$files" | grep -q "res/"; then
                echo "resources"
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
