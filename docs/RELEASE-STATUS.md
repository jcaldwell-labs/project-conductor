# jcaldwell-labs Release Status

*Last updated: 2026-01-08*

## Active Projects

| Project | Language | Owner | Current Version | Open Issues | CI Status |
|---------|----------|-------|-----------------|-------------|-----------|
| [my-context](https://github.com/jcaldwell-labs/my-context) | Go | godev | v2.3.0 | 2 | [\![CI](https://github.com/jcaldwell-labs/my-context/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/my-context/actions) |
| [boxes-live](https://github.com/jcaldwell-labs/boxes-live) | C | cdev | v1.1.0 | 42+ | [\![CI](https://github.com/jcaldwell-labs/boxes-live/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/boxes-live/actions) |
| [my-grid](https://github.com/jcaldwell-labs/my-grid) | Python | pythondev | - | 8 | [\![CI](https://github.com/jcaldwell-labs/my-grid/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/my-grid/actions) |
| [atari-style](https://github.com/jcaldwell-labs/atari-style) | Python | pythondev | v0.1.0 | 69 | [\![CI](https://github.com/jcaldwell-labs/atari-style/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/atari-style/actions) |
| [smartterm-prototype](https://github.com/jcaldwell-labs/smartterm-prototype) | C | cdev | v1.0.0 | 1 | [\![CI](https://github.com/jcaldwell-labs/smartterm-prototype/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/smartterm-prototype/actions) |
| [fintrack](https://github.com/jcaldwell-labs/fintrack) | Go | godev | - | 20 | - |
| [adventure-engine-v2](https://github.com/jcaldwell-labs/adventure-engine-v2) | C | cdev | - | 5 | - |
| [terminal-stars](https://github.com/jcaldwell-labs/terminal-stars) | C | cdev | - | 5 | [\![CI](https://github.com/jcaldwell-labs/terminal-stars/actions/workflows/ci.yml/badge.svg)](https://github.com/jcaldwell-labs/terminal-stars/actions) |
| [tario](https://github.com/jcaldwell-labs/tario) | C | cdev | - | 1 | - |
| [capability-catalog](https://github.com/jcaldwell-labs/capability-catalog) | Python | pythondev | - | 2 | - |

## WSL User Assignments

| User | Role | Languages | Projects |
|------|------|-----------|----------|
| **cdev** | C Development | C, Haskell | smartterm-prototype, boxes-live, adventure-engine-v2, terminal-stars, tario |
| **godev** | Go Development | Go | my-context, fintrack |
| **pythondev** | Python Development | Python | my-grid, atari-style, capability-catalog |
| **be-dev-agent** | Orchestration | Java, Shell | project-conductor, .github |

## Upcoming Milestones

| Project | Milestone | Due Date | Status |
|---------|-----------|----------|--------|
| my-grid | Sprint 005: AI Integration | TBD | In Progress |
| my-context | Critical Security Fixes | 2026-01-10 | Closed |
| adventure-engine-v2 | Critical Security Fixes | 2026-01-10 | Closed |

## Recent Releases

| Date | Project | Version | Highlights |
|------|---------|---------|------------|
| 2025-12-xx | my-context | v2.3.0 | Context home visibility |
| 2025-xx-xx | boxes-live | v1.1.0 | Campaign orchestration |
| 2025-xx-xx | smartterm-prototype | v1.0.0 | Production-ready library |

## Quick Commands

```bash
# Check open issues across all repos
for repo in my-context boxes-live my-grid atari-style smartterm-prototype fintrack; do
  echo "$repo: $(gh issue list -R jcaldwell-labs/$repo --state open --json number | jq length)"
done

# Create a release (from appropriate WSL user)
git tag vX.Y.Z && git push origin --tags
```

---

*Maintained by: project-conductor*
*Update frequency: On each release*
