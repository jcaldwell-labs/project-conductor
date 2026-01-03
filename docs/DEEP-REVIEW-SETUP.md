# Deep Review Script - Installation & Troubleshooting Guide

## Overview

The `deep-review.sh` script provides comprehensive code quality audits using specialized agents from the [claude-workflow](https://github.com/CloudAI-X/claude-workflow) project.

## Problems Encountered & Solutions

### 1. **AWK Range Pattern Bug** (CRITICAL)

**Problem**: The `get_project_field()` function used an awk range pattern that would match on a single line:

```bash
# BROKEN CODE:
awk "/^  $project:/,/^  [a-z]/{if(/$field:/) print}"
```

**Root Cause**:
- The end pattern `/^  [a-z]/` only matches a single character
- Both start and end patterns are evaluated on every line
- When the script hit `  my-grid:`, it would:
  1. Start the range (because it matches `/^  my-grid:/`)
  2. Immediately end the range (because `m` from `my-grid` matches `/^  [a-z]/`)
  3. Result: only one line extracted, no fields found

**Solution**: Use `sed` with proper range extraction:

```bash
# FIXED CODE:
sed -n "/^  $project:$/,/^  [a-z]/p" "$CONFIG_FILE" | \
  grep "^    $field:" | head -1 | sed 's/.*: *//' | tr -d '"'
```

**Key Improvements**:
- `sed -n` with `/p` flag for cleaner range extraction
- Anchors `$` to ensure exact project name match
- Separate `grep` step to find the specific field
- Proper indentation matching (4 spaces for fields)

### 2. **YAML Indentation Sensitivity**

**Problem**: The script is sensitive to YAML indentation inconsistencies.

**Requirements**:
- Projects must be indented with **exactly 2 spaces**: `  my-grid:`
- Fields must be indented with **exactly 4 spaces**: `    path:`
- Blank lines between projects should have consistent spacing

**Validation**:
```bash
# Check indentation
cat -A config/projects.yaml | grep -E '^  [a-z-]+:\$'

# Should show:
#   my-grid:$
#   atari-style:$
#   etc.
```

### 3. **claude-workflow Location Hardcoded**

**Problem**: The script hardcodes the claude-workflow path:

```bash
CLAUDE_WORKFLOW_AGENTS="/home/be-dev-agent/projects/claude-workflow"
```

**Solutions**:

**Option A**: Symlink to standard location
```bash
ln -s ~/your-path/claude-workflow /home/be-dev-agent/projects/claude-workflow
```

**Option B**: Edit the path in `deep-review.sh` line 11:
```bash
CLAUDE_WORKFLOW_AGENTS="/your/path/to/claude-workflow"
```

**Option C**: Use environment variable:
```bash
export CLAUDE_WORKFLOW_PATH="/your/path"
# Then edit script to use: ${CLAUDE_WORKFLOW_PATH:-/home/be-dev-agent/projects/claude-workflow}
```

### 4. **Long Execution Times**

**Problem**: Running all agents can take 10-30 minutes per project.

**Solutions**:

```bash
# Use --quick for faster reviews (code-reviewer + security-auditor only)
./scripts/deep-review.sh my-grid --quick

# Run specific agents only
./scripts/deep-review.sh my-grid --agents code-reviewer,docs-writer

# Run in background and monitor
nohup ./scripts/deep-review.sh my-grid > review.log 2>&1 &
tail -f review.log
```

### 5. **Prerequisites Not Clearly Documented**

**Required Tools**:
- Claude Code CLI (`claude` command)
- claude-workflow project cloned
- Standard Unix tools: `sed`, `grep`, `awk`, `head`, `tr`
- `gh` CLI (for accessing project repos)
- Git (for checking project status)

**Verification Script**:
```bash
#!/bin/bash
echo "Checking prerequisites..."

command -v claude >/dev/null 2>&1 || echo "❌ Claude Code CLI not found"
command -v gh >/dev/null 2>&1 || echo "❌ GitHub CLI (gh) not found"
[ -d /home/be-dev-agent/projects/claude-workflow ] || echo "❌ claude-workflow not found"

echo "✓ Prerequisites check complete"
```

## Testing the Installation

### Quick Test

```bash
# 1. Validate configuration parsing
./scripts/test-deep-review.sh

# 2. Check help output
./scripts/deep-review.sh --help

# 3. Verify project detection
./scripts/deep-review.sh my-grid --agents code-reviewer --dry-run
# (Note: --dry-run not implemented yet, but --help will show available projects)
```

### Full Test

```bash
# Run a quick review on a small project
./scripts/deep-review.sh fintrack --quick

# Check output
ls -la state/reviews/$(date +%Y-%m-%d)/

# Read summary
cat state/reviews/$(date +%Y-%m-%d)/fintrack-SUMMARY.md
```

## Known Limitations

1. **No Parallel Execution**: Agents run sequentially; consider running multiple projects in parallel manually:
   ```bash
   ./scripts/deep-review.sh project1 --quick &
   ./scripts/deep-review.sh project2 --quick &
   wait
   ```

2. **No Progress Indicators**: Long-running reviews have no progress updates
   - **Workaround**: Check `state/reviews/YYYY-MM-DD/` directory for partial results

3. **Error Handling**: Script doesn't gracefully handle all Claude Code failures
   - **Workaround**: Check exit codes and re-run failed agents manually

4. **No Resume Capability**: If a review fails midway, you must re-run all agents
   - **Workaround**: Use `--agents` to manually skip completed agents

## Best Practices

### 1. Start with Quick Reviews
```bash
# Get a fast overview first
./scripts/deep-review.sh my-grid --quick

# If issues found, run specific deep dives
./scripts/deep-review.sh my-grid --agents refactorer,test-architect
```

### 2. Schedule Regular Reviews
```bash
# Weekly full reviews (add to cron)
0 2 * * 1 cd ~/projects/project-conductor && \
  ./scripts/deep-review.sh --all --quick > /tmp/weekly-review.log 2>&1
```

### 3. Use with my-context
```bash
# Track review sessions
my-context start "deep-review-my-grid"
./scripts/deep-review.sh my-grid
my-context note "Found 3 critical security issues"
my-context export deep-review-my-grid
```

### 4. Create Action Items from Reviews
```bash
# After review, create GitHub issues
SUMMARY=$(cat state/reviews/$(date +%Y-%m-%d)/my-grid-SUMMARY.md)

# Extract critical findings and create issues
gh issue create \
  --repo jcaldwell-labs/my-grid \
  --title "Security: Fix critical findings from code review" \
  --body "$SUMMARY" \
  --label "security,priority:high"
```

## Troubleshooting

### "Project not found in config"

**Symptoms**: Script lists project in available projects but says it's not found

**Solution**: Check YAML indentation:
```bash
# Verify project entry
grep -A5 "^  my-grid:" config/projects.yaml

# Should show fields with 4-space indentation
```

### "claude-workflow not found"

**Solution**: Update path in script or create symlink:
```bash
ln -s ~/actual/path/claude-workflow /home/be-dev-agent/projects/claude-workflow
```

### "No output generated"

**Causes**:
1. Claude Code not authenticated
2. Project path doesn't exist
3. Agent configuration issues

**Debug**:
```bash
# Test Claude Code
cd ~/projects/my-grid
claude -p "What files are in this project?"

# Verify project path
PROJECT_PATH=$(sed -n "/^  my-grid:$/,/^  [a-z]/p" config/projects.yaml | \
  grep "^    path:" | sed 's/.*: *//' | tr -d '"')
echo "Path: $PROJECT_PATH"
ls -la ${PROJECT_PATH/#\~/$HOME}
```

### Reviews Take Too Long

**Solutions**:
1. Use `--quick` mode
2. Run specific agents: `--agents code-reviewer`
3. Kill and resume later (no built-in resume yet)

## Future Enhancements

Potential improvements for version 2.0:

- [ ] Add `--dry-run` flag to show what would be executed
- [ ] Implement `--resume` to continue failed reviews
- [ ] Add progress indicators for long-running reviews
- [ ] Support parallel agent execution
- [ ] Add `--format json` for programmatic consumption
- [ ] Include historical trend analysis
- [ ] Auto-create GitHub issues from critical findings
- [ ] Email/Slack notifications on completion
- [ ] Web dashboard for review results

## Support

If you encounter issues not covered here:

1. Check `state/reviews/` for partial output
2. Run `./scripts/test-deep-review.sh` to validate config
3. Review Claude Code logs: `~/.claude/logs/`
4. Open issue in project-conductor repo

## Version History

- **v1.0** (2026-01-02): Initial release
  - Fixed AWK range pattern bug
  - Added comprehensive error checking
  - Integrated with claude-workflow agents
