#!/bin/bash
# deep-review.sh - Comprehensive project review using claude-workflow agents
# Usage: ./deep-review.sh <project-name> [--agents code-reviewer,security-auditor,...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/projects.yaml"
REVIEWS_DIR="$PROJECT_ROOT/state/reviews"
CLAUDE_WORKFLOW_AGENTS="/home/be-dev-agent/projects/claude-workflow"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Available agents
declare -A AGENTS=(
    ["code-reviewer"]="📊 Code Quality Review"
    ["security-auditor"]="🔒 Security Audit"
    ["test-architect"]="🧪 Test Coverage Assessment"
    ["docs-writer"]="📝 Documentation Review"
    ["refactorer"]="♻️  Refactoring Opportunities"
    ["debugger"]="🐛 Bug & Issue Analysis"
)

usage() {
    echo "Usage: $0 <project-name> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agents AGENTS     Comma-separated list of agents to run"
    echo "                      Available: ${!AGENTS[@]}"
    echo "  --all               Run all available agents (default)"
    echo "  --quick             Run only code-reviewer and security-auditor"
    echo "  --output-dir DIR    Custom output directory (default: state/reviews/YYYY-MM-DD)"
    echo "  --help              Show this help message"
    echo ""
    echo "Available projects:"
    grep -E '^  [a-z]' "$CONFIG_FILE" | sed 's/://g' | awk '{print "  " $1}'
    echo ""
    echo "Examples:"
    echo "  $0 my-grid                                    # Full review of my-grid"
    echo "  $0 tui-base --quick                           # Quick review of tui-base"
    echo "  $0 ps-cli --agents code-reviewer,docs-writer  # Specific agents only"
    exit 1
}

get_project_field() {
    local project="$1"
    local field="$2"
    # Use sed to extract the project block, then grep for the field
    sed -n "/^  $project:$/,/^  [a-z]/p" "$CONFIG_FILE" | grep "^    $field:" | head -1 | sed 's/.*: *//' | tr -d '"'
}

check_prerequisites() {
    if [ ! -d "$CLAUDE_WORKFLOW_AGENTS" ]; then
        echo -e "${RED}Error: claude-workflow not found at $CLAUDE_WORKFLOW_AGENTS${NC}"
        echo "Please ensure claude-workflow is cloned to that location."
        exit 1
    fi

    if ! command -v claude &> /dev/null; then
        echo -e "${RED}Error: Claude Code CLI not found${NC}"
        echo "Please install Claude Code: https://claude.ai/download"
        exit 1
    fi
}

run_agent_review() {
    local agent="$1"
    local project="$2"
    local project_path="$3"
    local output_file="$4"

    local description="${AGENTS[$agent]}"

    echo -e "${CYAN}${description}${NC}"
    echo "Agent: $agent"
    echo "Output: $output_file"
    echo ""

    # Construct the prompt based on agent type
    local prompt
    case $agent in
        code-reviewer)
            prompt="Review all code in this project for quality issues. Focus on:
- Correctness and edge cases
- Security vulnerabilities
- Performance issues
- Maintainability concerns
- Test coverage

Organize findings by severity: Critical, Warning, Suggestion, and Positive Observations.
Include file paths and line numbers for all issues."
            ;;
        security-auditor)
            prompt="Perform a comprehensive security audit of this project. Check for:
- Hardcoded secrets or credentials
- Input validation issues
- SQL injection, XSS, command injection vulnerabilities
- Authentication/authorization flaws
- Dependency vulnerabilities
- Sensitive data exposure

Provide severity ratings and remediation steps for each finding."
            ;;
        test-architect)
            prompt="Assess the test coverage and quality of this project. Analyze:
- Current test coverage percentage (if available)
- Missing test cases for critical paths
- Test quality and maintainability
- Integration vs unit test balance
- Test organization and patterns

Recommend specific tests to add and improvements to existing tests."
            ;;
        docs-writer)
            prompt="Review the documentation completeness of this project. Check:
- README clarity and completeness
- API documentation presence and quality
- Code comments for complex logic
- Setup/installation instructions
- Contributing guidelines
- Changelog/version history

Recommend documentation improvements and missing sections."
            ;;
        refactorer)
            prompt="Identify refactoring opportunities in this project. Look for:
- Code duplication (DRY violations)
- Complex functions that need simplification
- Poorly named variables/functions
- God objects or classes with too many responsibilities
- Design pattern opportunities
- Dead code or unused dependencies

Prioritize refactoring by impact and effort required."
            ;;
        debugger)
            prompt="Analyze this project for bugs and potential issues. Investigate:
- Known issues from GitHub/issue tracker
- Common bug patterns in the codebase
- Error handling gaps
- Edge cases that may not be handled
- Potential race conditions or concurrency issues

Provide root cause analysis and fix recommendations."
            ;;
        *)
            echo -e "${RED}Unknown agent: $agent${NC}"
            return 1
            ;;
    esac

    # Run Claude with the appropriate agent
    cd "$project_path" || { echo -e "${RED}Cannot cd to $project_path${NC}"; return 1; }

    # Use the Task tool to invoke the specialized agent
    local full_prompt="Use the Task tool with subagent_type='$agent' to execute the following:

$prompt

Project: $project
Path: $project_path

Provide a comprehensive markdown report."

    # Execute and capture output
    if claude --plugin-dir "$CLAUDE_WORKFLOW_AGENTS" --dangerously-skip-permissions -p "$full_prompt" > "$output_file" 2>&1; then
        echo -e "${GREEN}✓ Complete${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Completed with warnings${NC}"
        return 0
    fi
}

generate_summary() {
    local project="$1"
    local report_dir="$2"
    local agents_run="$3"
    local summary_file="$report_dir/${project}-SUMMARY.md"

    echo -e "${BLUE}Generating summary report...${NC}"

    cat > "$summary_file" <<EOF
# Deep Review Summary: $project
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Review Directory:** \`$report_dir\`

## Agents Executed

EOF

    # List all agent reports
    for agent in $agents_run; do
        local description="${AGENTS[$agent]}"
        local report_file="${project}-${agent}.md"
        if [ -f "$report_dir/$report_file" ]; then
            echo "- $description → [\`$report_file\`](./$report_file)" >> "$summary_file"
        fi
    done

    cat >> "$summary_file" <<EOF

## Critical Findings

EOF

    # Extract critical issues from all reports
    local has_critical=false
    for agent in $agents_run; do
        local report_file="$report_dir/${project}-${agent}.md"
        if [ -f "$report_file" ]; then
            local critical=$(grep -A 5 "^### 🔴 Critical\|^## 🔴 Critical\|^# Critical" "$report_file" 2>/dev/null || true)
            if [ -n "$critical" ]; then
                echo "### From ${AGENTS[$agent]}" >> "$summary_file"
                echo "$critical" | head -20 >> "$summary_file"
                echo "" >> "$summary_file"
                has_critical=true
            fi
        fi
    done

    if [ "$has_critical" = false ]; then
        echo "✅ No critical issues found across all agent reviews." >> "$summary_file"
    fi

    cat >> "$summary_file" <<EOF

## Recommended Next Actions

1. **Review Critical Findings**: Address all 🔴 critical issues identified above
2. **Check Individual Reports**: Review each agent's detailed report for context
3. **Prioritize Fixes**: Create GitHub issues for high-priority items
4. **Track Progress**: Use \`my-context\` to track remediation work

## Review Files

EOF

    # List all generated files
    ls -1 "$report_dir"/${project}-*.md | while read -r file; do
        basename "$file" | sed 's/^/- /' >> "$summary_file"
    done

    echo -e "${GREEN}✓ Summary generated: $summary_file${NC}"
}

# Parse arguments
PROJECT=""
AGENTS_TO_RUN=""
RUN_ALL=true
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --agents)
            AGENTS_TO_RUN="$2"
            RUN_ALL=false
            shift 2
            ;;
        --all)
            RUN_ALL=true
            shift
            ;;
        --quick)
            AGENTS_TO_RUN="code-reviewer,security-auditor"
            RUN_ALL=false
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
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

# Validate input
[ -z "$PROJECT" ] && usage

# Check prerequisites
check_prerequisites

# Get project details
PROJECT_PATH=$(get_project_field "$PROJECT" "path")
PROJECT_REPO=$(get_project_field "$PROJECT" "repo")

if [ -z "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project '$PROJECT' not found in config${NC}"
    usage
fi

# Expand ~ in path
PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project directory not found: $PROJECT_PATH${NC}"
    exit 1
fi

# Set output directory
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$REVIEWS_DIR/$(date +%Y-%m-%d)"
fi
mkdir -p "$OUTPUT_DIR"

# Determine which agents to run
if [ "$RUN_ALL" = true ]; then
    AGENTS_LIST="${!AGENTS[@]}"
else
    AGENTS_LIST=$(echo "$AGENTS_TO_RUN" | tr ',' ' ')
fi

# Display header
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Deep Review: $PROJECT${NC}"
echo -e "${CYAN}Path: $PROJECT_PATH${NC}"
echo -e "${CYAN}Output: $OUTPUT_DIR${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Run each agent
for agent in $AGENTS_LIST; do
    # Validate agent exists
    if [ -z "${AGENTS[$agent]}" ]; then
        echo -e "${YELLOW}Warning: Unknown agent '$agent', skipping...${NC}"
        continue
    fi

    output_file="$OUTPUT_DIR/${PROJECT}-${agent}.md"

    echo -e "${CYAN}─────────────────────────────────────────────────────────${NC}"
    run_agent_review "$agent" "$PROJECT" "$PROJECT_PATH" "$output_file"
    echo ""
done

# Generate summary report
echo -e "${CYAN}─────────────────────────────────────────────────────────${NC}"
generate_summary "$PROJECT" "$OUTPUT_DIR" "$AGENTS_LIST"

# Display completion message
echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deep Review Complete!${NC}"
echo ""
echo -e "${CYAN}Review Summary:${NC} $OUTPUT_DIR/${PROJECT}-SUMMARY.md"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Read the summary: cat $OUTPUT_DIR/${PROJECT}-SUMMARY.md"
echo "  2. Review individual reports in: $OUTPUT_DIR/"
echo "  3. Create issues: gh issue create --repo $PROJECT_REPO"
echo "  4. Track fixes: my-context start deep-review-$PROJECT"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
