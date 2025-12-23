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
```

## Architecture

```
project-conductor/
├── config/
│   └── projects.yaml      # Project registry with priorities and thresholds
├── state/
│   ├── health.json        # Current health scores (generated)
│   └── sessions/          # Logs of advancement sessions
├── scripts/
│   ├── health-check.sh    # Query GitHub API for project metrics
│   ├── advance-project.sh # Launch Claude to work on a project
│   └── dashboard.sh       # Interactive terminal dashboard
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
