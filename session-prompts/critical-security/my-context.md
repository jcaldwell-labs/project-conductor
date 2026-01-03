# my-context: Security Fixes - Command Injection & Path Traversal

## Mission
Fix 2 critical security vulnerabilities in my-context and integrate claude-workflow for ongoing Go code quality.

## Context from Previous Work

**What We've Learned:**
1. Built deep-review.sh in project-conductor that orchestrates claude-workflow agents
2. Successfully demonstrated security fix pattern in adventure-engine-v2 (commits 96787a7, 5735b8b)
3. Established testing-first approach: no fix complete without test cases
4. Created upstream contribution proposal: https://github.com/CloudAI-X/claude-workflow/issues/2

**Reference Implementation:**
- Deep-review orchestration: `~/projects/project-conductor/scripts/deep-review.sh`
- Security fix patterns: `~/projects/adventure-engine-v2/` (commits for #14, #15)
- Session notes: `~/work/context-exports/2026-01/weekend-2026-01-03-detailed.md`

## Primary Objectives

### 1. Fix Security Issues (Issues #7, #8)
**Deadline: Friday 2026-01-10** (4 days remaining)

```bash
cd ~/projects/my-context
gh issue view 7  # Command injection in file monitor
gh issue view 8  # Path traversal in delete operations
```

#### Issue #7: Command Injection in File Monitor
**File:** `internal/watch/monitor.go`

**Problem:**
- File monitoring likely uses shell commands with unsanitized paths
- User-controlled file paths could inject shell commands

**Fix Strategy:**
1. Find all `exec.Command()` calls with `sh -c` or shell interpolation
2. Replace with direct Go file operations or properly escaped commands
3. Use `filepath.Clean()` and `filepath.Join()` instead of string concatenation
4. Validate all paths before passing to system commands

**Test Cases:**
```go
// test_file_monitor_security.go
func TestFileMonitor_NoCommandInjection(t *testing.T) {
    maliciousPath := "file.txt; rm -rf /"
    // Should sanitize or reject
}

func TestFileMonitor_PathTraversalAttempt(t *testing.T) {
    maliciousPath := "../../etc/passwd"
    // Should reject
}
```

#### Issue #8: Path Traversal in Delete Operations
**File:** `internal/core/context.go`

**Problem:**
- Delete operations may not validate file paths
- Could delete files outside intended context directory

**Fix Strategy:**
1. Create `isValidContextPath()` helper function
2. Validate all paths are within context directory
3. Use `filepath.Abs()` and check prefix match
4. Reject paths with `..`, absolute paths, or symlinks

**Test Cases:**
```go
// test_delete_security.go
func TestDelete_PathTraversalBlocked(t *testing.T) {
    ctx := NewContext("test")
    err := ctx.DeleteFile("../../sensitive.txt")
    assert.Error(t, err)
}

func TestDelete_AbsolutePathBlocked(t *testing.T) {
    ctx := NewContext("test")
    err := ctx.DeleteFile("/etc/passwd")
    assert.Error(t, err)
}
```

### 2. Integrate claude-workflow
**Goal:** Make code quality automation a first-class citizen for Go projects

**Actions:**
1. **Create project-specific review script**
   ```bash
   mkdir -p scripts
   # Create scripts/code-review.sh based on project-conductor pattern
   ```

2. **Add Makefile targets**
   ```makefile
   .PHONY: review security-audit

   review:
       ./scripts/code-review.sh

   security-audit:
       ./scripts/code-review.sh --agents security-auditor

   test-security:
       go test -v ./internal/... -run Security
   ```

3. **Document in README.md**
   - Add "Code Quality" section
   - Explain automated review workflow
   - Link to security testing approach

### 3. Improve Test Coverage (Issue #9)
**Current:** Low test coverage across internal packages
**Target:** >80% coverage for security-critical code

**Priority Files:**
- `internal/watch/monitor.go`
- `internal/core/context.go`
- `internal/storage/`

**Add Tests For:**
- Path validation edge cases
- Error handling (permission denied, disk full, etc.)
- Concurrent operations
- Database migration scenarios

## Secondary Objectives (If Time Permits)

### 4. Set Up CI/CD Security Checks
Add GitHub Actions workflow:

```yaml
# .github/workflows/security.yml
name: Security Audit
on: [push, pull_request]
jobs:
  gosec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
      - run: go install github.com/securego/gosec/v2/cmd/gosec@latest
      - run: gosec ./...

  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
      - run: go test -v ./... -race -coverprofile=coverage.txt
      - run: go tool cover -func=coverage.txt
```

### 5. Document Security Journey
Create `docs/SECURITY.md`:
- Timeline of security fixes
- Go security best practices used
- Testing strategy
- Threat model for my-context

## Success Criteria

**Must Have:**
- ✅ Issue #7 (command injection) fixed with tests
- ✅ Issue #8 (path traversal) fixed with tests
- ✅ All security tests passing
- ✅ gosec clean (or documented exceptions)
- ✅ claude-workflow integrated (scripts/code-review.sh working)
- ✅ Issues #7, #8 closed
- ✅ Milestone "Critical Security Fixes" completed

**Nice to Have:**
- ✅ Issue #9 (test coverage) improved to >80%
- ✅ CI/CD security checks added
- ✅ SECURITY.md documentation
- ✅ Race detector clean

## Key Files to Reference

**Deep-Review Implementation:**
```bash
cat ~/projects/project-conductor/scripts/deep-review.sh
cat ~/projects/project-conductor/docs/DEEP-REVIEW-SETUP.md
```

**Security Fix Patterns (from adventure-engine-v2):**
```bash
# Path validation pattern
git --git-dir=~/projects/adventure-engine-v2/.git show 5735b8b

# Testing pattern
cat ~/projects/adventure-engine-v2/tests/test_path_traversal.c
```

**Review Reports:**
```bash
cat ~/projects/project-conductor/state/reviews/2026-01-03/my-context-security-auditor.md
```

**Go Security Tools:**
- gosec: https://github.com/securego/gosec
- staticcheck: https://staticcheck.io/
- Go vet: `go vet ./...`

## Workflow Recommendation

1. **Start** (5 min)
   ```bash
   cd ~/projects/my-context
   export MY_CONTEXT_HOME=db
   my-context start "security-fixes-2026-01-03-my-context"
   gh issue view 7
   gh issue view 8
   ```

2. **Fix Issue #7: Command Injection** (1-2 hours)
   - Read `internal/watch/monitor.go`
   - Identify vulnerable `exec.Command()` calls
   - Replace with safe Go file operations
   - Add test cases in `internal/watch/monitor_security_test.go`
   - Run: `go test -v ./internal/watch/`

3. **Fix Issue #8: Path Traversal** (1-2 hours)
   - Read `internal/core/context.go`
   - Create `isValidContextPath()` helper
   - Apply validation to delete operations
   - Add test cases in `internal/core/context_security_test.go`
   - Run: `go test -v ./internal/core/`

4. **Integrate claude-workflow** (1 hour)
   - Create `scripts/code-review.sh`
   - Test on current codebase
   - Add Makefile targets
   - Update README.md

5. **Improve Test Coverage** (1-2 hours)
   - Run: `go test -coverprofile=coverage.out ./...`
   - View: `go tool cover -html=coverage.out`
   - Add tests for uncovered critical paths
   - Focus on security-critical code

6. **Validate** (30 min)
   ```bash
   go test -v ./... -race
   gosec ./...
   ./scripts/code-review.sh
   go test -coverprofile=coverage.out ./...
   go tool cover -func=coverage.out
   ```

7. **Close Out** (15 min)
   - Close issues #7, #8
   - Update milestone status
   - Export context
   - Commit and push

## Testing Checklist

```bash
# Security tests
go test -v ./internal/watch/ -run Security
go test -v ./internal/core/ -run Security

# Full test suite with race detector
go test -v ./... -race

# Security scanning
gosec ./...

# Code coverage
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total

# Static analysis
go vet ./...
staticcheck ./...  # if installed
```

## Notes

- **Priority:** Security fixes (#7, #8) > Test coverage (#9) > claude-workflow integration
- **Deadline:** Friday 2026-01-10 (get security fixes done this session!)
- **Pattern:** Write tests FIRST, then fix the vulnerability
- **Testing:** Use table-driven tests for multiple attack vectors
- **Documentation:** Add godoc comments explaining security considerations

## References

- Issue #7: https://github.com/jcaldwell-labs/my-context/issues/7
- Issue #8: https://github.com/jcaldwell-labs/my-context/issues/8
- Issue #9: https://github.com/jcaldwell-labs/my-context/issues/9
- Milestone: https://github.com/jcaldwell-labs/my-context/milestone/1
- Upstream: https://github.com/CloudAI-X/claude-workflow/issues/2
- Review report: ~/projects/project-conductor/state/reviews/2026-01-03/my-context-security-auditor.md

## Estimated Time

- Security fixes: 3-4 hours
- claude-workflow integration: 1 hour
- Test coverage improvements: 1-2 hours
- **Total: 5-7 hours**
