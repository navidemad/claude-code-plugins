#!/bin/bash
# Context Management for PRD Implementation
# Manages .claude/context/{prd-name}.json files

# Check for jq dependency
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for context management" >&2
    echo "Install with:" >&2
    echo "  macOS:         brew install jq" >&2
    echo "  Linux/WSL:     apt-get install jq  or  yum install jq" >&2
    exit 1
fi

CONTEXT_DIR=".claude/context"

# Initialize context file for a PRD
init_context() {
    local prd_file="$1"
    local platform="$2"

    # Extract PRD name from file path
    local prd_name=$(basename "$prd_file" .md)
    local context_file="$CONTEXT_DIR/${prd_name}.json"

    mkdir -p "$CONTEXT_DIR"

    # Create initial context
    cat > "$context_file" <<EOF
{
  "prd": "$prd_file",
  "platform": "$platform",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "patterns": {},
  "libraries": {},
  "files_created": [],
  "files_modified": [],
  "architectural_decisions": [],
  "testing_framework": "",
  "current_phase": "",
  "completed_phases": []
}
EOF

    echo "$context_file"
}

# Get context file for a PRD
get_context_file() {
    local prd_file="$1"
    local prd_name=$(basename "$prd_file" .md)
    echo "$CONTEXT_DIR/${prd_name}.json"
}

# Check if context exists
context_exists() {
    local prd_file="$1"
    local context_file=$(get_context_file "$prd_file")
    [[ -f "$context_file" ]]
}

# Update context field (uses jq if available, otherwise manual)
update_context() {
    local prd_file="$1"
    local field="$2"
    local value="$3"

    local context_file=$(get_context_file "$prd_file")

    # Use jq for proper JSON manipulation
    local temp_file="${context_file}.tmp"
    jq --arg field "$field" --arg value "$value" \
       '.[$field] = $value | .updated_at = now | strftime("%Y-%m-%dT%H:%M:%SZ")' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Add file to files_created array
add_created_file() {
    local prd_file="$1"
    local file_path="$2"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg file "$file_path" \
       '.files_created += [$file] | .files_created |= unique | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Add architectural decision
add_decision() {
    local prd_file="$1"
    local decision="$2"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg decision "$decision" \
       '.architectural_decisions += [$decision] | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Set pattern
set_pattern() {
    local prd_file="$1"
    local pattern_name="$2"
    local pattern_value="$3"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg name "$pattern_name" --arg value "$pattern_value" \
       '.patterns[$name] = $value | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Set library
set_library() {
    local prd_file="$1"
    local lib_name="$2"
    local lib_value="$3"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg name "$lib_name" --arg value "$lib_value" \
       '.libraries[$name] = $value | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Read entire context as JSON
read_context() {
    local prd_file="$1"
    local context_file=$(get_context_file "$prd_file")

    if [[ -f "$context_file" ]]; then
        cat "$context_file"
    else
        echo "{}"
    fi
}

# Get files created from core PRD (for expansion context loading)
get_core_files() {
    local core_prd_file="$1"
    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.files_created[]' "$context_file" 2>/dev/null
    fi
}

# Get patterns from core PRD
get_core_patterns() {
    local core_prd_file="$1"
    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.patterns' "$context_file" 2>/dev/null
    fi
}

# Mark phase complete
mark_phase_complete() {
    local prd_file="$1"
    local phase_name="$2"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg phase "$phase_name" \
       '.completed_phases += [$phase] | .completed_phases |= unique | .current_phase = "" | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}

# Set current phase
set_current_phase() {
    local prd_file="$1"
    local phase_name="$2"

    local context_file=$(get_context_file "$prd_file")

    local temp_file="${context_file}.tmp"
    jq --arg phase "$phase_name" \
       '.current_phase = $phase | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file"
    mv "$temp_file" "$context_file"
}
