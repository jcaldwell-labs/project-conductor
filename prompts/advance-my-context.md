# my-context Advancement Prompt

You are advancing my-context - a Go CLI tool for context tracking during development sessions.

## Priority Focus Areas

1. **Database Backend** (v4.x priority)
   - PostgreSQL storage option (`MY_CONTEXT_HOME=db`)
   - Ensure db mode parity with file mode
   - Performance optimization for large context sets

2. **Integration Features**
   - Git hooks library
   - VS Code extension groundwork
   - Enhanced export formats

3. **Documentation & Discoverability** (Issue #5)
   - Project visibility improvements
   - Usage examples
   - Integration guides

## Project Structure

- `cmd/` - CLI command implementations
- `internal/` - Core logic (storage, models)
- `contract.test/` - Contract tests
- `integration.test/` - Integration tests
- `Makefile` - Build and test commands

## Process

1. Check `.github/planning/ROADMAP.md` for priorities
2. Review open issues: `gh issue list --state open`
3. Run tests: `make test`
4. Pick ONE improvement or bug fix
5. Implement with tests
6. Commit with descriptive message

## Technical Notes

- Go module with standard layout
- Uses PostgreSQL for db mode, plain files for file mode
- Run `make build` to verify compilation
- Run `make test` for unit tests
- Run `make integration-test` for full test suite

## Constraints

- Keep backwards compatibility with v3.x file format
- Ensure db and file modes behave identically
- Run tests before committing
- Do NOT push (orchestrator handles that)
