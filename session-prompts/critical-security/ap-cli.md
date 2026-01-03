# ap-cli: Security Fixes & Test Coverage - HTTP Client, Path Traversal, Testing

## Mission
Fix 3 critical issues in ap-cli (zero test coverage, HTTP security flaws, path traversal) and integrate claude-workflow for ongoing Go code quality.

## Context from Previous Work

**What We've Learned:**
1. Built deep-review.sh in project-conductor that orchestrates claude-workflow agents
2. Successfully demonstrated security fix pattern in my-context (Go) and adventure-engine-v2 (C)
3. Established testing-first approach: no fix complete without test cases
4. Created upstream contribution proposal: https://github.com/CloudAI-X/claude-workflow/issues/2

**Reference Implementation:**
- Deep-review orchestration: `~/projects/project-conductor/scripts/deep-review.sh`
- Go security patterns: `~/projects/my-context/` (path validation, testing)
- Session notes: `~/work/context-exports/2026-01/weekend-2026-01-03-detailed.md`

## Primary Objectives

### 1. Fix Critical Issues (Issues #1, #2, #3)
**Deadline: Friday 2026-01-10** (4 days remaining)

```bash
cd ~/projects/ap-cli
gh issue view 1  # Zero test coverage
gh issue view 2  # HTTP client security flaws
gh issue view 3  # Path traversal vulnerability
```

#### Issue #1: Zero Test Coverage
**Severity:** 🔴 CRITICAL (Foundation)

**Problem:**
- No tests means no confidence in code correctness
- Cannot safely refactor or fix bugs
- Security fixes cannot be validated

**Fix Strategy:**
1. **Set up test infrastructure**
   ```bash
   mkdir -p internal/{auth,api,config,storage}/
   # Add _test.go files for each package
   ```

2. **Create test helpers**
   ```go
   // internal/testing/helpers.go
   package testing

   import (
       "net/http"
       "net/http/httptest"
       "testing"
   )

   func NewTestServer(t *testing.T) *httptest.Server {
       handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
           // Mock API responses
       })
       return httptest.NewServer(handler)
   }
   ```

3. **Priority test areas:**
   - [ ] HTTP client (internal/api/)
   - [ ] Path handling (internal/storage/)
   - [ ] Authentication (internal/auth/)
   - [ ] Configuration (internal/config/)
   - [ ] CLI commands (cmd/)

4. **Target coverage:**
   - Critical code: >80%
   - Security-sensitive: >90%
   - Overall: >70%

**Test Structure:**
```go
// internal/api/client_test.go
package api

import "testing"

func TestClient_MakesHTTPSRequests(t *testing.T) {
    // Issue #2: Verify HTTPS enforcement
}

func TestClient_ValidatesSSL(t *testing.T) {
    // Issue #2: Verify certificate validation
}

// internal/storage/path_test.go
package storage

func TestPath_BlocksTraversal(t *testing.T) {
    // Issue #3: Verify path validation
}
```

#### Issue #2: HTTP Client Security Flaws
**Severity:** 🔴 CRITICAL

**Problem Areas:**
1. **No HTTPS enforcement** - HTTP URLs accepted
2. **SSL validation disabled** - `InsecureSkipVerify: true`
3. **No timeout** - Requests can hang forever
4. **No redirect limits** - Open to redirect attacks
5. **No header validation** - Potential injection

**Fix Strategy:**

**1. Enforce HTTPS:**
```go
func ValidateURL(rawURL string) (*url.URL, error) {
    u, err := url.Parse(rawURL)
    if err != nil {
        return nil, err
    }
    if u.Scheme != "https" {
        return nil, fmt.Errorf("only HTTPS URLs allowed, got: %s", u.Scheme)
    }
    return u, nil
}
```

**2. Secure HTTP client:**
```go
func NewSecureClient() *http.Client {
    return &http.Client{
        Timeout: 30 * time.Second,
        Transport: &http.Transport{
            TLSClientConfig: &tls.Config{
                MinVersion: tls.VersionTLS12,
                // InsecureSkipVerify: false (default)
            },
            MaxIdleConns:        100,
            IdleConnTimeout:     90 * time.Second,
            DisableCompression:  false,
        },
        CheckRedirect: func(req *http.Request, via []*http.Request) error {
            if len(via) >= 10 {
                return fmt.Errorf("too many redirects")
            }
            // Verify redirect URL is HTTPS
            if req.URL.Scheme != "https" {
                return fmt.Errorf("redirect to non-HTTPS URL blocked")
            }
            return nil
        },
    }
}
```

**3. Validate response headers:**
```go
func ValidateResponse(resp *http.Response) error {
    // Check content type
    ct := resp.Header.Get("Content-Type")
    if !strings.HasPrefix(ct, "application/json") {
        return fmt.Errorf("unexpected content type: %s", ct)
    }

    // Check content length
    if resp.ContentLength > maxResponseSize {
        return fmt.Errorf("response too large: %d bytes", resp.ContentLength)
    }

    return nil
}
```

**Test Cases:**
```go
func TestClient_RejectsHTTP(t *testing.T) {
    client := NewClient()
    err := client.SetBaseURL("http://api.example.com")
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "HTTPS")
}

func TestClient_ValidatesSSL(t *testing.T) {
    // Use test server with self-signed cert
    // Verify connection fails (not skips validation)
}

func TestClient_TimesOut(t *testing.T) {
    // Test server that delays response
    // Verify client times out appropriately
}

func TestClient_LimitsRedirects(t *testing.T) {
    // Test server with infinite redirects
    // Verify client stops after limit
}
```

#### Issue #3: Path Traversal Vulnerability
**Severity:** 🔴 CRITICAL

**Problem:**
- File operations accept unsanitized paths
- Could access files outside intended directory
- No validation on config/data file paths

**Fix Strategy:**

**1. Create path validation library:**
```go
// internal/storage/path.go
package storage

import (
    "errors"
    "path/filepath"
    "strings"
)

var (
    ErrPathTraversal = errors.New("path traversal attempt detected")
    ErrAbsolutePath  = errors.New("absolute paths not allowed")
)

// ValidateRelativePath ensures path is safe and relative
func ValidateRelativePath(base, userPath string) (string, error) {
    // Reject absolute paths
    if filepath.IsAbs(userPath) {
        return "", ErrAbsolutePath
    }

    // Reject path traversal attempts
    if strings.Contains(userPath, "..") {
        return "", ErrPathTraversal
    }

    // Clean and join
    cleaned := filepath.Clean(userPath)
    fullPath := filepath.Join(base, cleaned)

    // Verify result is within base directory
    absBase, err := filepath.Abs(base)
    if err != nil {
        return "", err
    }

    absPath, err := filepath.Abs(fullPath)
    if err != nil {
        return "", err
    }

    if !strings.HasPrefix(absPath, absBase) {
        return "", ErrPathTraversal
    }

    return fullPath, nil
}
```

**2. Apply to all file operations:**
```go
func (s *Storage) LoadConfig(filename string) error {
    safePath, err := ValidateRelativePath(s.baseDir, filename)
    if err != nil {
        return fmt.Errorf("invalid path: %w", err)
    }

    return s.loadFromPath(safePath)
}
```

**Test Cases:**
```go
func TestValidateRelativePath_BlocksTraversal(t *testing.T) {
    tests := []struct {
        name    string
        path    string
        wantErr error
    }{
        {"simple traversal", "../etc/passwd", ErrPathTraversal},
        {"deep traversal", "../../../../../../etc/passwd", ErrPathTraversal},
        {"absolute path", "/etc/passwd", ErrAbsolutePath},
        {"tricky relative", "foo/../../bar", ErrPathTraversal},
        {"valid relative", "configs/app.json", nil},
        {"valid nested", "data/users/profile.json", nil},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := ValidateRelativePath("/base", tt.path)
            if tt.wantErr != nil {
                assert.ErrorIs(t, err, tt.wantErr)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

### 2. Integrate claude-workflow
**Goal:** Make code quality automation first-class for Go CLI projects

**Actions:**
1. **Create project-specific review script**
   ```bash
   mkdir -p scripts
   # Create scripts/code-review.sh based on project-conductor pattern
   ```

2. **Add Makefile targets**
   ```makefile
   .PHONY: test coverage review security-audit

   test:
       go test -v ./...

   coverage:
       go test -coverprofile=coverage.out ./...
       go tool cover -html=coverage.out

   review:
       ./scripts/code-review.sh

   security-audit:
       gosec ./...
       ./scripts/code-review.sh --agents security-auditor

   lint:
       go vet ./...
       staticcheck ./...
   ```

3. **Document in README.md**
   - Add "Development" section
   - Explain testing approach
   - Document security practices

## Secondary Objectives (If Time Permits)

### 4. Set Up CI/CD
Add GitHub Actions:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
      - run: go test -v ./... -race -coverprofile=coverage.txt
      - run: go tool cover -func=coverage.txt

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
      - run: go install github.com/securego/gosec/v2/cmd/gosec@latest
      - run: gosec ./...
      - run: go vet ./...
```

### 5. Document Security Approach
Create `docs/SECURITY.md`:
- HTTP client security design
- Path validation strategy
- Testing approach
- Threat model

## Success Criteria

**Must Have:**
- ✅ Test coverage >70% overall, >80% for critical code
- ✅ Issue #1 (test coverage) resolved
- ✅ Issue #2 (HTTP security) fixed with tests
- ✅ Issue #3 (path traversal) fixed with tests
- ✅ All tests passing with race detector
- ✅ gosec clean (or exceptions documented)
- ✅ claude-workflow integrated
- ✅ Issues #1, #2, #3 closed
- ✅ Milestone completed

**Nice to Have:**
- ✅ CI/CD set up
- ✅ SECURITY.md documentation
- ✅ staticcheck clean
- ✅ Integration tests for CLI commands

## Key Files to Reference

**Deep-Review Implementation:**
```bash
cat ~/projects/project-conductor/scripts/deep-review.sh
```

**Go Security Patterns (my-context):**
```bash
# Path validation patterns
cat ~/projects/my-context/internal/core/context.go

# Testing patterns
ls ~/projects/my-context/internal/*/  # Find *_test.go files
```

**Review Report:**
```bash
cat ~/projects/project-conductor/state/reviews/2026-01-03/ap-cli-security-auditor.md
```

**Go Security Tools:**
- gosec: https://github.com/securego/gosec
- staticcheck: https://staticcheck.io/
- nancy (dependency scanner): https://github.com/sonatype-nexus-community/nancy

## Workflow Recommendation

1. **Start** (5 min)
   ```bash
   cd ~/projects/ap-cli
   export MY_CONTEXT_HOME=db
   my-context start "security-fixes-2026-01-03-ap-cli"
   gh issue view 1
   gh issue view 2
   gh issue view 3
   ```

2. **Set Up Test Infrastructure** (1 hour)
   - Create test files for each package
   - Set up test helpers (mock HTTP server, temp dirs)
   - Add basic smoke tests
   - Run: `go test ./...`

3. **Fix Issue #2: HTTP Client Security** (2-3 hours)
   - Create secure HTTP client
   - Add HTTPS enforcement
   - Add timeout and redirect limits
   - Write comprehensive tests
   - Run: `go test -v ./internal/api/`

4. **Fix Issue #3: Path Traversal** (1-2 hours)
   - Create path validation library
   - Apply to all file operations
   - Add table-driven tests for edge cases
   - Run: `go test -v ./internal/storage/`

5. **Increase Test Coverage** (2-3 hours)
   - Add tests for CLI commands
   - Add tests for auth flows
   - Add tests for config parsing
   - Target: >70% overall coverage
   - Run: `go test -coverprofile=coverage.out ./...`

6. **Integrate claude-workflow** (1 hour)
   - Create scripts/code-review.sh
   - Test on current codebase
   - Add Makefile targets
   - Update README.md

7. **Validate** (30 min)
   ```bash
   go test -v ./... -race
   gosec ./...
   go vet ./...
   go test -coverprofile=coverage.out ./...
   go tool cover -func=coverage.out
   ./scripts/code-review.sh
   ```

8. **Close Out** (15 min)
   - Close issues #1, #2, #3
   - Update milestone
   - Export context
   - Commit and push

## Testing Checklist

```bash
# Unit tests
go test -v ./...

# With race detector
go test -v ./... -race

# Coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
go tool cover -func=coverage.out | grep total

# Security scanning
gosec ./...

# Static analysis
go vet ./...
staticcheck ./...  # if installed

# Manual testing
go build ./cmd/ap-cli
./ap-cli --help
./ap-cli version
# Try with malicious paths: ./ap-cli config load ../../../etc/passwd
```

## Notes

- **Priority:** Test infrastructure (#1) → HTTP security (#2) → Path traversal (#3)
- **Deadline:** Friday 2026-01-10
- **Pattern:** TDD - write failing tests first, then implement fixes
- **Testing:** Use table-driven tests for security validation
- **Documentation:** Add godoc explaining security decisions

## Go Security Best Practices

```go
// Secure HTTP client template
client := &http.Client{
    Timeout: 30 * time.Second,
    Transport: &http.Transport{
        TLSClientConfig: &tls.Config{
            MinVersion: tls.VersionTLS12,
        },
    },
    CheckRedirect: limitRedirects,
}

// Path validation template
func SafeJoin(base, userPath string) (string, error) {
    if filepath.IsAbs(userPath) {
        return "", errors.New("absolute paths not allowed")
    }
    if strings.Contains(userPath, "..") {
        return "", errors.New("path traversal detected")
    }

    clean := filepath.Clean(userPath)
    result := filepath.Join(base, clean)

    // Verify result is under base
    absBase, _ := filepath.Abs(base)
    absResult, _ := filepath.Abs(result)

    if !strings.HasPrefix(absResult, absBase) {
        return "", errors.New("path outside base directory")
    }

    return result, nil
}

// Table-driven test template
func TestFunction(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    string
        wantErr bool
    }{
        // test cases...
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Function(tt.input)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.want, got)
            }
        })
    }
}
```

## References

- Issue #1: https://github.com/jcaldwell1066/ap-cli/issues/1
- Issue #2: https://github.com/jcaldwell1066/ap-cli/issues/2
- Issue #3: https://github.com/jcaldwell1066/ap-cli/issues/3
- Milestone: https://github.com/jcaldwell1066/ap-cli/milestone/1
- Upstream: https://github.com/CloudAI-X/claude-workflow/issues/2
- Review report: ~/projects/project-conductor/state/reviews/2026-01-03/ap-cli-security-auditor.md

## Estimated Time

- Test infrastructure: 1 hour
- HTTP client security: 2-3 hours
- Path traversal fix: 1-2 hours
- Test coverage to >70%: 2-3 hours
- claude-workflow integration: 1 hour
- **Total: 7-10 hours**
