# Project Conductor

Orchestration system for advancing jcaldwell-labs projects autonomously.

## Purpose

This tool manages the health and progress of all jcaldwell-labs repositories:
- Tracks project staleness and health metrics
- Launches Claude Code sessions to advance stale projects
- Provides a terminal dashboard for monitoring

## Quick Start

```bash
# Check health of all projects
./scripts/health-check.sh

# Launch interactive dashboard
./scripts/dashboard.sh

# Advance a specific project
./scripts/advance-project.sh my-grid

# Advance the stalest project
./scripts/advance-project.sh --stale

# Advance all unhealthy projects (<80% health)
./scripts/advance-project.sh --all

# Advance and push
./scripts/advance-project.sh my-grid --push

# Run comprehensive quality review (uses claude-workflow agents)
./scripts/deep-review.sh my-grid

# Quick security and code review
./scripts/deep-review.sh my-grid --quick
```

## Architecture

```
project-conductor/
├── config/
│   └── projects.yaml      # Project registry with priorities and thresholds
├── state/
│   ├── health.json        # Current health scores (generated)
│   ├── sessions/          # Logs of advancement sessions
│   └── reviews/           # Deep review reports by date
├── scripts/
│   ├── health-check.sh    # Query GitHub API for project metrics
│   ├── advance-project.sh # Launch Claude to work on a project
│   ├── dashboard.sh       # Interactive terminal dashboard
│   └── deep-review.sh     # Comprehensive quality review using agents
├── prompts/
│   └── advance-*.md       # Custom prompts per project (optional)
└── CLAUDE.md              # This file
```

## Health Scoring

Projects are scored 0-100 based on:
- **Commit recency** (30%): Days since last commit vs stale threshold
- **Open issues** (20%): Penalty if >10 open issues
- **Priority weight** (adjusted): High priority projects penalized more for staleness

Health statuses:
- 🟢 **Healthy** (80-100%): Active, no action needed
- 🟡 **Warning** (50-79%): Getting stale, consider advancing
- 🔴 **Critical** (<50%): Needs immediate attention

## Deep Reviews with claude-workflow Agents

The `deep-review.sh` script leverages specialized agents from [claude-workflow](https://github.com/CloudAI-X/claude-workflow) to perform comprehensive code quality audits.

### Available Review Agents

| Agent | Focus | Use When |
|-------|-------|----------|
| **code-reviewer** | Code quality, correctness, maintainability | Regular quality checks |
| **security-auditor** | Security vulnerabilities, auth issues | Before releases, security audits |
| **test-architect** | Test coverage, test quality | Improving test suites |
| **docs-writer** | Documentation completeness | Documentation reviews |
| **refactorer** | Code smells, refactoring opportunities | Reducing technical debt |
| **debugger** | Known bugs, error handling | Bug investigations |

### Usage Examples

```bash
# Full review (all agents)
./scripts/deep-review.sh my-grid

# Quick review (code + security only)
./scripts/deep-review.sh tui-base --quick

# Specific agents
./scripts/deep-review.sh ps-cli --agents code-reviewer,docs-writer

# Custom output directory
./scripts/deep-review.sh my-grid --output-dir ./reports/sprint-26
```

### Review Output

Reports are saved to `state/reviews/YYYY-MM-DD/`:
- `{project}-SUMMARY.md` - Executive summary with critical findings
- `{project}-{agent}.md` - Individual agent reports

### Integration with Advancement

Use deep reviews to guide advancement priorities:

```bash
# 1. Run comprehensive review
./scripts/deep-review.sh my-grid

# 2. Check critical issues
cat state/reviews/$(date +%Y-%m-%d)/my-grid-SUMMARY.md

# 3. Create advancement prompt targeting critical findings
# (Create prompts/advance-my-grid.md based on review findings)

# 4. Advance with focused priorities
./scripts/advance-project.sh my-grid
```

## Custom Prompts

Create project-specific prompts in :

```markdown
# prompts/advance-my-grid.md
Focus on the PTY zone improvements. Specifically:
1. Check issue #59 for pyte integration status
2. Implement scrollback buffer persistence
3. Add tests for ANSI color preservation
```

## Dashboard Commands

| Key | Action |
|-----|--------|
| r | Refresh health data |
| a | Advance stalest project |
| A | Advance all unhealthy projects |
| 1-9 | Advance project by number |
| p | Push all unpushed commits |
| q | Quit |

## Integration with my-context

Track conductor sessions:
```bash
my-context start "conductor-session"
./scripts/advance-project.sh --all
my-context note "Advanced 3 stale projects"
my-context export conductor-session
```

## Automation

Add to cron for daily advancement:
```bash
# crontab -e
0 9 * * * cd ~/projects/project-conductor && ./scripts/advance-project.sh --stale --push
```

Or use GitHub Actions (see .github/workflows/advance.yml).
