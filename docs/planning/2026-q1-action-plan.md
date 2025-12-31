# 2026 Q1 Action Plan

**Based on**: jcaldwell-labs-2026-vision.md
**Created**: 2025-12-31
**Review Date**: 2026-01-15

---

## January 2026: Foundation

### Week 1 (Jan 1-7): User Discovery

| Action | Output | Owner |
|--------|--------|-------|
| Write user interview questions | Interview template in docs/planning/ | Dev |
| Identify 5 potential "Sam" candidates | List with contact info | Dev |
| Set up feedback channel | GitHub Discussions or Discord | Dev |
| Draft my-context "5 Min Start" guide | docs/getting-started.md | Dev |

### Week 2 (Jan 8-14): Project Consolidation Decision

| Action | Output | Owner |
|--------|--------|-------|
| Evaluate each project against "Would Sam use this?" | Decision matrix | Dev |
| Archive decision: fintrack, tario, adventure-engine-v2 | GitHub archive actions | Dev |
| cc-bash integration plan | RFC in my-grid repo | Dev |
| Update project-conductor config | Remove archived projects | Dev |

### Week 3-4 (Jan 15-31): my-context Release Prep

| Action | Output | Owner |
|--------|--------|-------|
| Create brew formula | jcaldwell-labs/homebrew-tap | Dev |
| Write installation docs | Multiple platforms | Dev |
| Create demo video/gif | README + social | Dev |
| Reach out to 3 beta users | Email/DM | Dev |

---

## February 2026: First External Users

### Goals
- [ ] 3 external users trying my-context
- [ ] First round of user feedback collected
- [ ] cc-bash merged as my-grid zone type
- [ ] Skill auto-trigger prototype working

### Key Milestones

| Date | Milestone |
|------|-----------|
| Feb 7 | my-context v3.1.0 with improved onboarding |
| Feb 14 | First external user interview completed |
| Feb 21 | cc-bash zone type PR in my-grid |
| Feb 28 | Skill auto-trigger MVP (Claude Code hook) |

---

## March 2026: Iteration

### Goals
- [ ] 10 external users on my-context
- [ ] my-grid v1.0 with cc-bash zone
- [ ] Archived projects fully sunset
- [ ] User feedback driving roadmap

### Key Questions to Answer by End of Q1
1. Do external users actually find my-context useful?
2. What features do they want that we don't have?
3. Is the terminal TUI consolidation working?
4. Are skills triggering automatically now?

---

## Success Criteria for Q1

### Quantitative
- External users (my-context): 10+
- Active projects: ≤ 6
- User interviews conducted: ≥ 5
- Skill auto-trigger rate: ≥ 50%

### Qualitative
- At least one unsolicited positive feedback from external user
- Clear signal on what features to build next (from users, not assumptions)
- Team feels lighter (fewer projects, more focus)

---

## What We're NOT Doing in Q1

To stay focused, explicitly defer:

- New project creation (no new repos)
- Major new features without user validation
- Process documentation expansion (enough docs, need action)
- Metrics dashboards (measure by talking to users, not charts)

---

## Weekly Check-In Template

Every Friday, answer:

1. **Users**: Did we talk to any this week? What did we learn?
2. **Focus**: Are we working on the 5 core projects or distracted?
3. **Automation**: Did skills trigger when they should have?
4. **Blockers**: What's stopping us from shipping to users?

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Can't find external users | High | Post in dev communities, leverage network |
| Consolidation breaks things | Medium | Feature parity checklist before archive |
| Skill auto-trigger too complex | Medium | Start with 3 most-used skills only |
| Scope creep ("just one more feature") | High | Every feature needs user request |

---

*This plan will be reviewed and adjusted bi-weekly.*
