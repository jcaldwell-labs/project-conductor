# Session Prompts System

**Ready-to-launch Claude Code session prompts for systematic project advancement.**

## Overview

The session-prompts system maintains comprehensive, actionable prompts for each jcaldwell-labs project. Instead of starting sessions with vague goals, each project has a carefully crafted prompt that:

- Provides full context from previous work
- Lists specific objectives and success criteria
- Includes code patterns and security best practices
- References relevant files and documentation
- Estimates time requirements
- Defines clear testing strategies

## Quick Start

### View Available Prompts

```bash
# From dashboard (interactive)
cd ~/projects/project-conductor
./scripts/dashboard.sh
# Press 's' for session prompts

# From command line
cat session-prompts/INDEX.md
```

### Launch a Session

```bash
# 1. View the prompt
cat session-prompts/critical-security/my-grid.md

# 2. Navigate to project
cd ~/projects/my-grid

# 3. Start Claude Code session and paste the prompt
# The session will have everything needed to succeed
```

## Directory Structure

```
session-prompts/
├── README.md                    # This file
├── INDEX.md                     # Master index with all projects
├── critical-security/           # Deadline: 2026-01-10
│   ├── adventure-engine-v2.md  # C memory safety (6 issues)
│   ├── my-context.md            # Go security (2 issues)
│   ├── my-grid.md               # Python security (3 issues)
│   └── ap-cli.md                # Go security + testing (3 issues)
├── active-development/          # Ongoing work (future)
│   └── (TBD)
└── backlog/                     # Lower priority (future)
    └── (TBD)
```

## Prompt Structure

Each prompt follows this template:

### 1. Mission Statement
Clear, concise goal for the session.

### 2. Context from Previous Work
- What we've learned
- Reference implementations
- Previous session notes

### 3. Primary Objectives
Detailed task breakdown with:
- Issue numbers and descriptions
- Fix strategies with code examples
- Test case requirements
- Success criteria

### 4. Secondary Objectives
Nice-to-have improvements if time permits.

### 5. Key Files to Reference
Direct paths to:
- Previous fixes
- Review reports
- Documentation
- Test patterns

### 6. Workflow Recommendation
Step-by-step execution plan with:
- Time estimates per phase
- Validation checkpoints
- Testing commands
- Completion criteria

### 7. Notes & Best Practices
- Language-specific security patterns
- Common pitfalls
- Testing approaches

### 8. References
- GitHub issue links
- Milestone tracking
- External documentation

## Integration with Dashboard

The dashboard provides quick access to session prompts:

```bash
./scripts/dashboard.sh

# In dashboard:
# Press 's' → View session prompts
# Press '1-4' → View specific prompt
# Press 'i' → View INDEX.md
# Press 'q' → Return to dashboard
```

## Creating New Prompts

### For Critical Security Issues

1. **Run deep review:**
   ```bash
   ./scripts/deep-review.sh PROJECT_NAME
   ```

2. **Create prompt file:**
   ```bash
   cp session-prompts/critical-security/my-grid.md \
      session-prompts/critical-security/NEW_PROJECT.md
   ```

3. **Customize sections:**
   - Update mission statement
   - Add specific issues from GitHub
   - Include relevant code patterns
   - Adjust time estimates

4. **Update INDEX.md:**
   - Add to appropriate section
   - Link to milestone
   - Update sprint summary

### For Active Development

1. **Create in active-development/:**
   ```bash
   cat > session-prompts/active-development/PROJECT.md
   ```

2. **Focus on feature goals:**
   - Specify feature requirements
   - Link to design docs
   - List implementation tasks
   - Define acceptance criteria

### For Backlog Items

1. **Create in backlog/:**
   ```bash
   cat > session-prompts/backlog/PROJECT.md
   ```

2. **Keep lightweight:**
   - Brief description
   - Why it matters
   - Links to discussions

## Maintenance

### After Each Session

1. **Mark progress in INDEX.md:**
   ```markdown
   - ✅ **2026-01-03:** adventure-engine-v2 issues #14, #15 completed
   ```

2. **Update prompt if needed:**
   - Remove completed objectives
   - Add new discoveries
   - Update time estimates

3. **Move to appropriate category:**
   - critical-security → active-development (if more work needed)
   - active-development → backlog (if deprioritized)

### Weekly Review (Fridays)

1. **Review all critical-security prompts:**
   - Are deadlines still accurate?
   - Have new issues been discovered?
   - Should priorities change?

2. **Update active-development:**
   - Move stale items to backlog
   - Promote high-priority backlog items

3. **Check milestone alignment:**
   - Ensure prompts match GitHub milestones
   - Update issue references

## Best Practices

### Writing Effective Prompts

1. **Be Specific:** Don't say "fix bugs" - list exact files and line numbers
2. **Provide Examples:** Include code patterns for fixes
3. **Reference Previous Work:** Link to similar fixes in other projects
4. **Estimate Realistically:** Break down time by subtask
5. **Define Success:** Clear, measurable completion criteria

### Using Prompts in Sessions

1. **Read Fully First:** Understand the entire scope before starting
2. **Start Context:** `my-context start "session-name"`
3. **Follow Workflow:** Use the recommended step-by-step approach
4. **Track Progress:** Use todo lists within the session
5. **Export Context:** Save session notes at the end

### Common Patterns

**Security Fixes:**
- Always write tests first
- Use language-specific scanners
- Reference security best practices
- Document threat model

**Feature Development:**
- Start with failing tests (TDD)
- Reference existing patterns in codebase
- Consider edge cases early
- Plan for error handling

**Refactoring:**
- Establish baseline tests first
- Make small, verifiable changes
- Run tests after each change
- Document architectural decisions

## Integration with Other Tools

### my-context

```bash
# Start session with prompt name
my-context start "session-2026-01-03-my-grid-security"

# Track prompt being used
my-context file ~/projects/project-conductor/session-prompts/critical-security/my-grid.md
my-context note "Using session prompt: my-grid critical security fixes"

# Export at end
my-context export session-2026-01-03-my-grid-security > \
  ~/work/context-exports/2026-01/03-my-grid.md
```

### claude-workflow

Each prompt includes claude-workflow integration:

```bash
# After fixes, run review
./scripts/code-review.sh

# Verify no new issues
./scripts/code-review.sh --agents security-auditor
```

### GitHub Milestones

Prompts directly link to milestones:

```bash
# Check milestone progress
gh api repos/jcaldwell-labs/my-grid/milestones/2 | \
  jq '{open_issues, closed_issues, due_on}'

# Update after session
gh issue close 66 67 68 --repo jcaldwell-labs/my-grid
```

## Future Enhancements

### Planned Features

1. **Auto-generation:** Create prompts from deep-review reports
2. **Session launcher:** Script to auto-navigate and paste prompt
3. **Progress tracking:** Visual milestone completion in dashboard
4. **Template library:** Reusable prompt sections for common tasks
5. **Version history:** Track how prompts evolve over time

### Ideas Under Consideration

- AI-assisted prompt updates based on session outcomes
- Integration with project health scores
- Automatic priority adjustment based on staleness
- Cross-project pattern library
- Prompt quality metrics

## FAQ

**Q: Should I modify the prompt during a session?**
A: Yes! If you discover new issues or better approaches, update the prompt file for next time.

**Q: What if the prompt is out of date?**
A: Review reports and GitHub issues first, then update the prompt before starting.

**Q: Can I create prompts for non-security work?**
A: Absolutely! Use active-development/ for features and backlog/ for ideas.

**Q: How detailed should prompts be?**
A: Critical prompts: very detailed. Active work: moderate. Backlog: brief overview.

**Q: Should prompts include code?**
A: Yes for patterns and examples. No for complete implementations.

## Contributing

When you create a great prompt:

1. **Test it:** Use it in a real session first
2. **Document results:** Note what worked/didn't work
3. **Share patterns:** Extract reusable sections
4. **Update INDEX:** Keep the master list current

## Related Documentation

- **Project Conductor:** `~/projects/project-conductor/CLAUDE.md`
- **Deep Review System:** `~/projects/project-conductor/docs/DEEP-REVIEW-SETUP.md`
- **Health Scoring:** `~/projects/project-conductor/scripts/health-check.sh`
- **Dashboard:** `~/projects/project-conductor/scripts/dashboard.sh`

---

**Last Updated:** 2026-01-03
**Maintainer:** jcaldwell-labs
**Version:** 1.0.0
