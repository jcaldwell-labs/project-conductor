# Release Process for jcaldwell-labs

This document describes the standardized release process for all jcaldwell-labs projects.

## Release Philosophy

- **Cadence**: Ad-hoc releases tied to milestone completion
- **Versioning**: Independent semantic versioning per project
- **Pre-releases**: RC tags (`v*-rc*`) for major version changes only
- **Automation**: GitHub Actions create releases automatically on tag push

## Pre-release Checklist

Before creating a release tag, verify:

- [ ] All CI checks passing on main branch
- [ ] CHANGELOG.md updated (move "Unreleased" section to new version)
- [ ] Version bumped in relevant files (if applicable):
  - Go: version constants in main.go
  - Python: `__version__` in package
  - C: VERSION in Makefile or header
- [ ] For major releases: Consider creating RC first
- [ ] Critical security issues resolved
- [ ] README.md reflects current state

## Creating a Release

### Standard Release (Patch/Minor)

```bash
# 1. Ensure main is up to date
git checkout main
git pull origin main

# 2. Update CHANGELOG.md
# Move items from "Unreleased" to new version section
# Format: ## [X.Y.Z] - YYYY-MM-DD

# 3. Commit the changelog update
git add CHANGELOG.md
git commit -m "chore: prepare release vX.Y.Z"

# 4. Create and push the tag
git tag vX.Y.Z
git push origin main --tags

# 5. GitHub Actions will automatically:
#    - Build release artifacts
#    - Create GitHub Release with auto-generated notes
#    - Upload artifacts with SHA256 checksums
```

### Major Release (with RC)

For major version bumps (breaking changes), use release candidates:

```bash
# 1. Create release candidate
git tag v2.0.0-rc1
git push origin --tags

# 2. Test RC in isolation
#    - Verify on target systems
#    - Address any issues found

# 3. If issues found, fix and create rc2
git tag v2.0.0-rc2
git push origin --tags

# 4. When ready, create final release
git tag v2.0.0
git push origin main --tags
```

## CHANGELOG Format

Follow [Keep a Changelog](https://keepachangelog.com/):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes

## [1.2.0] - 2026-01-08

### Added
- Feature X
- Feature Y

### Fixed
- Bug Z
```

## Project-Specific Notes

### C Projects (cdev)
- Binary name varies by project
- Requires ncurses for most builds
- Release archive: `{project}-{version}-linux-amd64.tar.gz`

### Go Projects (godev)
- Multi-platform binaries (linux, windows, darwin)
- CGO disabled for portability
- Release includes: binary + SHA256 checksum per platform

### Python Projects (pythondev)
- Source archive only (git archive)
- Install via: `pip install .` from extracted archive
- No binary distribution (yet)

## Rollback Procedure

If a release has issues:

1. **Do NOT delete the tag** (breaks links)
2. Fix issues on main branch
3. Create patch release (e.g., v1.2.1)
4. Update release notes on problematic version noting the fix

## Milestone Naming Convention

- `vX.Y.Z` - Specific version milestone
- `Backlog` - Future items, not yet scheduled
- `Critical Security Fixes` - Security-focused, with due date

## Contact

For release questions, open an issue in [project-conductor](https://github.com/jcaldwell-labs/project-conductor).
