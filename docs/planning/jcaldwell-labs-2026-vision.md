# jcaldwell-labs 2026 Vision: Introspective Reflection

**Date**: 2025-12-31
**Context**: End-of-year strategic planning jam session
**Mode**: Blindfolds off. Honest assessment.

---

## The Question We Need to Answer

> "Who are we building this for, and does it actually help them?"

---

## Current State: An Honest Look

### What We Have

**13 repositories** across four categories:

| Category | Projects | Health |
|----------|----------|--------|
| Terminal TUI | my-grid, boxes-live, smartterm/cc-bash, terminal-stars, atari-style | Active but fragmented |
| CLI Tools | my-context, fintrack, tario | my-context mature, others stale |
| Game Engines | adventure-engine-v2 | POC state |
| Meta | capability-catalog, project-conductor | Bootstrapping |

**A sophisticated meta-layer**:
- 15+ Claude Code skills with usage protocols
- my-context v3.0.0 with PostgreSQL backend
- project-conductor for autonomous advancement
- Quality control initiative documentation
- Context lifecycle management policies

### What's Actually Working

1. **my-context** - Genuinely useful for tracking work sessions. The PostgreSQL backend is solid. The export/search features work. This tool has real utility.

2. **my-grid** - The zone architecture (PTY, WATCH, PIPE) is novel. Vim-style navigation works. This could be something special if focused.

3. **cc-bash (today)** - Three-region TUI actually works now. Proves the concept.

### What's Not Working

1. **Skill Amnesia**: We documented 15 skills but the quality-control-initiative-2025-01.md reveals we don't use them. The meta-layer exists but doesn't trigger when needed.

2. **Context Fragmentation**: 420+ WSL contexts. The irony: we built my-context to track context, but we've generated so much context it's noise.

3. **Project Sprawl**: 13 repos, many at POC stage. We're starting things faster than we're finishing them.

4. **Automation Misdirection**: project-conductor advances "stale" projects, but staleness isn't the problem. Lack of users is the problem.

5. **Process Without Purpose**: SDLC.md, TDD requirements, PR workflows... all bypassed for "quick fixes." The ceremony exists but serves no master.

---

## The Hard Questions

### 1. Who are the users?

**Current answer**: Mostly just us (the developer + Claude).

**Honest assessment**: These tools are useful for a very specific workflow - a senior developer using Claude Code with extensive context tracking. That's a narrow audience.

**The opportunity**: Developers struggling with context loss, session continuity, and "where was I?" problems. That's a real pain point with broader appeal.

### 2. What problem are we solving?

**The sprawl suggests**: We're building tools because building is fun, not because there's a user crying out for them.

**The kernel of real value**:
- **my-context**: Solves "what did I do and why?"
- **my-grid**: Solves "how do I see multiple things at once in terminal?"
- **cc-bash**: Solves "I want Claude Code UX but for bash"

### 3. What's the unifying vision?

Looking at the portfolio, there's an implicit theme:

> **"Making knowledge work visible and persistent in terminal environments"**

- my-context: makes decisions/context visible
- my-grid: makes multiple streams visible simultaneously
- cc-bash: makes command execution visible with structure
- boxes-live: makes spatial layouts visible

This is actually compelling. The terminal is where developers live. Making work visible/persistent there matters.

### 4. Where are the unexploited synergies?

**my-context + my-grid**:
- What if my-grid had a CONTEXT zone that showed live my-context state?
- What if navigating to a file in my-grid automatically noted it in context?

**cc-bash + my-context**:
- What if cc-bash automatically tracked commands in context?
- What if you could annotate commands as significant?

**my-grid + cc-bash**:
- What if cc-bash was a zone TYPE in my-grid?
- Multiple bash sessions, visible side by side, output preserved

**capability-catalog + skills**:
- The skills ARE capabilities. They should be in the catalog.
- The catalog should inform skill triggering.

### 5. What are we automating wrong?

**Wrong automation**:
- project-conductor advancing stale repos (activity isn't value)
- Sprint ceremonies without users to ship to
- Health scores based on git activity, not user impact

**Missing automation**:
- Automatic skill triggering based on task patterns
- Context capture as byproduct of work (not explicit action)
- Quality gates that actually block (not documentation that's ignored)
- User feedback collection (we have no telemetry, no feedback loops)

---

## The Pivot: From Activity to Impact

### Thesis

> Stop measuring project health by commit recency.
> Start measuring by: "Does anyone use this? Does it help them?"

### 2026 Strategic Priorities

#### Priority 1: Ship my-context to Real Users

**Why**: It's the most mature tool. It solves a real problem. Other developers have context loss pain.

**Actions**:
- Create brew tap / apt repository
- Write "Getting Started in 5 Minutes" guide
- Identify 3 external beta users
- Add telemetry (opt-in) to understand usage patterns
- Build feedback mechanism into the tool itself

**Success metric**: 10 external users actively using my-context by Q2 2026

#### Priority 2: Consolidate Terminal TUI into One Vision

**Why**: We have 5 terminal TUI projects doing overlapping things. Time to focus.

**Proposed consolidation**:
```
my-grid (the platform)
├── cc-bash zone type (replaces standalone cc-bash)
├── boxes-live as canvas mode
├── terminal-stars as screensaver/demo mode
└── atari-style as visual effects library
```

**Actions**:
- Merge cc-bash as zone type into my-grid
- Extract atari-style visual effects as library used by others
- Archive standalone terminal-stars (becomes my-grid demo)
- boxes-live becomes "canvas mode" in my-grid

**Success metric**: One unified terminal TUI project with clear purpose

#### Priority 3: Make the Meta-Layer Actually Work

**Why**: We've built skills, context tracking, quality gates... none of them trigger automatically.

**The insight**: The meta-layer should be invisible. If you have to remember to use it, it won't get used.

**Actions**:
- Claude Code hooks that auto-check skill relevance
- pre-commit hooks that enforce (not just document) quality
- my-context auto-start on shell session start
- Retire unused skills (be ruthless: if not used in 90 days, archive)

**Success metric**: 90% of sessions use skills without explicit invocation

#### Priority 4: Build for Someone Specific

**Why**: "Developers" is too broad. We need a persona.

**Proposed persona**: "Sam the Senior Dev"
- Uses terminal heavily (tmux, vim, CLI tools)
- Works on complex systems (multiple repos, services)
- Loses context between sessions
- Wants to work faster but drowns in context switching
- Values tools that just work without configuration hell

**Actions**:
- Every feature decision: "Would Sam use this?"
- Write Sam's user journey for each tool
- Interview actual Sams (find 5 senior devs, ask about their pain)

**Success metric**: Tools designed for Sam, validated by actual users matching persona

#### Priority 5: Kill Projects That Aren't Serving Users

**Why**: Maintaining 13 repos is overhead. Each one takes attention from the ones that matter.

**Candidates for archival**:
- tario (game project, not aligned with core vision)

**Candidates for repositioning** (not archival):
- fintrack: Solved elsewhere as a product, but valuable as a **sample app** demonstrating what can be built with jcaldwell-labs tools. Reposition as template/showcase.
- terminal-stars: my-grid demo, but also a **minimalist shader teaching tool**. Keep as educational artifact.
- adventure-engine-v2: Evaluate - teaching tool potential or archive?

**Keep and focus**:
- my-context (core: context tracking)
- my-grid (core: terminal workspace)
- capability-catalog (meta: defines what we can do)
- project-conductor (meta: keeps us moving, but refocus metrics)

**Actions**:
- Archive 3 projects by end of Q1
- Transfer any useful code to remaining projects
- Update project-conductor to track only active projects

**Success metric**: 5 or fewer active projects, all with clear user value

---

## What Success Looks Like in 2026

### December 2026 Retrospective (aspirational)

> "This year we shipped my-context to 200 users. The feedback shaped v4.0 which now integrates directly with VS Code and Claude Code. my-grid became the terminal workspace tool for developers who live in tmux. We archived 6 projects and felt lighter for it. The skill system finally works - it just suggests the right thing at the right time. We stopped measuring git activity and started measuring 'developers helped.'"

### Metrics That Matter

| Metric | Current | 2026 Target |
|--------|---------|-------------|
| External users (my-context) | 0 | 100+ |
| External users (my-grid) | 0 | 50+ |
| Active projects | 13 | 5 |
| Skills auto-triggered | ~10% | 90% |
| Context exports per week | sporadic | daily (automated) |
| User feedback collected | 0 | weekly |

---

## The Philosophical Shift

### From: "What's technically interesting to build?"
### To: "What helps real people do their work better?"

### From: "How do we keep projects from going stale?"
### To: "How do we know if anyone cares about this project?"

### From: "More skills, more automation, more process"
### To: "Less that works reliably, invisibly, and actually helps"

---

## Immediate Actions (This Week)

1. **Post this document** to project-conductor repo as strategic vision
2. **Create user interview template** for finding "Sam"
3. **Draft my-context "Getting Started" guide**
4. **Identify 3 projects to archive** (get it on the record)
5. **Update project-conductor metrics** to include user-focused indicators

---

## The Executive Dysfunction Factor

An honest acknowledgment: the level of detail required to actually compile things - the session-by-session grind through syntax errors, dependency issues, and API quirks - has amplified rather than mitigated executive dysfunction.

**The irony**: We built my-context to combat context fragmentation, but the detailed work generated 420+ contexts. We built skills to reduce cognitive load, but remembering to use them is itself cognitive load. We built project-conductor to keep projects alive, but it measures activity not progress.

**The insight**: The meta-layer needs to be **invisible**. If it requires explicit invocation, it adds to the problem. The tools should work *with* the grain of how work actually happens, not require ceremony to use.

**What this means for 2026**:
- Zoom-out sessions (like this one) that use our own tools to track real progress
- Less session-level detail, more strategic trajectory
- Tools that capture context as byproduct, not explicit action
- Acceptance that "good enough and shipped" beats "perfect and in progress"

---

## Closing Thought

The quality-control-initiative revealed we've been building a beautiful machine that nobody drives. The meta-layer is impressive engineering. The skills are well-documented. The context tracking is sophisticated.

But who's using it? Who's better off because it exists?

2026 is the year we answer that question with actual users, actual feedback, and actual impact. We now have a foundation to have fruitful zoom-out sessions that track real progress using our own tools.

The blindfold is off. Time to build for humans.

---

*Written during a strategic reflection session, 2025-12-31*
*Next review: 2026-01-15 (two weeks)*
