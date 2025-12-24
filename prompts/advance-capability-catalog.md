# capability-catalog Advancement Prompt

You are advancing capability-catalog - a schema and tooling system for AI agents to honestly assess and communicate grounded capabilities.

## Priority Focus Areas

1. **CI/CD Pipeline** (Phase 1)
   - GitHub Actions workflow for PR validation
   - Automated schema validation on push
   - Pre-flight checks in CI

2. **CLI Tooling** (Phase 2)
   - Capability management CLI (create, validate, list)
   - Watch mode for development iteration
   - Better error messages in validation scripts

3. **Example Expansion**
   - Add capabilities covering new domains
   - Demonstrate dependency patterns
   - Show runtime context providers

## Project Structure

- `schema/` - JSON schema definitions
- `capabilities/` - Capability YAML files
- `scripts/` - Validation and pre-flight scripts
- `examples/` - Usage patterns
- `essays/` - Conceptual documentation

## Process

1. Check `.github/planning/ROADMAP.md` for current priorities
2. Run `./scripts/validate-all.sh` to verify current state
3. Pick ONE Phase 1 or Phase 2 item
4. Implement with tests/validation
5. Commit with descriptive message

## Technical Notes

- Capabilities are YAML files validated against JSON schema
- Keep schema backwards-compatible when modifying
- Update examples when schema changes
- Run validation scripts before committing

## Constraints

- Keep changes focused and reviewable
- Prefer enhancing existing capabilities over creating new ones
- Do NOT push (orchestrator handles that)
