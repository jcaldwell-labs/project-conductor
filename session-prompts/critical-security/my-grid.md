# my-grid: Security Fixes - Command Injection, Exception Handling, JSON Validation

## Mission
Fix 3 critical security and code quality issues in my-grid and integrate claude-workflow for ongoing Python code quality.

## Context from Previous Work

**What We've Learned:**
1. Built deep-review.sh in project-conductor that orchestrates claude-workflow agents
2. Successfully demonstrated security fix pattern in adventure-engine-v2 and Go projects
3. Established testing-first approach: no fix complete without test cases
4. Created upstream contribution proposal: https://github.com/CloudAI-X/claude-workflow/issues/2

**Reference Implementation:**
- Deep-review orchestration: `~/projects/project-conductor/scripts/deep-review.sh`
- Security fix patterns: `~/projects/adventure-engine-v2/` (path validation)
- Session notes: `~/work/context-exports/2026-01/weekend-2026-01-03-detailed.md`

## Primary Objectives

### 1. Fix Security & Quality Issues (Issues #66, #67, #68)
**Deadline: Friday 2026-01-10** (4 days remaining)

```bash
cd ~/projects/my-grid
gh issue view 66  # Command injection (shell=True)
gh issue view 67  # Bare except clauses
gh issue view 68  # JSON validation missing
```

#### Issue #66: Command Injection via shell=True
**Severity:** 🔴 CRITICAL

**Problem:**
- Using `subprocess.run(..., shell=True)` or `os.system()` with user input
- Allows arbitrary command execution
- Common in PTY/shell integration code

**Fix Strategy:**
1. Find all `subprocess` calls with `shell=True`
   ```bash
   grep -rn "shell=True" --include="*.py"
   grep -rn "os.system" --include="*.py"
   ```

2. Replace with safe alternatives:
   ```python
   # BEFORE (UNSAFE)
   subprocess.run(f"echo {user_input}", shell=True)

   # AFTER (SAFE)
   subprocess.run(["echo", user_input], shell=False)
   ```

3. For complex shell operations, use `shlex.quote()`:
   ```python
   import shlex
   cmd = f"complex {shlex.quote(user_input)} command"
   subprocess.run(cmd, shell=True)  # Now safe
   ```

4. Prefer direct Python operations:
   ```python
   # Instead of: os.system(f"mkdir {dirname}")
   # Use: os.makedirs(dirname, exist_ok=True)
   ```

**Test Cases:**
```python
# tests/test_security_command_injection.py
def test_shell_command_no_injection():
    """Test that malicious input is escaped"""
    malicious = "; rm -rf /"
    result = execute_command(malicious)
    # Should treat entire string as argument, not execute rm
    assert "rm" not in result.stdout

def test_subprocess_uses_list_form():
    """Verify all subprocess calls use list form"""
    # Static analysis test
    with open("my_grid/pty_manager.py") as f:
        content = f.read()
        assert "shell=True" not in content
```

#### Issue #67: Bare Except Clauses
**Severity:** 🟡 MEDIUM (Code Quality)

**Problem:**
- `except:` or `except Exception:` catches everything including KeyboardInterrupt
- Masks bugs and makes debugging hard
- Violates Python best practices

**Fix Strategy:**
1. Find all bare except clauses:
   ```bash
   grep -rn "except:" --include="*.py"
   grep -rn "except Exception:" --include="*.py"
   ```

2. Replace with specific exceptions:
   ```python
   # BEFORE (BAD)
   try:
       risky_operation()
   except:
       pass

   # AFTER (GOOD)
   try:
       risky_operation()
   except (OSError, ValueError) as e:
       logger.error(f"Operation failed: {e}")
       # Handle or re-raise
   ```

3. Categorize exceptions:
   - Expected errors: Handle specifically
   - Programming errors: Don't catch (AssertionError, TypeError, etc.)
   - System errors: Catch separately (KeyboardInterrupt, SystemExit)

**Test Cases:**
```python
# tests/test_exception_handling.py
def test_keyboard_interrupt_not_caught():
    """Verify Ctrl-C still works"""
    with pytest.raises(KeyboardInterrupt):
        trigger_keyboard_interrupt()

def test_specific_exceptions_logged():
    """Verify errors are logged with context"""
    with pytest.raises(ValueError):
        invalid_operation()
    # Check logs contain meaningful error
```

#### Issue #68: JSON Validation Missing
**Severity:** 🟡 MEDIUM (Security)

**Problem:**
- JSON data from files/network not validated before use
- Could cause crashes or unexpected behavior
- Potential for injection attacks via crafted JSON

**Fix Strategy:**
1. Find all JSON parsing:
   ```bash
   grep -rn "json.load" --include="*.py"
   grep -rn "json.loads" --include="*.py"
   ```

2. Add schema validation with `jsonschema`:
   ```python
   import jsonschema

   # Define schema
   LAYOUT_SCHEMA = {
       "type": "object",
       "properties": {
           "zones": {"type": "array"},
           "version": {"type": "string"}
       },
       "required": ["zones"]
   }

   # Validate before use
   def load_layout(path: str):
       with open(path) as f:
           data = json.load(f)
       jsonschema.validate(data, LAYOUT_SCHEMA)
       return data
   ```

3. Add error handling for malformed JSON:
   ```python
   try:
       data = json.load(f)
   except json.JSONDecodeError as e:
       logger.error(f"Invalid JSON in {path}: {e}")
       return default_config()
   ```

**Test Cases:**
```python
# tests/test_json_validation.py
def test_valid_json_accepted():
    """Valid layout JSON loads successfully"""
    data = load_layout("fixtures/valid_layout.json")
    assert "zones" in data

def test_invalid_schema_rejected():
    """JSON with wrong schema is rejected"""
    with pytest.raises(jsonschema.ValidationError):
        load_layout("fixtures/missing_zones.json")

def test_malformed_json_handled():
    """Malformed JSON doesn't crash"""
    with pytest.raises(json.JSONDecodeError):
        load_layout("fixtures/malformed.json")
```

### 2. Integrate claude-workflow
**Goal:** Make code quality automation a first-class citizen for Python projects

**Actions:**
1. **Create project-specific review script**
   ```bash
   mkdir -p scripts
   # Create scripts/code-review.sh based on project-conductor pattern
   ```

2. **Add to Makefile/justfile**
   ```makefile
   .PHONY: review security-audit lint

   review:
       ./scripts/code-review.sh

   security-audit:
       ./scripts/code-review.sh --agents security-auditor

   lint:
       ruff check .
       mypy my_grid/

   test-security:
       pytest tests/test_security*.py -v
   ```

3. **Set up Python security tools**
   ```bash
   # Install in dev dependencies
   pip install bandit safety ruff mypy

   # Run security scans
   bandit -r my_grid/
   safety check
   ```

### 3. Improve PTY Zone (Active Development)
**Context:** Issue #59 for pyte integration is ongoing

**If time permits:**
- Review PTY zone security after fixing command injection
- Ensure ANSI parsing doesn't introduce vulnerabilities
- Add fuzzing tests for terminal sequences

## Secondary Objectives (If Time Permits)

### 4. Set Up CI/CD Security Checks
Add GitHub Actions workflow:

```yaml
# .github/workflows/security.yml
name: Security & Quality
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install bandit safety ruff
      - run: bandit -r my_grid/
      - run: safety check
      - run: ruff check .

  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install -e ".[dev]"
      - run: pytest tests/ -v --cov=my_grid
      - run: pytest tests/test_security*.py -v
```

### 5. Document Security Journey
Create `docs/SECURITY.md`:
- Timeline of security fixes
- Python security best practices used
- Testing strategy
- Threat model for my-grid

## Success Criteria

**Must Have:**
- ✅ Issue #66 (command injection) fixed with tests
- ✅ Issue #67 (bare excepts) fixed
- ✅ Issue #68 (JSON validation) fixed with tests
- ✅ All security tests passing
- ✅ bandit clean (or documented exceptions)
- ✅ claude-workflow integrated (scripts/code-review.sh working)
- ✅ Issues #66, #67, #68 closed
- ✅ Milestone "Critical Security Fixes (my-grid)" completed

**Nice to Have:**
- ✅ CI/CD security checks added
- ✅ SECURITY.md documentation
- ✅ Type hints added to security-critical functions
- ✅ mypy checks passing

## Key Files to Reference

**Deep-Review Implementation:**
```bash
cat ~/projects/project-conductor/scripts/deep-review.sh
cat ~/projects/project-conductor/docs/DEEP-REVIEW-SETUP.md
```

**Review Reports:**
```bash
cat ~/projects/project-conductor/state/reviews/2026-01-03/my-grid-security-auditor.md
cat ~/projects/project-conductor/state/reviews/2026-01-03/my-grid-code-reviewer.md
```

**Python Security Tools:**
- bandit: https://github.com/PyCQA/bandit
- safety: https://pyup.io/safety/
- ruff: https://github.com/astral-sh/ruff
- jsonschema: https://python-jsonschema.readthedocs.io/

## Workflow Recommendation

1. **Start** (5 min)
   ```bash
   cd ~/projects/my-grid
   export MY_CONTEXT_HOME=db
   my-context start "security-fixes-2026-01-03-my-grid"
   gh issue view 66
   gh issue view 67
   gh issue view 68
   ```

2. **Fix Issue #66: Command Injection** (2-3 hours)
   - Find all `shell=True` usage: `grep -rn "shell=True" --include="*.py"`
   - Replace with safe subprocess patterns
   - Add test cases in `tests/test_security_command_injection.py`
   - Run: `pytest tests/test_security*.py -v`
   - Run: `bandit -r my_grid/`

3. **Fix Issue #67: Bare Excepts** (1 hour)
   - Find all bare excepts: `grep -rn "except:" --include="*.py"`
   - Replace with specific exception types
   - Ensure KeyboardInterrupt not caught
   - Test: `pytest -v` (verify Ctrl-C still works)

4. **Fix Issue #68: JSON Validation** (1-2 hours)
   - Add jsonschema dependency
   - Define schemas for layout files
   - Add validation to JSON loading functions
   - Add test cases in `tests/test_json_validation.py`
   - Run: `pytest tests/test_json*.py -v`

5. **Integrate claude-workflow** (1 hour)
   - Create `scripts/code-review.sh`
   - Test on current codebase
   - Add Makefile targets
   - Update README.md

6. **Validate** (30 min)
   ```bash
   pytest tests/ -v --cov=my_grid
   bandit -r my_grid/
   ruff check .
   mypy my_grid/
   ./scripts/code-review.sh
   ```

7. **Close Out** (15 min)
   - Close issues #66, #67, #68
   - Update milestone status
   - Export context
   - Commit and push

## Testing Checklist

```bash
# Security tests
pytest tests/test_security*.py -v

# Full test suite
pytest tests/ -v --cov=my_grid

# Security scanning
bandit -r my_grid/
safety check

# Linting
ruff check .
mypy my_grid/

# Manual verification
# 1. Run my-grid and verify PTY zone works
# 2. Try malicious input: "; rm -rf /"
# 3. Press Ctrl-C to verify interrupt works
```

## Notes

- **Priority:** Command injection (#66) > JSON validation (#68) > Bare excepts (#67)
- **Deadline:** Friday 2026-01-10 (get security fixes done this session!)
- **Pattern:** Write tests FIRST showing the vulnerability, then fix it
- **Testing:** Use pytest parametrize for multiple attack vectors
- **Documentation:** Add docstrings explaining security considerations

## Common Python Security Patterns

```python
# Safe subprocess usage
import subprocess
import shlex

# Method 1: List form (preferred)
subprocess.run(["command", arg1, arg2], check=True)

# Method 2: shlex.quote for complex cases
cmd = f"complex {shlex.quote(user_input)} command"
subprocess.run(cmd, shell=True, check=True)

# Safe file operations
import os
from pathlib import Path

# Validate paths
def is_safe_path(base: Path, path: Path) -> bool:
    try:
        resolved = (base / path).resolve()
        return resolved.is_relative_to(base)
    except ValueError:
        return False

# Specific exception handling
try:
    operation()
except FileNotFoundError:
    handle_missing_file()
except PermissionError:
    handle_permission_denied()
# Let other exceptions propagate

# JSON validation
import jsonschema

SCHEMA = {"type": "object", "required": ["field"]}

def load_config(path: str):
    with open(path) as f:
        data = json.load(f)
    jsonschema.validate(data, SCHEMA)
    return data
```

## References

- Issue #66: https://github.com/jcaldwell-labs/my-grid/issues/66
- Issue #67: https://github.com/jcaldwell-labs/my-grid/issues/67
- Issue #68: https://github.com/jcaldwell-labs/my-grid/issues/68
- Milestone: https://github.com/jcaldwell-labs/my-grid/milestone/2
- Upstream: https://github.com/CloudAI-X/claude-workflow/issues/2
- Review report: ~/projects/project-conductor/state/reviews/2026-01-03/my-grid-security-auditor.md

## Estimated Time

- Command injection fix: 2-3 hours
- Bare excepts fix: 1 hour
- JSON validation fix: 1-2 hours
- claude-workflow integration: 1 hour
- **Total: 5-7 hours**
