#!/bin/bash
# advance-project.sh - Launch Claude Code to advance a project
# Usage: ./advance-project.sh <project-name> [--push]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/projects.yaml"
PROMPTS_DIR="$PROJECT_ROOT/prompts"
STATE_DIR="$PROJECT_ROOT/state"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <project-name|--stale|--all> [--push] [--dry-run]"
    echo ""
    echo "Options:"
    echo "  <project-name>  Advance a specific project"
    echo "  --stale         Advance the stalest project (health < 50)"
    echo "  --all           Advance all projects with health < 80"
    echo "  --push          Push commits after advancement"
    echo "  --dry-run       Show what would be done without executing"
    echo ""
    echo "Available projects:"
    grep -E '^  [a-z]' "$CONFIG_FILE" | sed 's/://g' | awk '{print "  " $1}'
    exit 1
}

get_project_field() {
    local project="$1"
    local field="$2"
    awk "/^  $project:/,/^  [a-z]/{if(/$field:/) print}" "$CONFIG_FILE" | head -1 | sed 's/.*: *//' | tr -d '"'
}

get_stalest_project() {
    if [ ! -f "$STATE_DIR/health.json" ]; then
        echo -e "${YELLOW}No health data. Running health check first...${NC}"
        "$SCRIPT_DIR/health-check.sh" > /dev/null
    fi
    
    # Find project with lowest health score
    jq -r '.projects | to_entries | sort_by(.value.health) | .[0].key' "$STATE_DIR/health.json"
}

get_unhealthy_projects() {
    if [ ! -f "$STATE_DIR/health.json" ]; then
        "$SCRIPT_DIR/health-check.sh" > /dev/null
    fi
    jq -r '.projects | to_entries | map(select(.value.health < 80)) | .[].key' "$STATE_DIR/health.json"
}

advance_project() {
    local project="$1"
    local push="$2"
    local dry_run="$3"
    
    local path=$(get_project_field "$project" "path")
    local repo=$(get_project_field "$project" "repo")
    local roadmap=$(get_project_field "$project" "roadmap")
    
    # Expand ~ in path
    path="${path/#\~\/$HOME/}"
    
    # Check for custom prompt
    local prompt_file="$PROMPTS_DIR/advance-$project.md"
    local prompt
    
    if [ -f "$prompt_file" ]; then
        prompt=$(cat "$prompt_file")
    else
        # Default advancement prompt
        prompt="You are advancing the $project project in jcaldwell-labs.

INSTRUCTIONS:
1. Read the roadmap at $roadmap to understand current priorities
2. Check open issues with: gh issue list --repo $repo --state open
3. Pick ONE high-priority incomplete item (prefer issues labeled 'priority: high')
4. Implement it with proper tests if applicable
5. Commit with a descriptive message (do NOT push unless told)

CONSTRAINTS:
- Focus on ONE deliverable per session
- Keep changes small and reviewable (<500 lines)
- Run existing tests if present
- Document any decisions in commit message

After completing, summarize what you did and what the next priority should be."
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Advancing: $project${NC}"
    echo -e "${CYAN}Path: $path${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute:${NC}"
        echo "cd $path && claude --dangerously-skip-permissions -p '...'"
        return 0
    fi
    
    # Change to project directory and run Claude
    cd "$path" || { echo -e "${RED}Cannot cd to $path${NC}"; return 1; }
    
    # Pull latest first
    git pull --rebase origin HEAD 2>/dev/null || true
    
    # Run Claude
    local output
    output=$(claude --dangerously-skip-permissions -p "$prompt" 2>&1)
    local exit_code=$?
    
    echo "$output"
    
    # Log the session
    local log_file="$STATE_DIR/sessions/$(date +%Y-%m-%d)-$project.log"
    mkdir -p "$STATE_DIR/sessions"
    echo "=== Session: $(date -Iseconds) ===" >> "$log_file"
    echo "$output" >> "$log_file"
    
    # Push if requested and successful
    if [ "$push" = "true" ] && [ $exit_code -eq 0 ]; then
        echo -e "${CYAN}Pushing changes...${NC}"
        git push origin HEAD
    fi
    
    return $exit_code
}

# Parse arguments
PROJECT=""
PUSH="false"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --stale)
            PROJECT="--stale"
            shift
            ;;
        --all)
            PROJECT="--all"
            shift
            ;;
        --push)
            PUSH="true"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            PROJECT="$1"
            shift
            ;;
    esac
done

[ -z "$PROJECT" ] && usage

# Execute based on mode
if [ "$PROJECT" = "--stale" ]; then
    stalest=$(get_stalest_project)
    echo -e "${YELLOW}Stalest project: $stalest${NC}"
    advance_project "$stalest" "$PUSH" "$DRY_RUN"
    
elif [ "$PROJECT" = "--all" ]; then
    projects=$(get_unhealthy_projects)
    if [ -z "$projects" ]; then
        echo -e "${GREEN}All projects are healthy (>= 80%)!${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}Advancing unhealthy projects:${NC}"
    echo "$projects"
    echo ""
    
    for p in $projects; do
        advance_project "$p" "$PUSH" "$DRY_RUN"
        echo ""
    done
else
    advance_project "$PROJECT" "$PUSH" "$DRY_RUN"
fi

echo -e "${GREEN}Done!${NC}"
