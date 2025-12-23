#!/bin/bash
# health-check.sh - Check health of all jcaldwell-labs projects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_DIR="$PROJECT_ROOT/state"
OUTPUT_FILE="$STATE_DIR/health.json"

mkdir -p "$STATE_DIR"

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Hardcoded project list (simpler than yaml parsing)
declare -A PROJECTS=(
    ["my-grid"]="jcaldwell-labs/my-grid|high|7"
    ["atari-style"]="jcaldwell-labs/atari-style|high|7"
    ["boxes-live"]="jcaldwell-labs/boxes-live|medium|10"
    ["terminal-stars"]="jcaldwell-labs/terminal-stars|medium|10"
    ["smartterm-prototype"]="jcaldwell-labs/smartterm-prototype|medium|14"
    ["my-context"]="jcaldwell-labs/my-context|high|7"
    ["fintrack"]="jcaldwell-labs/fintrack|low|14"
    ["tario"]="jcaldwell-labs/tario|medium|14"
    ["adventure-engine-v2"]="jcaldwell-labs/adventure-engine-v2|medium|10"
    ["capability-catalog"]="jcaldwell-labs/capability-catalog|high|7"
)

calculate_health() {
    local project="$1"
    local repo="$2"
    local stale_days="$3"
    
    # Get last commit info
    local commit_info
    commit_info=$(gh api "repos/$repo/commits?per_page=1" 2>/dev/null) || {
        echo "0|error|API failed"
        return
    }
    
    local last_commit_date
    last_commit_date=$(echo "$commit_info" | jq -r '.[0].commit.committer.date // empty' 2>/dev/null)
    
    if [ -z "$last_commit_date" ]; then
        echo "0|unknown|no commits"
        return
    fi
    
    # Calculate days since last commit
    local last_commit_ts now_ts days_ago
    last_commit_ts=$(date -d "$last_commit_date" +%s 2>/dev/null) || last_commit_ts=0
    now_ts=$(date +%s)
    days_ago=$(( (now_ts - last_commit_ts) / 86400 ))
    
    # Get open issues count
    local open_issues
    open_issues=$(gh api "repos/$repo" --jq '.open_issues_count // 0' 2>/dev/null) || open_issues=0
    
    # Calculate health score (0-100)
    local health=100
    
    # Deduct for staleness
    if [ "$days_ago" -gt "$stale_days" ]; then
        local overage=$((days_ago - stale_days))
        local penalty=$((overage * 5))
        [ "$penalty" -gt 60 ] && penalty=60
        health=$((health - penalty))
    fi
    
    # Deduct for many open issues
    if [ "$open_issues" -gt 10 ]; then
        local issue_penalty=$(( (open_issues - 10) * 2 ))
        [ "$issue_penalty" -gt 20 ] && issue_penalty=20
        health=$((health - issue_penalty))
    fi
    
    [ "$health" -lt 0 ] && health=0
    
    # Format age
    local age_str
    if [ "$days_ago" -eq 0 ]; then
        age_str="today"
    elif [ "$days_ago" -eq 1 ]; then
        age_str="1d ago"
    else
        age_str="${days_ago}d ago"
    fi
    
    echo "$health|$age_str|$open_issues issues"
}

echo -e "${CYAN}Checking jcaldwell-labs project health...${NC}"
echo ""

# Start JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"timestamp\": \"$(date -Iseconds)\"," >> "$OUTPUT_FILE"
echo "  \"projects\": {" >> "$OUTPUT_FILE"

first=true
for project in "${!PROJECTS[@]}"; do
    IFS='|' read -r repo priority stale_days <<< "${PROJECTS[$project]}"
    
    result=$(calculate_health "$project" "$repo" "$stale_days")
    health=$(echo "$result" | cut -d'|' -f1)
    age=$(echo "$result" | cut -d'|' -f2)
    info=$(echo "$result" | cut -d'|' -f3)
    
    # Status
    if [ "$health" -ge 80 ]; then
        status="healthy"; icon="🟢"; color="$GREEN"
    elif [ "$health" -ge 50 ]; then
        status="warning"; icon="🟡"; color="$YELLOW"
    else
        status="critical"; icon="🔴"; color="$RED"
    fi
    
    printf "%s %-18s ${color}%3d%%${NC}  %-10s %s\n" "$icon" "$project" "$health" "$age" "$info"
    
    # JSON entry
    [ "$first" = true ] && first=false || echo "," >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << JSONBLOCK
    "$project": {
      "repo": "$repo",
      "health": $health,
      "status": "$status",
      "last_activity": "$age",
      "info": "$info",
      "priority": "$priority"
    }
JSONBLOCK
done

echo "" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

echo ""
echo -e "${CYAN}Health data saved to: $OUTPUT_FILE${NC}"
