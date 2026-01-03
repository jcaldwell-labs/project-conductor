# Adventure Engine v2: Integrate claude-workflow + Complete Security Fixes

## Mission
Complete the remaining 6 critical memory safety issues in adventure-engine-v2 #16, and integrate claude-workflow agents directly into the project for ongoing code quality.

## Context from Previous Work

**What We've Learned:**
1. Built deep-review.sh in project-conductor that orchestrates multiple claude-workflow agents
2. Successfully fixed 2/3 critical security issues (buffer overflow #14, path traversal #15)
3. Created upstream contribution proposal: https://github.com/CloudAI-X/claude-workflow/issues/2
4. Demonstrated multi-agent workflow pattern with code-reviewer + security-auditor

**Reference Implementation:**
- Deep-review orchestration: `~/projects/project-conductor/scripts/deep-review.sh`
- Session notes: `~/work/context-exports/2026-01/weekend-2026-01-03-detailed.md`
- Security fixes: commits 96787a7, 5735b8b in adventure-engine-v2

## Primary Objectives

### 1. Complete Security Fixes (Issue #16)
**Deadline: Friday 2026-01-10** (4 days remaining)

Fix these 6 remaining critical issues:

```bash
cd ~/projects/adventure-engine-v2
gh issue view 16
```

**Critical Issues:**
- [ ] Unvalidated buffer reads with sscanf (session.c)
- [ ] Race conditions in binary registry files (session.c:452-513)
- [ ] Unchecked fread() causing memory corruption
- [ ] Null termination issues with strncpy (world_loader.c)
- [ ] Format string vulnerability (world_loader.c:128-130)
- [ ] Integer overflow in player count validation

**Testing Requirements:**
- Build with AddressSanitizer: `CFLAGS="-fsanitize=address,undefined -g" make`
- Add test cases for each fix (following pattern from #14, #15)
- Run static analysis: `scan-build make` (if available)
- Valgrind check: `valgrind --leak-check=full ./adventure`

### 2. Integrate claude-workflow into Project
**Goal:** Make code quality automation a first-class citizen

**Actions:**
1. **Add claude-workflow as project dependency**
   ```bash
   cd ~/projects/adventure-engine-v2
   mkdir -p .claude-workflow
   ```

2. **Create project-specific review script**
   - File: `scripts/code-review.sh`
   - Based on: `~/projects/project-conductor/scripts/deep-review.sh`
   - Customized for C memory safety focus
   - Agents: code-reviewer, security-auditor, debugger

3. **Add Makefile targets**
   ```makefile
   review:
       ./scripts/code-review.sh

   security-audit:
       ./scripts/code-review.sh --agents security-auditor
   ```

4. **Document in README.md**
   - Add "Code Quality" section
   - Explain how to run automated reviews
   - Link to claude-workflow documentation

### 3. Learn from Upstream Issue #2
Check if maintainer has responded:

```bash
gh issue view 2 --repo CloudAI-X/claude-workflow --comments
```

**If there's feedback:**
- Apply any suggestions to our integration
- Note patterns they recommend
- Consider contributing adventure-engine-v2 as example project

**If no response yet:**
- Proceed with integration based on our working pattern
- Document our approach for potential contribution

## Secondary Objectives (If Time Permits)

### 4. Set Up CI/CD Security Checks
Add GitHub Actions workflow:

```yaml
# .github/workflows/security.yml
name: Security Audit
on: [push, pull_request]
jobs:
  sanitizers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: make clean
      - run: CFLAGS="-fsanitize=address,undefined" make
      - run: make test
```

### 5. Document Security Journey
Create `docs/SECURITY.md`:
- Timeline of fixes
- Lessons learned from C memory safety
- Testing strategy
- Future considerations (Rust rewrite?)

## Success Criteria

**Must Have:**
- ✅ All 6 remaining security issues fixed
- ✅ New test cases passing
- ✅ AddressSanitizer clean build
- ✅ claude-workflow integrated (scripts/code-review.sh working)
- ✅ Issue #16 closed
- ✅ Milestone "Critical Security Fixes" completed

**Nice to Have:**
- ✅ CI/CD security checks added
- ✅ SECURITY.md documentation
- ✅ Valgrind clean
- ✅ Static analysis clean

## Key Files to Reference

**Previous Security Fixes:**
```bash
# Buffer overflow fix pattern
git show 96787a7

# Path traversal fix pattern
git show 5735b8b
```

**Deep-Review Implementation:**
```bash
cat ~/projects/project-conductor/scripts/deep-review.sh
cat ~/projects/project-conductor/docs/DEEP-REVIEW-SETUP.md
```

**Security Test Pattern:**
```bash
cat ~/projects/adventure-engine-v2/tests/test_path_traversal.c
```

**Review Reports:**
```bash
cat ~/projects/project-conductor/state/reviews/2026-01-03/adventure-engine-v2-security-auditor.md
```

## Workflow Recommendation

1. **Start** (5 min)
   - Create context: `my-context start "security-fixes-2026-01-03-adventure-engine-v2"`
   - Review issue #16 details
   - Check upstream issue #2 for feedback

2. **Fix Security Issues** (4-5 hours)
   - Work through 6 issues systematically
   - Add tests for each fix
   - Build with sanitizers after each change
   - Track progress in todo list

3. **Integrate claude-workflow** (1-2 hours)
   - Create scripts/code-review.sh
   - Test on current codebase
   - Add Makefile targets
   - Update README.md

4. **Validate** (30 min)
   - Run full test suite
   - Run code-review.sh
   - Check all sanitizers clean
   - Verify milestone completion

5. **Close Out** (15 min)
   - Close issue #16
   - Update milestone status
   - Export context
   - Commit and push

## Notes

- **Priority:** Security fixes > claude-workflow integration
- **Deadline:** Friday 2026-01-10 (get security fixes done this session!)
- **Pattern:** Follow the same meticulous approach from #14 and #15
- **Testing:** No fix is complete without a test case
- **Documentation:** Update comments in code to explain security-critical sections

## References

- Issue #16: https://github.com/jcaldwell-labs/adventure-engine-v2/issues/16
- Milestone: https://github.com/jcaldwell-labs/adventure-engine-v2/milestone/1
- Upstream: https://github.com/CloudAI-X/claude-workflow/issues/2
- Deep-review docs: ~/projects/project-conductor/docs/DEEP-REVIEW-SETUP.md

## Estimated Time

- Security fixes: 4-5 hours
- claude-workflow integration: 1-2 hours
- Validation & documentation: 1 hour
- **Total: 6-8 hours**
