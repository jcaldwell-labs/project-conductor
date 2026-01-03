#!/bin/bash
# test-deep-review.sh - Test deep-review.sh configuration parsing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/projects.yaml"

# Source the get_project_field function
get_project_field() {
    local project="$1"
    local field="$2"
    sed -n "/^  $project:$/,/^  [a-z]/p" "$CONFIG_FILE" | grep "^    $field:" | head -1 | sed 's/.*: *//' | tr -d '"'
}

echo "Testing deep-review.sh configuration parsing..."
echo ""

# Test all projects from config
projects=$(grep -E '^  [a-z-]+:' "$CONFIG_FILE" | sed 's/:.*//; s/^  //')

for project in $projects; do
    path=$(get_project_field "$project" "path")
    repo=$(get_project_field "$project" "repo")

    if [ -n "$path" ] && [ -n "$repo" ]; then
        echo "✓ $project"
        echo "  Path: $path"
        echo "  Repo: $repo"
    else
        echo "✗ $project - Missing path or repo"
        echo "  Path: '$path'"
        echo "  Repo: '$repo'"
    fi
    echo ""
done

echo "Test complete!"
