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

    # Validate inputs
    if [[ -z "$prd_file" ]]; then
        echo "ERROR: prd_file parameter required" >&2
        return 1
    fi
    if [[ -z "$platform" ]]; then
        echo "ERROR: platform parameter required" >&2
        return 1
    fi

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

    if [[ $? -eq 0 ]]; then
        echo "$context_file"
        return 0
    else
        echo "ERROR: Failed to create context file" >&2
        return 1
    fi
}

# Get context file path for a PRD
get_context_file() {
    local prd_file="$1"
    if [[ -z "$prd_file" ]]; then
        echo "ERROR: prd_file parameter required" >&2
        return 1
    fi
    local prd_name=$(basename "$prd_file" .md)
    echo "$CONTEXT_DIR/${prd_name}.json"
}

# Check if context exists
context_exists() {
    local prd_file="$1"
    if [[ -z "$prd_file" ]]; then
        return 1
    fi
    local context_file=$(get_context_file "$prd_file")
    [[ -f "$context_file" ]]
}

# Update context field (top-level field only)
update_context() {
    local prd_file="$1"
    local field="$2"
    local value="$3"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$field" ]]; then
        echo "ERROR: prd_file and field parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    # Use jq for proper JSON manipulation
    local temp_file="${context_file}.tmp"
    if jq --arg field "$field" --arg value "$value" \
       '.[$field] = $value | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to update context field: $field" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Add file to files_created array
add_created_file() {
    local prd_file="$1"
    local file_path="$2"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$file_path" ]]; then
        echo "ERROR: prd_file and file_path parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg file "$file_path" \
       '.files_created += [$file] | .files_created |= unique | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to add created file: $file_path" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Add file to files_modified array
add_modified_file() {
    local prd_file="$1"
    local file_path="$2"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$file_path" ]]; then
        echo "ERROR: prd_file and file_path parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg file "$file_path" \
       '.files_modified += [$file] | .files_modified |= unique | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to add modified file: $file_path" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Add architectural decision
add_decision() {
    local prd_file="$1"
    local decision="$2"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$decision" ]]; then
        echo "ERROR: prd_file and decision parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg decision "$decision" \
       '.architectural_decisions += [$decision] | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to add decision: $decision" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Set pattern
set_pattern() {
    local prd_file="$1"
    local pattern_name="$2"
    local pattern_value="$3"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$pattern_name" ]]; then
        echo "ERROR: prd_file and pattern_name parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg name "$pattern_name" --arg value "$pattern_value" \
       '.patterns[$name] = $value | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to set pattern: $pattern_name" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Set library
set_library() {
    local prd_file="$1"
    local lib_name="$2"
    local lib_value="$3"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$lib_name" ]]; then
        echo "ERROR: prd_file and lib_name parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg name "$lib_name" --arg value "$lib_value" \
       '.libraries[$name] = $value | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to set library: $lib_name" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Read entire context as JSON
read_context() {
    local prd_file="$1"
    if [[ -z "$prd_file" ]]; then
        echo "{}"
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    if [[ -f "$context_file" ]]; then
        cat "$context_file"
        return 0
    else
        echo "{}"
        return 1
    fi
}

# Get files created from core PRD (for expansion context loading)
get_core_files() {
    local core_prd_file="$1"
    if [[ -z "$core_prd_file" ]]; then
        return 1
    fi

    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.files_created[]' "$context_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Get patterns from core PRD
get_core_patterns() {
    local core_prd_file="$1"
    if [[ -z "$core_prd_file" ]]; then
        return 1
    fi

    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.patterns' "$context_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Get libraries from core PRD
get_core_libraries() {
    local core_prd_file="$1"
    if [[ -z "$core_prd_file" ]]; then
        return 1
    fi

    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.libraries' "$context_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Get architectural decisions from core PRD
get_core_decisions() {
    local core_prd_file="$1"
    if [[ -z "$core_prd_file" ]]; then
        return 1
    fi

    local context_file=$(get_context_file "$core_prd_file")

    if [[ -f "$context_file" ]]; then
        jq -r '.architectural_decisions[]' "$context_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Mark phase complete
mark_phase_complete() {
    local prd_file="$1"
    local phase_name="$2"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$phase_name" ]]; then
        echo "ERROR: prd_file and phase_name parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg phase "$phase_name" \
       '.completed_phases += [$phase] | .completed_phases |= unique | .current_phase = "" | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to mark phase complete: $phase_name" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Set current phase
set_current_phase() {
    local prd_file="$1"
    local phase_name="$2"

    # Validate inputs
    if [[ -z "$prd_file" ]] || [[ -z "$phase_name" ]]; then
        echo "ERROR: prd_file and phase_name parameters required" >&2
        return 1
    fi

    local context_file=$(get_context_file "$prd_file")

    # Check if context exists
    if [[ ! -f "$context_file" ]]; then
        echo "ERROR: Context file does not exist: $context_file" >&2
        return 1
    fi

    local temp_file="${context_file}.tmp"
    if jq --arg phase "$phase_name" \
       '.current_phase = $phase | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
       "$context_file" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$context_file"
        return 0
    else
        echo "ERROR: Failed to set current phase: $phase_name" >&2
        rm -f "$temp_file"
        return 1
    fi
}
