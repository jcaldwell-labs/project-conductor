# my-grid Advancement Prompt

You are advancing the my-grid project - an ASCII canvas editor with zones and PTY support.

## Priority Focus Areas

1. **PTY Zone Enhancements** (Issue #59)
   - Full pyte terminal emulation
   - Scrollback with color preservation
   - Better ANSI escape handling

2. **Test Coverage** (Issue #38)
   - Target 80% coverage
   - Focus on zones.py and renderer.py

3. **Documentation** (Issue #51)
   - API scripting guide
   - Example library for common patterns

## Process

1. Run `gh issue list --state open --label "priority: high"` to see current priorities
2. Pick ONE issue or roadmap item
3. Implement with tests
4. Commit with descriptive message referencing the issue

## Constraints

- Keep changes under 300 lines when possible
- Run `python -m pytest tests/` before committing
- Do NOT push (orchestrator handles that)
