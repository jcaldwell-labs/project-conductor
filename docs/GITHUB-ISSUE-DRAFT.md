# GitHub Issue Draft for claude-workflow

**Title:** Add practical examples for multi-agent orchestration workflows

---

## Summary

I built a production system using claude-workflow that orchestrates 6 agents for comprehensive code reviews. I'd like to contribute this as a practical example to help others combine agents effectively.

## The Gap

The claude-workflow README shows individual agent capabilities beautifully, but there's no guidance on:
- How to run multiple agents sequentially
- How to aggregate results across agents
- How to generate consolidated reports
- Complete workflow patterns from start to finish

## What I Built

A code review orchestration system that:
1. Runs 6 specialized agents in sequence (code-reviewer → debugger → security-auditor → test-architect → refactorer → docs-writer)
2. Collects individual reports in markdown format
3. Generates an executive summary consolidating critical findings
4. Creates actionable recommendations

**Real-world results:**
- Tested on terminal TUI projects, Go CLI tools, and web applications
- Identified actual security vulnerabilities, resource leaks, and test coverage gaps
- Generated 6-7 detailed reports (15-25KB) in ~10-20 minutes depending on project size
- Found issues that individual agents wouldn't surface alone

## Proposed Contribution

I'd like to contribute this pattern as a reusable example:

```
examples/
└── multi-agent-orchestration/
    ├── orchestrate-review.sh     # Genericized orchestration script
    ├── README.md                  # Complete usage guide
    ├── config.example.yaml        # Configuration template
    └── sample-output/             # Real-world examples
        ├── SUMMARY.md
        ├── code-reviewer-report.md
        ├── security-auditor-report.md
        └── ...
```

**Key features of the example:**
- **Configurable**: Users specify which agents to run and in what order
- **Generic**: Works with any project (not coupled to specific tooling)
- **Production-tested**: Battle-tested on 3+ real projects
- **Well-documented**: Includes usage patterns, customization guide, and troubleshooting

## Example Usage (from proposed script)

```bash
# Full comprehensive review (all agents)
./orchestrate-review.sh /path/to/project --output ./review-2026-01-02

# Quick security + quality check
./orchestrate-review.sh /path/to/project --agents code-reviewer,security-auditor

# Custom agent sequence
./orchestrate-review.sh /path/to/project --agents "debugger,refactorer,test-architect"
```

**Sample output structure:**
```
review-2026-01-02/
├── project-SUMMARY.md          # Executive summary with critical findings
├── code-reviewer.md            # Individual agent reports
├── security-auditor.md
├── test-architect.md
├── refactorer.md
├── docs-writer.md
└── debugger.md
```

## Why This Would Be Valuable

1. **Demonstrates agent composition** - Shows agents working together, not just individually
2. **Real-world workflow** - Complete pattern from invocation to actionable output
3. **Lowers barrier to entry** - Users can copy/adapt for their own orchestration needs
4. **Showcases plugin power** - Proves claude-workflow can handle complex workflows
5. **Community contribution** - First example contribution could encourage others

## Sample Output

Here's what the summary report looks like from a real project review:

```markdown
# Deep Review Summary: my-grid
**Date:** 2026-01-02

## Agents Executed
- 📊 Code Quality Review → code-reviewer.md
- 🔒 Security Audit → security-auditor.md
- 🧪 Test Coverage Assessment → test-architect.md
- ♻️  Refactoring Opportunities → refactorer.md
- 📝 Documentation Review → docs-writer.md
- 🐛 Bug & Issue Analysis → debugger.md

## Critical Findings
### From Code Quality Review
- Complex nested conditionals in grid navigation logic
- Memory allocation patterns could be optimized
- Some edge cases in coordinate calculations not handled

### From Security Audit
- User input validation needs strengthening
- Buffer overflow risks in ANSI parsing
- Input sanitization for terminal escape sequences

### From Test Architect
- Test coverage at 45% - missing edge case tests
- Integration tests needed for PTY zone functionality
- Performance tests missing for large grid operations

## Recommended Next Actions
1. Add comprehensive input validation for terminal sequences
2. Implement bounds checking for grid operations
3. Increase test coverage to 80%+
4. Add performance benchmarks
...
```

## Questions for Maintainers

Before I invest time in creating the PR:

1. **Is this kind of contribution welcome?** I want to respect your vision for the project
2. **Preferred structure?** Should examples live in `examples/` or elsewhere?
3. **Documentation style?** Any templates or conventions I should follow?
4. **Scope?** Should I include just the orchestration script, or also:
   - Report aggregation utilities?
   - Configuration file templates?
   - Multiple workflow examples (quick-check, full-review, pre-release-audit)?

## Alternative Approaches

If this doesn't fit the project's direction, I'm happy to:
- Create a separate `claude-workflow-examples` repo and link from your docs
- Write a blog post with gists instead
- Contribute something else that would be more valuable

I'm flexible and want to contribute in whatever way helps the community most!

## References

- Sample project for testing: [my-grid](https://github.com/jcaldwell-labs/my-grid) - Terminal ASCII canvas editor
- Related: Your existing `templates/` directory shows you value user-copyable resources
- Happy to share code samples from my implementation if helpful

---

**Happy to discuss and adapt this proposal based on your feedback!** 🚀
