# Project Conductor

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> Orchestration system for keeping jcaldwell-labs projects moving forward.

## Overview

Project Conductor monitors the health of all jcaldwell-labs repositories and automatically advances stale projects using Claude Code sessions.

## Quick Start

```bash
# Check project health
./scripts/health-check.sh

# Launch dashboard
./scripts/dashboard.sh

# Advance stalest project
./scripts/advance-project.sh --stale
```

## Dashboard Preview

```
╔════════════════════════════════════════════════════════════════════╗
║ jcaldwell-labs Project Conductor                                   ║
║ 2025-12-23 17:30:00                                               ║
╠════════════════════════════════════════════════════════════════════╣
║ 1. 🔴 fintrack         40%  14d ago  5 issues                     ║
║ 2. 🟡 smartterm        55%  12d ago  3 issues                     ║
║ 3. 🟡 tario            60%  10d ago  2 issues                     ║
║ 4. 🟡 terminal-stars   65%   7d ago  4 issues                     ║
║ 5. 🟡 boxes-live       70%   5d ago  8 issues                     ║
║ 6. 🟢 adventure-v2     80%   4d ago  6 issues                     ║
║ 7. 🟢 my-context       85%   3d ago  2 issues                     ║
║ 8. 🟢 capability-cat   88%   1d ago  1 issues                     ║
║ 9. 🟢 atari-style      90%   1d ago  3 issues                     ║
║10. 🟢 my-grid          95%   2h ago  5 issues                     ║
╠════════════════════════════════════════════════════════════════════╣
║ Commands:                                                          ║
║   [r]efresh  [a]dvance stale  [A]dvance all  [q]uit               ║
║   [1-9] advance specific  [d]etail <num>  [p]ush all              ║
╚════════════════════════════════════════════════════════════════════╝
```

## Features

- **Health Monitoring**: Track commit recency, open issues, test status
- **Autonomous Advancement**: Launch Claude Code to work on projects
- **Priority Weighting**: High-priority projects flagged sooner
- **Custom Prompts**: Per-project advancement instructions
- **Session Logging**: Track what Claude did in each session

## Related Projects

Part of the [jcaldwell-labs](https://github.com/jcaldwell-labs) organization.

## License

MIT
