#!/bin/bash
# dashboard.sh - Interactive terminal dashboard for project health
# Requires: jq, gh cli

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_FILE="$PROJECT_ROOT/state/health.json"

# Colors and formatting
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

clear_screen() {
    printf '\033[2J\033[H'
}

draw_header() {
    local width=70
    local title="jcaldwell-labs Project Conductor"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${CYAN}${BOLD}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    printf "${CYAN}${BOLD}║${NC} %-*s ${CYAN}${BOLD}║${NC}\n" $((width-3)) "$title"
    printf "${CYAN}${BOLD}║${NC} ${DIM}%-*s${NC} ${CYAN}${BOLD}║${NC}\n" $((width-3)) "$timestamp"
    echo -e "${CYAN}${BOLD}╠$(printf '═%.0s' $(seq 1 $((width-2))))╣${NC}"
}

draw_project_row() {
    local project="$1"
    local health="$2"
    local status="$3"
    local last_activity="$4"
    local info="$5"
    local priority="$6"
    
    # Status icon
    local icon
    case $status in
        healthy)  icon="🟢"; color="$GREEN" ;;
        warning)  icon="🟡"; color="$YELLOW" ;;
        critical) icon="🔴"; color="$RED" ;;
        *)        icon="⚪"; color="$NC" ;;
    esac
    
    # Priority indicator
    local pri_icon
    case $priority in
        high)   pri_icon="↑" ;;
        medium) pri_icon="→" ;;
        low)    pri_icon="↓" ;;
        *)      pri_icon=" " ;;
    esac
    
    printf "${CYAN}${BOLD}║${NC} %s %-16s ${color}%3d%%${NC} %-8s %-14s %s ${CYAN}${BOLD}║${NC}\n"         "$icon" "$project" "$health" "$last_activity" "$info" "$pri_icon"
}

draw_footer() {
    local width=70
    echo -e "${CYAN}${BOLD}╠$(printf '═%.0s' $(seq 1 $((width-2))))╣${NC}"
    printf "${CYAN}${BOLD}║${NC} ${BOLD}Commands:${NC} %-54s ${CYAN}${BOLD}║${NC}\n" ""
    printf "${CYAN}${BOLD}║${NC}   [r]efresh  [a]dvance stale  [A]dvance all  [q]uit     ${CYAN}${BOLD}║${NC}\n"
    printf "${CYAN}${BOLD}║${NC}   [1-9] advance specific  [s]ession prompts  [p]ush all ${CYAN}${BOLD}║${NC}\n"
    echo -e "${CYAN}${BOLD}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
}

draw_dashboard() {
    clear_screen
    draw_header
    
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${CYAN}${BOLD}║${NC} ${YELLOW}No health data. Press 'r' to refresh.${NC}                    ${CYAN}${BOLD}║${NC}"
    else
        local idx=1
        # Read and sort projects by health (ascending - worst first)
        while IFS= read -r line; do
            local project=$(echo "$line" | jq -r '.key')
            local health=$(echo "$line" | jq -r '.value.health')
            local status=$(echo "$line" | jq -r '.value.status')
            local last_activity=$(echo "$line" | jq -r '.value.last_activity')
            local info=$(echo "$line" | jq -r '.value.info')
            local priority=$(echo "$line" | jq -r '.value.priority')
            
            printf "${CYAN}${BOLD}║${NC} ${DIM}%d.${NC}" "$idx"
            # Shift the row content to account for the number
            local icon
            case $status in
                healthy)  icon="🟢"; color="$GREEN" ;;
                warning)  icon="🟡"; color="$YELLOW" ;;
                critical) icon="🔴"; color="$RED" ;;
                *)        icon="⚪"; color="$NC" ;;
            esac
            printf " %s %-14s ${color}%3d%%${NC} %-8s %-12s    ${CYAN}${BOLD}║${NC}\n"                 "$icon" "$project" "$health" "$last_activity" "$info"
            
            ((idx++))
        done < <(jq -c '.projects | to_entries | sort_by(.value.health)[]' "$STATE_FILE")
    fi
    
    draw_footer
}

refresh_health() {
    echo -e "${CYAN}Refreshing health data...${NC}"
    "$SCRIPT_DIR/health-check.sh"
    sleep 1
}

advance_stale() {
    echo -e "${YELLOW}Advancing stalest project...${NC}"
    "$SCRIPT_DIR/advance-project.sh" --stale
    echo ""
    echo -e "${CYAN}Press any key to continue...${NC}"
    read -n 1
}

advance_all() {
    echo -e "${YELLOW}Advancing all unhealthy projects...${NC}"
    "$SCRIPT_DIR/advance-project.sh" --all
    echo ""
    echo -e "${CYAN}Press any key to continue...${NC}"
    read -n 1
}

advance_by_number() {
    local num="$1"
    local project=$(jq -r ".projects | to_entries | sort_by(.value.health)[$((num-1))].key" "$STATE_FILE")
    if [ -n "$project" ] && [ "$project" != "null" ]; then
        echo -e "${YELLOW}Advancing $project...${NC}"
        "$SCRIPT_DIR/advance-project.sh" "$project"
        echo ""
        echo -e "${CYAN}Press any key to continue...${NC}"
        read -n 1
    fi
}

push_all() {
    echo -e "${YELLOW}Pushing all projects with unpushed commits...${NC}"
    for project in $(jq -r '.projects | keys[]' "$STATE_FILE"); do
        local path=$(grep -A5 "^  $project:" "$PROJECT_ROOT/config/projects.yaml" | grep "path:" | head -1 | sed 's/.*: *//' | tr -d '"')
        path="${path/#\~\/$HOME/}"
        if [ -d "$path" ]; then
            cd "$path"
            if git status | grep -q "Your branch is ahead"; then
                echo -e "  ${CYAN}Pushing $project...${NC}"
                git push origin HEAD 2>/dev/null || echo -e "    ${RED}Failed${NC}"
            fi
        fi
    done
    echo -e "${GREEN}Done!${NC}"
    sleep 2
}

show_session_prompts() {
    clear_screen
    local prompts_dir="$PROJECT_ROOT/session-prompts"

    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                      📋 Session Prompts                            ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo ""

    if [ ! -d "$prompts_dir/critical-security" ]; then
        echo -e "${RED}No session prompts found at: $prompts_dir${NC}"
        echo ""
        echo -e "${CYAN}Press any key to return...${NC}"
        read -n 1
        return
    fi

    echo -e "${RED}${BOLD}🔴 Critical Security (Deadline: 2026-01-10)${NC}"
    echo ""

    local idx=1
    for prompt_file in "$prompts_dir/critical-security"/*.md; do
        if [ -f "$prompt_file" ]; then
            local name=$(basename "$prompt_file" .md)
            local issues=""

            # Extract issue count from the file
            if grep -q "Issues:" "$prompt_file"; then
                issues=$(grep "^\*\*Issues:\*\*" "$prompt_file" | head -1 | sed 's/\*\*Issues:\*\* //')
            fi

            printf "  ${CYAN}%d.${NC} %-20s ${DIM}%s${NC}\n" "$idx" "$name" "$issues"
            ((idx++))
        fi
    done

    echo ""
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}${BOLD}║${NC} ${BOLD}Commands:${NC}                                                       ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}║${NC}   [1-4] View prompt    [i] View INDEX    [q] Back to dashboard ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    read -rsn1 choice
    case "$choice" in
        [1-4])
            local files=("$prompts_dir/critical-security"/*.md)
            local selected="${files[$((choice-1))]}"
            if [ -f "$selected" ]; then
                clear_screen
                cat "$selected"
                echo ""
                echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}Copy this prompt and paste into a new Claude Code session${NC}"
                echo -e "${CYAN}Press any key to continue...${NC}"
                read -n 1
            fi
            ;;
        i|I)
            clear_screen
            cat "$prompts_dir/INDEX.md"
            echo ""
            echo -e "${CYAN}Press any key to continue...${NC}"
            read -n 1
            ;;
        q|Q)
            return
            ;;
    esac
}

# Main loop
main() {
    # Initial health check if no data
    [ ! -f "$STATE_FILE" ] && refresh_health
    
    while true; do
        draw_dashboard
        
        # Read single character
        read -rsn1 input
        
        case "$input" in
            r|R) refresh_health ;;
            a)   advance_stale ;;
            A)   advance_all ;;
            s|S) show_session_prompts ;;
            p|P) push_all ;;
            q|Q) clear_screen; exit 0 ;;
            [1-9]) advance_by_number "$input" ;;
        esac
    done
}

main
