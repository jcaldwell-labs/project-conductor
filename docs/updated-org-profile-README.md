# JCaldwell Labs

> Experimental developer tools, terminal applications, and context-aware development utilities

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

## Mission

Building practical tools that enhance developer productivity and explore the intersection of terminal UIs, context-aware development, and AI-assisted workflows. We focus on:

- **Terminal-first experiences** - Rich, interactive applications that leverage modern terminal capabilities
- **Context awareness** - Tools that understand and adapt to development workflows
- **Developer productivity** - Utilities that streamline common tasks and reduce friction
- **Experimental prototypes** - Exploring new ideas at the intersection of classic computing and modern AI

## Projects

### Developer Tools & Utilities

| Repository | Description | Status |
|------------|-------------|--------|
| [my-context](https://github.com/jcaldwell-labs/my-context) | Context management and agent journaling for AI-assisted development workflows | ![Active](https://img.shields.io/badge/status-active-success) |
| [capability-catalog](https://github.com/jcaldwell-labs/capability-catalog) | Schema framework for documenting and discovering agent capabilities | ![Active](https://img.shields.io/badge/status-active-success) |
| [fintrack](https://github.com/jcaldwell-labs/fintrack) | Financial tracking and analysis tool | ![Active](https://img.shields.io/badge/status-active-success) |

### Terminal Applications

| Repository | Description | Status |
|------------|-------------|--------|
| [my-grid](https://github.com/jcaldwell-labs/my-grid) | Vim-inspired terminal grid editor with visual selection, registers, and PTY zones | ![Active](https://img.shields.io/badge/status-active-success) |
| [boxes-live](https://github.com/jcaldwell-labs/boxes-live) | Interactive terminal canvas with pan and zoom - like Miro for the terminal | ![Active](https://img.shields.io/badge/status-active-success) |
| [terminal-stars](https://github.com/jcaldwell-labs/terminal-stars) | Starfield visualization with frame buffering and motion effects | ![Active](https://img.shields.io/badge/status-active-success) |
| [smartterm-prototype](https://github.com/jcaldwell-labs/smartterm-prototype) | Claude Code-inspired terminal UI with scrolling output, context awareness, and status bar | ![Prototype](https://img.shields.io/badge/status-prototype-yellow) |

### Games & Interactive Experiences

| Repository | Description | Status |
|------------|-------------|--------|
| [tario](https://github.com/jcaldwell-labs/tario) | ASCII side-scrolling platformer game in C using ANSI escape codes | ![Active](https://img.shields.io/badge/status-active-success) |
| [adventure-engine-v2](https://github.com/jcaldwell-labs/adventure-engine-v2) | Text-based adventure game engine built in C with smart terminal UI | ![Active](https://img.shields.io/badge/status-active-success) |
| [atari-style](https://github.com/jcaldwell-labs/atari-style) | Terminal-based interactive demos with shader effects, Lissajous curves, and retro aesthetics | ![Active](https://img.shields.io/badge/status-active-success) |

### Organization & Infrastructure

| Repository | Description | Status |
|------------|-------------|--------|
| [project-conductor](https://github.com/jcaldwell-labs/project-conductor) | Orchestration system for health monitoring and autonomous project advancement | ![Active](https://img.shields.io/badge/status-active-success) |
| [.github](https://github.com/jcaldwell-labs/.github) | Organization profile and community health files | ![Active](https://img.shields.io/badge/status-active-success) |

### Legend

- ![Active](https://img.shields.io/badge/status-active-success) **Active** - Under active development or maintenance
- ![Production](https://img.shields.io/badge/status-production-blue) **Production** - Stable and production-ready
- ![Prototype](https://img.shields.io/badge/status-prototype-yellow) **Prototype** - Experimental, proof-of-concept stage

## Technology Stack

Projects across the organization use a variety of languages and tools:

- **C** - Low-level systems programming, terminal applications, games
- **Go** - CLI tools, utilities, performance-critical applications
- **Python** - Scripting, shader effects, rapid prototyping
- **Haskell** - Terminal UI applications (my-grid uses Brick)
- **Shell** - Build scripts, automation, environment setup

Common patterns:
- ANSI escape codes for terminal graphics and control
- Frame buffering for smooth animations
- Context-aware tooling and AI integration
- Cross-platform compatibility (Linux, macOS, BSD)

## Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding features, improving documentation, or sharing ideas, your help is appreciated.

### Getting Started

1. **Choose a project** - Browse the repositories above and find one that interests you
2. **Read the docs** - Check the project's README and our [CONTRIBUTING.md](CONTRIBUTING.md) guide
3. **Start small** - Look for issues tagged `good-first-issue` or `help-wanted`
4. **Join the discussion** - Ask questions in [Discussions](https://github.com/orgs/jcaldwell-labs/discussions)

### Ways to Contribute

- Report bugs - Help us identify and fix issues
- Suggest features - Share ideas for improvements
- Improve documentation - Make our docs clearer and more comprehensive
- Test and provide feedback - Try out prototypes and share your experience
- Submit code - Fix bugs or implement new features
- Design and UX - Improve terminal UI/UX patterns
- Share your use case - Tell us how you're using our tools

### Quick Links

- [Contributing Guidelines](CONTRIBUTING.md) - Development workflow, code standards, testing
- [Code of Conduct](CODE_OF_CONDUCT.md) - Our commitment to an inclusive community
- [Security Policy](SECURITY.md) - How to report security vulnerabilities

### Good First Issues

New to the project? Look for these labels across repositories:
- `good-first-issue` - Well-defined, beginner-friendly tasks
- `help-wanted` - Issues where we'd appreciate community help
- `documentation` - Docs improvements that don't require deep codebase knowledge

## Project Organization

### Repository Naming

- **Tools/Libraries**: Descriptive names (`my-context`, `fintrack`, `capability-catalog`)
- **Games**: Short, memorable names (`tario`, `adventure-engine-v2`)
- **Prototypes**: Descriptive with `-prototype` suffix or concept names

### Labels & Topics

Repositories use consistent topics for discoverability:
- `terminal`, `cli`, `tui` - Terminal/command-line applications
- `game`, `interactive` - Games and interactive experiences
- `developer-tools`, `productivity` - Development utilities
- `c`, `go`, `python`, `haskell`, `shell` - Primary language
- `experimental`, `prototype` - Development stage

### Sprint Organization

Most repositories use sprint labels for issue planning:
- `sprint-001` through `sprint-004` - Planned work cycles
- `backlog` - Future work items

## Learn More

### Documentation

- Each repository has detailed README with setup and usage instructions
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development practices
- Check individual repos for architecture docs and design decisions

### Community

- [GitHub Discussions](https://github.com/orgs/jcaldwell-labs/discussions) - Questions, ideas, announcements
- [Issues](https://github.com/jcaldwell-labs) - Bug reports and feature requests (per repository)

### Related Projects & Inspiration

- **Terminal Graphics**: VT100/ANSI escape sequences, ncurses, termbox
- **Context-Aware Dev**: Claude Code, GitHub Copilot, Cursor
- **Classic Games**: Atari 2600, ASCII games, roguelikes
- **Developer Tools**: fzf, ripgrep, tmux, vim

## Contact

- **Organization**: [@jcaldwell-labs](https://github.com/jcaldwell-labs)
- **Maintainer**: [@jcaldwell1066](https://github.com/jcaldwell1066)

---

<div align="center">

**Built with care by the JCaldwell Labs community**

[Projects](#projects) | [Contributing](#contributing) | [Community](https://github.com/orgs/jcaldwell-labs/discussions)

</div>
