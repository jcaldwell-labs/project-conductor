# Session Prompts - Ready-to-Launch Claude Code Sessions

**Last Updated:** 2026-01-03
**Status:** 4 critical security projects with deadline 2026-01-10

## Quick Launch

```bash
# View a prompt
cat ~/projects/project-conductor/session-prompts/critical-security/my-grid.md

# Launch session with prompt
cd ~/projects/my-grid
# Then paste prompt contents into new Claude Code session
```

---

## 🔴 Critical Security Fixes (Deadline: Friday 2026-01-10)

These projects have critical security vulnerabilities that must be fixed by Friday.

### 1. adventure-engine-v2 (C)
**Issues:** 1 remaining (6 memory safety issues)
**Status:** 67% complete (2 of 3 done)
**Estimate:** 6-8 hours
**Prompt:** `critical-security/adventure-engine-v2.md`

**Launch:**
```bash
cd ~/projects/adventure-engine-v2
cat ~/projects/project-conductor/session-prompts/critical-security/adventure-engine-v2.md
# Copy and paste into Claude Code session
```

**Critical Issues:**
- Unvalidated buffer reads (sscanf)
- Race conditions in registry files
- Unchecked fread() calls
- Null termination issues (strncpy)
- Format string vulnerabilities
- Integer overflow validation

**Milestone:** https://github.com/jcaldwell-labs/adventure-engine-v2/milestone/1

---

### 2. my-context (Go)
**Issues:** 2 remaining
**Status:** 0% complete
**Estimate:** 5-7 hours
**Prompt:** `critical-security/my-context.md`

**Launch:**
```bash
cd ~/projects/my-context
cat ~/projects/project-conductor/session-prompts/critical-security/my-context.md
# Copy and paste into Claude Code session
```

**Critical Issues:**
- #7: Command injection in file monitor
- #8: Path traversal in delete operations
- #9: Low test coverage (bonus)

**Milestone:** https://github.com/jcaldwell-labs/my-context/milestone/1

---

### 3. my-grid (Python)
**Issues:** 3 remaining
**Status:** 0% complete
**Estimate:** 5-7 hours
**Prompt:** `critical-security/my-grid.md`

**Launch:**
```bash
cd ~/projects/my-grid
cat ~/projects/project-conductor/session-prompts/critical-security/my-grid.md
# Copy and paste into Claude Code session
```

**Critical Issues:**
- #66: Command injection (shell=True)
- #67: Bare except clauses
- #68: JSON validation missing

**Milestone:** https://github.com/jcaldwell-labs/my-grid/milestone/2

---

### 4. ap-cli (Go)
**Issues:** 3 remaining
**Status:** 0% complete
**Estimate:** 7-10 hours
**Prompt:** `critical-security/ap-cli.md`

**Launch:**
```bash
cd ~/projects/ap-cli
cat ~/projects/project-conductor/session-prompts/critical-security/ap-cli.md
# Copy and paste into Claude Code session
```

**Critical Issues:**
- #1: Zero test coverage
- #2: HTTP client security flaws
- #3: Path traversal vulnerability

**Milestone:** https://github.com/jcaldwell1066/ap-cli/milestone/1

---

## 📊 Sprint Summary

**Total Critical Issues:** 9 (11 including bonus)
**Deadline:** Friday 2026-01-10 (4 days remaining)
**Completed:** 2/11 (18%)
**Remaining:** 9/11 (82%)

**Estimated Work:**
- adventure-engine-v2: 6-8 hours
- my-context: 5-7 hours
- my-grid: 5-7 hours
- ap-cli: 7-10 hours
- **Total: 23-32 hours**

**Recommended Schedule:**
- Day 1 (Today): adventure-engine-v2 (finish milestone)
- Day 2 (Sunday): my-context (2 issues, smaller scope)
- Day 3 (Monday): my-grid (3 issues, Python)
- Day 4 (Tuesday): ap-cli (most complex, needs full day)
- Day 5 (Wednesday): Buffer day for testing/cleanup

---

## 🎯 Common Objectives Across All Projects

Every session should accomplish:

1. **Fix security vulnerabilities** - Primary goal
2. **Add comprehensive tests** - No fix complete without tests
3. **Integrate claude-workflow** - Add `scripts/code-review.sh` to each project
4. **Document security approach** - Add/update SECURITY.md
5. **Close milestone** - Mark issues resolved

---

## 🔧 Common Patterns & Tools

### Security Fixing Workflow
1. **Read the issue** - Understand the vulnerability
2. **Write failing tests** - Prove the vulnerability exists
3. **Implement fix** - Use safe alternatives
4. **Verify tests pass** - Ensure vulnerability is closed
5. **Run security scanners** - Confirm no regressions
6. **Document** - Explain the fix in code comments

### Language-Specific Tools

**C (adventure-engine-v2):**
```bash
# Build with sanitizers
CFLAGS="-fsanitize=address,undefined -g" make

# Static analysis
scan-build make

# Memory leak detection
valgrind --leak-check=full ./adventure
```

**Go (my-context, ap-cli):**
```bash
# Security scanning
gosec ./...

# Race detector
go test -race ./...

# Coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

**Python (my-grid):**
```bash
# Security scanning
bandit -r my_grid/
safety check

# Linting
ruff check .
mypy my_grid/

# Tests
pytest tests/ -v --cov=my_grid
```

### claude-workflow Integration

Every project should get:
```bash
# scripts/code-review.sh
#!/bin/bash
# Based on: ~/projects/project-conductor/scripts/deep-review.sh

PROJECT_NAME="$(basename $PWD)"
WORKFLOW_PATH="$HOME/.local/share/claude-workflow"

# Run code-reviewer and security-auditor
"$WORKFLOW_PATH/code-reviewer" .
"$WORKFLOW_PATH/security-auditor" .
```

---

## 📁 Directory Structure

```
session-prompts/
├── INDEX.md                          # This file
├── critical-security/                # Deadline: 2026-01-10
│   ├── adventure-engine-v2.md       # C memory safety (6 issues)
│   ├── my-context.md                 # Go security (2 issues)
│   ├── my-grid.md                    # Python security (3 issues)
│   └── ap-cli.md                     # Go security + testing (3 issues)
├── active-development/               # Ongoing work (future)
│   └── (to be created)
└── backlog/                          # Lower priority (future)
    └── (to be created)
```

---

## 🚀 Session Launch Script (Future Enhancement)

```bash
# scripts/launch-session.sh PROJECT_NAME
#!/bin/bash
set -euo pipefail

PROJECT=$1
PROMPT_DIR="$HOME/projects/project-conductor/session-prompts"

# Find prompt
PROMPT=$(find "$PROMPT_DIR" -name "${PROJECT}.md" | head -n1)

if [ -z "$PROMPT" ]; then
    echo "No prompt found for: $PROJECT"
    exit 1
fi

# Display prompt
cat "$PROMPT"

echo ""
echo "═══════════════════════════════════════════"
echo "Launch session with this prompt? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" = "y" ]; then
    cd "$HOME/projects/$PROJECT"
    echo "Changed to: $PWD"
    echo "Paste the prompt above into Claude Code"
fi
```

---

## 📈 Progress Tracking

### Completed Sessions
- ✅ **2026-01-03:** adventure-engine-v2 issues #14, #15 (buffer overflow, path traversal)

### Pending Sessions
- ⏳ **Next:** adventure-engine-v2 issue #16 (6 remaining memory safety issues)
- ⏳ **Then:** my-context issues #7, #8 (command injection, path traversal)
- ⏳ **Then:** my-grid issues #66, #67, #68 (command injection, bare excepts, JSON)
- ⏳ **Then:** ap-cli issues #1, #2, #3 (test coverage, HTTP security, path traversal)

### Milestone Links
- [adventure-engine-v2 milestone](https://github.com/jcaldwell-labs/adventure-engine-v2/milestone/1)
- [my-context milestone](https://github.com/jcaldwell-labs/my-context/milestone/1)
- [my-grid milestone](https://github.com/jcaldwell-labs/my-grid/milestone/2)
- [ap-cli milestone](https://github.com/jcaldwell1066/ap-cli/milestone/1)

---

## 🔗 Related Resources

**Project Conductor:**
- Health check: `~/projects/project-conductor/scripts/health-check.sh`
- Dashboard: `~/projects/project-conductor/scripts/dashboard.sh`
- Deep review: `~/projects/project-conductor/scripts/deep-review.sh`

**Previous Session:**
- Context export: `~/work/context-exports/2026-01/weekend-2026-01-03-detailed.md`
- Review reports: `~/projects/project-conductor/state/reviews/2026-01-03/`
- Session summary: `~/projects/project-conductor/state/reviews/2026-01-03/SESSION-SUMMARY.md`

**Upstream:**
- claude-workflow contribution: https://github.com/CloudAI-X/claude-workflow/issues/2
- claude-workflow repo: https://github.com/CloudAI-X/claude-workflow

---

## 💡 Tips for Effective Sessions

1. **One project per session** - Don't try to multi-task
2. **Start with context** - Use `my-context start "session-name"`
3. **Test-first approach** - Write failing tests before fixing
4. **Use todo lists** - Track progress within the session
5. **Security scanners** - Run language-specific tools frequently
6. **Export context** - Save session notes at the end
7. **Close issues** - Mark GitHub issues resolved when done
8. **Push immediately** - Don't leave unpushed commits

---

## 📝 Updating This Index

When you complete a session:
1. Update **Completed Sessions** section
2. Mark prompt status in **Pending Sessions**
3. Update **Sprint Summary** percentages
4. Check milestone links are current

When you create new prompts:
1. Add to appropriate directory (critical/active/backlog)
2. Add entry to this INDEX.md
3. Update **Directory Structure** if needed
4. Link to relevant GitHub issues/milestones

---

**Last Review:** 2026-01-03
**Next Review:** After each completed session
